/*
 * /WS/… — Business Central's SOAP endpoint (lib/webServices/soap.ts): ?wsdl on GET, envelopes on
 * POST. Authenticates with HTTP Basic (username + Web Service Access Key) or the session cookie;
 * WSDL is served without authentication so tooling can import it. Every call is logged.
 */
import { authenticateRequest, logCall } from '@/lib/webServices';
import { handleSoap, faultFor } from '@/lib/webServices/soap';

export const dynamic = 'force-dynamic';

type Ctx = { params: Promise<{ path?: string[] }> };

async function serve(request: Request, ctx: Ctx): Promise<Response> {
  const started = Date.now();
  const { path = [] } = await ctx.params;
  const url = new URL(request.url);
  const ip = request.headers.get('x-forwarded-for')?.split(',')[0].trim() ?? null;
  let username: string | null = null;
  let result;
  try {
    const user = await authenticateRequest(request);
    username = user?.username ?? null;
    result = await handleSoap(request, path, user, `${url.origin}/WS`);
  } catch (e) {
    result = faultFor(e);
  }
  const headers: Record<string, string> = { 'Content-Type': 'text/xml; charset=utf-8', 'Cache-Control': 'no-store' };
  if (result.status === 401) headers['WWW-Authenticate'] = 'Basic realm="Web Services"';
  const fault = result.xml.match(/<faultstring>([\s\S]*?)<\/faultstring>/)?.[1] ?? null;
  logCall({
    protocol: 'SOAP', method: request.method, serviceName: result.serviceName ?? path.find((s, i) => i > 0 && /^(page|codeunit)$/i.test(path[i - 1] ?? '')) ?? path[path.length - 1] ?? null,
    operation: result.operation ?? null, path: url.pathname + url.search, username, status: result.status, durationMs: Date.now() - started, ip, error: fault,
  });
  return new Response(result.xml, { status: result.status, headers });
}

export const GET = serve;
export const POST = serve;

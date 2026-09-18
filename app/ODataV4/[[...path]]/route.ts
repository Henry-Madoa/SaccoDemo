/*
 * /ODataV4/… — Business Central's OData V4 endpoint (lib/webServices/odata.ts). Authenticates
 * with HTTP Basic (username + Web Service Access Key) or the app's session cookie, answers in
 * OData JSON, and logs every call to the Web Service Log.
 */
import { authenticateRequest, logCall, statusOfError } from '@/lib/webServices';
import { companyRegistry, withCompany } from '@/lib/db';
import { handleOData, odataError } from '@/lib/webServices/odata';

export const dynamic = 'force-dynamic';

type Ctx = { params: Promise<{ path?: string[] }> };

async function serve(request: Request, ctx: Ctx): Promise<Response> {
  const started = Date.now();
  const { path = [] } = await ctx.params;
  const url = new URL(request.url);
  const baseUrl = `${url.origin}/ODataV4`;
  const ip = request.headers.get('x-forwarded-for')?.split(',')[0].trim() ?? null;
  let username: string | null = null;
  let result;
  try {
    // Company('CODE') as the first segment (or ?company=CODE) selects the company the call runs
    // in; without it the call runs in the live company.
    const m = decodeURIComponent(path[0] ?? '').match(/^Company(['"]?(.+?)['"]?)$/i);
    const code = m?.[1] ?? url.searchParams.get('company');
    const company = code ? (await companyRegistry()).find((c) => c.code.toUpperCase() === code.toUpperCase()) : null;
    if (code && !company) {
      result = odataError(404, 'NotFound', `Company '${code}' does not exist`);
    } else {
      const segs = m ? path.slice(1) : path;
      result = await withCompany(company?.schema_name ?? 'public', async () => {
        const user = await authenticateRequest(request);
        if (!user) return odataError(401, 'Unauthorized', 'Authentication required: HTTP Basic with your username and Web Service Access Key');
        username = user.username;
        return handleOData(request, segs, user, m ? `${baseUrl}/${path[0]}` : baseUrl);
      });
    }
  } catch (e) {
    const { status, code, message } = statusOfError(e);
    result = odataError(status, code, message);
  }
  const headers: Record<string, string> = {
    'OData-Version': '4.0',
    'Cache-Control': 'no-store',
    ...(result.headers ?? {}),
  };
  if (result.status === 401) headers['WWW-Authenticate'] = 'Basic realm="Web Services"';
  let body: BodyInit | null = null;
  if (result.raw != null) { body = result.raw; headers['Content-Type'] = result.contentType ?? 'text/plain; charset=utf-8'; }
  else if (result.body !== undefined) { body = JSON.stringify(result.body); headers['Content-Type'] = 'application/json; odata.metadata=minimal; charset=utf-8'; }
  const error = result.body && typeof result.body === 'object' && 'error' in (result.body as object) ? (result.body as { error: { message: string } }).error.message : null;
  logCall({
    protocol: 'ODATA', method: request.method, serviceName: result.serviceName ?? path[0]?.replace(/\(.*$/, '') ?? null, operation: result.operation ?? null,
    path: url.pathname + url.search, username, status: result.status, durationMs: Date.now() - started, ip, error,
  });
  return new Response(body, { status: result.status, headers });
}

export const GET = serve;
export const POST = serve;
export const PATCH = serve;
export const PUT = serve;
export const DELETE = serve;
export async function OPTIONS(): Promise<Response> {
  return new Response(null, { status: 204, headers: { Allow: 'GET, POST, PATCH, PUT, DELETE, OPTIONS', 'OData-Version': '4.0' } });
}

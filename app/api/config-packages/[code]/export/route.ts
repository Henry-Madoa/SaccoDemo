import { requireAction } from '@/lib/session';
import { exportConfigPackage } from '@/lib/configPackages';
import { AppError } from '@/lib/errors';

export async function GET(_request: Request, { params }: { params: Promise<{ code: string }> }): Promise<Response> {
  try {
    await requireAction('ADMIN_CONFIG_PACKAGE_MANAGE');
    const { code } = await params;
    const { filename, csv } = await exportConfigPackage(code);
    return new Response(csv, {
      headers: {
        'Content-Type': 'text/csv; charset=utf-8',
        'Content-Disposition': `attachment; filename="${filename}"`,
      },
    });
  } catch (err) {
    const message = err instanceof AppError ? err.message : 'Export failed';
    const status = err instanceof AppError && err.code === 'FORBIDDEN' ? 403 : 400;
    return new Response(message, { status });
  }
}

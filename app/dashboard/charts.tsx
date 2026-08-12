'use client';

import { GroupedBars } from '@/components/charts/grouped-bars';
import { Donut } from '@/components/charts/donut';
import { useFormat } from '@/components/ui/format-provider';
import { formatMonth } from '@/lib/format';
import type { Cents, DashboardData } from '@/lib/types';

const SERIES = ['var(--series-1)', 'var(--series-2)', 'var(--series-3)'];
const SLICES = [...SERIES, 'var(--brand-accent)', 'var(--info)'];

export function MonthlyVolumesChart({ monthly }: { monthly: DashboardData['monthly'] }) {
  return (
    <GroupedBars
      height={250}
      labels={monthly.map((m) => formatMonth(m.month))}
      series={[
        { name: 'Deposits', color: SERIES[0], values: monthly.map((m) => m.deposits) },
        { name: 'Withdrawals', color: SERIES[1], values: monthly.map((m) => m.withdrawals) },
        { name: 'Disbursements', color: SERIES[2], values: monthly.map((m) => m.disbursements) },
      ]}
    />
  );
}

export function DepositMixChart({ deposits, total }: { deposits: DashboardData['deposits']; total: Cents }) {
  const { curShort } = useFormat();
  return (
    <Donut
      segments={deposits
        .filter((x) => x.total > 0)
        .map((x, i) => ({ label: x.name, value: x.total, color: SLICES[i % SLICES.length] }))}
      centerValue={curShort(total)}
      centerLabel="total"
    />
  );
}

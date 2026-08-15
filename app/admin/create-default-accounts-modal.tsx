'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Modal } from '@/components/ui/modal';
import { Progress } from '@/components/ui/progress';
import { useToast } from '@/components/ui/toast';
import {
  loadDefaultAccountsBacklog, createOneDefaultAccount, finishDefaultAccountsRun,
} from '@/app/actions/pool';
import type { DefaultAccountBacklogItem } from '@/lib/types';

type JobStage = 'preparing' | 'running' | 'complete';

const STAGES: { key: JobStage; label: string }[] = [
  { key: 'preparing', label: 'Preparing' },
  { key: 'running', label: 'Opening accounts' },
  { key: 'complete', label: 'Complete' },
];

function StageStepper({ stage }: { stage: JobStage }) {
  const order: JobStage[] = ['preparing', 'running', 'complete'];
  const currentIdx = order.indexOf(stage);
  return (
    <div className="job-stages">
      {STAGES.map((s, i) => (
        <span key={s.key} style={{ display: 'contents' }}>
          <span className={`job-stage ${i === currentIdx ? 'active' : i < currentIdx ? 'done' : ''}`}>{s.label}</span>
          {i < STAGES.length - 1 ? <span className="job-stage-arrow">→</span> : null}
        </span>
      ))}
    </div>
  );
}

/** Drives the backlog one item at a time — a real server round trip per item, so the
 *  progress bar, current-document line and counters all reflect what's actually happened,
 *  not a simulated animation. */
function ProgressRun({ items }: { items: DefaultAccountBacklogItem[] }) {
  const [index, setIndex] = useState(0);
  const [success, setSuccess] = useState(0);
  const [failed, setFailed] = useState(0);
  const [stage, setStage] = useState<JobStage>('running');

  const total = items.length;
  const processed = success + failed;
  const current = index < total ? items[index] : null;
  const pct = total ? (processed / total) * 100 : 100;

  useEffect(() => {
    let cancelled = false;
    (async () => {
      for (let i = 0; i < items.length; i += 1) {
        if (cancelled) break;
        setIndex(i);
        const item = items[i];
        // eslint-disable-next-line no-await-in-loop -- intentionally sequential, one request per item, for real per-item progress
        const res = await createOneDefaultAccount(item.memberId, item.productId);
        if (cancelled) break;
        if (!res.ok) setFailed((n) => n + 1);
        else setSuccess((n) => n + 1);
      }
      if (!cancelled) { setIndex(items.length); setStage('complete'); }
      await finishDefaultAccountsRun();
    })();
    return () => { cancelled = true; };
  }, [items]);

  const done = stage === 'complete';

  return (
    <>
      <StageStepper stage={done ? 'complete' : 'running'} />

      <div className="progress-row">
        <Progress value={pct} />
        <span className="progress-pct">{Math.round(pct)}%</span>
      </div>

      <div className="job-current">
        {done ? (
          <b>All {total} item{total === 1 ? '' : 's'} processed.</b>
        ) : current ? (
          <>
            <div className="mono">
              {current.memberNo} — {current.memberName} → {current.productName} ({current.productCode})
            </div>
            <div className="job-current-stage">Opening account…</div>
          </>
        ) : null}
      </div>

      <div className="job-counters">
        <div className="job-counter ok"><b>{success}</b><span>Success</span></div>
        <div className="job-counter bad"><b>{failed}</b><span>Failed</span></div>
        <div className="job-counter"><b>{total - processed}</b><span>Pending</span></div>
      </div>
    </>
  );
}

/** "Create Default Accounts" — backfills any default account a category's existing members
 *  are still missing (e.g. after the default set changed), showing real progress rather than
 *  running as a single opaque bulk call. */
export function CreateDefaultAccountsButton({ categoryId, categoryLabel, className = 'btn sm ghost' }: {
  categoryId: number;
  categoryLabel: string;
  className?: string;
}) {
  const toast = useToast();
  const router = useRouter();
  const [checking, setChecking] = useState(false);
  const [items, setItems] = useState<DefaultAccountBacklogItem[] | null>(null);

  const start = async () => {
    setChecking(true);
    try {
      const res = await loadDefaultAccountsBacklog(categoryId);
      if (!res.ok) { toast('Could not start', res.error, 'err'); return; }
      if (!res.data.length) {
        toast('Already up to date', 'Every member in this category already holds their default accounts', 'ok');
        return;
      }
      setItems(res.data);
    } finally {
      setChecking(false);
    }
  };

  const close = () => {
    setItems(null);
    router.refresh();
  };

  return (
    <>
      <button type="button" className={className} disabled={checking} onClick={start}>
        {checking ? 'Checking…' : 'Create Default Accounts'}
      </button>
      {items ? (
        <Modal
          title={`Create default accounts — ${categoryLabel}`}
          onClose={close}
          footer={<button type="button" className="btn" onClick={close}>Close</button>}
        >
          <ProgressRun items={items} />
        </Modal>
      ) : null}
    </>
  );
}

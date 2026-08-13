'use client';

import { useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Card, CardHead, Toolbar, Spacer } from '@/components/ui/primitives';
import { Field, readForm } from '@/components/ui/field';
import { useToast } from '@/components/ui/toast';
import { saveMemberApplication } from '@/app/actions/memberApplications';
import { today } from '@/lib/format';
import { MEMBER_TITLES } from '@/lib/constants';
import type { MemberCategory } from '@/lib/types';

export function NewApplicationForm({ memberCategories }: {
  memberCategories: MemberCategory[];
}) {
  const router = useRouter();
  const toast = useToast();
  const formRef = useRef<HTMLFormElement>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');

  const create = async () => {
    const form = formRef.current;
    if (!form || !form.reportValidity()) return;
    setBusy(true);
    setError('');
    try {
      const values = readForm(form);
      const res = await saveMemberApplication(null, values);
      if (!res.ok) { setError(res.error || 'Could not create application'); return; }
      toast('Application created', 'Add the rest of the details on the application page.', 'ok');
      router.push(`/member-applications/view/${(res.data as { no: string }).no}`);
    } finally {
      setBusy(false);
    }
  };

  return (
    <Card>
      <CardHead title="New member application" sub="The remaining details can be filled in afterwards" />
      <form ref={formRef} onSubmit={(e) => e.preventDefault()}>
        <div className="grid g3">
          <Field name="member_category_id" label="Member category" type="select"
            options={[
              { value: '', label: 'Select category…' },
              ...memberCategories.map((c) => ({ value: c.id, label: c.description })),
            ]} />
          <Field name="join_date" label="Date joined" type="date" defaultValue={today()} />
          <Field name="title" label="Title" type="select" options={MEMBER_TITLES} />
          <Field name="first_name" label="First name" required />
          <Field name="last_name" label="Last name" required />
          <Field name="phone" label="Phone" required />
        </div>
      </form>
      <Toolbar>
        <Spacer />
        {error ? <div className="modal-error">{error}</div> : null}
        <button type="button" className="btn ghost" onClick={() => router.push('/member-applications')}
          disabled={busy}>
          Cancel
        </button>
        <button type="button" className="btn" onClick={create} disabled={busy}>
          {busy ? 'Creating…' : 'Create application'}
        </button>
      </Toolbar>
    </Card>
  );
}

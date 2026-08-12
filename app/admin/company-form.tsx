'use client';

import { useEffect, useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Card } from '@/components/ui/primitives';
import { Field, readForm } from '@/components/ui/field';
import { DefinitionList } from '@/components/ui/primitives';
import { useToast } from '@/components/ui/toast';
import { saveOrganisation } from '@/app/actions/admin';
import { saveOrgLogo } from '@/app/actions/media';
import { FilePicker } from '@/components/ui/uploader';
import { SOCIETY_TYPES, MONTH_NAMES } from '@/lib/constants';
import { formatDateTime, initials } from '@/lib/format';
import type { Organisation } from '@/lib/types';

export interface CompanyFormProps {
  org: Organisation;
  /** Resolved server-side: a Cloudinary delivery URL, or a legacy data URL. */
  logoSrc: string | null;
  mediaEnabled: boolean;
}

export function CompanyForm({ org, logoSrc, mediaEnabled }: CompanyFormProps) {
  const formRef = useRef<HTMLFormElement>(null);
  const router = useRouter();
  const toast = useToast();
  const [busy, setBusy] = useState(false);
  const [preview, setPreview] = useState(logoSrc);
  // `useState(logoSrc)` only seeds on mount — a later router.refresh() sends a
  // fresh `logoSrc` prop but won't touch state that's already initialised, so
  // the preview has to be resynced explicitly or it goes stale after the
  // first upload.
  useEffect(() => setPreview(logoSrc), [logoSrc]);
  const [name, setName] = useState(org.name ?? '');
  const [shortName, setShortName] = useState(org.short_name ?? '');

  const previewName = shortName || name || 'SACCO';

  /*
   * The logo saves on its own rather than with the rest of the form: the file
   * is already in Cloudinary by this point, and making the admin remember to
   * press Save afterwards is how you end up with orphaned assets.
   */
  const applyLogo = async (file: { publicId: string; originalFilename: string } | null) => {
    setBusy(true);
    try {
      const res = await saveOrgLogo(file);
      if (!res.ok) { toast('Could not update logo', res.error, 'err'); return; }
      toast(file ? 'Logo updated' : 'Logo removed', 'Live across the system', 'ok');
      router.refresh();
    } finally {
      setBusy(false);
    }
  };

  const save = async () => {
    const form = formRef.current;
    if (!form || !form.reportValidity()) return;
    setBusy(true);
    try {
      // `logo` is deliberately absent — it is owned by applyLogo above.
      const res = await saveOrganisation(readForm(form));
      if (!res.ok) {
        toast('Could not save', res.error, 'err');
        return;
      }
      toast('Company information saved', 'The change is live across the system', 'ok');
      router.refresh();
    } finally {
      setBusy(false);
    }
  };

  return (
    <form ref={formRef} onSubmit={(e) => { e.preventDefault(); save(); }}>
      <div className="grid split-aside">
        <div>
          <Card>
            <h3>Society identity</h3>
            <div className="card-sub">
              These details appear on the sign-in screen, the sidebar, statements and every report header.
            </div>
            <div className="grid g2">
              <div className="field">
                <label htmlFor="f_name">Registered society name <span className="req">*</span></label>
                <input id="f_name" name="name" type="text" required value={name}
                  onChange={(e) => setName(e.target.value)} />
              </div>
              <div className="field">
                <label htmlFor="f_short_name">Short name</label>
                <input id="f_short_name" name="short_name" type="text" value={shortName}
                  onChange={(e) => setShortName(e.target.value)} />
                <div className="hint">Used in the sidebar and browser title</div>
              </div>
            </div>
            <Field name="motto" label="Motto or tagline" defaultValue={org.motto} />
            <div className="grid g3">
              <Field name="society_type" label="Society type" type="select"
                defaultValue={org.society_type} options={SOCIETY_TYPES} />
              <Field name="registration_no" label="Registration number" defaultValue={org.registration_no} />
              <Field name="sasra_licence_no" label="Regulatory licence number" defaultValue={org.sasra_licence_no} />
            </div>
            <Field name="kra_pin" label="Tax PIN" defaultValue={org.kra_pin} />
          </Card>

          <Card>
            <h3>Contact and address</h3>
            <div className="card-sub">Printed on member statements and correspondence.</div>
            <div className="grid g2">
              <Field name="physical_address" label="Physical address" defaultValue={org.physical_address} />
              <Field name="postal_address" label="Postal address" defaultValue={org.postal_address} />
              <Field name="city" label="Town / city" defaultValue={org.city} />
              <Field name="county" label="County" defaultValue={org.county} />
              <Field name="country" label="Country" defaultValue={org.country} />
              <Field name="website" label="Website" defaultValue={org.website} />
              <Field name="phone_primary" label="Primary telephone" defaultValue={org.phone_primary} />
              <Field name="phone_secondary" label="Secondary telephone" defaultValue={org.phone_secondary} />
              <Field name="email" label="Email address" type="email" defaultValue={org.email} />
            </div>
          </Card>

          <Card>
            <h3>Banking and collections</h3>
            <div className="card-sub">Used on receipts and payment instructions.</div>
            <div className="grid g3">
              <Field name="paybill_no" label="Mobile money paybill" defaultValue={org.paybill_no} />
              <Field name="bank_name" label="Bank" defaultValue={org.bank_name} />
              <Field name="bank_account_no" label="Bank account number" defaultValue={org.bank_account_no} />
            </div>
          </Card>

          <Card>
            <h3>Locale and financial year</h3>
            <div className="card-sub">Controls how money and dates are displayed across the system.</div>
            <div className="grid g3">
              <Field name="currency_code" label="Currency code" defaultValue={org.currency_code} />
              <Field name="currency_symbol" label="Currency symbol" defaultValue={org.currency_symbol} />
              <Field name="locale" label="Number locale" defaultValue={org.locale} hint="e.g. en-KE" />
              <Field name="timezone" label="Timezone" defaultValue={org.timezone} />
              <Field name="fy_start_month" label="Financial year starts" type="select"
                defaultValue={org.fy_start_month}
                options={MONTH_NAMES.map((m, i) => ({ value: i + 1, label: m }))} />
              <Field name="fy_start_day" label="on day" type="number" min={1} defaultValue={org.fy_start_day} />
            </div>
            <Field name="statement_footer" label="Statement footer text" type="textarea"
              defaultValue={org.statement_footer} />
          </Card>
        </div>

        <div>
          <Card>
            <h3>Logo</h3>
            <div className="card-sub">
              PNG, JPEG, WebP or SVG under 1.5 MB. Shown on the sidebar and sign-in screen.
            </div>
            <div className="logo-drop">
              {preview
                ? <img src={preview} alt="Society logo" />
                : <div className="logo-empty" aria-hidden="true">{initials(previewName)}</div>}
              <div style={{ flex: 1 }}>
                {mediaEnabled ? (
                  <>
                    <FilePicker
                      kind="logo"
                      accept="image/*"
                      label="Upload logo"
                      disabled={busy}
                      onUploaded={applyLogo}
                    />
                    {preview ? (
                      <div className="inline" style={{ marginTop: 8 }}>
                        <button type="button" className="btn ghost sm" disabled={busy}
                          onClick={() => applyLogo(null)}>
                          Remove logo
                        </button>
                      </div>
                    ) : null}
                  </>
                ) : (
                  <div className="note">
                    Media storage is not configured. Set the <code>CLOUDINARY_*</code> environment variables to enable uploads.
                  </div>
                )}
              </div>
            </div>
          </Card>

          <Card>
            <h3>Live preview</h3>
            <div className="card-sub">How the identity reads in the interface.</div>
            <div className="brand-preview">
              <div className="mark">{initials(previewName)}</div>
              <div>
                <div className="name">{previewName}</div>
                <div className="sub">Core Banking System</div>
              </div>
            </div>
            <div style={{ marginTop: 14 }}>
              <DefinitionList items={[
                ['Last updated', formatDateTime(org.updated_at)],
                ['By', org.updated_by || '—'],
              ]} />
            </div>
          </Card>

          <Card className="sticky-card">
            <button type="button" className="btn block" onClick={save} disabled={busy}>
              {busy ? 'Saving…' : 'Save company information'}
            </button>
            <button type="button" className="btn ghost block" style={{ marginTop: 8 }}
              disabled={busy} onClick={() => router.refresh()}>
              Discard changes
            </button>
          </Card>
        </div>
      </div>
    </form>
  );
}

# Tier One SACCO — Core Banking & Management Information System

A working implementation of the *Tier One SACCO Technical Architecture & System Design Document*:
members and KYC, BOSA savings, FOSA teller operations, loan origination through collection, a
double-entry general ledger, role-based access control, and an **Admin Centre** where company
information and the entire visual theme are configured at runtime.

Every shilling in the system moves through one posting engine. Nothing writes a balance directly.

Built with **Next.js (App Router) and TypeScript**: pages are React Server Components that query the
domain services directly, and every mutation is a Server Action. There is no REST layer between the
UI and the business logic.

---

## Running it

```bash
npm install
npm run dev
```

Then open **http://localhost:3000**.

The database is PostgreSQL, reached through `DATABASE_URL`. Apply the schema with
`npm run db:migrate`; on first run the system seeds a realistic society: 120 members, 5 savings
products, 4 loan products, a full chart of accounts, and two years of transaction history —
roughly 3,000 journals, all balanced.

### Sign-in accounts

| Username  | Password     | Role                | What they can do |
|-----------|--------------|---------------------|------------------|
| `admin`   | `admin123`   | System Administrator | Everything, including the Admin Centre |
| `manager` | `manager123` | Branch Manager       | Approves and disburses loans |
| `loans`   | `loans123`   | Loans Officer        | Captures loans — **cannot approve its own work** |
| `teller`  | `teller123`  | Teller               | Deposits, withdrawals, repayments |
| `finance` | `finance123` | Finance Officer      | Journals, trial balance, period close |
| `auditor` | `auditor123` | Internal Auditor     | Read-only, including the audit trail |

Sign in as `loans`, capture a loan, then sign in as `manager` to approve it — the segregation-of-duties
rule is enforced server-side, not in the browser.

### Other commands

```bash
npm test           # 44 financial-integrity tests
npm run typecheck  # tsc --noEmit across the whole codebase
npm run build      # production build
npm run db:migrate # apply pending Prisma migrations
npm run db:studio  # browse the data
npm run reset      # drop, re-migrate and reseed — destroys all data
```

---

## The two things you asked for specifically

### 1. Admin Centre → Company Information

**Admin Centre → Company Information** is the single place the society's identity is maintained:
registered name, short name, motto, society type, registration and licence numbers, tax PIN,
physical and postal address, telephones, email, website, paybill, bank details, logo upload,
currency and locale, timezone, financial-year start, and the statement footer.

Saving it takes effect immediately and everywhere — the sign-in screen, the sidebar, the browser
title, page subtitles, statements and report headers all read from this one record. There is a live
preview beside the form, and every change is written to the audit trail with the field names that
changed and who changed them.

### 2. Dynamic theming from the Admin Portal

**Admin Centre → Appearance & Theme.**

The theme is *data*, not code. Every colour, corner radius, font stack, font size and spacing
density in the interface resolves to a CSS custom property. Those properties live in a database
record; the root layout renders them into a `<style>` block in the document head on every request —
so even the sign-in screen, shown before anyone authenticates, wears the society's colours, and
there is no unstyled flash while a stylesheet loads.

The editor gives you:

- **Five presets** — Emerald Standard, Sacco Blue, Maroon Heritage, Slate Professional and Midnight
  (dark) — as a starting point.
- **28 individual tokens** grouped as Brand, Navigation, Surfaces, Status, Charts, and Typography &
  shape. Each has a colour picker and a hex field.
- **Instant preview.** Editing a token repaints the whole running application immediately, not just
  a swatch. A component preview panel sits beside the editor.
- **Save / revert.** Changes are local until you press *Save theme for everyone*; an unsaved-changes
  marker tells you where you stand, and *Revert* restores the last saved state.

Chart series colours are tokens too (`--series-1..3`), pre-set to hues validated for colour-vision
deficiency separation, and are editable like anything else.

Adding a new token takes one entry in `lib/themes.ts` — the editor UI, the validation and the
stylesheet all build themselves from that list.

---

## What is implemented

**Members & CRM** — member numbering from a controlled sequence, KYC profile, employment and
affordability data, next of kin, duplicate detection on national ID, status lifecycle
(Application → Active → Dormant → Suspended → Exited), and a Member 360 view combining profile,
accounts, loans, guarantorship exposure and transaction history.

**BOSA & savings** — configurable products (share capital, member deposits, FOSA savings, fixed
deposit, holiday savings) each with minimum balances, opening minimums, withdrawal rules and
charges, notice periods, and a GL control account. Deposits, withdrawals, controlled reversals, and
a running-balance statement with opening and closing balances.

**FOSA & transaction banking** — teller, M-Pesa, bank and check-off channels, each mapped to its own
settlement account. Available-funds validation before posting. Freeze and dormancy controls that
block transactions without touching history.

**Loans** — four products with configurable rate, interest method (reducing balance or flat), term,
amount limits, deposit multiplier, membership period, processing fee, insurance, penalty rate,
guarantor count and maximum deduction ratio. Explainable credit appraisal that returns each policy
factor with a pass/fail and the numbers behind it. Maker-checker approval, disbursement net of
charges into a member account, amortisation schedules, repayment allocation, arrears ageing and
risk classification.

**General ledger** — full chart of accounts with header and postable accounts, manual journals with
a live balance check, journal reversal with compensating entries, per-account ledger drill-down,
trial balance computed from journal lines rather than stored balances, and accounting periods that
can be closed and reopened.

**Reports** — statement of financial position, statement of comprehensive income, and a risk
classification and provisioning report shaped after the SASRA Form 4 return.

**Small screens** — below 900px the sidebar becomes an off-canvas drawer opened by a hamburger in
the top bar, dismissed by the backdrop, Escape, or navigating. Wide ledgers scroll inside their own
container so the page body never scrolls sideways; dialogs go full-bleed on phones; the heading
subtitle and the signed-in name give way to the avatar as width runs out. Touch targets grow on
coarse pointers, and the drawer respects `prefers-reduced-motion`.

**Security** — scrypt password hashing with per-user salts, sessions held in an `httpOnly` cookie
with expiry, role-based access control over a `RESOURCE:ACTION` permission catalogue, server-side
enforcement inside every Server Action and page, and an append-only audit trail.

---

## How the money works

This is the part worth reading if you plan to extend the system.

`lib/accounting.ts` exposes `postJournal(...)`. It is the **only** code in the system that writes to
`journal`, `journal_line`, or `gl_account.balance`. Savings, loans, fees and interest all raise a
business event and hand it balanced lines. The engine refuses anything that would corrupt the
ledger:

- debits must equal credits, and the total must be non-zero
- accounts must exist, be active, and be postable (header accounts are rejected)
- the accounting period must be open
- an idempotency key is never honoured twice — a replayed payment callback returns the original
  journal instead of posting a second one
- reversals post compensating entries; the original journal is never mutated

Because of that single choke point, the subsidiary ledgers cannot drift from the GL. The test suite
asserts this directly: every savings product's total account balance equals its GL control account,
and every loan product's outstanding principal equals its receivable account — before and after a
full loan lifecycle runs.

Money is stored as **integer minor units** (cents). There is no floating-point arithmetic anywhere
in the financial path. Dates are ISO-8601; timestamps are UTC.

### Worked example — disbursing a 334,000 loan into a member's FOSA account

```
DR  1140  Development Loans Receivable      334,000.00
CR  2020  FOSA Savings Accounts             334,000.00
DR  2020  FOSA Savings Accounts               6,680.00   (charges recovered)
CR  4020  Loan Processing and Insurance Fees   6,680.00
```

The member is credited 327,320.00 net, the receivable carries the gross 334,000.00, and fee income
is recognised at disbursement.

### Repayment waterfall

Penalties first, then — **instalment by instalment, oldest first** — that instalment's interest and
then its principal, before moving to the next. Clearing the whole schedule's interest first would
starve the earliest instalment of principal and push a member who paid exactly their instalment into
arrears. There is a test for precisely this.

---

## Test coverage

`npm test` runs 44 assertions against a throwaway database, covering the critical financial
scenarios named in section 25 of the design document:

- every journal balances; the trial balance nets to zero; stored balances match recomputed ones
- assets equal liabilities plus equity plus surplus
- each savings and loan product reconciles to its GL control account
- unbalanced journals, header-account postings and mixed debit/credit lines are rejected
- a duplicate idempotency key does not post twice
- a closed period rejects posting
- a reversal unwinds the balance without mutating the original
- insufficient funds and minimum-balance breaches are rejected before posting
- non-withdrawable products and frozen accounts refuse transactions
- reducing-balance, flat and zero-interest schedules amortise exactly
- paying one instalment clears that instalment in full
- a maker cannot approve their own loan; an unapproved loan cannot be disbursed
- disbursement, repayment splitting, overpayment rejection and loan closure
- arrears classification matches the configured day bands
- passwords are salted and never stored in the clear; role permissions gate correctly
- a dated trial balance still lists accounts with no movement

---

## Layout

```
app/
  layout.tsx              Root shell — renders theme tokens into <head>, seeds on boot
  login/                  Sign-in page and its Server Action
  (app)/                  Authenticated routes; layout.tsx draws the sidebar
    dashboard/            Stat tiles and charts
    members/              Registry and the member 360 view
    savings/              Account list and statement of account
    loans/                Origination, appraisal, the loan file
    approvals/            Maker-checker queue
    accounting/[[...tab]] Trial balance, journals, chart of accounts, periods
    reports/[[...tab]]    Balance sheet, income statement, PAR
    admin/[[...tab]]      Company, theme, users, roles, branches, products, audit
  actions/                Server Actions — the only mutation entry points
components/
  ui/                     Card, Stat, Pill, Modal, Field, Toast, filters, Money
  charts/                 Dependency-free SVG charts as React components
  layout/                 Sidebar and page chrome
lib/
  db.ts                   Postgres access: placeholder translation, transactions
  types.ts                One interface per table, plus the derived shapes
  accounting.ts           The posting engine — the only writer to the ledger
  loans.ts                Amortisation maths and the repayment waterfall (pure)
  savings.ts              BOSA/FOSA services
  loanService.ts          Origination, appraisal, approval, disbursement, collection
  members.ts gl.ts admin.ts reports.ts org.ts
  auth.ts session.ts      Hashing, cookie sessions, permission catalogue
  constants.ts            Domain vocabulary shared with client components
  themes.ts               Theme presets and the token catalogue
  seed.ts                 Demonstration data
test/verify.ts            Financial integrity suite
data/sacco.db             Created on first run
```

Pages are Server Components and query `lib/` directly; only the pieces that need state — modals,
filters, the theme editor, chart tooltips — are client components. `lib/constants.ts` exists so
those client components can name a status or a channel without importing a module that reaches the
database.

---

## Moving to the production stack

The design document specifies Next.js + NestJS + PostgreSQL + Prisma + Redis. The Next.js and
TypeScript halves are done; what remains is deliberately shaped to migrate:

- **Database** — Prisma owns the schema and the migrations under `prisma/`. Money columns are
  `bigint` cents, never a floating-point type: the ledger already carries balances above three
  billion, which overflows PostgreSQL's 4-byte `integer`.
- **Query layer** — every statement goes through the helpers in `lib/db.ts` (`one`, `all`, `run`,
  `tx`), which translate `?`/`@named` placeholders to `$n` and coerce `bigint` to `number` at the
  boundary. Changing driver is a change to that file, not to the services.
- **Domain services** — `accounting.ts`, `savings.ts`, `loanService.ts` and `loans.ts` have no HTTP,
  React or driver-specific coupling beyond the query layer, and become NestJS providers unchanged.
- **API surface** — if an external API is needed alongside the UI, the Server Actions in
  `app/actions/` are thin permission-checking wrappers over those services; the same services can be
  mounted under REST controllers without touching business logic.
- **Concurrency** — `version` columns are already on `savings_account` and `loan` for optimistic
  locking, but nothing enforces them yet. Concurrent writers need those checks plus
  `SELECT … FOR UPDATE` on the balance read inside the posting transaction.
- **Async work** — arrears ageing, interest accrual and notifications currently run inline. They are
  the natural first workers to move onto a queue.

---

## Scope and honest limitations

This is a working system built to demonstrate and validate the design, not a licensed production
core banking platform. Before any live deployment:

- **Regulatory returns.** The risk-classification report is shaped after the SASRA Form 4 return, but
  the bands, provisioning rates and file format must be confirmed against the regulator's current
  published requirements. Section 17 of the design document is right that this belongs in a
  versioned regulatory configuration layer.
- **Interest recognition** is cash-basis — loan interest is recognised when a repayment is posted.
  Accrual-basis recognition with an interest-receivable account is the usual requirement and is a
  contained change inside the posting engine.
- **Not yet built:** dividend and interest-on-deposits allocation runs, standing orders, employer
  check-off file upload and reconciliation, the member and employer self-service portals, live
  M-Pesa and bank integrations (the channel and idempotency scaffolding is in place — the provider
  adapters are not), automated penalty accrual, and document management.
- **Deployment hardening** — HTTPS termination, rate limiting, secret management, backup and restore
  verification, and the DR objectives described in section 22 are all out of scope here. The session
  cookie is `httpOnly` and `sameSite=lax`, and is marked `secure` in production; Server Actions
  carry Next.js's own origin check, but a formal CSRF review is still owed.
- **Connection pooling** — the client is a module-level singleton per process. Behind a serverless
  platform, point `DATABASE_URL` at a pooled endpoint (Neon's `-pooler` host) and keep migrations
  on the direct one.

I have not independently verified the SASRA references cited in the design document; treat the
regulatory shapes in this build as a starting structure to confirm, not as compliance.

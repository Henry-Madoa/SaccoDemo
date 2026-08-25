from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import mm
from reportlab.platypus import (SimpleDocTemplate, Paragraph, Spacer, PageBreak,
    Table, TableStyle, KeepTogether)
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfbase import pdfmetrics
from reportlab.lib.colors import HexColor
import os

OUT = os.path.join('output', 'pdf', 'Nation_CBS_Nextjs_Technical_Implementation_Blueprint.pdf')
os.makedirs(os.path.dirname(OUT), exist_ok=True)

NAVY = HexColor('#0B1F3A'); BLUE = HexColor('#1261A6'); TEAL = HexColor('#007D78')
INK = HexColor('#172033'); MUTED = HexColor('#5A687A'); PALE = HexColor('#EEF4FA')
GREEN = HexColor('#E7F6F1'); AMBER = HexColor('#FFF4D8'); LINE = HexColor('#D9E1EA')

styles = getSampleStyleSheet()
styles.add(ParagraphStyle(name='CoverTitle', fontName='Helvetica-Bold', fontSize=28, leading=33, textColor=NAVY, spaceAfter=12))
styles.add(ParagraphStyle(name='CoverSub', fontName='Helvetica', fontSize=13, leading=19, textColor=MUTED))
styles.add(ParagraphStyle(name='H1x', fontName='Helvetica-Bold', fontSize=19, leading=24, textColor=NAVY, spaceBefore=4, spaceAfter=10))
styles.add(ParagraphStyle(name='H2x', fontName='Helvetica-Bold', fontSize=12.5, leading=16, textColor=BLUE, spaceBefore=12, spaceAfter=6))
styles.add(ParagraphStyle(name='Bodyx', fontName='Helvetica', fontSize=9.3, leading=13.3, textColor=INK, spaceAfter=6))
styles.add(ParagraphStyle(name='Small', fontName='Helvetica', fontSize=8, leading=10.5, textColor=MUTED))
styles.add(ParagraphStyle(name='CodexBlock', fontName='Courier', fontSize=7.6, leading=10, textColor=INK, backColor=PALE, borderColor=LINE, borderWidth=.25, borderPadding=6, spaceBefore=5, spaceAfter=8))
styles.add(ParagraphStyle(name='Callout', fontName='Helvetica', fontSize=9, leading=13, textColor=INK, backColor=GREEN, borderColor=HexColor('#B9E7D9'), borderWidth=.5, borderPadding=8, spaceBefore=5, spaceAfter=10))
styles.add(ParagraphStyle(name='Warning', fontName='Helvetica', fontSize=9, leading=13, textColor=INK, backColor=AMBER, borderColor=HexColor('#F2D38B'), borderWidth=.5, borderPadding=8, spaceBefore=5, spaceAfter=10))

def p(txt, style='Bodyx'):
    return Paragraph(txt, styles[style])

def bullets(items):
    return [p('&bull; ' + x) for x in items]

def table(headers, rows, widths=None):
    data = [[p(h, 'Small') for h in headers]] + [[p(str(x), 'Small') for x in row] for row in rows]
    t = Table(data, colWidths=widths, repeatRows=1, hAlign='LEFT')
    t.setStyle(TableStyle([
        ('BACKGROUND',(0,0),(-1,0),NAVY), ('TEXTCOLOR',(0,0),(-1,0),colors.white),
        ('VALIGN',(0,0),(-1,-1),'TOP'), ('GRID',(0,0),(-1,-1),.25,LINE),
        ('ROWBACKGROUNDS',(0,1),(-1,-1),[colors.white, PALE]),
        ('LEFTPADDING',(0,0),(-1,-1),6), ('RIGHTPADDING',(0,0),(-1,-1),6),
        ('TOPPADDING',(0,0),(-1,-1),5), ('BOTTOMPADDING',(0,0),(-1,-1),5),
    ]))
    return t

def section(title, intro=None):
    s=[p(title,'H1x')]
    if intro: s.append(p(intro))
    return s

def footer(canvas, doc):
    canvas.saveState()
    canvas.setStrokeColor(LINE); canvas.setLineWidth(.4); canvas.line(18*mm, 14*mm, 192*mm, 14*mm)
    canvas.setFillColor(MUTED); canvas.setFont('Helvetica', 8)
    canvas.drawString(18*mm, 9*mm, 'Nation CBS | Next.js Technical Implementation Blueprint | Internal')
    canvas.drawRightString(192*mm, 9*mm, 'Page %d' % doc.page)
    canvas.restoreState()

story=[]
# cover
story += [Spacer(1,38*mm), p('NATION CBS', 'Small'), Spacer(1,4*mm), p('Next.js Technical<br/>Implementation Blueprint','CoverTitle'),
          p('A source-grounded specification for rebuilding the supplied Business Central extension as a secure, modular web application.', 'CoverSub'),
          Spacer(1,28*mm), table(['Source assessed','Implementation target','Document status'], [['Nation CBS AL extension (v1.0.0.0); 665 AL files', 'Next.js App Router + TypeScript + relational database', 'Build blueprint - assumptions identified where source is not definitive']], [54*mm,65*mm,55*mm]),
          Spacer(1,18*mm), p('Prepared 17 August 2026', 'Small'), PageBreak()]

story += section('1. Executive summary', 'This is a techno-functional implementation guide for a Next.js product. It organizes the system by business module, user outcome, workflow, data, controls, and delivery acceptance - not by source-code conversion.')
story += [p('<b>What was found.</b> Nation CBS is a SACCO / cooperative financial-services extension built on Microsoft Dynamics 365 Business Central. Its implementation is composed of 163 custom tables, 268 pages, 98 reports, 28 codeunits, 40 enums, 7 XML imports, and extensions to base ERP entities. It depends on a separate Nation ERP extension and Business Central platform services.'),
          p('<b>Recommended product boundary.</b> Rebuild it as a modular core-banking operations portal. Keep financial posting and Business Central-specific ledger behavior behind explicit domain services. Treat the first release as an operational web application with auditable workflows, role-based access, imports, document handling, and integration adapters.'),
          p('<b>Important limitation.</b> The source shows user-facing pages, table schemas, reports, and business procedures. It does not supply a complete external API contract, production configuration values, authentication design, reporting layouts, or runtime data. Those must be confirmed in discovery before production cutover.', 'Warning')]
story += section('2. Source inventory and interpretation')
story.append(table(['AL asset','Count','Next.js interpretation'], [
 ['Custom tables','163','Persistent domain entities and operational ledgers'], ['Pages','268','List, detail, wizard, dashboard, and setup screens'], ['Reports','98','Operational reports, statements, certificates, schedules, notices'], ['Codeunits','28','Domain services, approvals, posting routines, integrations, scheduled operations'], ['Enums / extensions','43','Controlled vocabularies and ERP type extensions'], ['XMLports','7','Bulk import pipelines: checkoff, SMS, dividends, debts/loans'], ['Queries','4','Read-model / reporting queries'], ['App dependency','1','Nation ERP v1.0.0.0; requires replacement interfaces or retained ERP integration']
], [38*mm,18*mm,118*mm]))
story += [p('The most important codeunits are Product Management, Member Management, Loans Management, Payroll Loan Management, Fixed Deposit Management, Journal Management, Checkoff Management, Scheduled Activities, Notifications Management, Integrations Management, Channels Integrations, FOSA Management, Cash Management, Share Trading Management, Dividend Management, ATM Integration, and Custodial Management.'), PageBreak()]

story += section('3. Target architecture', 'Use a modular monolith first. It matches the source’s transactional coupling, allows a single financial audit trail, and keeps deployment simple. Extract adapters or workers only for unreliable / asynchronous external systems.')
story.append(p('Browser UI -> Next.js App Router -> Server Actions / Route Handlers -> Domain services -> PostgreSQL<br/>                                                             -> Outbox + worker -> SMS, payments, ATM, SharePoint, payroll, channels<br/>                                                             -> Object storage -> attachments and generated reports', 'CodexBlock'))
story.append(table(['Layer','Recommended choice','Responsibility'], [
 ['Web','Next.js 15+ App Router, TypeScript, React Server Components','Authenticated operations UI, forms, dashboards, document views'],
 ['API','Route Handlers + typed service layer','Internal UI API; partner webhooks; OpenAPI for public integrations'],
 ['Persistence','PostgreSQL + Prisma or Drizzle','Transactions, audit records, immutable posting journals, row-level constraints'],
 ['Auth','OIDC provider (Auth.js / enterprise IdP)','SSO, MFA, session policy, role and branch scoping'],
 ['Async','BullMQ + Redis or managed queue','Imports, scheduled jobs, report runs, retries, notifications, integration outbox'],
 ['Storage','S3-compatible object storage','Attachments, applications, statement PDFs, export files'],
 ['Observability','Structured logs, error tracking, metrics','Correlation IDs, posting traceability, job failure alerts']
], [28*mm,50*mm,96*mm]))
story += [p('<b>Rule:</b> no direct database mutation from UI components. Every monetary or approval state transition must call a server-side domain command inside a database transaction.', 'Callout'), PageBreak()]

story += section('4. Module map and navigation', 'The source’s Role Center exposes broad operational navigation. Use route groups by business capability, and use list/detail patterns consistently.')
story.append(table(['Module','Source evidence','Suggested routes / responsibilities'], [
 ['Identity & admin','Role Center; User Profile Management; User Setup extension','/admin/users, /roles, /branches, /settings, /audit'],
 ['Member lifecycle','Members, Member Application, KINs, accounts, activation, withdrawal','/members, /member-applications, /members/[id], /withdrawals'],
 ['Products & accounts','Sacco Products, categories, charges, member accounts, fixed deposits','/products, /accounts, /fixed-deposits'],
 ['Loans & securities','Loans, schedules, guarantees, collateral, moratorium, recovery','/loans, /loan-applications, /collateral, /guarantees, /recoveries'],
 ['Cash / FOSA / teller','FOSA transactions, teller transactions, denomination, cash management','/teller, /cash, /fosa, /journals'],
 ['Payroll & checkoff','Employers, payroll codes, uploads, calculations, advice','/employers, /checkoffs, /payroll'],
 ['Dividends & shares','Dividend headers/lines/recoveries, share trading/floating/transfers','/dividends, /shares, /share-transfers'],
 ['Payments & channels','Standing orders, PesaLink, B2B, mobile, ATM, channel transactions','/payments, /standing-orders, /channels, /atm'],
 ['Compliance & custodial','AML checks, custodial services, document checklist','/compliance, /custodial, /documents'],
 ['Reports','98 SSRS/RDLC report assets','/reports, /statements, /exports']
], [35*mm,58*mm,81*mm]))
story += [p('The counts in the source indicate especially large Member (49 pages), Loan (41), Share (13), Dividend (11), Channel (10), Checkoff (9), ATM (8), and Mobile (8) surface areas. Build the shared patterns first: filters, status chips, work queues, detail tabs, attachments, approval actions, CSV import/export, and printable documents.'), PageBreak()]

story += section('5. Module implementation cards', 'Use each card as a build backlog and UAT checklist. A module is complete only when users can execute its happy path, approval path, exception path, audit trace, and core output.')
def module_card(title, purpose, actors, data, screens, lifecycle, controls, outputs, done):
    story.append(p(title, 'H2x'))
    story.append(table(['Purpose and actors','Records and screens','Lifecycle, controls and acceptance'], [[
        purpose + '<br/><br/><b>Actors:</b> ' + actors,
        '<b>Records:</b> ' + data + '<br/><br/><b>Screens:</b> ' + screens,
        '<b>Lifecycle:</b> ' + lifecycle + '<br/><br/><b>Controls:</b> ' + controls + '<br/><br/><b>Outputs:</b> ' + outputs + '<br/><br/><b>Done:</b> ' + done
    ]], [51*mm,55*mm,73*mm]))

module_card('5.1 Member management and onboarding', 'Register, verify, activate, maintain, and exit individual or corporate members, including their default accounts and KYC evidence.', 'Member services, KYC/compliance, branch staff, approvers.', 'Member Application, Member, Member Edit, Member Account, Category, Nominee/KIN, Activation, Withdrawal, Document.', '/member-applications, /members, /members/[id], /members/[id]/accounts, /members/[id]/documents, /withdrawals.', 'Draft -> validate/KYC -> approval -> member + accounts created -> active; edits and withdrawals use separate approvals.', 'Validate identity, KRA PIN, phone, age/date and duplicate rules; category determines default accounts; restrict/document member views; no withdrawal until obligations settle.', 'Membership form/list, KIN list, statement, withdrawal documents.', 'A user completes individual and corporate onboarding, approvals cannot be bypassed, attachments are controlled, and resulting accounts reconcile to opening entries.')

module_card('5.2 Products, accounts and fixed deposits', 'Configure member financial products, pricing, charges, account mappings, and deposit lifecycle.', 'Product administrators, finance, branch operations.', 'Product, Category, Interest Band, Charge Setup, Member Account, Fixed Deposit Type/Account/Schedule.', '/products, /products/[code], /charges, /accounts, /fixed-deposits.', 'Setup -> approved/active product -> account opening -> transaction/accrual -> maturity, renewal or closure.', 'Require posting type, account mapping, rates and charge policy before activation; prevent transactions on blocked products; selected interest band must cover the term.', 'Account list, fixed-deposit certificate, maturity/accrual reports.', 'Configured products can open compliant accounts and produce correct schedule, maturity, and certificate outcomes.')

module_card('5.3 Loans, appraisal, security and recovery', 'Originate, appraise, approve, disburse, service, restructure, secure, and recover member loans.', 'Credit officers, guarantors, approvers, collections, finance.', 'Loan, Schedule, Security, Guarantee, Collateral, Appraisal, Interest Accrual, Moratorium, Recovery, Defaulter Notice.', '/loan-applications, /loans, /loans/[id], /guarantees, /collateral, /recoveries, /moratoriums.', 'Application -> appraisal -> security -> approval -> disbursement/posting -> repayment/accrual -> arrears/recovery -> close or controlled restructure.', 'Enforce eligibility, contributions, product terms, charges, security limits, mandatory documents, maker-checker and controlled reversal rather than posted edits.', 'Application/appraisal, repayment schedule, register, ageing, disbursement, defaulter and guarantor reports.', 'Signed-off sample cases reproduce correct schedule, journal, repayment allocation, arrears classification and recovery result.')

module_card('5.4 Teller, FOSA, cash and journals', 'Run member cash services and internal financial movements with daily till and journal control.', 'Tellers, supervisors, cashiers, finance.', 'Teller Setup/Transaction, FOSA Transaction, Denomination, Journal Voucher, Cheque Deposit, Bankers Cheque.', '/teller, /fosa, /cash, /journals, /receipts, /payments, /cheque-deposits.', 'Initiate -> validate balance/account -> approve if needed -> post -> receipt/journal -> reconcile. Cheques retain clearing states.', 'Enforce till entitlement and denomination balance; posting setup complete; debit = credit; immutable entries and reversal-only correction.', 'Cash receipt, cash book, deposit slip, vouchers, bank balance report.', 'Deposit, withdrawal, end-of-day reconciliation and trace to approval/journal all work.')

module_card('5.5 Payroll and checkoff collections', 'Receive employer deductions, validate them, allocate member obligations, and issue advice/exceptions.', 'Payroll officers, employer liaison, collections, finance.', 'Employer, Payroll Code, Checkoff Upload/Header/Line/Calculation, Variation, Advice.', '/employers, /payroll, /checkoffs, /checkoffs/imports, /checkoffs/[batch].', 'Upload -> stage/preview -> correct rows -> approve -> post allocation -> advice/reconcile.', 'Preserve raw file/errors; no direct upload posting; prevent duplicate period batch; match member/account; reconcile batch total to allocations.', 'Checkoff advice, monthly receipts, variance, under/over-paid analysis.', 'Representative payroll has row-level errors, correction, one-time approval/posting and full employer-total reconciliation.')
story.append(PageBreak())

module_card('5.6 Dividends, shares and member capital', 'Calculate and distribute dividends, recover obligations, and manage share activity.', 'Finance, member services, dividend committee, approvers.', 'Dividend Header/Line/Recoveries/Entries, Share Trading, Floating, Transfer.', '/dividends, /dividends/[period], /share-trading, /share-floating, /share-transfers.', 'Freeze parameters -> calculate -> review/approve -> recover/post -> issue result. Share actions have independent approvals.', 'Freeze balance date/input; retain calculation evidence; no duplicate period posting; distinguish calculated, recovered and payable values.', 'Dividend slip, transfer receipt, share detail and classification reports.', 'A signed-off sample run is reproducible, traceable at member level and posts once.')

module_card('5.7 Payments, standing orders and channels', 'Process payment instructions and external-channel activity through settlement and reconciliation.', 'Payments operations, channel support, finance.', 'Standing Order, PesaLink, B2B, Channel Transaction/Setup/Dump/Reversal, Account Instruction.', '/payments, /standing-orders, /pesalink, /b2b, /channels.', 'Create -> approve -> submit -> callback/poll -> settle/post -> archive/reconcile; failed/skipped/reversed items remain actionable.', 'Unique external reference/idempotency; signed webhooks; full status history; never treat timeout as failure; daily settlement reconciliation.', 'Standing order register, payment due, repayment schedule, exception queues.', 'Delayed/duplicate callbacks never double-post, and each external reference reconciles to settlement.')

module_card('5.8 Mobile, ATM and communications', 'Manage channel enrolment/cards, ingest activity/reversals, and send member communications securely.', 'Digital operations, card team, support, member services.', 'Mobile Application/Member/Ledger, ATM Application/Card/Transaction, SMS Ledger, Bulk SMS.', '/mobile, /mobile-applications, /atm, /atm-cards, /atm-transactions, /messages.', 'Application -> approve -> link -> active; receive transaction -> validate -> post/reverse -> notify. Bulk SMS: audience -> queue -> delivery outcome.', 'Mask card values; validate card/member/account link; retain reversal reference; separate received from posted; apply consent/opt-out and secure logs.', 'ATM/mobile eligibility and transaction reports; message delivery/failure log.', 'Sandbox enrolment, posting, reversal, masking and retry behavior are demonstrated.')

module_card('5.9 Compliance, documents and custodial', 'Control KYC evidence, AML review, document checklists, custodial holdings and liens.', 'Compliance, custodial operations, auditors, approvers.', 'Attachment/Checklist, AML Check, Custodial Header/Movement/Service/Entry, Lien, View Log.', '/compliance, /aml-checks, /documents, /custodial, /liens, /audit.', 'Evidence -> checklist/review -> approval -> active exception/service -> monitored change -> closure/release.', 'Role-limited document access; checksum/version/metadata; lien and custodial movement require reason + approval; views are audited.', 'Custodial receipt/holding, collateral/lien, AML and document-completeness queues.', 'Auditor can trace regulated action to evidence, approval, access history and immutable movement/posting.')

module_card('5.10 Administration, reports and operations control', 'Manage master setup, permissions, scheduled processing, work queues, reports, and support visibility.', 'Administrators, branch managers, finance, operations, auditors.', 'Sacco Setup, User Setup, Lookup Values, Scheduled Activities, Job Execution, Cues, Report Runs.', '/admin/settings, /admin/users, /admin/jobs, /dashboards, /reports, /audit.', 'Configure -> validate -> activate; job -> record result -> retry/escalate; dashboards surface pending work.', 'Audit configuration changes; secrets in vault; job locking/idempotency; scoped report export; retain parameters and source cutoff.', 'Operational dashboards plus member, loan, collections, cash, dividend and channel report runs.', 'Admin config, controlled job retry, role-scoped report and traceable run history all operate reliably.')
story.append(PageBreak())

story += section('6. Cross-module data model', 'Model the source records as normalized entities plus an append-only accounting and audit layer. Do not recreate Business Central FlowFields as stored mutable totals; calculate them from ledger entries or materialized projections.')
story.append(table(['Aggregate','Core entities','Key relationships / constraints'], [
 ['Member','Member, MemberApplication, MemberAccount, NomineeKin, MemberDocument','Member has many accounts, applications, KINs, documents; identity number unique per identity type'],
 ['Product','Product, ProductCategory, ProductCharge, InterestBand','Product controls posting type, rates, account mappings, eligibility, charges'],
 ['Loan','Loan, LoanSchedule, LoanSecurity, Guarantee, Collateral, LoanRecovery','Loan belongs to member/product; schedules versioned; guarantee/collateral allocations cannot exceed eligible balance'],
 ['Money movement','Transaction, TransactionLine, Account, Journal, Settlement','Double-entry immutable posted entries; idempotency key on inbound integrations'],
 ['Workflow','ApprovalRequest, ApprovalStep, ApprovalDecision, Comment','Document type + ID; transitions only through policy service'],
 ['Payroll','Employer, PayrollCode, CheckoffBatch, CheckoffLine','Batch import retains raw file, validation result, row errors, and posting reference'],
 ['Channels','ChannelTransaction, ATMCard, MobileMember, StandingOrder','External reference unique per channel; status/outcome and retry history retained'],
 ['Documents','Attachment, DocumentChecklist, GeneratedDocument','Metadata in DB, binary in object storage, virus scan status']
], [31*mm,62*mm,81*mm]))
story += [p('Recommended conventions: UUID primary keys externally; human-readable business numbers from a sequencer; ISO dates in UTC timestamps; Decimal / NUMERIC for money; currency code on every monetary value; soft-delete only for reference data; never delete posted financial entries.'), p('6.1 Core data dictionary - members, products and loans', 'H2x')]
story.append(table(['Table','Key fields and recommended PostgreSQL type','Relationships / implementation notes'], [
 ['members','id UUID PK; member_no VARCHAR(20) UNIQUE; first_name/middle_name/last_name VARCHAR(50); full_name VARCHAR(150); mobile_phone VARCHAR(50); identification_no VARCHAR(50); date_of_birth DATE; status member_status ENUM; created_at TIMESTAMPTZ','Source: Members. Add identity_type and unique (identity_type, identification_no). Encrypt / mask sensitive identity fields; retain audit/version history.'],
 ['products','id UUID PK; code VARCHAR(20) UNIQUE; category_code VARCHAR(20); description VARCHAR(100); posting_type product_posting_type ENUM; interest_rate NUMERIC(19,4); interest_method loan_rate_type ENUM; active BOOLEAN','Source: Sacco Products. Do not store chart-account codes without a validated account mapping table. Product changes need effective dating.'],
 ['loans','id UUID PK; loan_no VARCHAR(20) UNIQUE; member_id UUID FK; product_id UUID FK; requested_amount/approved_amount/disbursed_amount NUMERIC(19,4); interest_rate NUMERIC(19,4); installments INTEGER; application_date DATE; repayment_start_date DATE; status document_status ENUM','Source: Loans. Maintain status and posted_at separately; monetary values carry currency; enforce non-negative and approved <= permitted policy.'],
 ['loan_schedules','id UUID PK; loan_id UUID FK; installment_no INTEGER; expected_date DATE; principal_repayment NUMERIC(19,4); interest_repayment NUMERIC(19,4); total_repayment NUMERIC(19,4); running_balance NUMERIC(19,4)','Source: Loan Schedule. Unique (loan_id, installment_no); version schedules when restructured; totals reconcile to approved principal and calculated interest.']
], [31*mm,91*mm,52*mm]))
story += [PageBreak(), p('6.2 Core data dictionary - security, collections and distributions', 'H2x')]
story.append(table(['Table','Key fields and recommended PostgreSQL type','Relationships / implementation notes'], [
 ['loan_guarantees','id UUID PK; loan_id UUID FK; guarantor_member_id UUID FK; guaranteed_amount NUMERIC(19,4); available_guarantee NUMERIC(19,4); self_guarantee BOOLEAN; substitution_status ENUM','Source: Loan Guarantees. Available value is derived / locked during approval; prevent total allocations above permitted member guarantee.'],
 ['collateral','id UUID PK; collateral_no VARCHAR(20) UNIQUE; member_id UUID FK; collateral_type VARCHAR(20); description VARCHAR(150); collateral_value NUMERIC(19,4); status collateral_status ENUM; serial_reg_no VARCHAR(100); insurance_expiry DATE','Source: Collateral Register. Link collateral allocations to loans in a child table; retain valuation evidence and release authorization.'],
 ['checkoff_batches','id UUID PK; batch_no VARCHAR(20) UNIQUE; employer_id UUID FK; document_date DATE; posting_date DATE; uploaded_amount NUMERIC(19,4); status document_status ENUM; posted BOOLEAN; source_file_id UUID FK','Source: Checkoff Header. Unique (employer_id, payroll_period, upload_type) after confirming business rule. Preserve file checksum, parser version and validation state.'],
 ['checkoff_lines','id UUID PK; batch_id UUID FK; member_id UUID FK NULL; payroll_no VARCHAR(20); amount_earned NUMERIC(19,4); recoveries NUMERIC(19,4); net_amount NUMERIC(19,4); posted BOOLEAN; row_status import_row_status ENUM','Source: Checkoff Lines. Support unmatched / suspense rows. Keep original row payload and error messages for remediation.'],
 ['dividend_runs','id UUID PK; run_no VARCHAR(20) UNIQUE; start_date/end_date DATE; transaction_code VARCHAR(20); expense_account_id UUID; payable_account_id UUID; recover_loans BOOLEAN; status dividend_status ENUM','Source: Dividend Header. Freeze parameter snapshot and input cutoff; a run is immutable once posted.'],
 ['dividend_lines','id UUID PK; dividend_run_id UUID FK; member_id UUID FK; automatic_amount NUMERIC(19,4); manual_amount NUMERIC(19,4); recoveries NUMERIC(19,4); net_amount NUMERIC(19,4); posted BOOLEAN; notified BOOLEAN','Source: Dividend Lines. Unique (dividend_run_id, member_id); track manual override reason and approver.']
], [31*mm,91*mm,52*mm]))
story += [PageBreak(), Spacer(1, 8*mm), p('6.3 Core data dictionary - transactions, channels and controls', 'H2x')]
story.append(table(['Table','Key fields and recommended PostgreSQL type','Relationships / implementation notes'], [
 ['teller_transactions','id UUID PK; document_no VARCHAR(20) UNIQUE; transaction_type ENUM; member_id UUID FK; account_id UUID FK; amount NUMERIC(19,4); teller_user_id UUID; till_id UUID; status document_status ENUM; posted BOOLEAN','Source: Teller Transactions. Require a separate till/session table and a link to the final accounting transaction.'],
 ['fosa_transactions','id UUID PK; document_no VARCHAR(20) UNIQUE; transaction_type fosa_transaction_type ENUM; source_account_id UUID; destination_account_id UUID; amount NUMERIC(19,4); denominations NUMERIC(19,4); status document_status ENUM; posted BOOLEAN','Source: FOSA Transactions. Validate source/destination difference and transaction-specific account rules.'],
 ['channel_transactions','id UUID PK; channel ENUM; external_reference VARCHAR(250); direction ENUM; transaction_type VARCHAR(20); account_id UUID; member_id UUID; amount NUMERIC(19,4); status channel_status ENUM; received_at TIMESTAMPTZ; posted_at TIMESTAMPTZ','Source: Channel Transactions and ATM Transactions. Unique (channel, external_reference); raw callback in separate immutable channel_messages table.'],
 ['atm_cards','id UUID PK; card_token VARCHAR(100) UNIQUE; member_id UUID FK; account_id UUID FK; atm_type_id UUID FK; status card_status ENUM; issued_at DATE; collected_at DATE','Source: ATM Cards/Applications. Never store full PAN unless contract and PCI scope explicitly allow it; use token/masked display.'],
 ['accounting_transactions','id UUID PK; transaction_no VARCHAR(30) UNIQUE; source_type VARCHAR(50); source_id UUID; posting_date DATE; status posting_status ENUM; idempotency_key VARCHAR(100) UNIQUE; posted_at TIMESTAMPTZ','New core ledger boundary. Child accounting_transaction_lines store account_id, debit NUMERIC(19,4), credit NUMERIC(19,4), currency_code and dimensions. Enforce balanced entries.'],
 ['approval_requests','id UUID PK; document_type VARCHAR(50); document_id UUID; state approval_state ENUM; submitted_by UUID; current_step INTEGER; amount NUMERIC(19,4); decided_at TIMESTAMPTZ','New workflow boundary based on AL approval services. Child decisions include approver, decision, comment, timestamp and delegated authority evidence.'],
 ['attachments','id UUID PK; owner_type VARCHAR(50); owner_id UUID; file_name VARCHAR(255); storage_key VARCHAR(500); checksum CHAR(64); content_type VARCHAR(100); scan_status ENUM; uploaded_by UUID; uploaded_at TIMESTAMPTZ','Source: document attachment service. Binary remains in object storage; use signed access and a document-access audit log.']
], [31*mm,91*mm,52*mm]))
story += [PageBreak()]

story += section('7. Workflow and financial-posting design')
story += [p('The source contains explicit send/cancel/release/reopen approval handlers for at least 30 document types, including loan applications/disbursements/restructures, collateral, member applications and edits, teller transactions, liens, standing orders, fixed deposits, ATM and mobile applications, checkoff, member withdrawal, dividend headers, FOSA transactions, cheque deposits, AML checks, and share floating.'),
             p('Draft -> Pending approval -> Approved -> Posted / Processed<br/>                             -> Rejected -> Reopened -> Draft', 'CodexBlock'),
             p('<b>Implement as a state machine.</b> Maintain a document-type configuration table with allowed states, role/group policy, amount thresholds, required checklist items, and whether a posted reversal is required. Every transition writes an immutable ApprovalDecision and AuditEvent. Approval comments must be mandatory on rejection, matching the source’s rejection-comment check.'),
             p('<b>Posting.</b> A command such as <font name="Courier">postLoanDisbursement()</font> must validate the approved state, lock its aggregate row, derive accounting lines, write one balanced Transaction and child lines, mark the document posted, create an outbox event, and commit atomically. Retrying the same command must return the original result via a unique idempotency key.', 'Callout')]
story += section('8. API and command design')
story.append(table(['Pattern','Examples','Notes'], [
 ['Reads','GET /api/members?status=active; GET /api/loans/:id','Cursor pagination, filter schema, field-level permissions'],
 ['Commands','POST /api/loans; POST /api/loans/:id/submit; POST /api/loans/:id/post','Separate commands from resource updates'],
 ['Approvals','POST /api/approvals/:id/approve; POST /api/approvals/:id/reject','Require decision reason / comment as policy dictates'],
 ['Imports','POST /api/checkoffs/import; GET /api/imports/:id','Async parse, preview, validation, then explicit commit'],
 ['Webhooks','POST /api/webhooks/atm; /mobile; /payments','Signature verification, raw payload persistence, idempotency'],
 ['Reports','POST /api/reports/:name/runs; GET /api/report-runs/:id','Async render; signed short-lived file URL']
], [31*mm,76*mm,67*mm]))
story += [p('Use Zod schemas shared by client and server. Publish an OpenAPI contract for partners, but never expose internal posting endpoints directly without strong client authentication, scoped authorization, replay protection, and rate limits.'), PageBreak()]

story += section('9. Integration blueprint', 'The source identifies multiple external touchpoints. Implement each as a replaceable adapter behind a stable application service; do not put partner-specific payload logic in route handlers.')
story.append(table(['Adapter','Source signal','Required behavior'], [
 ['SMS / notifications','Notifications Management, Bulk SMS, SMS URL configuration','Template messages; queued delivery; provider callback; retry / dead-letter; opt-out and PII-safe logs'],
 ['Document storage','Document Attachment Management: SharePoint upload/link','Presigned upload; malware scan; checksum; metadata; optional SharePoint adapter'],
 ['ATM','ATM Integration, cards, ATM transactions, reversals','Inbound webhook; card masking; settlement mapping; reversal lifecycle; reconciliation'],
 ['Mobile / channel','Mobile Application, Mobile Transactions, Channel Transactions','Signed callbacks; external reference idempotency; status polling / webhook recovery'],
 ['PesaLink / B2B','PesaLink, Coop B2B Integration, B2B Transactions','Payment initiation, callback, settlement and archive/reconciliation states'],
 ['Payroll / checkoff','XML imports, Checkoff Management, employers','File staging, field mapping, row-level error file, approval then posting'],
 ['Identity / compliance','Member Management IPRS/KRA validations; AML Management','Secure API vault, consent / legal basis, audit and response retention']
], [35*mm,62*mm,77*mm]))
story += [p('Use an outbox table written in the same transaction as each business event. A worker publishes events and records delivery attempts. This avoids the common failure mode where a transaction is posted but the SMS, external channel update, or generated document is silently lost.'), PageBreak()]

story += section('10. Security, control, and audit requirements')
story += bullets([
 'Adopt least-privilege RBAC with permissions at module, action, field, and branch/employer scope. Model Business Central user setup rules as policy records, not scattered UI checks.',
 'Require MFA through the identity provider. Use short sessions, CSRF protection for cookie flows, secure headers, and request/response validation.',
 'Encrypt sensitive fields and object-store payloads at rest. Redact national IDs, KRA PINs, card numbers, phones, and account numbers from logs. The source includes card masking and identity validation behavior; retain both.',
 'Store audit events for create/update/state transition/post/reverse/export/view. Capture actor, role, timestamp, correlation ID, old/new values with sensitive-field masking, and reason.',
 'Separate duties: initiator cannot approve own financial document; configurable maker-checker thresholds; require comment on rejection; stop mutable updates after posting except controlled reversals.',
 'Reconcile external payments, ATM activity, and channel transactions daily. Alert on unmatched, duplicated, failed, skipped, or late records.'
])
story += [p('Obtain a formal data-protection and retention review for the jurisdiction before deployment. The source is financial-services software and handles high-sensitivity personal and financial data.', 'Warning'), PageBreak()]

story += section('11. Reporting, documents, and dashboards')
story += [p('There are 98 SSRS/RDLC report definitions in the source. Prioritize outputs that drive operations or compliance: member statement, loan application/appraisal/schedule/register, disbursement schedule/summary, loan balances and ageing, defaulter notices, checkoff advice, cash book, bank balances, receipts, fixed-deposit certificate, collateral register, dividend slip, and share transfer documents.'),
             p('Build reports from query-specific read models. A report run must persist its parameters, requesting user, version, generated timestamp, source-data cutoff, checksum, and output URI. Render PDFs asynchronously, not in the request thread. For statements and notices, snapshot the source data used to produce the document.'),
             table(['Dashboard','Primary metrics','Drill-down'], [
 ['Operations','pending approvals, unposted imports, failed jobs, cash position','approval request, import batch, job log'], ['Credit','applications, disbursement pipeline, arrears, default bands','loan and member'], ['Members','new/active/withdrawn, account openings, KYC exceptions','member profile'], ['Collections','checkoff received/posted/errors, recovery performance','employer and batch'], ['Channels','pending/failed/reversed transactions, reconciliation aged items','external reference']
 ], [33*mm,72*mm,69*mm]), PageBreak()]

story += section('12. Delivery plan and acceptance gates')
story.append(table(['Phase','Scope','Exit criteria'], [
 ['0. Discovery (2-4 weeks)','Validate business rules, ledger mapping, reports, partner contracts, data quality and roles','Signed domain glossary, migration mapping, API list, priority report list'],
 ['1. Platform foundation','Auth/RBAC, audit/outbox, attachments, shared UI, configuration, CI/CD','Threat model passed; audit and role tests; deployment pipeline working'],
 ['2. Core operations','Members, products/accounts, loan application + approval, basic reporting','Parallel UAT of member / loan workflows; reconciliation rules accepted'],
 ['3. Financial operations','Posting ledger, FOSA/teller, checkoff/payroll, fixed deposits, dividends/shares','Balanced posting tests; import controls; operational sign-off'],
 ['4. Channels and integrations','ATM, mobile, payments, SMS, SharePoint, reconciliation','Sandbox and failure/retry tests; webhook idempotency verified'],
 ['5. Migration and rollout','Historical data, report parity, staff training, cutover support','Trial migrations, count/balance reconciliation, rollback plan, go-live approval']
], [34*mm,70*mm,70*mm]))
story += [p('<b>Recommended first vertical slice:</b> Member onboarding -> approval -> member account opening -> document attachment -> audit trail -> member statement. It establishes identity, workflow, documents, account data, reporting, and the common UI patterns before the higher-risk loan and cash modules.'),
             p('<b>Do not estimate solely from page count.</b> The risk is concentrated in posting, approval, calculation, migration, integration, and report parity. Confirm these before committing a fixed delivery date.', 'Warning'), PageBreak()]

story += section('13. Test strategy and migration')
story += bullets([
 'Unit-test calculation, eligibility, schedule, charge, allocation, status-transition, and authorization rules. Golden test cases must be extracted from current production scenarios with anonymized values.',
 'Use integration tests against mocked SMS/payment/ATM/SharePoint adapters and contract tests against partner sandbox APIs. Verify duplicate callbacks and delayed/reordered messages.',
 'Use end-to-end tests for maker-checker workflows, import preview/commit, posting/reversal, attachment access, report generation, and permission boundaries.',
 'Perform financial invariant tests: every posted transaction balances; no unauthorized transition occurs; scheduled totals reconcile; guarantees/collateral are not over-allocated; reversal refers to original transaction.',
 'Migrate in stages: reference data -> members/KYC -> accounts and opening balances -> loans/schedules/securities -> open workflows -> attachments -> historical reporting. Store source record identifiers for traceability.',
 'Run at least two trial migrations. Reconcile entity counts, balances by product/member/GL mapping, open loan schedules, and a representative set of statements and reports before cutover.'
])
story += section('14. Decisions required before implementation')
story.append(table(['Decision','Why it matters','Owner'], [
 ['System of record','Whether Next.js replaces or integrates with Business Central changes the ledger and migration design','Business + architecture'],
 ['Financial posting model','Define chart mapping, reversals, periods, approval gates, and reconciliation','Finance + engineering'],
 ['Priority scope','The full 268-page surface should be phased, not built as one release','Product + operations'],
 ['Partner contracts','ATM, mobile, PesaLink/B2B, SMS, identity and SharePoint APIs need validated contracts','Integration owners'],
 ['Data retention & privacy','Determines encryption, access, archival, consent, and audit requirements','Compliance + legal'],
 ['Report parity','Choose statutory/operational reports required at go-live and their acceptance samples','Operations + finance']
], [40*mm,92*mm,42*mm]))
story += [Spacer(1,7*mm), p('Appendix - source anchors', 'H2x'), p('Key source artifacts assessed: <font name="Courier">app.json</font>; codeunits 52204000-52204029; tables 52204000-52204208; Role Center page 52204000; 98 SSRS/RDLC report definitions; 7 XMLports for debt/loan, dividend, bulk SMS and checkoff flows. Version and dependency claims are taken from app.json. Module and workflow claims are taken from object names and visible AL procedures.'),
             p('This blueprint intentionally avoids copying the extension code. It specifies an implementation architecture and transition path suitable for a modern web application.', 'Small')]

doc=SimpleDocTemplate(OUT, pagesize=A4, rightMargin=18*mm, leftMargin=18*mm, topMargin=17*mm, bottomMargin=20*mm, title='Nation CBS - Next.js Technical Implementation Blueprint', author='Codex')
doc.build(story, onFirstPage=footer, onLaterPages=footer)
print(OUT)

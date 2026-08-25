import os, re
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import mm
from reportlab.lib.colors import HexColor
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak, Table, TableStyle

OUT='output/pdf/Nation_CBS_Complete_Nextjs_Techno_Functional_Specification.pdf'
os.makedirs(os.path.dirname(OUT), exist_ok=True)
NAVY=HexColor('#0B1F3A'); BLUE=HexColor('#1261A6'); PALE=HexColor('#EEF4FA'); LINE=HexColor('#D9E1EA'); INK=HexColor('#172033'); MUTED=HexColor('#5A687A'); GREEN=HexColor('#E7F6F1'); AMBER=HexColor('#FFF4D8')
s=getSampleStyleSheet()
s.add(ParagraphStyle(name='Cover',fontName='Helvetica-Bold',fontSize=26,leading=31,textColor=NAVY,spaceAfter=13))
s.add(ParagraphStyle(name='H1x',fontName='Helvetica-Bold',fontSize=18,leading=23,textColor=NAVY,spaceBefore=3,spaceAfter=9))
s.add(ParagraphStyle(name='H2x',fontName='Helvetica-Bold',fontSize=12.2,leading=15,textColor=BLUE,spaceBefore=10,spaceAfter=5))
s.add(ParagraphStyle(name='Bodyx',fontName='Helvetica',fontSize=9,leading=13,textColor=INK,spaceAfter=5))
s.add(ParagraphStyle(name='Small',fontName='Helvetica',fontSize=7.4,leading=9.4,textColor=MUTED))
s.add(ParagraphStyle(name='Callout',fontName='Helvetica',fontSize=9,leading=13,textColor=INK,backColor=GREEN,borderColor=HexColor('#B9E7D9'),borderWidth=.5,borderPadding=7,spaceBefore=5,spaceAfter=8))
s.add(ParagraphStyle(name='Warn',fontName='Helvetica',fontSize=8.7,leading=12.5,textColor=INK,backColor=AMBER,borderColor=HexColor('#F2D38B'),borderWidth=.5,borderPadding=7,spaceBefore=5,spaceAfter=8))

def p(t,style='Bodyx'): return Paragraph(t,s[style])
def t(headers,rows,widths):
    data=[[p(x,'Small') for x in headers]]+[[p(str(x),'Small') for x in r] for r in rows]
    x=Table(data,colWidths=widths,repeatRows=1,hAlign='LEFT')
    x.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),NAVY),('TEXTCOLOR',(0,0),(-1,0),colors.white),('VALIGN',(0,0),(-1,-1),'TOP'),('GRID',(0,0),(-1,-1),.25,LINE),('ROWBACKGROUNDS',(0,1),(-1,-1),[colors.white,PALE]),('LEFTPADDING',(0,0),(-1,-1),6),('RIGHTPADDING',(0,0),(-1,-1),6),('TOPPADDING',(0,0),(-1,-1),5),('BOTTOMPADDING',(0,0),(-1,-1),5)]))
    return x
def footer(c,d):
    c.saveState(); c.setStrokeColor(LINE); c.line(18*mm,14*mm,192*mm,14*mm); c.setFillColor(MUTED); c.setFont('Helvetica',8); c.drawString(18*mm,9*mm,'Nation CBS | Complete Specification | Internal'); c.drawRightString(192*mm,9*mm,'Page %d'%d.page); c.restoreState()
def h(title,intro=None):
    a=[p(title,'H1x')]
    if intro:a.append(p(intro))
    return a

def type_map(al):
    a=al.lower()
    if a.startswith('code['): return 'VARCHAR(%s)' % re.search(r'\[(\d+)\]',al).group(1)
    if a.startswith('text['): return 'VARCHAR(%s)' % re.search(r'\[(\d+)\]',al).group(1)
    if a=='decimal': return 'NUMERIC(19,4)'
    if a=='integer': return 'INTEGER'
    if a=='date': return 'DATE'
    if a=='datetime': return 'TIMESTAMPTZ'
    if a=='boolean': return 'BOOLEAN'
    if a=='blob': return 'OBJECT STORAGE REF'
    if a.startswith('enum') or a=='option': return 'ENUM / LOOKUP'
    return al.upper()

def fields(file):
    text=open(file,encoding='utf-8-sig').read()
    result=[]
    for m in re.finditer(r'field\(\d+;\s*"?([^";]+)"?;\s*([^\)]+)\)',text):
        name=m.group(1).strip(); al=m.group(2).strip()
        result.append((name,al,type_map(al)))
    return result

def role_for(name):
    n=name.lower()
    if any(x in n for x in ['no.', 'document no', 'loan no', 'entry no']): return 'Identifier / relationship'
    if any(x in n for x in ['created','posted','submitted','approved','reviewed','appraised','processed','last ','date','on']): return 'Lifecycle / audit date'
    if 'status' in n or n in ['closed','posted','disbursed','fully disbursed','restructured','substituted','self','release']: return 'State / control'
    if any(x in n for x in ['amount','balance','interest','repayment','installment','deposit','guarantee','arrears','recover','charge','commission','income','earnings','deductions','value','multiplier','principal','insurance','net ']): return 'Money / calculation'
    if any(x in n for x in ['member','product','account','employer','sector','bank','collector','witness','pay to','staff']): return 'Reference / party'
    if any(x in n for x in ['description','name','remarks','comments','reference']): return 'Display / narrative'
    return 'Business attribute'

root='src/table'
loan_security_files=[
 ('Loans',os.path.join(root,'Tab52204014.Loans.al')),
 ('Loan schedules',os.path.join(root,'Tab52204015.LoanSchedule.al')),
 ('Repayment schedules',os.path.join(root,'Tab52204016.RepaymentSchedule.al')),
 ('Product interest bands',os.path.join(root,'Tab52204030.ProductInterestBands.al')),
 ('Product charge setup',os.path.join(root,'Tab52204024.ProductChargeSetup.al')),
 ('Loan calculator',os.path.join(root,'Tab52204036.LoanCalculator.al')),
 ('Loan calculator lines',os.path.join(root,'Tab52204037.LoanCalculatorLines.al')),
 ('Appraisal accounts',os.path.join(root,'Tab52204047.AppraisalAccounts.al')),
 ('Loan guarantees',os.path.join(root,'Tab52204048.LoanGuarantees.al')),
 ('Loan securities',os.path.join(root,'Tab52204028.LoanSecurities.al')),
 ('Collateral applications',os.path.join(root,'Tab52204026.CollateralApplication.al')),
 ('Collateral register',os.path.join(root,'Tab52204027.CollateralRegister.al')),
 ('Collateral releases',os.path.join(root,'Tab52204031.CollateralRelease.al')),
 ('Security-management header',os.path.join(root,'Tab52204085.LoanSecurityMgmt.al')),
 ('Security-management lines',os.path.join(root,'Tab52204058.LoanSecurityMgmtLines.al')),
 ('Security-management detail lines',os.path.join(root,'Tab52204059.LoanSecurityMgmtDetLines.al')),
 ('Loan batches',os.path.join(root,'Tab52204081.LoanBatchHeader.al')),
 ('Loan batch lines',os.path.join(root,'Tab52204082.LoanBatchLines.al')),
 ('Loan moratorium / restructure',os.path.join(root,'Tab52204142.LoanMoratorium.al')),
 ('Loan recoveries setup',os.path.join(root,'Tab52204050.LoanRecoveries.al')),
 ('Loan recovery header',os.path.join(root,'Tab52204057.LoanRecoveryHeader.al')),
 ('Loan recovery lines',os.path.join(root,'Tab52204086.LoanRecoveryLines.al')),
 ('Channel loan application',os.path.join(root,'Tab52204104.ChannelLoanApplication.al')),
]

def title_from_file(path):
    text=open(path,encoding='utf-8-sig').read(2500)
    m=re.search(r'^\s*(?:table|tableextension)\s+\d+\s+"?([^"{]+)',text,re.M)
    return (m.group(1).strip() if m else os.path.basename(path))

def all_field_sources():
    items=[]
    for folder in ['src/table','src/tableextension']:
        for file in sorted([os.path.join(folder,x) for x in os.listdir(folder) if x.lower().endswith('.al')]):
            items.append((title_from_file(file),file))
    return items

def procedures(file):
    out=[]
    for i,line in enumerate(open(file,encoding='utf-8-sig'),1):
        m=re.match(r'\s*(?:(local|internal)\s+)?procedure\s+([^\(]+)\(',line)
        if m: out.append((i,m.group(2).strip(),m.group(1) or 'public'))
    return out

def procedure_transfer(name):
    n=name.lower()
    if any(x in n for x in ['post','disburse','accrue','billing','calculate','generate','process']): return 'Server-side command / job; transaction, idempotency, ledger/audit checks'
    if any(x in n for x in ['validate','check','test']): return 'Validation policy; return structured rule failure and UI message'
    if any(x in n for x in ['get','populate','create','copy','parse']): return 'Domain query / derivation; snapshot inputs where used for a decision'
    if any(x in n for x in ['send','notification','notice','upload']): return 'Asynchronous integration / outbox task with delivery trace'
    if any(x in n for x in ['onafter','onbefore']): return 'Domain hook; implement only as an explicit application event where still required'
    return 'Domain operation; confirm process rule with business owner and cover with an acceptance test'

def module_for_codeunit(filename):
    n=filename.lower()
    for key,label in [('approval','Approvals and workflow'),('workflow','Approvals and workflow'),('product','Products and pricing'),('member','Members and accounts'),('loan','Loans and security'),('payroll','Payroll'),('fixed','Fixed deposits'),('journal','Journals and accounting'),('checkoff','Checkoff collections'),('scheduled','Scheduled operations'),('notification','Communications'),('integration','External integrations'),('channel','Digital channels'),('debtor','Collections'),('fosa','FOSA and teller'),('cash','Cash management'),('share','Shares'),('dividend','Dividends'),('atm','ATM'),('profile','Identity and access'),('laundary','Compliance'),('custodial','Custodial')]:
        if key in n:return label
    return 'Platform support'

story=[]
story += [Spacer(1,37*mm),p('NATION CBS','Small'),Spacer(1,4*mm),p('Complete Next.js<br/>Techno-functional Specification','Cover'),p('Detailed module documentation for implementation in Next.js: scope, data, rules, workflows, controls, source procedures, and testable outcomes.','Bodyx'),Spacer(1,22*mm),t(['Coverage','Source basis','Implementation stance'],[['All Nation CBS business modules; detailed Loans and Security section; complete procedure and field catalogues','665 AL files: custom tables/extensions, service codeunits, pages, reports and configuration','Business implementation reference - source behavior is catalogued; policy values are explicitly configurable']], [55*mm,57*mm,62*mm]),Spacer(1,20*mm),p('Prepared 17 August 2026 | Complete implementation reference','Small'),PageBreak()]

story += h('1. Purpose, boundary and reading guide','This document is intentionally implementation-focused. It describes the behavior the Next.js system must provide, while identifying where exact financial policy must be confirmed with the SACCO.')
story += [p('<b>In scope:</b> loan product policy, member loan application, calculator and appraisal, guarantors and collateral, approvals, creation/disbursement, schedules, billing/accrual/penalties, repayments, restructuring/moratorium, recovery, batch disbursement, and channel applications.'),p('<b>Out of scope:</b> exact GL posting-account numbers, rate values, approval thresholds, external provider payloads, and legal retention values. The supplied source identifies these controls but does not provide a validated business configuration package.'),p('Every item marked <b>policy</b> must be made configurable, versioned and approval-controlled in the Next.js implementation. Do not hard-code SACCO rates, multipliers, penalty rules, recovery priority, or workflow thresholds.', 'Warn')]
story += h('2. End-to-end loan lifecycle')
story += [p('Product setup -> application -> validation / appraisal -> security capture -> submit -> approve -> create loan account -> disburse -> schedule + ledger -> accrue / bill -> collect -> classify / recover -> close<br/>                                                                             -> restructure or moratorium -> revised schedule -> continue servicing','Callout'),
p('The UI should render a single Loan workspace with tabs: Overview, Application, Appraisal, Securities, Guarantors, Documents, Approvals, Disbursements, Schedule, Transactions, Arrears, Recovery, Restructure, Audit. Each tab has explicit action eligibility based on state and role.')]
story.append(t(['State','Permitted operational meaning','Required control'],[['Draft','Application can be edited; no financial effect','Creator-only changes; required fields and documents tracked'],['Pending approval','Awaiting configured decision','No material edits; approval trail and comments'],['Approved','Credit decision accepted but not yet posted','Revalidate eligibility and security before disbursement'],['Disbursed / Posted','Financial account and entries exist','No delete/edit; corrections are reversal, recovery, or restructure'],['In arrears / default','Servicing indicator, not a replacement for posted state','Derived from schedule vs paid data; collection actions audited'],['Closed','Balances settled and closing criteria met','No new postings; retain reports/attachments/audit'],['Rejected / Reopened','Application returned for change','Comment mandatory on rejection; re-submission creates audit transition']], [32*mm,79*mm,63*mm]))
story.append(PageBreak())

story += h('3. Submodule 1 - loan product policy and pricing')
story += [p('Purpose: define what can be borrowed, by whom, on what terms, and how interest, charges, penalties, securities, and posting behave. It is the first dependency for every other loan action.'),t(['Configuration object','Functional use','Next.js implementation rule'],[['Product','Product code, posting type, source, eligibility, interest rate/method, repayment behavior','Effective-date every financial setting; approved version must be snapshotted on loan approval'],['Interest band','Maps min/max installments to interest rate and processing fee','Exactly one active band must match the selected term; reject overlapping active ranges'],['Charge setup','Charge code, calculation type, source charge, posting destination','Use a safe expression engine / declared formulas; test every configured formula'],['Loan product constraints','Maximum repayment period, multiplier, salary/deposit rules, disbursement/loan account mappings','Model as explicit configuration fields and validation policies, not hidden UI conditions']], [38*mm,67*mm,69*mm]),p('<b>Pricing logic evidenced by the source:</b> on product/term selection, the loan reads the product interest rate and repayment method; where interest bands are active, it selects the band where min installments <= selected installments <= max installments. Product charges are calculated from product charge setup and may evaluate a configured formula against a base amount. The proposed system must show the formula result and every charge line before submission.')]
story += h('4. Submodule 2 - loan application and pre-appraisal')
story += [p('Purpose: collect the requested credit, resolve member/product context, calculate a transparent offer, and prevent invalid submissions before an approver sees them.'),t(['Step','Functional logic','Implementation / evidence'],[['Create','User chooses member, product, requested amount, term, payment/disbursement option','Load product version, member profile, existing loans, deposits, member accounts and required documents'],['Derive','System derives rate, repayment method, proposed start/end, monthly principal/interest/total, charges and net amount','Persist a calculation snapshot; the user sees formula inputs and outputs'],['Pre-appraise','System builds appraisal accounts, salary/deposit information, existing obligations, securities/guarantee eligibility','Never overwrite user-entered values silently; distinguish calculated vs manually overridden values'],['Validate','Run product, age/KYC, account, term, affordability, duplicate, security and required field checks','Return field-level errors and a business-readable rejection reason'],['Submit','Freeze application values and send to configurable workflow','Create ApprovalRequest, attachments/checklist snapshot and audit event']], [28*mm,79*mm,67*mm]),p('<b>Minimum validation checklist from the source:</b> member and product must exist; loan amount and repayment term must be valid; product has interest/repayment settings; selected interest band must exist when bands are used; required disbursement/account and posting setup must exist; appraisals must be committed; guarantee/witness eligibility is checked; duplicate-loan and product-specific rules are evaluated. Exact policy thresholds require business confirmation.')]
story += h('5. Submodule 3 - appraisal and affordability')
story += [p('The calculator records current deposits, loan-deposit multiplier, outstanding loans, deposit appraisal, product, principal, rate, repayment start, installments, earnings, deductions, net income, and amount available. Appraisal accounts record account type, account, balance and multiplied value.'),p('Implement an <b>appraisal engine</b> that produces a dated immutable result: availableDepositCapacity, grossIncome, deductions, netIncome, existingDebtService, proposedInstallment, debtServiceRatio, guarantorCapacity, collateralCapacity, recommendedAmount, and exceptions. Calculations must be versioned by policy/effective date. Where staff override a computed value, require reason + approved authority.'),p('The source distinguishes deposit, salary/FOSA, self-guarantee, non-self-guarantee, special-loan and channel-appraisal paths. Present them as selectable product policies, not separate unmaintainable screens.', 'Callout')]
story.append(PageBreak())

story += h('6. Submodule 4 - guarantors and security management')
story += [p('Purpose: capture member guarantees and substitute/release them safely over the life of a loan. A guarantee is an allocation of member capacity to a loan; it must not be represented as a plain editable amount after approval.'),t(['Process','Source-backed behavior','Next.js control'],[['Capture guarantee','Guarantee stores member deposits, multiplied deposits, guaranteed amount, outstanding guarantees, available guarantee, self-guarantee and substitution state','Lock guarantor capacity in one transaction; reject concurrent overallocation'],['Calculate outstanding liability','For an active guarantee, source calculates ratio = guaranteed amount / approved amount, then outstanding = loan balance * ratio, capped by total guarantee; substituted guarantee has zero ratio','Store calculation inputs and result; use Decimal; show current amount and cap in UI'],['Eligibility','Self and non-self capacity considers deposits, configured multipliers and existing outstanding guarantees','Implement reusable eligibility command with policy version and result explanation'],['Substitution / release','Security-management header and lines identify existing security, qualified/original/proposed remaining guarantee and replacement amounts','Require new allocation to pass before old allocation can be released; approval then post atomically'],['Recovery','Recovery process can allocate member/guarantor amounts and calculate guarantor ratios','Cap recovery at outstanding liability and available recoverable balance; generate notice/audit']], [35*mm,75*mm,64*mm]),p('Recommended invariant: for each guarantor, <font name="Courier">sum(active allocation outstanding)</font> must never exceed configured eligible capacity; for each loan, the sum of approved guarantee/security allocation must meet the product’s required coverage rule. Use row locking or SERIALIZABLE transaction isolation for allocation changes.', 'Callout')]
story += h('7. Submodule 5 - collateral registration, linking and release')
story += [p('Collateral application captures the member, category/type, description, multiplier, valuation, guaranteed value, last valuation date, joint ownership, owner identifiers, images/documents, registration/serial number, insurance and tracking dates, multi-linking option, cheque/reference, location/county, approval status and posting flags. Upon approval, it is posted to the collateral register.'),t(['Stage','Business logic','Required outcome'],[['Register application','Capture collateral evidence and ownership; calculate policy-qualified guarantee from value and multiplier','Document checklist, valuation date, PII protection, duplicate serial/registration check'],['Approve and post','Create registered collateral record from approved application','Immutable link to application; retain attachments and approved valuation snapshot'],['Link to loan','Loan Securities connects loan, security type/code, security value, guarantee, member, linked-loan balance and substitution state','Validate collateral availability; multi-link only when policy permits; record allocation not merely a single linked loan'],['Outstanding value','Source allocates collateral responsibility proportionally using loan balance, total securities / total guarantees, and individual security guarantee / total securities','For Next.js, retain this as a validated calculation policy; expose formula and inputs. Confirm with finance before use for recovery/release.'],['Release / collect','Collateral Release records release reason, linked balance, collector identity/contact, collection date, status and posting','Only allow when linked balance / required coverage rules permit; approval is mandatory; preserve release acknowledgement']], [29*mm,79*mm,66*mm])]
story.append(PageBreak())

story += h('8. Submodule 6 - approval, loan creation and disbursement')
story += [p('The source has explicit workflow events for loan application, loan disbursement, loan restructure, collateral application/release, loan-security management and loan recovery. The Next.js workflow must use document-specific state transitions with maker-checker restrictions and decision comments.'),t(['Command','Preconditions','Atomic results'],[['submitLoan','Draft, validation/checklist passes, calculation snapshot present','Freeze proposal, create approval request, write audit event'],['approveLoan','Assigned approver, workflow step open, no conflict of interest','Decision record, application becomes Approved, no posting yet'],['createLoan','Approved application, product/account setup valid','Loan number and loan account; copy/snapshot approved product/rate/term/security data'],['disburseLoan','Approved loan, security remains valid, available disbursement amount, posting date open','Balanced accounting transaction, disbursement record, schedule (if required), status/posted time, outbox notification'],['postBatch','Approved batch with eligible lines, each loan revalidated','One result per line; failed lines isolated/reportable; batch totals reconciled'],['reverseDisbursement','Authorized correction only, original transaction reference supplied','Balanced reverse entries; no destructive edits; status and audit trail updated']], [33*mm,69*mm,72*mm]),p('Disbursement data includes mode, account, first disbursement, fully-disbursed, batch, payment bank/branch/account/name, insurance, charges, recoveries, net amount and posting reference. For each disbursement, provide a preview showing gross amount, less charges/recoveries/insurance, net payable, destination, and accounting impact before final post.')]
story += h('9. Submodule 7 - repayment schedules, accrual and servicing')
story += [p('Schedule tables carry document/loan reference, expected date, description, principal repayment, interest repayment, monthly repayment and running balance. The calculator has the equivalent projection lines. Treat an approved schedule as an immutable version; create a new version after a formal restructure, never overwrite a posted schedule.'),t(['Service','Logic required','Control'],[['Schedule generation','Generate due dates from repayment start / term and product frequency; calculate principal, interest, installment and running balance','Totals equal approved principal and scheduled interest within rounding rule; final installment absorbs residual'],['Amortised method','Source uses rate-based annuity calculation for amortised loans; per-annum vs periodic rate matters','Policy stores rate basis and rounding; calculation is tested with golden examples'],['Other methods','Source contains alternative repayment method paths including reducing/straight-line style logic','Define calculation method enum and published formulas; do not infer from labels alone'],['Interest accrual/billing','Source supports accrued daily interest, standard interest billing and upfront interest','Separate accrual (estimate/receivable) from posting; idempotency keyed by loan/date/run'],['Penalty','Source calculates penalty with freeze flag, penalty balance and last penalty date','Penalty policy is configurable; do not levy twice for same condition/date; support suspension/freeze'],['Repayment','Recovery/posting allocates payment to loan components and updates derived balances','Use configured allocation waterfall - typically fees/penalty/interest/principal only after confirmation; transaction lines remain source of truth']], [30*mm,83*mm,61*mm])]
story += h('10. Submodule 8 - arrears, classification and collections')
story += [p('The loan record exposes defaulted days, loan classification, defaulted installments, total/principal/interest arrears, last pay date, last interest/penalty charge, debt collector fields, recovery totals and notice pathways. These are mainly derived operational measures and should be projections calculated from schedule and ledger data at an as-of date.'),p('Arrears algorithm: for each due schedule line at the as-of date, compare due principal/interest/penalty with settled components; aggregate unpaid due amounts; derive earliest overdue date and defaulted days; classify using configurable ageing bands; persist daily snapshot for reporting but recompute on demand for investigation. Notices must record template/version, recipients, delivery outcome and approval where required.')]
story.append(PageBreak())

story += h('11. Submodule 9 - moratorium, restructure and recovery')
story += [p('Loan Moratorium stores type, loan/product, current principal, moratorium date/period/start/end, remaining installments, restructure date, new repayment start/end, current/new monthly installment, repayment period, status and posting audit. Source logic can freeze principal, interest, or both during the moratorium period; restructure generates revised repayment behavior.'),t(['Action','Detailed functional behavior','Post / audit rule'],[['Moratorium request','Select loan, type (principal, interest, full repayment, or configured type), dates, period and reason; derive remaining installments/current balance','Validate dates and required period; approval required; preserve schedule version before change'],['Post moratorium','Build a revised schedule from the effective date; zero principal and/or interest during the moratorium according to type; retain remaining balance','Create schedule version and document reference; never overwrite paid history'],['Restructure','Recalculate balance, term and new installment. Source has amortised formula and rate-basis branches','Require credit approval and disclosure; capture original/revised terms and reason; accounting impact separately approved'],['Recovery case','Recovery header gathers loan, accrued interest, total recoverable, self/member deposits, guarantor recovery and balances; lines hold member/guarantor recovery amount/type','Calculate recoverable caps; approval before post; create linked recovery/disbursement/accounting records'],['Recovery post','Source may create recovery-linked loan effects and post accrued interest before completing recovery','Use one database transaction or a compensating workflow; every source/recovery line maps to journal lines and notices']], [31*mm,82*mm,61*mm]),p('Never use a moratorium or restructure screen to change historical ledger postings. It is a forward-looking contractual change plus, where necessary, separately approved accounting adjustments.', 'Warn')]
story += h('12. Submodule 10 - channel loan applications')
story += [p('Channel Loan Application mirrors most core loan fields: member/product, amounts, rate/method, dates, statuses, account/billing/disbursement, balances, arrears, sector, recovery, security, income and portal fields. Implement it as a <b>source channel</b> on the same LoanApplication aggregate, with extra channel metadata and stricter idempotency, rather than duplicating the entire loan model.'),p('Required logic: authenticate callback or channel user; validate channel reference uniqueness; identify active member; load product/channel eligibility; run the same appraisal/loan-band policy; store raw request and consent; return a deterministic decision/next status; hand off to standard approvals/disbursement. No mobile/channel route may bypass the core approval, security or posting controls.')]
story.append(PageBreak())

story += h('13. Required screens, APIs and roles')
story.append(t(['Screen / API','Key actions','Who can act'],[['Loan work queue / GET /loans','Filter by state, product, branch, arrears, owner; export authorized view','Credit, collections, supervisor'],['Application detail / POST /loan-applications','Draft, calculate, validate, submit, reopen','Credit officer / maker'],['Appraisal / POST /loans/:id/appraise','Recalculate, view affordability/security evidence, override with reason','Credit officer; approver for overrides'],['Guarantors / securities','Add, allocate, substitute, request release','Credit officer; security operations'],['Collateral register','Register, attach valuation, link/unlink, release','Security officer; approver'],['Approval inbox','Approve/reject/escalate; view audit and documentation','Configured approvers only'],['Disbursement / POST /loans/:id/disburse','Preview and post; batch submit/post; reverse authorized transaction','Finance / disbursement officer'],['Servicing','View schedule/ledger; accrue/bill; post repayment; freeze penalty','Finance / collections'],['Restructure/recovery','Request, approve, post; issue notices','Collections / credit / approver'],['Reports','Schedule, register, balances, ageing, appraisal, recovery, guarantor/collateral','Role-scoped operations/finance']], [49*mm,79*mm,46*mm]))
story += [p('<b>API rule:</b> use command endpoints for every state/financial action, for example <font name="Courier">POST /api/loans/{id}/submit</font>, <font name="Courier">/approve</font>, <font name="Courier">/disburse</font>, <font name="Courier">/repayments</font>, <font name="Courier">/restructures</font>, and <font name="Courier">/recoveries</font>. Each command requires idempotency key, server-side authorization, transaction boundary, audit event and useful error result.', 'Callout')]
story += h('14. Test pack and acceptance cases')
story.append(t(['Case','Expected result'],[['Interest-band boundary','Min/max term selects exactly one active band; no band/overlap blocks submission'],['Loan appraisal','Member with existing loans/guarantees receives reproducible capacity result and reasoned exceptions'],['Guarantee concurrency','Two applications cannot reserve the same guarantor capacity beyond its eligible limit'],['Collateral link/release','Collateral cannot be released while coverage or linked balance rule fails; approval and receipt recorded'],['Disbursement idempotency','Repeated request with same key creates one posting and returns same response'],['Schedule rounding','Schedule principal sums exactly to approved principal; last installment reconciles rounding'],['Partial repayment','Configured allocation waterfall creates balanced entries and correct derived balances'],['Moratorium','Principal/interest/full types alter only future schedule components according to policy; paid history unchanged'],['Channel duplicate','Same verified external reference is processed once despite retry/delayed callback'],['Recovery','Member and guarantor recovery never exceeds configured outstanding/recoverable amounts; journals/notices traceable']], [48*mm,126*mm]))
story.append(PageBreak())

story += h('15. Cross-module implementation catalogue', 'This section extends the loan/security specification into every functional area in the supplied extension. Use the module catalog for work planning and the subsequent procedure/field catalogues for traceability and full data coverage.')
story.append(t(['Module','Primary source services / submodules','Implementation obligations'],[
 ['Members and accounts','Member applications, edits, KYC, accounts, activation, withdrawal, ATM/mobile enrolment, advice','Identity validation, duplicate control, default accounts, lifecycle approvals, PII protection, statements and audit'],
 ['Products and pricing','Products, categories, charges, interest bands, product management','Effective-dated product rules, rate/charge calculation, controlled configuration and eligibility'],
 ['Loans and security','Application, appraisal, schedules, guarantees, collateral, disbursement, billing, recovery, restructure','Detailed in sections 3-14; use immutable financial and schedule versions'],
 ['Payroll and checkoff','Employers, payroll codes, uploads, calculations, variations, advice','Stage/validate/approve/post import; retain raw rows/errors and reconcile totals'],
 ['Fixed deposits','Deposit types/accounts/schedules, accrual and maturity','Rate/maturity policy, approval where needed, ledger postings and certificates'],
 ['Teller, FOSA and cash','Teller transactions/setup, FOSA, denominations, cash management, journal vouchers','Till entitlements, balanced posting, denomination/reconciliation and receipt trace'],
 ['Payments and channels','Standing orders, PesaLink, B2B, account instructions, external/channel transactions','Idempotent references, signed callbacks, state history, settlement and reconciliation'],
 ['ATM/mobile/communications','Cards, ATM/mobile applications and ledger, bulk SMS/notifications','Masked tokens, approval/enrolment, safe inbound transaction/reversal, delivery outbox'],
 ['Shares and dividends','Share trading/floating/transfers, dividend header/lines/recoveries','Frozen calculation run, controlled recovery/distribution, one-time posting and slips'],
 ['Compliance and custodial','AML checks, liens, documents, custodial services/movement','Role-limited evidence, approvals, immutable movement and access audit'],
 ['Administration and reporting','Setup, lookup values, jobs, role centre/cues, 98 reports','Audited configuration, idempotent jobs, scoped reports, saved parameters/cutoffs']
],[38*mm,68*mm,76*mm]))
story += [p('Global process transfer rules', 'H2x'),p('Every source procedure below must be assigned to one Next.js domain service. Financial mutation procedures become authenticated server-side commands; scheduled procedures become queue jobs; integration procedures become adapters/outbox workers; calculation and validation procedures become deterministic, unit-tested policies. Preserve the process result and audit evidence, but do not recreate Business Central page triggers or database-side side effects in the browser.', 'Callout'),PageBreak()]

story += h('16. Complete source procedure and process catalogue', 'Every declared procedure in the 28 supplied codeunits is listed for traceability. The target designation tells the implementer where to place it; the existing AL procedure remains the definitive behavior to characterize with examples before migration.')
codeunit_files=sorted([os.path.join('src/codeunit',x) for x in os.listdir('src/codeunit') if x.lower().endswith('.al')])
for file in codeunit_files:
    proc=procedures(file)
    if not proc: continue
    name=os.path.basename(file)
    story.append(p('%s - %s' % (module_for_codeunit(name),name),'H2x'))
    story.append(t(['Line','Source procedure','Visibility','Next.js logic transfer'],[[line,func,vis,procedure_transfer(func)] for line,func,vis in proc],[14*mm,62*mm,22*mm,84*mm]))
    story.append(Spacer(1,3*mm))
story.append(PageBreak())

story += h('17. Complete source-field dictionary', 'Every declared field in the 163 custom tables and 24 table extensions is included. “Target type” is suggested PostgreSQL storage; it is not a direction to copy display-only or calculated values without normalization.')
for title,file in all_field_sources():
    rows=fields(file)
    if not rows: continue
    story.append(p(title,'H2x'))
    r=[]
    for name,al,pg in rows:
        r.append([name,al,pg,role_for(name)])
    story.append(t(['Source field','AL type','Target type','Use / classification'],r,[47*mm,33*mm,42*mm,52*mm]))
    story.append(Spacer(1,3*mm))
story += [p('Implementation note: field dictionaries document the supplied source’s declared data. Before database migration, run a formal mapping workshop to identify deprecated fields, derived FlowFields, duplicated display values, sensitive fields and mandatory historical records. The target model should not copy every display field where it can reliably be obtained via a foreign key/read model.', 'Warn')]

doc=SimpleDocTemplate(OUT,pagesize=A4,leftMargin=18*mm,rightMargin=18*mm,topMargin=17*mm,bottomMargin=20*mm,title='Nation CBS Complete Next.js Techno-functional Specification',author='Codex')
doc.build(story,onFirstPage=footer,onLaterPages=footer)
print(OUT)

report 52203553 "Payroll GrossNet Pay II"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Payroll GrossNet Pay II.rdlc';

    dataset
    {
        dataitem("Payroll Period Transaction"; "Payroll Period Transaction")
        {
            DataItemTableView = WHERE("Transaction Code"=CONST('GPAY'));
            RequestFilterFields = "Global Dimension 1 Code", "Global Dimension 2 Code", "Payroll Period";

            column(USERID; UserId)
            {
            }
            column(TODAY; Today)
            {
            }
            column(PeriodName; PeriodName)
            {
            }
            column(CurrReport_PAGENO; CurrReport.PageNo)
            {
            }
            column(companyinfo_Picture; companyinfo.Picture)
            {
            }
            column(companyinfoName; companyinfo.Name)
            {
            }
            column(ReportFilters; ReportFilters)
            {
            }
            column(JobTitle; JobTitle)
            {
            }
            column(JobDescription; JobDescription)
            {
            }
            column(EmployeeCode_PayrollPeriodTransaction; "Payroll Period Transaction"."Employee Code")
            {
            }
            column(TransactionCode_PayrollPeriodTransaction; "Payroll Period Transaction"."Transaction Code")
            {
            }
            column(GroupText_PayrollPeriodTransaction; "Payroll Period Transaction"."Group Text")
            {
            }
            column(TransactionName_PayrollPeriodTransaction; "Payroll Period Transaction"."Transaction Name")
            {
            }
            column(Amount_PayrollPeriodTransaction; "Payroll Period Transaction".Amount)
            {
            }
            column(Balance_PayrollPeriodTransaction; "Payroll Period Transaction".Balance)
            {
            }
            column(OriginalAmount_PayrollPeriodTransaction; "Payroll Period Transaction"."Original Amount")
            {
            }
            column(GroupOrder_PayrollPeriodTransaction; "Payroll Period Transaction"."Group Order")
            {
            }
            column(SubGroupOrder_PayrollPeriodTransaction; "Payroll Period Transaction"."Sub Group Order")
            {
            }
            column(PeriodMonth_PayrollPeriodTransaction; "Payroll Period Transaction"."Period Month")
            {
            }
            column(PeriodYear_PayrollPeriodTransaction; "Payroll Period Transaction"."Period Year")
            {
            }
            column(PeriodFilter_PayrollPeriodTransaction; "Payroll Period Transaction"."Period Filter")
            {
            }
            column(PayrollPeriod_PayrollPeriodTransaction; "Payroll Period Transaction"."Payroll Period")
            {
            }
            column(Membership_PayrollPeriodTransaction; "Payroll Period Transaction".Membership)
            {
            }
            column(ReferenceNo_PayrollPeriodTransaction; "Payroll Period Transaction"."Reference No")
            {
            }
            column(DepartmentCode_PayrollPeriodTransaction; "Payroll Period Transaction"."Department Code")
            {
            }
            column(Lumpsumitems_PayrollPeriodTransaction; "Payroll Period Transaction".Lumpsumitems)
            {
            }
            column(TravelAllowance_PayrollPeriodTransaction; "Payroll Period Transaction".TravelAllowance)
            {
            }
            column(GLAccount_PayrollPeriodTransaction; "Payroll Period Transaction"."GL Account")
            {
            }
            column(CompanyDeduction_PayrollPeriodTransaction; "Payroll Period Transaction"."Company Deduction")
            {
            }
            column(EmpAmount_PayrollPeriodTransaction; "Payroll Period Transaction"."Emp Amount")
            {
            }
            column(EmpBalance_PayrollPeriodTransaction; "Payroll Period Transaction"."Emp Balance")
            {
            }
            column(JournalAccountCode_PayrollPeriodTransaction; "Payroll Period Transaction"."Journal Account Code")
            {
            }
            column(JournalAccountType_PayrollPeriodTransaction; "Payroll Period Transaction"."Journal Account Type")
            {
            }
            column(PostAs_PayrollPeriodTransaction; "Payroll Period Transaction"."Post As")
            {
            }
            column(LoanNumber_PayrollPeriodTransaction; "Payroll Period Transaction"."Loan Number")
            {
            }
            column(coopparameters_PayrollPeriodTransaction; "Payroll Period Transaction"."Coop Parameters")
            {
            }
            column(PayrollCode_PayrollPeriodTransaction; "Payroll Period Transaction"."Payroll Code")
            {
            }
            column(PaymentMode_PayrollPeriodTransaction; "Payroll Period Transaction"."Payment Mode")
            {
            }
            column(LocationDivision_PayrollPeriodTransaction; "Payroll Period Transaction"."Location/Division")
            {
            }
            column(Department_PayrollPeriodTransaction; "Payroll Period Transaction".Department)
            {
            }
            column(CostCentre_PayrollPeriodTransaction; "Payroll Period Transaction"."Cost Centre")
            {
            }
            column(SalaryGrade_PayrollPeriodTransaction; "Payroll Period Transaction"."Salary Grade")
            {
            }
            column(SalaryNotch_PayrollPeriodTransaction; "Payroll Period Transaction"."Salary Notch")
            {
            }
            column(PayslipOrder_PayrollPeriodTransaction; "Payroll Period Transaction"."Payslip Order")
            {
            }
            column(NoOfUnits_PayrollPeriodTransaction; "Payroll Period Transaction"."No. Of Units")
            {
            }
            column(EmployeeClassification_PayrollPeriodTransaction; "Payroll Period Transaction"."Employee Classification")
            {
            }
            column(State_PayrollPeriodTransaction; "Payroll Period Transaction".State)
            {
            }
            column(NewDepartmentalCode_PayrollPeriodTransaction; "Payroll Period Transaction"."New Departmental Code")
            {
            }
            column(grants_PayrollPeriodTransaction; "Payroll Period Transaction".grants)
            {
            }
            column(BankCode_PayrollPeriodTransaction; "Payroll Period Transaction"."Bank Code")
            {
            }
            column(BranchCode_PayrollPeriodTransaction; "Payroll Period Transaction"."Branch Code")
            {
            }
            column(ACNumber_PayrollPeriodTransaction; "Payroll Period Transaction"."A/C Number")
            {
            }
            column(BankDetails_PayrollPeriodTransaction; "Payroll Period Transaction"."Bank Details")
            {
            }
            column(BranchDetails_PayrollPeriodTransaction; "Payroll Period Transaction"."Branch Details")
            {
            }
            column(EmpStatus_PayrollPeriodTransaction; "Payroll Period Transaction"."Emp Status")
            {
            }
            // column(PostToProgramm_PayrollPeriodTransaction;"Payroll Period Transaction"."Post To Programm")
            // {
            // }
            // column(PostToDepartment_PayrollPeriodTransaction;"Payroll Period Transaction"."Post To Department")
            // {
            // }
            // column(PostToGLAccount_PayrollPeriodTransaction;"Payroll Period Transaction"."Post To G/L Account")
            // {
            // }
            column(GlobalDimension1Code_PayrollPeriodTransaction; "Payroll Period Transaction"."Global Dimension 1 Code")
            {
            }
            column(GlobalDimension2Code_PayrollPeriodTransaction; "Payroll Period Transaction"."Global Dimension 2 Code")
            {
            }
            column(ContractType_PayrollPeriodTransaction; "Payroll Period Transaction"."Contract Type")
            {
            }
            column(TransactionType_PayrollPeriodTransaction; "Payroll Period Transaction"."Transaction Type")
            {
            }
            column(PostingGroup_PayrollPeriodTransaction; "Payroll Period Transaction"."Posting Group")
            {
            }
            column(StaffName_PayrollPeriodTransaction; "Payroll Period Transaction"."Staff Name")
            {
            }
            column(PostToJournal_PayrollPeriodTransaction; "Payroll Period Transaction"."Post To Journal")
            {
            }
            column(P10AllowanceType_PayrollPeriodTransaction; "Payroll Period Transaction"."P10 Allowance Type")
            {
            }
            column(PaymentHeld_PayrollPeriodTransaction; "Payroll Period Transaction"."Payment Held")
            {
            }
            column(AmountHeld_PayrollPeriodTransaction; "Payroll Period Transaction"."Amount Held")
            {
            }
            column(ReasonForHold_PayrollPeriodTransaction; "Payroll Period Transaction"."Reason For Hold")
            {
            }
            column(PostIn_PayrollPeriodTransaction; "Payroll Period Transaction"."Post In")
            {
            }
            column(Subledger_PayrollPeriodTransaction; "Payroll Period Transaction".Subledger)
            {
            }
            column(ImprestNo_PayrollPeriodTransaction; "Payroll Period Transaction"."Imprest No")
            {
            }
            trigger OnAfterGetRecord()
            begin
                JobTitle:='';
                JobDescription:='';
                if Employee.Get("Payroll Period Transaction"."Employee Code")then begin
                    JobTitle:=Employee."Job Title";
                    JobDescription:=Employee."Job Title";
                end;
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                field(SelectedPeriod; SelectedPeriod)
                {
                    Caption = 'Selected Period';
                    TableRelation = "Payroll Periods";
                }
                field("Include Inactive Employees"; IncludeInactiveEmployees)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Program"; Programm)
                {
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
                }
                field(Department; Department)
                {
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        objPeriod.Reset;
        objPeriod.SetRange(objPeriod."Start Date", SelectedPeriod);
        if objPeriod.Find('-')then begin
            PeriodName:=objPeriod."Period Name";
        end;
        if companyinfo.Get()then companyinfo.CalcFields(companyinfo.Picture);
        ReportFilters:="Payroll Period Transaction".GetFilters();
        if ReportFilters = '' then ReportFilters:='None';
    end;
    var Employee: Record Employee;
    objPeriod: Record "Payroll Periods";
    SelectedPeriod: Date;
    PeriodName: Text[30];
    companyinfo: Record "Company Information";
    IncludeInactiveEmployees: Boolean;
    ReportFilters: Text;
    Programm: Code[50];
    Department: Code[50];
    JobTitle: Code[20];
    JobDescription: Text;
}

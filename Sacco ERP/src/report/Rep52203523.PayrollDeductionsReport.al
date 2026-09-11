report 52203523 "Payroll Deductions Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Payroll Deductions Report.rdlc';

    dataset
    {
        dataitem("Payroll Period Transaction"; "Payroll Period Transaction")
        {
            DataItemTableView = SORTING("Group Order", "Transaction Code", "Period Month", "Period Year", Membership, "Reference No", "Department Code")WHERE("Group Text"=FILTER('DEDUCTIONS'), "Transaction Type"=CONST(Deduction));
            RequestFilterFields = "Payroll Period", "Employee Code", "Transaction Code", "Posting Group", "Global Dimension 1 Code", "Global Dimension 2 Code";

            column(CompanyName; CompanyInformation.Name)
            {
            }
            column(CompanyPicture; CompanyInformation.Picture)
            {
            }
            column(CompanyAddress; CompanyInformation.Address)
            {
            }
            column(CompanyPhone; CompanyInformation."Phone No.")
            {
            }
            column(CompanyLocation; CompanyInformation.Location)
            {
            }
            column(CompanyEmail; CompanyInformation."E-Mail")
            {
            }
            column(CompanyWebsite; CompanyInformation."Home Page")
            {
            }
            column(AppliedFilters; AppliedFilters)
            {
            }
            column(CompanyPostCode; CompanyInformation."Post Code")
            {
            }
            column(GlobalDimension2Code_PayrollPeriodTransaction; "Payroll Period Transaction"."Global Dimension 2 Code")
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
            column(GlobalDimension1Code_PayrollPeriodTransaction; "Payroll Period Transaction"."Global Dimension 1 Code")
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
            column(DepartmentName; DepartmentName)
            {
            }
            trigger OnAfterGetRecord()
            begin
                DimensionValue.Reset;
                DimensionValue.SetRange(Code, "Payroll Period Transaction"."Global Dimension 1 Code");
                if DimensionValue.FindFirst then DepartmentName:=DimensionValue.Name;
            end;
            trigger OnPreDataItem()
            begin
                if "Payroll Period Transaction".GetFilter("Payroll Period Transaction"."Payroll Period") = '' then Error('You must specify the payroll period');
                AppliedFilters:="Payroll Period Transaction".GetFilters;
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
            }
        }
    }
    trigger OnPreReport()
    begin
        CompanyInformation.Get;
        CompanyInformation.CalcFields(Picture);
    end;
    var LastFieldNo: Integer;
    FooterPrinted: Boolean;
    TotalFor: Label 'Total for ';
    PeriodTrans: Record "Payroll Period Transaction";
    GroupOrder: Label '3';
    objPeriod: Record "Payroll Periods";
    SelectedPeriod: Date;
    PeriodName: Text[30];
    CompanyInfo: Record "Company Information";
    TotalsAllowances: Decimal;
    Dept: Boolean;
    Allowances_ReportCaptionLbl: Label 'Allowances Report';
    User_Name_CaptionLbl: Label 'User Name:';
    Print_Date_CaptionLbl: Label 'Print Date:';
    Period_CaptionLbl: Label 'Period:';
    Page_No_CaptionLbl: Label 'Page No:';
    Transaction_Name_CaptionLbl: Label 'Transaction Name:';
    Period_Amount_CaptionLbl: Label 'Period Amount:';
    Prepared_by_______________________________________Date_________________CaptionLbl: Label 'Prepared by……………………………………………………..                 Date……………………………………………';
    Checked_by________________________________________Date_________________CaptionLbl: Label 'Checked by…………………………………………………..                   Date……………………………………………';
    Authorized_by____________________________________Date_________________CaptionLbl: Label 'Authorized by……………………………………………………..              Date……………………………………………';
    Approved_by______________________________________Date_________________CaptionLbl: Label 'Approved by……………………………………………………..                Date……………………………………………';
    Employees: Record Employee;
    EmployeeName: Text[100];
    CI: Record "Company Information";
    IDNumber: Code[30];
    CompanyInformation: Record "Company Information";
    DepartmentName: Text;
    DimensionValue: Record "Dimension Value";
    AppliedFilters: Text;
}

report 52203540 "Payroll Costing Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Payroll Costing Report.rdlc';

    dataset
    {
        dataitem("Payroll Period Transaction"; "Payroll Period Transaction")
        {
            RequestFilterFields = "Employee Code", "Transaction Code", "Payroll Period", "Global Dimension 1 Code";

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
            column(CompanyPostCode; CompanyInformation."Post Code")
            {
            }
            column(JobTitle; JobTitle)
            {
            }
            column(JobGroup; JobGroup)
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
            column(HoldPayment_PayrollPeriodTransaction; "Payroll Period Transaction"."Payment Held")
            {
            }
            trigger OnAfterGetRecord()
            begin
                JobGroup:='';
                JobTitle:='';
                if Employee.Get("Payroll Period Transaction"."Employee Code")then begin
                    JobGroup:=Employee."Job Scale";
                    JobTitle:=Employee."Job Title";
                end;
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
                if "Payroll Period Transaction".GetFilter("Payroll Period Transaction"."Payroll Period") = '' then if "Payroll Period Transaction".GetFilter("Payroll Period Transaction"."Transaction Code") = '' then Error('You must specify the transaction type');
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    JobTitle: Code[50];
    JobGroup: Code[20];
    Employee: Record Employee;
}

report 52203542 "Payroll Summary-Fin"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Payroll Summary-Fin.rdlc';

    dataset
    {
        dataitem("Payroll Periods"; "Payroll Periods")
        {
            RequestFilterFields = "Start Date";

            column(PeriodMonth_PayrollPeriod; "Payroll Periods"."Period Month")
            {
            }
            column(PeriodYear_PayrollPeriod; "Payroll Periods"."Period Year")
            {
            }
            column(PeriodName_PayrollPeriod; "Payroll Periods"."Period Name")
            {
            }
            column(DateOpened_PayrollPeriod; "Payroll Periods"."Start Date")
            {
            }
            column(DateClosed_PayrollPeriod; "Payroll Periods"."Closed On")
            {
            }
            column(Closed_PayrollPeriod; "Payroll Periods".Closed)
            {
            }
            column(ClosedBy_PayrollPeriod; "Payroll Periods"."Closed By")
            {
            }
            column(OpenedBy_PayrollPeriod; "Payroll Periods"."Opened By")
            {
            }
            column(CompanyName; CompanyInformation.Name)
            {
            }
            column(CompanyAddress; CompanyInformation.Address)
            {
            }
            column(CompanyCity; CompanyInformation.City)
            {
            }
            column(CompanyPhoneNo; CompanyInformation."Phone No.")
            {
            }
            column(CompanyPicture; CompanyInformation.Picture)
            {
            }
            column(CompanyPostCode; CompanyInformation."Post Code")
            {
            }
            column(CompanyFaxNo; CompanyInformation."Fax No.")
            {
            }
            column(CompanyWedAddress; CompanyInformation."Home Page")
            {
            }
            column(CompanyPhoneNo2; CompanyInformation."Phone No. 2")
            {
            }
            column(CompanyCounty; CompanyInformation.County)
            {
            }
            column(CompanyEmail; CompanyInformation."E-Mail")
            {
            }
            dataitem("Payroll Period Transaction"; "Payroll Period Transaction")
            {
                DataItemLink = "Payroll Period"=FIELD("Start Date");
                DataItemTableView = WHERE("Transaction Type"=FILTER(Deduction|Income));

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
                column(EmpName; EmpName)
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
                trigger OnAfterGetRecord()
                begin
                    EmpName:='';
                    if EmployeesHR.Get("Payroll Period Transaction"."Employee Code")then EmpName:=EmployeesHR."First Name" + ' ' + EmployeesHR."Middle Name" + ' ' + EmployeesHR."Last Name";
                end;
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    EmployeesHR: Record Employee;
    EmpName: Text;
}

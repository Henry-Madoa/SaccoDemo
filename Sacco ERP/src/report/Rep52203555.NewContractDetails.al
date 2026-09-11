report 52203555 "New Contract Details"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/New Contract Details.rdl';

    dataset
    {
        dataitem("Employee Change Request"; "Employee Change Request")
        {
            DataItemTableView = WHERE("Nature of Change"=CONST("New Contract"));

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
            dataitem("Contract Change Lines"; "Contract Change Lines")
            {
                DataItemLink = "Change No"=FIELD("No."), "Employee No"=FIELD("Employee No");

                column(EmployeeNo_ContractChangeLines; "Contract Change Lines"."Employee No")
                {
                }
                column(EmployeeName_ContractChangeLines; "Contract Change Lines"."Employee Name")
                {
                }
                column(ContractCode_ContractChangeLines; "Contract Change Lines"."Contract Code")
                {
                }
                column(ContractDescription_ContractChangeLines; "Contract Change Lines"."Contract Description")
                {
                }
                column(ContractPeriod_ContractChangeLines; "Contract Change Lines"."Contract Period")
                {
                }
                column(ContractStartDate_ContractChangeLines; "Contract Change Lines"."Contract Start Date")
                {
                }
                column(ContractEndDate_ContractChangeLines; "Contract Change Lines"."Contract End Date")
                {
                }
                column(JobTitle_ContractChangeLines; "Contract Change Lines"."Job Title")
                {
                }
                column(Grade_ContractChangeLines; "Contract Change Lines".Grade)
                {
                }
                column(LineNo_ContractChangeLines; "Contract Change Lines"."Line No")
                {
                }
                column(CurrentContract_ContractChangeLines; "Contract Change Lines"."Current Contract")
                {
                }
                column(NoticePeriod_ContractChangeLines; "Contract Change Lines"."Notice Period")
                {
                }
                column(Salary_ContractChangeLines; "Contract Change Lines".Salary)
                {
                }
                column(LineManager_ContractChangeLines; "Contract Change Lines"."Line Manager")
                {
                }
                column(ManagerName_ContractChangeLines; "Contract Change Lines"."Manager Name")
                {
                }
                column(Department_ContractChangeLines; "Contract Change Lines".Department)
                {
                }
                column(ContractStatus_ContractChangeLines; "Contract Change Lines"."Contract Status")
                {
                }
                column(Pointer_ContractChangeLines; "Contract Change Lines".Pointer)
                {
                }
                column(EmployeeTitle_ContractChangeLines; "Contract Change Lines"."Employee Title")
                {
                }
                column(ChangeNo_ContractChangeLines; "Contract Change Lines"."Change No")
                {
                }
                column(Status_ContractChangeLines; "Contract Change Lines".Status)
                {
                }
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.GET;
                CompanyInformation.CALCFIELDS(Picture);
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    PeriodYear: Integer;
    GratuityAmount: Decimal;
    PayrollPeriods: Record "Payroll Periods";
    PayrollPeriodTransaction: Record "Payroll Period Transaction";
}

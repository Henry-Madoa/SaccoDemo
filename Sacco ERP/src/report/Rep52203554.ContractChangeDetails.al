report 52203554 "Contract Change Details"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Contract Change Details.rdl';

    dataset
    {
        dataitem("Employee Change Request"; "Employee Change Request")
        {
            DataItemTableView = WHERE("Nature of Change"=CONST("Contract Renewal"));

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
                DataItemLink = "Change No"=FIELD("No."), "Employee No"=field("Employee No");

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
                column(Department_ContractChangeLines; DepartmentName)
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
            dataitem(Employee; Employee)
            {
                DataItemLink = "No."=FIELD("Employee No");

                column(GlobalDimension1Code_Employee; Employee."Global Dimension 1 Code")
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if DimValue.Get('DEPARTMENT', Employee."Global Dimension 1 Code")then DepartmentName:=DimValue.Name;
                end;
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
    DepartmentName: Text;
    DimValue: Record "Dimension Value";
}

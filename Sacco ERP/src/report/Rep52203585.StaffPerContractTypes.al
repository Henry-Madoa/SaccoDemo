report 52203585 "Staff Per Contract Types"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Staff Per Contract Types.rdl';

    dataset
    {
        dataitem(Employee; Employee)
        {
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
            column(GratuityAmount; GratuityAmount)
            {
            }
            column(FullName_Employee; Employee.FullName)
            {
            }
            column(No_Employee; Employee."No.")
            {
            }
            column(EmplymtContractCode_Employee; Employee."Emplymt. Contract Code")
            {
            }
            column(ContractStartDate_Employee; Employee."Contract Start Date")
            {
            }
            column(ContractEndDate_Employee; Employee."Contract End Date")
            {
            }
            column(Gender_Employee; Employee.Gender)
            {
            }
            column(DepartmentName; DepartmentName)
            {
            }
            column(BranchName; BranchName)
            {
            }
            dataitem("Employee Contract Details"; "Employee Contract Details")
            {
                DataItemLink = "Employee No"=FIELD("No.");
                DataItemTableView = WHERE("Contract Status"=CONST(Active));

                column(EmployeeNo_EmployeeContractDetails; "Employee Contract Details"."Employee No")
                {
                }
                column(EmployeeName_EmployeeContractDetails; "Employee Contract Details"."Employee Name")
                {
                }
                column(ContractCode_EmployeeContractDetails; "Employee Contract Details"."Contract Code")
                {
                }
                column(ContractDescription_EmployeeContractDetails; "Employee Contract Details"."Contract Description")
                {
                }
                column(ContractPeriod_EmployeeContractDetails; "Employee Contract Details"."Contract Period")
                {
                }
                column(ContractStartDate_EmployeeContractDetails; "Employee Contract Details"."Contract Start Date")
                {
                }
                column(ContractEndDate_EmployeeContractDetails; "Employee Contract Details"."Contract End Date")
                {
                }
                column(GrantDetails; GrantDetails)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    GrantDetails:='';
                    EmployeeDonorsVar.RESET;
                    EmployeeDonorsVar.SETRANGE("Contract Code", "Employee Contract Details"."Contract Code");
                    EmployeeDonorsVar.SETRANGE("Contract Line No", "Employee Contract Details"."Line No");
                    EmployeeDonorsVar.SETRANGE("Grant Status", EmployeeDonorsVar."Grant Status"::Active);
                    IF EmployeeDonorsVar.FINDSET THEN BEGIN
                        GrantDetails:='';
                        REPEAT GrantDetails+=EmployeeDonorsVar."Donor Code" + ' : ' + FORMAT(EmployeeDonorsVar.Percentage) + '% & ';
                        UNTIL EmployeeDonorsVar.NEXT = 0;
                        IF GrantDetails <> '' THEN GrantDetails:=DELSTR(GrantDetails, STRLEN(GrantDetails) - 1, 1);
                    end;
                end;
            }
            trigger OnAfterGetRecord()
            begin
                if DimValue.Get('DEPARTMENT', Employee."Global Dimension 1 Code")then DepartmentName:=DimValue.Name;
                if DimValue.Get('BRANCH', Employee."Global Dimension 1 Code")then BranchName:=DimValue.Name;
            end;
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
    GrantDetails: Text;
    EmployeeDonorsVar: Record "Employee Donors";
    DepartmentName: Text;
    BranchName: Text;
    DimValue: Record "Dimension Value";
}

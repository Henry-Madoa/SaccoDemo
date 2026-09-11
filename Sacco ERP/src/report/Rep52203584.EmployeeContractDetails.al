report 52203584 "Employee Contract Details"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Employee Contract Details.rdl';

    dataset
    {
        dataitem("Employee Contract Details"; "Employee Contract Details")
        {
            DataItemTableView = WHERE("Contract Status"=CONST(Active));
            RequestFilterFields = "Employee No", "Contract Code", "Contract Start Date", "Contract End Date";

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
            column(CompanyLocation; CompanyInformation."Location Code")
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
            column(GrantDetails; GrantDetails)
            {
            }
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
            column(JobTitle_EmployeeContractDetails; "Employee Contract Details"."Job Title")
            {
            }
            column(Grade_EmployeeContractDetails; "Employee Contract Details".Grade)
            {
            }
            column(LineNo_EmployeeContractDetails; "Employee Contract Details"."Line No")
            {
            }
            column(CurrentContract_EmployeeContractDetails; "Employee Contract Details"."Current Contract")
            {
            }
            column(NoticePeriod_EmployeeContractDetails; "Employee Contract Details"."Notice Period")
            {
            }
            column(Salary_EmployeeContractDetails; "Employee Contract Details".Salary)
            {
            }
            column(LineManager_EmployeeContractDetails; "Employee Contract Details"."Line Manager")
            {
            }
            column(ManagerName_EmployeeContractDetails; "Employee Contract Details"."Manager Name")
            {
            }
            column(Department_EmployeeContractDetails; DepartmentName)
            {
            }
            column(ContractStatus_EmployeeContractDetails; "Employee Contract Details"."Contract Status")
            {
            }
            column(Pointer_EmployeeContractDetails; "Employee Contract Details".Pointer)
            {
            }
            column(EmployeeTitle_EmployeeContractDetails; "Employee Contract Details"."Employee Title")
            {
            }
            column(ReportFilters; ReportFilters)
            {
            }
            dataitem(Employee; Employee)
            {
                DataItemLink = "No."=FIELD("Employee No");

                column(GlobalDimension5Code_Employee; Employee."Global Dimension 5 Code")
                {
                }
                column(Gender_Employee; Employee.Gender)
                {
                }
                column(CostCenterCode_Employee; Employee."Cost Center Code")
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if DimValue.Get('DEPARTMENT', Employee."Global Dimension 1 Code")then DepartmentName:=DimValue.Name;
                end;
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
            trigger OnPreDataItem()
            begin
                CompanyInformation.GET;
                CompanyInformation.CALCFIELDS(Picture);
                ReportFilters:="Employee Contract Details".GETFILTERS;
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    ReportFilters: Text;
    GrantDetails: Text;
    EmployeeDonorsVar: Record "Employee Donors";
    DepartmentName: Text;
    DimValue: Record "Dimension Value";
}

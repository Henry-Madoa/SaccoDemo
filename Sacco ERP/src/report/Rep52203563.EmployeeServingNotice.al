report 52203563 "Employee Serving Notice"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Employee Serving Notice.rdl';

    dataset
    {
        dataitem(Employee; Employee)
        {
            DataItemTableView = WHERE("Employee Status"=CONST(Active));
            RequestFilterFields = "No.", "Employment Date", Title;

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
            column(Division; Division)
            {
            }
            column(Department; Department)
            {
            }
            column(Section; Section)
            {
            }
            column(Unit; Unit)
            {
            }
            column(Service_Period_Employee; Employee."Service Period")
            {
            }
            column(Notice_Period_Employee; Employee."Notice Period")
            {
            }
            column(ServingNotice_Employee; Employee."Serving Notice")
            {
            }
            column(DateServingNotice_Employee; Employee."Contract Start Date")
            {
            }
            column(EndofNotice_Employee; Employee."Contract End Date")
            {
            }
            column(No_Employee; Employee."No.")
            {
            }
            column(FullName_Employee; Employee.FullName)
            {
            }
            column(EmploymentDate_Employee; Employee."Employment Date")
            {
            }
            column(NationalID_Employee; Employee."National ID")
            {
            }
            column(SHIFNumber_Employee; Employee."SHIF No.")
            {
            }
            column(NSSFNumber_Employee; Employee."NSSF No.")
            {
            }
            column(KRANumber_Employee; Employee."KRA Number")
            {
            }
            column(ReportFilters; ReportFilters)
            {
            }
            column(Grade_Employee; Employee."Job Scale")
            {
            }
            column(Pointer_Employee; Employee."J-G Steps")
            {
            }
            column(GlobalDimension2Code_Employee; Employee."Global Dimension 2 Code")
            {
            }
            column(ContractStartDate_Employee; Employee."Contract Start Date")
            {
            }
            column(ContractEndDate_Employee; Employee."Contract End Date")
            {
            }
            column(CostCenterCode_Employee; Employee."Cost Center Code")
            {
            }
            column(PayrollScale_Employee; Employee."Job Scale")
            {
            }
            column(JobDescription_Employee; Employee."Job Title")
            {
            }
            column(Gender_Employee; Employee.Gender)
            {
            }
            column(Supervisor; Supervisor)
            {
            }
            column(TypeofEmployee_Employee; Employee."Type of Employee")
            {
            }
            column(EmployeeCategory_Employee; Employee."Employee Category")
            {
            }
            column(EmplymtContractCode_Employee; Employee."Emplymt. Contract Code")
            {
            }
            column(GrantApproverName_Employee; Employee."Grant Approver Name")
            {
            }
            column(LineManagerName_Employee; Employee."Line Manager Name")
            {
            }
            column(OverviewManagerName_Employee; Employee."Overview Manager Name")
            {
            }
            column(GlobalDimension5Code_Employee; Employee."Global Dimension 5 Code")
            {
            }
            trigger OnAfterGetRecord()
            begin
                Supervisor:='';
                IF EmployeeRec.GET(Employee."Manager No.")THEN Supervisor:=EmployeeRec.FullName;
                Division:='';
                Department:='';
                Section:='';
                Unit:='';
                DimensionValue.RESET;
                DimensionValue.SETRANGE("Dimension Code", 'DIVISION');
                DimensionValue.SETRANGE(Code, Employee."Global Dimension 1 Code");
                IF DimensionValue.FINDFIRST THEN Division:=DimensionValue.Name;
                DimensionValue.RESET;
                DimensionValue.SETRANGE("Dimension Code", 'DEPARTMENT');
                DimensionValue.SETRANGE(Code, Employee."Global Dimension 2 Code");
                IF DimensionValue.FINDFIRST THEN Department:=DimensionValue.Name;
                DimensionValue.RESET;
                DimensionValue.SETRANGE("Dimension Code", 'SECTIONS');
                DimensionValue.SETRANGE(Code, Employee."Global Dimension 3 Code");
                IF DimensionValue.FINDFIRST THEN Section:=DimensionValue.Name;
                DimensionValue.RESET;
                DimensionValue.SETRANGE("Dimension Code", 'UNIT');
                DimensionValue.SETRANGE(Code, Employee."Global Dimension 4 Code");
                IF DimensionValue.FINDFIRST THEN Unit:=DimensionValue.Name;
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.GET;
                CompanyInformation.CALCFIELDS(Picture);
                ReportFilters:=Employee.GETFILTERS;
            end;
        }
    }
    trigger OnPreReport()
    begin
        ReportFilters:=Employee.GETFILTERS;
    end;
    var CompanyInformation: Record "Company Information";
    ReportFilters: Text;
    Supervisor: Text;
    EmployeeRec: Record Employee;
    Division: Text;
    Department: Text;
    Section: Text;
    Unit: Text;
    DimensionValue: Record "Dimension Value";
}

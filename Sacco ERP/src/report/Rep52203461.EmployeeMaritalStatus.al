report 52203461 "Employee Marital Status"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Employee Marital Status.rdlc';

    dataset
    {
        dataitem(Employee; Employee)
        {
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
            column(MaritalStatus_Employee; Employee."Marital Status")
            {
            }
            trigger OnAfterGetRecord()
            begin
                Supervisor:='';
                IF EmployeeRec.GET(Employee."Manager No.")THEN Supervisor:=EmployeeRec.FullName;
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
}

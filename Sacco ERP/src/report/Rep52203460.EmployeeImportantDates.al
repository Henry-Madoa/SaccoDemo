report 52203460 "Employee Important Dates"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Employee Important Dates.rdl';

    dataset
    {
        dataitem(Employee; Employee)
        {
            RequestFilterFields = "No.", "Employment Date";

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
            column(BirthDate_Employee; Employee."Birth Date")
            {
            }
            column(YearsToRetirement; YearsToRetirement)
            {
            }
            column(Age; Age)
            {
            }
            column(ServicePeriod_Employee; Employee."Service Period")
            {
            }
            column(CostCenterCode_Employee; Employee."Cost Center Code")
            {
            }
            column(ContractStartDate_Employee; Employee."Contract Start Date")
            {
            }
            column(ContractEndDate_Employee; Employee."Contract End Date")
            {
            }
            column(JobDescription_Employee; Employee."Job Title")
            {
            }
            column(EmplymtContractCode_Employee; Employee."Emplymt. Contract Code")
            {
            }
            column(GlobalDimension2Code_Employee; Employee."Global Dimension 2 Code")
            {
            }
            column(Department_Employee; DepartmentName)
            {
            }
            column(PayrollScale_Employee; Employee."Job Scale")
            {
            }
            column(Gender_Employee; Employee.Gender)
            {
            }
            column(GlobalDimension5Code_Employee; Employee."Global Dimension 5 Code")
            {
            }
            trigger OnAfterGetRecord()
            begin
                if DimValue.Get('DEPARTMENT', Employee."Global Dimension 1 Code")then DepartmentName:=DimValue.Name;
                YearsToRetirement:='';
                Age:='';
                IF Employee."Birth Date" <> 0D THEN BEGIN
                    Age:=HRDates.DetermineDatesDiffrence(Employee."Birth Date", TODAY);
                    HumanResSetup.GET();
                    HumanResSetup.TESTFIELD("Retirement Age");
                    YearsToRetirement:=HRDates.DetermineDatesDiffrence(TODAY, CALCDATE(HumanResSetup."Retirement Age", "Birth Date"));
                end;
                IF Employee."Employment Date" <> 0D THEN BEGIN
                    Employee."Service Period":=HRDates.DetermineDatesDiffrence(Employee."Employment Date", TODAY);
                    Employee.MODIFY(TRUE);
                end;
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.GET;
                CompanyInformation.CALCFIELDS(Picture);
            end;
        }
    }
    trigger OnPreReport()
    begin
        ReportFilters:=Employee.GETFILTERS;
    end;
    var CompanyInformation: Record "Company Information";
    ReportFilters: Text;
    HRDates: Codeunit "HR Dates";
    YearsToRetirement: Text;
    Age: Text;
    HumanResourceCommentLine: Record "Human Resource Comment Line";
    HumanResSetup: Record "Human Resources Setup";
    VacantPosisiton: Integer;
    DepartmentName: Text;
    DimValue: Record "Dimension Value";
}

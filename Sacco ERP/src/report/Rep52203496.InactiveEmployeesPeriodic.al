report 52203496 "Inactive Employees (Periodic)"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Inactive Employees (Periodic).rdl';

    dataset
    {
        dataitem(Employee; Employee)
        {
            DataItemTableView = where("Employee Status"=filter(<>Active));

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
            column(Employee_Status_Employee; Employee."Employee Status")
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
            column(Start_Date; StartDate)
            {
            }
            column(End_Date; EndDate)
            {
            }
            column(ReportFilters; ReportFilters)
            {
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
                If((StartDate <> 0D) and (EndDate <> 0D))then Employee.SetRange("Date of Leaving", StartDate, EndDate);
                ReportFilters:=Employee.GETFILTERS;
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                field("Start Date"; StartDate)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("End Date"; EndDate)
                {
                    trigger OnValidate()
                    begin
                        if EndDate <> 0D then begin
                            if StartDate = 0D then Error('Start date must have a value');
                            if EndDate < StartDate then Error('End date cannot be less than start date');
                        end;
                    end;
                }
            }
        }
    }
    var CompanyInformation: Record "Company Information";
    ReportFilters: Text;
    StartDate: Date;
    EndDate: Date;
}

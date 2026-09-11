report 52203493 "Employement List (Periodic)"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Employement List (Periodic).rdlc';

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
            column(Start_Date; StartDate)
            {
            }
            column(End_Date; EndDate)
            {
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
                if StartDate = 0D then Error('End date must have a value');
                Employee.SetRange("Employment Date", StartDate, EndDate);
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
    StartDate: Date;
    EndDate: Date;
}

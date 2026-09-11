report 52203435 "Employee Emergency Contacts"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Employee Emergency Contacts.rdl';

    dataset
    {
        dataitem(Employee; Employee)
        {
            RequestFilterFields = "No.";

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
            dataitem("Next Of  Kin Details"; "Employee Relative")
            {
                DataItemLink = "Employee No."=FIELD("No.");

                column(No_NextOfKinDetails; "Next Of  Kin Details"."Line No.")
                {
                }
                column(EmployeeNo_NextOfKinDetails; "Next Of  Kin Details"."Employee No.")
                {
                }
                column(FirstName_NextOfKinDetails; "Next Of  Kin Details"."First Name")
                {
                }
                column(MiddleName_NextOfKinDetails; "Next Of  Kin Details"."Middle Name")
                {
                }
                column(LastName_NextOfKinDetails; "Next Of  Kin Details"."Last Name")
                {
                }
                column(FullName_NextOfKinDetails; "Next Of  Kin Details"."First Name" + ' ' + "Next Of  Kin Details"."Middle Name" + ' ' + "Next Of  Kin Details"."Last Name")
                {
                }
                column(IDBirthCertificateNo_NextOfKinDetails; "Next Of  Kin Details"."ID/Birth Certificate No.")
                {
                }
                column(DateofBirth_NextOfKinDetails; "Next Of  Kin Details"."Date of Birth")
                {
                }
                column(PhoneNo_NextOfKinDetails; "Next Of  Kin Details"."Phone No.")
                {
                }
                column(EmailAddress_NextOfKinDetails; "Next Of  Kin Details"."Email Address")
                {
                }
                column(Entitlement_NextOfKinDetails; "Next Of  Kin Details".Entitlement)
                {
                }
                column(Relationship_NextOfKinDetails; "Next Of  Kin Details"."Relative Code")
                {
                }
                column(Gender_NextOfKinDetails; "Next Of  Kin Details".Gender)
                {
                }
                column(Age_NextOfKinDetails; "Next Of  Kin Details".Age)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if "Next Of  Kin Details"."Birth Date" <> 0D then begin
                        "Next Of  Kin Details".Age:=HRDates.DetermineDatesDiffrence("Next Of  Kin Details"."Birth Date", Today);
                        "Next Of  Kin Details".Modify(true);
                    end;
                end;
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
            }
        }
    }
    var CompanyInformation: Record "Company Information";
    StartDate: Date;
    EndDate: Date;
    HRDates: Codeunit "HR Dates";
}

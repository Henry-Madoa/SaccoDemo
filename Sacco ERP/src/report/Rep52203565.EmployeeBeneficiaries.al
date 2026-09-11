report 52203565 "Employee Beneficiaries"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Employee Beneficiaries.rdl';

    dataset
    {
        dataitem(Employee; Employee)
        {
            PrintOnlyIfDetail = true;
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
            dataitem("Employee Beneficiaries"; "Employee Beneficiaries")
            {
                DataItemLink = "Employee No."=FIELD("No.");

                column(No_EmployeeBeneficiaries; "Employee Beneficiaries"."No.")
                {
                }
                column(EmployeeNo_EmployeeBeneficiaries; "Employee Beneficiaries"."Employee No.")
                {
                }
                column(FullNames_EmployeeBeneficiaries; "Employee Beneficiaries"."Full Names")
                {
                }
                column(IDBirthCertificateNo_EmployeeBeneficiaries; "Employee Beneficiaries"."ID/Birth Certificate No.")
                {
                }
                column(DateofBirth_EmployeeBeneficiaries; "Employee Beneficiaries"."Date of Birth")
                {
                }
                column(PhoneNo_EmployeeBeneficiaries; "Employee Beneficiaries"."Phone No.")
                {
                }
                column(EmailAddress_EmployeeBeneficiaries; "Employee Beneficiaries"."Email Address")
                {
                }
                column(Entitlement_EmployeeBeneficiaries; "Employee Beneficiaries".Entitlement)
                {
                }
                column(Relationship_EmployeeBeneficiaries; "Employee Beneficiaries".Relationship)
                {
                }
                column(Gender_EmployeeBeneficiaries; "Employee Beneficiaries".Gender)
                {
                }
                column(Beneficiary_EmployeeBeneficiaries; "Employee Beneficiaries".Beneficiary)
                {
                }
                column(Percentage_EmployeeBeneficiaries; "Employee Beneficiaries".Percentage)
                {
                }
                column(Comments_EmployeeBeneficiaries; "Employee Beneficiaries".Comments)
                {
                }
                column(Age_EmployeeBeneficiaries; "Employee Beneficiaries".Age)
                {
                }
                column(Type_EmployeeBeneficiaries; "Employee Beneficiaries".Type)
                {
                }
                column(EmploymentDate_EmployeeBeneficiaries; "Employee Beneficiaries"."Employment Date")
                {
                }
                column(Grade_EmployeeBeneficiaries; "Employee Beneficiaries".Grade)
                {
                }
                column(EmployeeGender_EmployeeBeneficiaries; "Employee Beneficiaries"."Employee Gender")
                {
                }
                trigger OnAfterGetRecord()
                begin
                    IF "Employee Beneficiaries"."Date of Birth" <> 0D THEN BEGIN
                        "Employee Beneficiaries".Age:=HRDates.DetermineDatesDiffrence("Employee Beneficiaries"."Date of Birth", TODAY);
                        "Employee Beneficiaries".MODIFY(TRUE);
                    end;
                end;
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.GET;
                CompanyInformation.CALCFIELDS(Picture);
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

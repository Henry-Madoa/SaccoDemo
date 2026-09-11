report 52203598 "Driver Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Driver Report.rdlc';

    dataset
    {
        dataitem("Motor Vehicle Drivers Data"; "Motor Vehicle Drivers Data")
        {
            column(CompanyInformationName; CompanyInformation.Name)
            {
            }
            column(CompanyInformationAddress; CompanyInformation.Address)
            {
            }
            column(CompanyInformationAddress2; CompanyInformation."Address 2")
            {
            }
            column(CompanyInformationCity; CompanyInformation.City)
            {
            }
            column(CompanyInformationPicture; CompanyInformation.Picture)
            {
            }
            column(CompanyInformationCountryRegionCode; CompanyInformation."Country/Region Code")
            {
            }
            column(CompanyInformationPhoneNo; CompanyInformation."Phone No.")
            {
            }
            column(CompanyInformationEMail; CompanyInformation."E-Mail")
            {
            }
            column(CompanyInformationHomePage; CompanyInformation."Home Page")
            {
            }
            column(EmploymentNo_MotorVehicleDriversData; "Motor Vehicle Drivers Data"."Employment No.")
            {
            }
            column(FirstName_MotorVehicleDriversData; "Motor Vehicle Drivers Data"."First Name")
            {
            }
            column(MiddleName_MotorVehicleDriversData; "Motor Vehicle Drivers Data"."Middle Name")
            {
            }
            column(LastName_MotorVehicleDriversData; "Motor Vehicle Drivers Data"."Last Name")
            {
            }
            column(IDNo_MotorVehicleDriversData; "Motor Vehicle Drivers Data"."ID No.")
            {
            }
            column(DOB_MotorVehicleDriversData; "Motor Vehicle Drivers Data"."D.O.B")
            {
            }
            column(DrivingLicenseNo_MotorVehicleDriversData; "Motor Vehicle Drivers Data"."Driving License No.")
            {
            }
            column(DrivingLicenseIssueDate_MotorVehicleDriversData; "Motor Vehicle Drivers Data"."Driving License Issue Date")
            {
            }
            column(DrivingLicenseExpiryDate_MotorVehicleDriversData; "Motor Vehicle Drivers Data"."Driving License Expiry Date")
            {
            }
            column(DrivingLicenseType_MotorVehicleDriversData; "Motor Vehicle Drivers Data"."Driving License Type")
            {
            }
            column(DateofEmployment_MotorVehicleDriversData; "Motor Vehicle Drivers Data"."Date of Employment")
            {
            }
            column(LicenseUseDuration_MotorVehicleDriversData; "Motor Vehicle Drivers Data"."License Use Duration")
            {
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
        }
        actions
        {
        }
    }
    labels
    {
    }
    var CompanyInformation: Record "Company Information";
}

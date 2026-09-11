report 52203593 "Vehicle Maintenance Exp Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Vehicle Maintenance Exp Report.rdlc';

    dataset
    {
        dataitem("Motor Vehicle Ledger"; "Motor Vehicle Ledger")
        {
            DataItemTableView = WHERE("Transaction Type"=CONST(Maintenance));

            column(EntryNo_MotorVehicleLedger; "Motor Vehicle Ledger"."Entry No")
            {
            }
            column(PostingDate_MotorVehicleLedger; "Motor Vehicle Ledger"."Posting Date")
            {
            }
            column(TransactionType_MotorVehicleLedger; "Motor Vehicle Ledger"."Transaction Type")
            {
            }
            column(DocumentNo_MotorVehicleLedger; "Motor Vehicle Ledger"."Document No.")
            {
            }
            column(PostingDescription_MotorVehicleLedger; "Motor Vehicle Ledger"."Posting Description")
            {
            }
            column(Amount_MotorVehicleLedger; "Motor Vehicle Ledger".Amount)
            {
            }
            column(AmountLCY_MotorVehicleLedger; "Motor Vehicle Ledger"."Amount (LCY)")
            {
            }
            column(VehicleREGNo_MotorVehicleLedger; "Motor Vehicle Ledger"."Vehicle REG. No")
            {
            }
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

report 52203574 "Contract Status Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Contract Status Report.rdlc';

    dataset
    {
        dataitem("Contract Header"; "Contract Header")
        {
            RequestFilterFields = "Contract Status", "Tender Amount", "Vendor No.", "Requisition No", "Contract Start Date", "Contract period";

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
            column(No_ContractHeader; "Contract Header"."No.")
            {
            }
            column(VendorNo_ContractHeader; "Contract Header"."Vendor No.")
            {
            }
            column(TenderNo_ContractHeader; "Contract Header"."Tender No.")
            {
            }
            column(TenderTitle_ContractHeader; "Contract Header"."Tender Title")
            {
            }
            column(AgreementDate_ContractHeader; "Contract Header"."Agreement Date")
            {
            }
            column(ContractStartDate_ContractHeader; "Contract Header"."Contract Start Date")
            {
            }
            column(Contractperiod_ContractHeader; "Contract Header"."Contract period")
            {
            }
            column(ContractEndDate_ContractHeader; "Contract Header"."Contract End Date")
            {
            }
            column(TenderAmount_ContractHeader; "Contract Header"."Tender Amount")
            {
            }
            column(ContractStatus_ContractHeader; "Contract Header"."Contract Status")
            {
            }
            column(Vendor_Name; VendorName)
            {
            }
            trigger OnAfterGetRecord()
            begin
                if Vendor.Get("Contract Header"."Vendor No.")then VendorName:=Vendor.Name;
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    Vendor: Record Vendor;
    VendorName: Text[50];
}

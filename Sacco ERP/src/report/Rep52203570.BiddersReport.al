report 52203570 "Bidders Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Bidders Report.rdlc';

    dataset
    {
        dataitem("Tender Suppliers"; "Tender Suppliers")
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
            column(SupplierNo_TenderSuppliers; "Tender Suppliers"."Supplier No.")
            {
            }
            column(ReferenceNo_TenderSuppliers; "Tender Suppliers"."Reference No")
            {
            }
            column(VendorName_TenderSuppliers; "Tender Suppliers"."Vendor Name")
            {
            }
            column(Adress_TenderSuppliers; "Tender Suppliers".Adress)
            {
            }
            column(PostCode_TenderSuppliers; "Tender Suppliers"."Post Code")
            {
            }
            column(City_TenderSuppliers; "Tender Suppliers".City)
            {
            }
            column(PhysicalLocation_TenderSuppliers; "Tender Suppliers"."Physical Location")
            {
            }
            column(EmailAddress_TenderSuppliers; "Tender Suppliers"."Email Address")
            {
            }
            column(ContactPersonName_TenderSuppliers; "Tender Suppliers"."Contact Person Name")
            {
            }
            column(ContactPersonPhoneNo_TenderSuppliers; "Tender Suppliers"."Contact Person Phone No.")
            {
            }
            column(ContactPersonEmail_TenderSuppliers; "Tender Suppliers"."Contact Person E-mail")
            {
            }
            column(BidAmount_TenderSuppliers; "Tender Suppliers"."Bid Amount")
            {
            }
            column(SecurityBidAmount_TenderSuppliers; "Tender Suppliers"."Security Bid Amount")
            {
            }
            column(TechnicalScore_TenderSuppliers; "Tender Suppliers"."Technical Score")
            {
            }
            column(PassedMandatory_TenderSuppliers; "Tender Suppliers"."Passed Mandatory")
            {
            }
            column(PassedTechnical_TenderSuppliers; "Tender Suppliers"."Passed Technical")
            {
            }
            column(Awarded_TenderSuppliers; "Tender Suppliers".Awarded)
            {
            }
            column(FinancialScore_TenderSuppliers; "Tender Suppliers"."Financial Score")
            {
            }
            column(TotalScore_TenderSuppliers; "Tender Suppliers"."Total Score")
            {
            }
            column(Tender_Title; TenderTitle)
            {
            }
            trigger OnAfterGetRecord()
            begin
                if ProcurementRequest.Get("Tender Suppliers"."Reference No")then begin
                    TenderTitle:=ProcurementRequest.Description;
                end;
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    ProcurementRequest: Record "Procurement Request";
    TenderTitle: Text[50];
}

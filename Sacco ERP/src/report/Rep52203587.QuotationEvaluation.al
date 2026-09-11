report 52203587 "Quotation Evaluation"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Quotation Evaluation.rdlc';

    dataset
    {
        dataitem("Quotation Vendors Bids"; "Quotation Vendors Bids")
        {
            RequestFilterFields = "Quote No";

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
            column(QuoteNo_QuotationVendorsBids; "Quotation Vendors Bids"."Quote No")
            {
            }
            column(VendorNo_QuotationVendorsBids; "Quotation Vendors Bids"."Vendor No")
            {
            }
            column(VendorName_QuotationVendorsBids; "Quotation Vendors Bids"."Vendor Name")
            {
            }
            column(LineNo_QuotationVendorsBids; "Quotation Vendors Bids"."Line No")
            {
            }
            column(ItemNo_QuotationVendorsBids; "Quotation Vendors Bids"."Item No")
            {
            }
            column(ItemName_QuotationVendorsBids; "Quotation Vendors Bids"."Item Name")
            {
            }
            column(QuotedAmount_QuotationVendorsBids; "Quotation Vendors Bids"."Quoted Amount")
            {
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
}

report 52203575 "Quotations Per Supplier"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Quotations Per Supplier.rdlc';

    dataset
    {
        dataitem("Procurement Request"; "Procurement Request")
        {
            DataItemTableView = WHERE("Procurement Method"=CONST(RFQ));
            PrintOnlyIfDetail = true;

            column(TotalAmount_ProcurementRequest; "Procurement Request"."Total Amount")
            {
            }
            column(No_ProcurementRequest; "Procurement Request"."No.")
            {
            }
            column(RequisitonNo_ProcurementRequest; "Procurement Request"."Requisiton No")
            {
            }
            column(SupplierCategory_ProcurementRequest; "Procurement Request"."Supplier Category")
            {
            }
            dataitem("Procurement Request Lines"; "Procurement Request Lines")
            {
                DataItemLink = "Procurement No"=FIELD("No.");
                RequestFilterFields = "Vendor To Award";

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
                column(Vendor_Name; VendorName)
                {
                }
                column(VendorToAward_ProcurementRequestLines; "Procurement Request Lines"."Vendor To Award")
                {
                }
                column(TotalAmount_ProcurementRequestLines; "Procurement Request Lines"."Total Amount")
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if Vendor.Get("Procurement Request Lines"."Vendor To Award")then VendorName:=Vendor.Name;
                end;
                trigger OnPreDataItem()
                begin
                    CompanyInformation.Get;
                    CompanyInformation.CalcFields(Picture);
                end;
            }
        }
    }
    var CompanyInformation: Record "Company Information";
    Vendor: Record Vendor;
    VendorName: Text;
}

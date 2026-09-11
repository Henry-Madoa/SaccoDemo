report 52203569 "Bidders Awarded"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Bidders Awarded.rdlc';

    dataset
    {
        dataitem("Procurement Request"; "Procurement Request")
        {
            PrintOnlyIfDetail = true;

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
            column(SupplierCategory_ProcurementRequest; "Procurement Request"."Supplier Category")
            {
            }
            column(DateAwarded_ProcurementRequest; "Procurement Request"."Date Awarded")
            {
            }
            dataitem("Procurement Request Lines"; "Procurement Request Lines")
            {
                DataItemLink = "Procurement No"=FIELD("No.");

                column(No_ProcurementRequestLines; "Procurement Request Lines"."No.")
                {
                }
                column(Name_ProcurementRequestLines; "Procurement Request Lines".Name)
                {
                }
                column(Description_ProcurementRequestLines; "Procurement Request Lines".Description)
                {
                }
                column(Quantity_ProcurementRequestLines; "Procurement Request Lines".Quantity)
                {
                }
                column(UnitPrice_ProcurementRequestLines; "Procurement Request Lines"."Unit Price")
                {
                }
                column(TotalAmount_ProcurementRequestLines; "Procurement Request Lines"."Total Amount")
                {
                }
                column(UnitofMeasure_ProcurementRequestLines; "Procurement Request Lines"."Unit of Measure")
                {
                }
                column(VendorToAward_ProcurementRequestLines; "Procurement Request Lines"."Vendor To Award")
                {
                }
                column(TenderWinner_ProcurementRequestLines; "Procurement Request Lines"."Tender Winner")
                {
                }
                column(Supplier; Vendor1)
                {
                }
                column(Supplier_Name; Vendor1Name)
                {
                }
                column(DateofPrequalification; DateofPrequalification)
                {
                }
                column(Dateofaward; DateofAward)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    Vendor1:='';
                    Vendor1Name:='';
                    if Vendor.Get("Procurement Request Lines"."Vendor To Award")then begin
                        Vendor1Name:=Vendor.Name;
                        Vendor1:="Procurement Request Lines"."Vendor To Award";
                        DateofPrequalification:=Vendor."Registration Date";
                    end;
                    if Vendor1 = '' then begin
                        if Vendor.Get("Procurement Request Lines"."Tender Winner")then begin
                            Vendor1Name:=Vendor.Name;
                            Vendor1:="Procurement Request Lines"."Tender Winner";
                            DateofPrequalification:=Vendor."Registration Date";
                        end;
                    end;
                    if Vendor1 = '' then CurrReport.Skip;
                end;
            }
            trigger OnAfterGetRecord()
            begin
                case "Procurement Request"."Procurement Method" of "Procurement Request"."Procurement Method"::"Open Tendering": begin
                    Vendor1:="Procurement Request"."Vendor No";
                end;
                "Procurement Request"."Procurement Method"::"Restricted Tendering": begin
                    Vendor1:="Procurement Request"."Vendor No";
                end;
                "Procurement Request"."Procurement Method"::"Direct Procurement": begin
                    Vendor1:="Procurement Request"."Vendor No";
                end;
                "Procurement Request"."Procurement Method"::RFP: begin
                    Vendor1:="Procurement Request"."Vendor No";
                end;
                "Procurement Request"."Procurement Method"::RFQ: begin
                    Vendor1:="Procurement Request"."Vendor No";
                end;
                "Procurement Request"."Procurement Method"::"Low Value Procurement": begin
                    Vendor1:="Procurement Request"."Vendor No";
                end;
                end;
                if Vendor.Get(Vendor1)then begin
                    Vendor1Name:=Vendor.Name;
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
    QuotationBidders: Record "Quotation Bidders";
    QuotationVendorsBids: Record "Quotation Vendors Bids";
    SupplierApplication: Record "Supplier Application";
    Vendor1: Code[10];
    Vendor: Record Vendor;
    Vendor1Name: Text;
    QuoteperBid: Decimal;
    DateofPrequalification: Date;
    DateofAward: Date;
}

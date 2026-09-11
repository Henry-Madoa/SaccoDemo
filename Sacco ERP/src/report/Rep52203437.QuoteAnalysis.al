report 52203437 "Quote Analysis"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Quote Analysis.rdlc';

    dataset
    {
        dataitem("RFQ Lines"; "RFQ Lines")
        {
            RequestFilterFields = "RFQ No";

            column(Logo; CompInfo.Picture)
            {
            }
            column(Logo2; CompInfo.Picture2)
            {
            }
            column(Watermark; AdvancedFinanceSetup."Watermark Portrait")
            {
            }
            column(CompName; CompInfo.Name)
            {
            }
            column(CompAddress; CompInfo.Address)
            {
            }
            column(CompAddress2; CompInfo."Address 2")
            {
            }
            column(CompCity; CompInfo.City)
            {
            }
            column(CompPhone; CompInfo."Phone No.")
            {
            }
            column(CompCountry; CompInfo."Country/Region Code")
            {
            }
            column(RFQNo; "RFQ Lines"."RFQ No")
            {
            }
            column(Type; "RFQ Lines".Type)
            {
            }
            column(No; "RFQ Lines".No)
            {
            }
            column(Description; "RFQ Lines".Description)
            {
            }
            column(UoM; "RFQ Lines"."Unit of Measure")
            {
            }
            column(Quantity; "RFQ Lines".Quantity)
            {
            }
            dataitem("Purchase Line"; "Purchase Line")
            {
                DataItemLink = "RFQ No"=FIELD("RFQ No"), Type=FIELD(Type), "No."=FIELD(No);

                /*DataItemTableView = SORTING("Unit Cost") ORDER(Ascending);*/
                column(VendorName; VendorName)
                {
                }
                column(Item; "Purchase Line".Description)
                {
                }
                column(Qty; "Purchase Line".Quantity)
                {
                }
                column(Cost; "Purchase Line"."Unit Cost")
                {
                }
                column(Total; "Purchase Line".Amount)
                {
                }
                column(SelectedText; SelectedText)
                {
                }
                column(IndicatorValue; IndicatorValue)
                {
                }
                column(Recomm; StrSubstNo(RecommendationText, SmallestBidVendor))
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if VendorRec.Get("Purchase Line"."Buy-from Vendor No.")then VendorName:=VendorRec.Name;
                    SN:=SN + 1;
                    if SN = 1 then SelectedText:=VendorName
                    else
                        SelectedText:='';
                    if SN = 1 then IndicatorValue:=10
                    else if SN = 2 then IndicatorValue:=50
                        else
                            IndicatorValue:=100; //
                end;
            }
            trigger OnAfterGetRecord()
            begin
                SN:=0;
                IndicatorValue:=0;
                RFQVendor.Reset;
                RFQVendor.SetRange("RFQ No", "RFQ Lines"."RFQ No");
                if RFQVendor.FindFirst then begin
                    RFQVendor.CalcFields(Total);
                    SmallestBid:=RFQVendor.Total;
                    SmallestBidVendor:=RFQVendor.Name;
                    RFQVendor2.Reset;
                    RFQVendor2.SetRange("RFQ No", RFQVendor."RFQ No");
                    if RFQVendor2.Find('-')then begin
                        repeat RFQVendor2.CalcFields(Total);
                            if RFQVendor2.Total < SmallestBid then begin
                                SmallestBid:=RFQVendor2.Total;
                                SmallestBidVendor:=RFQVendor2.Name;
                            end;
                            SmallestBid:=SmallestBid;
                        until RFQVendor2.Next = 0;
                    end;
                end;
            end;
        }
    }
    trigger OnPreReport()
    begin
        CompInfo.Get;
        CompInfo.CalcFields(Picture);
        CompInfo.CalcFields(Picture2);
        AdvancedFinanceSetup.Get;
    //AdvancedFinanceSetup.CALCFIELDS("Watermark Portrait");
    end;
    var VendorRec: Record Vendor;
    VendorName: Text;
    SN: Integer;
    SelectedText: Text;
    CompInfo: Record "Company Information";
    IndicatorValue: Integer;
    Total: Decimal;
    RFQVendor: Record "RFQ Vendors";
    SmallestBid: Decimal;
    SmallestBidVendor: Text;
    RFQVendor2: Record "RFQ Vendors";
    RecommendationText: Label 'Based on Price, %1 has been Recommended on this Bid Analysis';
    AdvancedFinanceSetup: Record "General Ledger Setup";
}

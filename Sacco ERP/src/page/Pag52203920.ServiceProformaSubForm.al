page 52203920 "Service Proforma SubForm"
{
    ApplicationArea = All;
    AutoSplitKey = true;
    PageType = ListPart;
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';
    SourceTable = "Service Proforma Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Item No"; Rec."Item No")
                {
                    ApplicationArea = All;
                }
                field("Item Name"; Rec."Item Name")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                }
                field(Sundries; Rec.Sundries)
                {
                    ApplicationArea = All;
                }
                field("Discount %"; Rec."Discount %")
                {
                    ApplicationArea = All;
                }
                field("VAT %"; Rec."VAT %")
                {
                    ApplicationArea = All;
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
    }
    trigger OnAfterGetCurrRecord()
    begin
        CalculateTotals;
    end;
    trigger OnModifyRecord(): Boolean begin
        CalculateTotals;
    end;
    var ServiceProformaCard: Page "Service Proforma Card";
    local procedure CalculateTotals()
    var
        ServiceProformaHeader: Record "Service Proforma Header";
        ServiceProformaLine: Record "Service Proforma Line";
        AmountTotal: Decimal;
        SundriesTotal: Decimal;
    begin
        ServiceProformaLine.Reset;
        ServiceProformaLine.SetRange("Document No.", Rec."Document No.");
        if ServiceProformaLine.FindSet then begin
            ServiceProformaLine.CalcSums("Total Amount", Sundries);
            AmountTotal:=ServiceProformaLine."Total Amount";
            SundriesTotal:=ServiceProformaLine.Sundries;
            ServiceProformaHeader.Reset;
            ServiceProformaHeader.SetRange("No.", ServiceProformaLine."Document No.");
            if ServiceProformaHeader.FindFirst then begin
                ServiceProformaHeader."Total Amount":=AmountTotal;
                ServiceProformaHeader."Total Sundries":=SundriesTotal;
                ServiceProformaHeader."Total Amount + Sundries":=ServiceProformaHeader."Total Amount" + ServiceProformaHeader."Total Sundries";
            //ServiceProformaHeader.MODIFY(TRUE);
            end;
        end;
    end;
}

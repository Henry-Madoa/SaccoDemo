page 52203837 "Vendor Quoted Amount Per Item"
{
    PageType = List;
    SourceTable = "Quotation Vendors Bids";
    SourceTableView = SORTING("Quoted Amount")ORDER(Ascending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Vendor No"; Rec."Vendor No")
                {
                    ApplicationArea = All;
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
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
                field("Quoted Amount"; Rec."Quoted Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("VAT Inclusive"; Rec."VAT Inclusive")
                {
                    ApplicationArea = All;
                }
                field("VAT Amount"; Rec."VAT %")
                {
                    ApplicationArea = All;
                    Caption = 'VAT Amount';
                }
                field("Committee Selection Count"; Rec."Committee Selection Count")
                {
                    ApplicationArea = All;
                }
                field("Lead Time"; Rec."Lead Time")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Quote No"; Rec."Quote No")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Line No"; Rec."Line No")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Populate Item Lines")
            {
                ApplicationArea = All;
                Image = GetLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    QuotationVendorsBids.Reset;
                    QuotationVendorsBids.SetRange("Quote No", Rec."Quote No");
                    QuotationVendorsBids.SetRange("Vendor No", Rec."Vendor No");
                    if QuotationVendorsBids.FindFirst then begin
                        if not Confirm('There are entries in the document that will be reset. Do you want to continue?')then exit;
                        QuotationVendorsBids.DeleteAll;
                    end;
                    QuotationBidders.Reset;
                    QuotationBidders.SetRange("Reference No", QuotationVendorsBids."Quote No");
                    QuotationBidders.SetRange("Vendor No.", QuotationVendorsBids."Vendor No");
                    if QuotationBidders.FindFirst then begin
                        repeat ProcurementRequestLines.Reset;
                            ProcurementRequestLines.SetRange("Procurement No", Rec."Quote No");
                            if ProcurementRequestLines.FindFirst then begin
                                repeat QuotationVendorsBids.Init;
                                    QuotationVendorsBids."Line No":=ProcurementRequestLines."Line No.";
                                    QuotationVendorsBids."Quote No":=Rec."Quote No";
                                    QuotationVendorsBids."Vendor No":=QuotationBidders."Vendor No.";
                                    QuotationVendorsBids.Validate("Vendor No");
                                    QuotationVendorsBids."Item No":=ProcurementRequestLines."No.";
                                    QuotationVendorsBids.Validate("Item No");
                                    QuotationVendorsBids.Description:=CopyStr(ProcurementRequestLines.Description, 1, 250);
                                    QuotationVendorsBids.Quantity:=ProcurementRequestLines.Quantity;
                                    QuotationVendorsBids.Insert;
                                until ProcurementRequestLines.Next = 0;
                            end;
                        until QuotationBidders.Next = 0;
                    end;
                end;
            }
        }
    }
    var ProcurementRequest: Record "Procurement Request";
    QuoteAmountEditable: Boolean;
    QuotationVendorsBids: Record "Quotation Vendors Bids";
    ProcurementRequestLines: Record "Procurement Request Lines";
    QuotationBidders: Record "Quotation Bidders";
    local procedure IanSetControlAppearance()
    begin
        if ProcurementRequest.Get(Rec."Quote No")then begin
            if not(ProcurementRequest."Quotation Status" in[ProcurementRequest."Quotation Status"::"Quote Submission"])then QuoteAmountEditable:=false
            else
                QuoteAmountEditable:=true;
        end;
    end;
}

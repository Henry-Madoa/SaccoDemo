page 52203550 "RFQ Vendors"
{
    PageType = List;
    SourceTable = "RFQ Vendors";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Vendor No"; Rec."Vendor No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Competency; Rec.Competency)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Capacity; Rec.Capacity)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Commitment; Rec.Commitment)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Control; Rec.Control)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Cash Resources"; Rec."Cash Resources")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Cost; Rec.Cost)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Consistency; Rec.Consistency)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Generate Quote")
            {
                ApplicationArea = Basic, Suite;
                Image = Quote;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    QuoteVendors: Record "RFQ Vendors";
                begin
                    CurrPage.SetSelectionFilter(Rec);
                    repeat ProcurementManagement.GenerateQuote(Rec."RFQ No", Rec."Vendor No");
                    until QuoteVendors.Next = 0;
                end;
            }
            action("View Quote")
            {
                ApplicationArea = Basic, Suite;
                Image = View;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    CurrPage.SetSelectionFilter(Rec);
                    if Rec.Find('-')then begin
                        repeat if QuoteRec.Get(QuoteRec."Document Type"::Quote, Rec."Quote No")then PAGE.Run(49, QuoteRec)
                            else
                                Error('A quote has not been generated for %1', Rec.Name);
                        until Rec.Next = 0;
                    end;
                end;
            }
        }
    }
    var ProcurementManagement: Codeunit "Procurement Management";
    QuoteRec: Record "Purchase Header";
}

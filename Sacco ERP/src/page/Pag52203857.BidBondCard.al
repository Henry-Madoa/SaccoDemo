page 52203857 "Bid Bond Card"
{
    ApplicationArea = All;
    PageType = Card;
    SourceTable = "Tender Bid Bonds";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Tender No."; Rec."Tender No.")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if xRec."Tender No." <> Rec."Tender No." then Error('Kindly Create another Bid Bond Instead of Amending this');
                    end;
                }
                field("Tender Status"; Rec."Tender Status")
                {
                    ApplicationArea = All;
                }
            }
            part(Control10; "Tender Bidders-Bond")
            {
                ApplicationArea = All;
                SubPageLink = "Reference No"=FIELD("Tender No.");
            }
        }
    }
    actions
    {
        area(creation)
        {
            action("Report")
            {
                Image = "Report";
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.Reset;
                    Rec.SetFilter("Tender No.", Rec."Tender No.");
                    REPORT.Run(53029, true, true, Rec);
                end;
            }
        }
    }
}

page 52204215 "Share Floating Lines"
{
    PageType = ListPart;
    SourceTable = "Share Trading Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Member No."; Rec."Member No.")
                {
                    Style = Favorable;
                    StyleExpr = IsAwarded;
                }
                field("Member Name"; Rec."Member Name")
                {
                    Style = Favorable;
                    StyleExpr = IsAwarded;
                }
                field("Bid Price"; Rec."Bid Price")
                {
                    Style = Favorable;
                    StyleExpr = IsAwarded;
                }
                field("Account No"; Rec."Account No")
                {
                    Style = Favorable;
                    StyleExpr = IsAwarded;
                }
                field("Account Balance"; Rec."Account Balance")
                {
                    Style = Favorable;
                    StyleExpr = IsAwarded;
                }
                field(Awarded; Rec.Awarded)
                {
                    Style = Favorable;
                    StyleExpr = IsAwarded;
                }
                field(Shares; Rec.Shares)
                {
                    Style = Favorable;
                    StyleExpr = IsAwarded;
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    Style = Unfavorable;
                    StyleExpr = IsBought;
                }
                field(Bought; Rec.Bought)
                {
                    Style = Unfavorable;
                    StyleExpr = IsBought;
                }
                field("Bid Date"; Rec."Bid Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Minimum Balance"; Rec."Minimum Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Charges; Rec.Charges)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        IsAwarded := Rec.Awarded;
        IsBought := Rec.Bought;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        IsAwarded := Rec.Awarded;
        IsBought := Rec.Bought;
    end;

    var
        IsAwarded: Boolean;
        IsBought: Boolean;
}

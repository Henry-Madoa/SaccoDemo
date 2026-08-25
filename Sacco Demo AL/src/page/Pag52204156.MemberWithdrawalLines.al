page 52204156 "Member Withdrawal Lines"
{
    PageType = ListPart;
    SourceTable = "Member Withdrawal Lines";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Account No"; Rec."Account No")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field(Balance; Rec.Balance)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Amount (Base)"; Rec."Amount (Base)")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Share Capital"; Rec."Share Capital")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Accrued Interest"; Rec."Accrued Interest")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
            }
        }
    }
    var
        StyleText: Text[20];

    trigger OnAfterGetRecord()
    begin
        case Rec."Entry Type" of
            Rec."Entry Type"::Asset:
                StyleText := 'StrongAccent';
            Rec."Entry Type"::Liability:
                StyleText := 'Unfavorable';
            else
                StyleText := 'StandardAccent';
        end;
    end;
}

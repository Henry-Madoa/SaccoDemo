page 52204232 "ATM Transactions"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "ATM Transactions";
    SourceTableView = sorting("Entry No.") order(descending) where(Posted = const(false));
    InsertAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                    Editable = false;
                }
                field("ATM Card No"; MemberMgt.MaskCardNo(Rec."Card No"))
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                    Editable = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                    Editable = false;
                }
                field("Reference No"; Rec."Reference No")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                    Editable = false;
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                    Editable = false;
                }
                field("Transaction Name"; Rec."Transaction Name")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Account No"; Rec."Account No")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                    Editable = false;
                }
                field("Member No"; Rec."Member No")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                    Editable = false;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                    Editable = false;
                }
                field("Device Type"; Rec."Device Type")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                    Editable = false;
                }
                field(Location; Rec.Location)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                    Editable = false;
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                    Editable = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                    Editable = false;
                }
                field("Posting Time"; Rec."Posting Time")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                    Editable = false;
                }
                field(Reversed; Rec.Reversal)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Reversed Posted"; Rec."Reversed Posted")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                    Editable = false;
                }
                field("Transaction Date"; Rec."Transaction Date")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                    Editable = false;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Post ATM Transaction")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = UpdateDescription;

                trigger OnAction()
                var
                    ATMIntegration: Codeunit "ATM Integration";
                begin
                    ATMIntegration.PostATMTransactions;
                end;
            }
            action("Post ATM Reversals")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = UpdateDescription;

                trigger OnAction()
                var
                    ATMIntegration: Codeunit "ATM Integration";
                begin
                    ATMIntegration.PostATMReversals;
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        StyleText := '';
        if Rec.Posted = true then
            StyleText := 'Subordinate'
        else begin
            case Rec."Posting Type" of
                Rec."Posting Type"::Debit:
                    StyleText := 'Strong';
                Rec."Posting Type"::Credit:
                    StyleText := 'Favourable';
                else
                    StyleText := 'Ambigous';
            end;
        end;
    end;

    var
        StyleText: Text[100];
        MemberMgt: Codeunit "Member Management";
}

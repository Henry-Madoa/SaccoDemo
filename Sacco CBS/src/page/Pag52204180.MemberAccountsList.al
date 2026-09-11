page 52204180 "Member Accounts List"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = Vendor;
    InsertAllowed = false;
    DeleteAllowed = false;
    CardPageId = "Member Account Card";
    SourceTableView = where("Account Type" = filter(Sacco | loan));

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Member No."; Rec."Member No.")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Paybill Business Account No."; Rec."Paybill Business Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field(Balance; Rec.Balance)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Account Class"; Rec."Product Posting Type")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Product Code"; Rec."Product Code")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Card No"; MemberMgt.MaskCardNo(Rec."Card No"))
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
            }
        }
        area(FactBoxes)
        {
            part(Statistics; "Account Statistics")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "No." = field("No.");
            }
        }
    }
    var
        StyleText: Text[100];
        MemberMgt: Codeunit "Member Management";

    trigger OnAfterGetRecord()
    begin
        if Rec."Product Posting Type" = Rec."Product Posting Type"::"Loan Account" then
            StyleText := 'Ambiguous'
        else if Rec."Product Posting Type" = Rec."Product Posting Type"::"Fixed Deposit Account" then
            StyleText := 'StrongAccent'
        else
            StyleText := 'Favorable';
    end;
}

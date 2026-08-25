page 52204231 "Member Accounts Balances"
{
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Member Accounts Balances";
    SourceTableView = sorting("Entry No.") order(descending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member No."; Rec."Member No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Product Code"; Rec."Product Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Already Posted"; Rec."Already Posted")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posted Amount"; Rec."Posted Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Update Account Balances")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = UpdateDescription;

                trigger OnAction()
                var
                    MemberMgt: Codeunit "Member Management";
                begin
                    MemberMgt.UpdateMembersAccountsOpeningBalances;
                end;
            }
            action("Check Posting")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = PostedDeposit;

                trigger OnAction()
                var
                    MemberMgt: Codeunit "Member Management";
                begin
                    MemberMgt.CheckPosting;
                end;
            }
            action("Check Posted Amount")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = PostedDeposit;
                Visible = false;

                trigger OnAction()
                var
                    MemberMgt: Codeunit "Member Management";
                begin
                    MemberMgt.CheckPostedAmount;
                end;
            }
        }
    }
}

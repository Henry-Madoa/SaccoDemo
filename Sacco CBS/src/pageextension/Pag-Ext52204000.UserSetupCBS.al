pageextension 52204000 "User Setup CBS" extends "User Setup"
{
    layout
    {
        // Add changes to page layout here
        addafter("Approver ID")
        {
            field(Substitute; Rec.Substitute)
            {
                ApplicationArea = Basic, Suite;
            }
        }
        addafter("Payroll Admin")
        {
            field("Mobile Limit Notifications"; Rec."Mobile Limit Notifications")
            {
                ApplicationArea = Basic, Suite;
            }
            field("View Protected Account"; Rec."View Protected Account")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Can M-Allocate"; Rec."Can M-Allocate")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Can Run Penalty"; Rec."Can Run Penalty")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Can Update Debt Collector"; Rec."Can Update Debt Collector")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Can Update Subscriptions"; Rec."Can Update Subscriptions")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Can Use General Journal"; Rec."Can Use General Journal")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Can Overdraw Account"; Rec."Can Overdraw Account")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Can Auto Reverse"; Rec."Can Auto Reverse")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Can Transfer To Other Members"; Rec."Can Transfer To Other Members")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Member Accounts Blocking"; Rec."Member Accounts Blocking")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Can Unblock Mobile Banking"; Rec."Can Unblock Mobile Banking")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Mark Receipt Posted"; Rec."Mark Receipt Posted")
            {
                ApplicationArea = Basic, Suite;
            }
            field("View ATM Cards"; Rec."View ATM Cards")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Can Suspend Interest"; Rec."Can Suspend Interest")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    actions
    {
        // Add changes to page actions here
        addfirst(Navigation)
        {
            action("BCRQ Setup")
            {
                Promoted = true;
                ApplicationArea = Basic, Suite;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Setup;
                RunObject = page "BCRQ Setup";
                RunPageLink = "User ID" = field("User ID");
            }
        }
    }
}

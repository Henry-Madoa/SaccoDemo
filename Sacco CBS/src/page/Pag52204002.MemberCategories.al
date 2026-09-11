page 52204002 "Member Categories"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Member Categories";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Type; Rec."Category Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Class; Rec.Class)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Registration Fee"; Rec."Registration Fee")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field("Registration Fee Account"; Rec."Registration Fee Account")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field(Channels; Rec.Channels)
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
            action("Default Accounts")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;
                Ellipsis = true;
                Image = Account;
                RunObject = page "Member Default Accounts";
                RunPageLink = "Category Code" = field(Code);
            }
            action("Application Documents")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;
                Ellipsis = true;
                Image = Documents;
                RunObject = page "Category Checklist Setup";
                RunPageLink = "Source Code" = field(Code);
            }
            action("Create Members Default Acc.")
            {
                //Visible = false;
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;
                Ellipsis = true;
                Image = Accounts;

                trigger OnAction()
                var
                    MemberManagement: Codeunit "Member Management";
                begin
                    MemberManagement.CreateMembersDefaultAccounts(Rec);
                end;
            }
        }
    }
}

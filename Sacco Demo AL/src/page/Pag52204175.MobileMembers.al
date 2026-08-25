page 52204175 "Mobile Members"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Mobile Members";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Member No"; Rec."Member No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Full Name"; Rec."Full Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Phone No"; Rec."Phone No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("ID No"; Rec."ID No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Activated By"; Rec."Activated By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Activated On"; Rec."Activated On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("FOSA Account"; Rec."FOSA Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Status"; Rec."Member Status")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Last Reactivation Date"; Rec."Last Reactivation Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Mobile Ledger"; Rec."Mobile Ledger")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        area(Factboxes)
        {
            part("Member Statistics"; "Member Statistics")
            {
                SubPageLink = "No." = field("Member No");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Block)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Cancel;

                trigger OnAction()
                var
                    MemberMgt: Codeunit "Member Management";
                begin
                    Rec.TestField("Member Status", "Member Status"::Active);
                    if Confirm('Do you want to Block?') then MemberMgt.BlockMobileMember(Rec."Member No");
                end;
            }
        }
    }
}

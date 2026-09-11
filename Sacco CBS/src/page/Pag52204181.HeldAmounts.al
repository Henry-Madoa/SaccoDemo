page 52204181 "Held Amounts"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Uncleared Funds";
    InsertAllowed = false;
    //DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Document No"; Rec."Document No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member No"; Rec."Member No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Entry No"; Rec."Entry No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Cleared; Rec.Cleared)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Cleared By"; Rec."Cleared By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Cleared On"; Rec."Cleared On")
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
            action("Release Amount")
            {
                ApplicationArea = Basic, Suite;
                Image = ReopenPeriod;

                trigger OnAction();
                var
                    UserSetup: Record "BCRQ Setup";
                begin
                    if Confirm('Do you want to Release Held Amount') then begin
                        UserSetup.Get(UserId);
                        UserSetup.TestField("Can Release Uncleared Funds");
                        Rec.Cleared := true;
                        Rec."Cleared By" := UserId;
                        Rec."Cleared On" := CurrentDateTime;
                        Rec.Modify();
                    end;
                end;
            }
        }
    }
}

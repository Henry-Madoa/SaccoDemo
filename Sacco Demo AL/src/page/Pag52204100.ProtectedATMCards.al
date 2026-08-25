page 52204100 "Protected ATM Cards"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "ATM Cards";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Card No."; Rec."Card No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Added By"; Rec."Added By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Added On"; Rec."Added On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Assigned To Member No."; Rec."Assigned To Member No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Assigned to Account No"; Rec."Assigned to Account No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Assigned By"; Rec."Assigned By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Assigned On"; Rec."Assigned On")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        if not UserSetup.Get(UserId) then
            Error('Contact Admin for your username to be added on the setup')
        else begin
            If not UserSetup."View ATM Cards" then Error('You are not permited to view this page');
        end;
    end;

    var
        UserSetup: Record "User Setup";
}

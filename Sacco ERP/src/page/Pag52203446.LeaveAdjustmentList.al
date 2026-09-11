page 52203446 "Leave Adjustment List"
{
    Caption = 'Leave Adjustments List';
    CardPageID = "Leave Adjustment Card";
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "Leave Adjustment Header";
    SourceTableView = WHERE(Status=FILTER(Open|"Pending Approval"|Approved));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Leave Adjustments No."; Rec."Leave Adjustments No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("No. Of Days"; Rec."No. Of Days")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Job Group"; Rec."Job Group")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        UserSetup.Get(UserId);
        UserSetup.TestField("HR Admin", true);
    end;
    var UserSetup: Record "User Setup";
}

page 52203690 "Training Applications"
{
    CardPageID = "Training Application";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Training Application";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Date of Application"; Rec."Date of Application")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Training Calender"; Rec."Training Calender")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Period; Format(Rec.Period))
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Trainer; Rec.Trainer)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        if not LoginMgmt.IsWebServiceUser then if UserSetup.Get(UserId)then begin
                if not UserSetup."HR Admin" then Rec.SetRange("Created By", UserId);
            end
            else
                Error('You have to be setup in user setup');
    end;
    var UserSetup: Record "User Setup";
    LoginMgmt: Codeunit "User Management Ext";
}

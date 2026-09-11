page 52203448 "Leave Types Setup"
{
    CardPageID = "HR Leave Types Card";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Leave Types";

    layout
    {
        area(content)
        {
            repeater(Control1000000000)
            {
                ShowCaption = false;

                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Days; Rec.Days)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Gender; Rec.Gender)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Acrue Days"; Rec."Acrue Days")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Requires Attachment"; Rec."Requires Attachment")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Is Sick Leave"; Rec."Is Sick Leave")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

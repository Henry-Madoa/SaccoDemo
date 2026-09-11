page 52204202 "Member View Logs"
{
    ApplicationArea = All;
    Caption = 'Member View Logs';
    PageType = List;
    SourceTable = "Member View Logs";
    UsageCategory = Administration;
    InsertAllowed = false;
    Editable = false;
    ModifyAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Member No."; Rec."Member No.") { ApplicationArea = All; }
                field("Member Name"; Rec."Member Name") { ApplicationArea = All; }
                field(Reason; Rec.Reason) { ApplicationArea = All; }
                field("Viewed By"; Rec."Viewed By") { ApplicationArea = All; }
                field("Viewed At"; Rec."Viewed At") { ApplicationArea = All; }
                field("Source Page"; Rec."Source Page") { ApplicationArea = All; }
                field("Session ID"; Rec."Session ID") { ApplicationArea = All; }
                field("Client Type"; Rec."Client Type") { ApplicationArea = All; }
            }
        }
    }
}

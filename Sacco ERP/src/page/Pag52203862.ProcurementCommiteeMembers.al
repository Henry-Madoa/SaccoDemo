page 52203862 "Procurement Commitee Members"
{
    ApplicationArea = All;
    AutoSplitKey = true;
    DataCaptionFields = "User ID", "Employee Name", "Line No.";
    PageType = List;
    SourceTable = "Procurement Committee Members";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = All;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
    }
}

page 52203564 "Company Activities"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Company Activities";

    layout
    {
        area(content)
        {
            repeater(Control15)
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
                field(Day; Rec.Day)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Venue; Rec.Venue)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Responsibility; Rec.Responsibility)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Costs; Rec.Costs)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("G/L Account No"; Rec."G/L Account No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Bal. Account Type"; Rec."Bal. Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("Bal. Account No"; Rec."Bal. Account No")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field(Post; Rec.Post)
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("Attachment No."; Rec."Attachment No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Language Code (Default)"; Rec."Language Code (Default)")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Attachement; Rec.Attachement)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

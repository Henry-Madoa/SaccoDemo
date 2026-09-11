page 52203680 "Notification Templates"
{
    CardPageID = "Notification Template Card";
    PageType = List;
    SourceTable = "Notification Template";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line No"; Rec."Line No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Notification Type"; Rec."Notification Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Source; Rec.Source)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Subject; Rec.Subject)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        Rec.GetEmailDescriptionCalculated();
    end;
    var EmailBody: Text;
}

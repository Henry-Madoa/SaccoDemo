page 52203679 "Notification Template Card"
{
    PageType = Card;
    SourceTable = "Notification Template";

    layout
    {
        area(content)
        {
            group(General)
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
                field(Subject; Rec.Subject)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Body; EmailBody)
                {
                    MultiLine = true;

                    trigger OnValidate()
                    begin
                        Rec.SetEmailBody(EmailBody);
                    end;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        EmailBody:=Rec.GetEmailBody();
    end;
    var EmailBody: Text;
}

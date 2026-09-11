page 52204256 "Storage Type Header"
{
    PageType = Card;
    SourceTable = "Storage Types";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part(Control8; "Storage Type Lines")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = Type=FIELD(Type);
            }
            group(Audit)
            {
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

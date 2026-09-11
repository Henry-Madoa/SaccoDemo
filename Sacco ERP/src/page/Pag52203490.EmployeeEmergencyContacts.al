page 52203490 "Employee Emergency Contacts"
{
    PageType = List;
    SourceTable = "Employee Emergency Contacts";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Full Name"; Rec."Full Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Relationship; Rec.Relationship)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Alternative Phone No."; Rec."Alternative Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Email Address"; Rec."Email Address")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

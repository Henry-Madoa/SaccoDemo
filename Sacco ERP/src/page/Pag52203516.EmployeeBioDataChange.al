page 52203516 "Employee Bio Data Change"
{
    PageType = ListPart;
    SourceTable = "Employee Bio Data Change";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Change No."; Rec."Change No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Phone Number"; Rec."Phone Number")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Personal E-mail"; Rec."Personal E-mail")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Passport No"; Rec."Passport No")
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
}

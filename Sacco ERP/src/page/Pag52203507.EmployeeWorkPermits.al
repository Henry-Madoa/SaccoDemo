page 52203507 "Employee Work Permits"
{
    PageType = ListPart;
    SourceTable = "Work Permits";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Permit No"; Rec."Permit No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Date of Issue"; Rec."Date of Issue")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Effective Date"; Rec."Effective Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Expiry Date"; Rec."Expiry Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Renewal Date"; Rec."Renewal Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Permit Type"; Rec."Permit Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Passport Number"; Rec."Passport Number")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("File Number"; Rec."File Number")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Permit Status"; Rec."Permit Status")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

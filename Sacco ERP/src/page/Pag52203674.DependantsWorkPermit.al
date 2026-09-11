page 52203674 "Dependants Work Permit"
{
    PageType = List;
    SourceTable = "Dependants Work Permit";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Dependant Name"; Rec."Dependant Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Nationality; Rec.Nationality)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Permit No"; Rec."Permit No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("File No"; Rec."File No")
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
                field("Date of Issue"; Rec."Date of Issue")
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
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

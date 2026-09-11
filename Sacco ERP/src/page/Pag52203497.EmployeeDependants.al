page 52203497 "Employee Dependants"
{
    PageType = List;
    SourceTable = "Employee Depandants";

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
                field("ID/Birth Certificate No."; Rec."ID/Birth Certificate No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Is Student"; Rec."Is Student")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Date of Birth"; Rec."Date of Birth")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Age; Rec.Age)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Gender; Rec.Gender)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(navigation)
        {
            action("Dependants Work Permits")
            {
                ApplicationArea = Basic, Suite;
                Image = Workdays;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Dependants Work Permit";
                RunPageLink = "Dependant Name"=FIELD("Full Name"), "Employee No"=FIELD("Employee No."), "Dependant Line No"=FIELD("Line No.");
            }
        }
    }
    var EmployeeDepandants: Record "Employee Depandants";
}

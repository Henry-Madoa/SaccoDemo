page 52203760 "Employee Contract Details"
{
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Employee Contract Details";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;

                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contract Code"; Rec."Contract Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contract Description"; Rec."Contract Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contract Start Date"; Rec."Contract Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contract Period"; Rec."Contract Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contract End Date"; Rec."Contract End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Notice Period"; Rec."Notice Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contract Status"; Rec."Contract Status")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Job Title"; Rec."Job Title")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Grade; Rec.Grade)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Salary; Rec.Salary)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Manager Name"; Rec."Manager Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Department; Rec.Department)
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
            action("Grant Details")
            {
                ApplicationArea = Basic, Suite;
                Image = Hierarchy;
                Promoted = true;
                PromotedCategory = New;
                PromotedIsBig = true;
                RunObject = Page "Employee Donors";
                RunPageLink = "Contract Line No"=FIELD("Line No"), "Employee No"=FIELD("Employee No");
            }
        }
    }
}

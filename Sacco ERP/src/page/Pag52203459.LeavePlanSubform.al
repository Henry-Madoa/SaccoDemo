page 52203459 "Leave Plan Subform"
{
    PageType = ListPart;
    SourceTable = "Leave Plan Lines";

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
                field("Plan No."; Rec."Plan No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Leave Code"; Rec."Leave Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Code."; Rec."Employee Code.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Leave Type Description"; Rec."Leave Type Description")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Leave Balance"; Rec."Leave Balance")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Days Planned"; Rec."Days Planned")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Holidays; Rec.Holidays)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Weekend Days"; Rec."Weekend Days")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Total No Of Days"; Rec."Total No Of Days")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
            }
        }
    }
}

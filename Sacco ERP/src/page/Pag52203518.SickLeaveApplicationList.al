page 52203518 "Sick Leave Application List"
{
    CardPageID = "Leave Application";
    Editable = false;
    PageType = List;
    SourceTable = "Leave Applications";
    SourceTableView = WHERE("Nature of Application"=CONST("Leave Application"), "Leave Code"=CONST('SCK'));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Days Applied"; Rec."Days Applied")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Application Date"; Rec."Application Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Leave Code"; Rec."Leave Code")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    var Employee: Record Employee;
    UserSetup: Record "User Setup";
    "--Philip": Integer;
}

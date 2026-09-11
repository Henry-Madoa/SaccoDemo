page 52203513 "Leave Reimbursements"
{
    CardPageID = "Leave Reimbursement";
    Editable = false;
    PageType = List;
    SourceTable = "Leave Applications";
    SourceTableView = WHERE("Nature of Application"=CONST("Leave Reimbursement"));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Days To Reimburse"; Rec."Days To Reimburse")
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
            }
        }
    }
    trigger OnOpenPage()
    begin
        UserSetup.Get(UserId);
    /*IF NOT UserSetup."Is HR Admin" THEN BEGIN
              FILTERGROUP(2);
              SETRANGE("Employee No",UserSetup."Employee No.");
              FILTERGROUP(0);
            end;
            */
    end;
    var Employee: Record Employee;
    UserSetup: Record "User Setup";
    "--Philip": Integer;
}

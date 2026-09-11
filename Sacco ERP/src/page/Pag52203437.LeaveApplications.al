page 52203437 "Leave Applications"
{
    CardPageID = "Leave Application";
    Editable = false;
    PageType = List;
    SourceTable = "Leave Applications";
    SourceTableView = WHERE("Nature of Application"=CONST("Leave Application"));

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
    actions
    {
        area(Navigation)
        {
            action("Clear Ledger Entries")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Delete;

                trigger OnAction()
                begin
                    if not Confirm('You are about to delete all posted Leave Ledger Entries, Do you wish to continue?', true)then exit;
                    LeaveLedgerEntries.Reset;
                    LeaveLedgerEntries.SetFilter(Quantity, '<>%1', 0);
                    LeaveLedgerEntries.DeleteAll(true);
                    Message('All Leave Ledger Entries have been deleted');
                end;
            }
            action("Clear Leave Applications")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = ClearLog;

                trigger OnAction()
                begin
                    if not Confirm('You are about to delete all Leave Applications, Do you wish to continue?', true)then exit;
                    LeaveApplications.Reset;
                    LeaveApplications.SetFilter("No.", '<>%1', '');
                    LeaveApplications.DeleteAll(true);
                    Message('All Leave Applications have been deleted');
                end;
            }
        }
    }
    var LeaveLedgerEntries: Record "Leave Ledger Entries";
    LeaveApplications: Record "Leave Applications";
}

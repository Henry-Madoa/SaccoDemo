page 52203665 "Contract Renewal List"
{
    CardPageID = "Contract Renewal Card";
    DeleteAllowed = false;
    // Editable = false;
    // InsertAllowed = false;
    // ModifyAllowed = false;
    PageType = List;
    SourceTable = "Employee Change Request";
    SourceTableView = WHERE("Nature of Change"=FILTER("Contract Renewal"));

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
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(creation)
        {
            action(Delegate)
            {
                ApplicationArea = BasicHR;
                Image = Delegate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.Testfield(Status, Rec.Status::Open);
                    if not Confirm('Are you sure you want to delegate the selected COC')then exit;
                    Clear(CoCDelegationDialog);
                    CoCDelegationDialog.LookupMode(true);
                    CoCDelegationDialog.RunModal;
                    if CoCDelegationDialog.GetEmployeeNo() <> '' then begin
                        Rec."Created By":=CoCDelegationDialog.GetEmployeeNo();
                        Rec.Modify(true);
                    end
                    else
                        Message('you selected no employee');
                end;
            }
        }
    }
    var CoCDelegationDialog: Page "CoC Delegation Dialog";
}

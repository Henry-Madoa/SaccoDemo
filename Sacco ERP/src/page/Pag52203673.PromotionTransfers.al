page 52203673 "Promotion & Transfers"
{
    PageType = Card;
    SourceTable = "Employee Change Request";

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = PageEditable;

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
                field("Current Grade"; Rec."Current Grade")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Current Pointer"; Rec."Current Pointer")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Current Salary Grade"; Rec."Current Salary Grade")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("New Grade"; Rec."New Grade")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("New Pointer"; Rec."New Pointer")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("New Salary Grade"; Rec."New Salary Grade")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Approval Entries"; Rec."Approval Entries")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Current Department"; Rec."Current Department")
                {
                    ApplicationArea = All;
                }
                field("New Department"; Rec."New Department")
                {
                    ApplicationArea = All;
                }
                field("Current Project"; Rec."Current Project")
                {
                    ApplicationArea = All;
                }
                field("New Project"; Rec."New Project")
                {
                    ApplicationArea = All;
                }
                field("Current Job"; Rec."Current Job")
                {
                    ApplicationArea = All;
                }
                field("New Job"; Rec."New Job")
                {
                    ApplicationArea = All;
                }
            }
            part("Contract Details"; "Contract Change Lines")
            {
                Editable = false;
                SubPageLink = "Change No"=FIELD("No."), "Employee No"=FIELD("Employee No");
            }
            part("Employee Qualification"; "Employee Qualifications Change")
            {
                ApplicationArea = All;
                SubPageLink = "Employee No."=FIELD("Employee No");
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Send Approval Request")
            {
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::Open);
                    if not Confirm('Are you sure you want to send it for approval?')then exit
                    else
                    begin
                        ApprovalsMgmt.OnSendEmployeeChangeForApproval(Rec);
                        CurrPage.Close();
                    end;
                end;
            }
            action("Cancel Approval Request")
            {
                Image = CancelApprovalRequest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::"Pending Approval");
                    if not Confirm('Are you sure you want to cancel approval request?')then exit
                    else
                    begin
                        ApprovalsMgmt.OnCancelEmployeeChangeApprovalRequest(Rec);
                        CurrPage.Close();
                    end;
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        ControlPageAppearance;
    end;
    trigger OnAfterGetRecord()
    begin
        ControlPageAppearance;
    end;
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Nature of Change":=Rec."Nature of Change"::"Salary Increment";
    end;
    trigger OnOpenPage()
    begin
        ControlPageAppearance;
    end;
    var ApprovalsMgmt: Codeunit "Approval Mgmt. Ext";
    PageEditable: Boolean;
    local procedure ControlPageAppearance()
    begin
        if Rec.Status in[Rec.Status::Open]then PageEditable:=true
        else
            PageEditable:=false;
    end;
}

page 52203538 "New Contract Card"
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
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part(Control6; "New Contract Lines")
            {
                ApplicationArea = All;
                Editable = PageEditable;
                SubPageLink = "Employee No"=FIELD("Employee No"), "Change No"=FIELD("No.");
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Create Contract")
            {
                ApplicationArea = BasicHR;
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not Confirm('Are you sure you want to create contract?')then exit;
                    ChangeRequestManagement.CreateNewEmployeeContract(Rec);
                    Rec.Executed:=true;
                    CurrPage.Close();
                end;
            }
            action("Cancel Approval Request")
            {
                ApplicationArea = BasicHR;
                Image = CancelApprovalRequest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = false;

                trigger OnAction()
                begin
                    Rec.Testfield(Status, Rec.Status::"Pending Approval");
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
        ControlPageAppearance end;
    trigger OnAfterGetRecord()
    begin
        ControlPageAppearance end;
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Nature of Change":=Rec."Nature of Change"::"New Contract";
    end;
    trigger OnOpenPage()
    begin
        ControlPageAppearance end;
    var ApprovalsMgmt: Codeunit "Approval Mgmt. Ext";
    ChangeRequestManagement: Codeunit "Change Request Management";
    PageEditable: Boolean;
    local procedure ControlPageAppearance()
    begin
        if Rec.Status in[Rec.Status::Open]then PageEditable:=true
        else
            PageEditable:=false end;
}

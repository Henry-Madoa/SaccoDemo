page 52203521 "Requisition Header-Pe"
{
    Caption = 'Requisition Pending Approval';
    PromotedActionCategories = 'New,Process,Report,Approval,Request Approval';
    PageType = Card;
    SourceTable = "Requisition Header";
    SourceTableView = WHERE(Status=CONST("Pending Approval"));

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = false;

                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Code"; Rec."Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Requisition Date"; Rec."Requisition Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Pending Approvals"; Rec."Pending Approvals")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;

                    trigger OnAssistEdit()
                    var
                        Entries: Record "Approval Entry";
                    begin
                        Entries.Reset();
                        Entries.SetRange("Table ID", 50200);
                        Entries.SetRange("Document No.", Rec."No.");
                        Entries.SetFilter(Status, '%1|%2', Entries.Status::Open, Entries.Status::Created);
                        Page.RunModal(Page::"Custom Approval Entries", Entries);
                    end;
                }
                field(Approvers; Rec.Approvers)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;

                    trigger OnAssistEdit()
                    var
                        Entries: Record "Approval Entry";
                    begin
                        Entries.Reset();
                        Entries.SetRange("Table ID", 50200);
                        Entries.SetRange("Document No.", Rec."No.");
                        Entries.SetFilter(Status, '=%1', Entries.Status::Approved);
                        Page.RunModal(Page::"Custom Approval Entries", Entries);
                    end;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Raised by"; Rec."Raised by")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Requisition Details")
            {
                field(Reason; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    editable = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    editable = false;
                }
            }
            part(Control16; "Purch Requisition Lines")
            {
                //Not include Store Request from Requisition Type
                //Purchase Reques
                ApplicationArea = Basic, Suite;
                Visible = NotStoreRequest;
                SubPageLink = "Requisition No"=FIELD("No.");
            }
            part(Control17; "Store Requisition Lines")
            {
                //Store Request from Requisition Type
                //Store Request
                ApplicationArea = Basic, Suite;
                Visible = StoreRequest;
                SubPageLink = "Requisition No"=FIELD("No.");
            }
        }
        area(factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attachments';
                SubPageLink = "Table ID"=CONST(50200), "No."=FIELD("No.");
            }
            part("Approval Entries"; "Customize Approval Entries")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Approval Entries';
                SubPageLink = "Table ID"=CONST(50200), "Document No."=FIELD("No.");
            }
            systempart(Control15; Notes)
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    actions
    {
        area(processing)
        {
            group("Manual Approval")
            {
                Visible = NOT OpenApprovalEntriesExistForCurrUser;

                action(Reopen)
                {
                    ApplicationArea = Suite;
                    Caption = 'Re&open';
                    Enabled = ((Rec.Status = Rec.Status::Approved) and (Rec.Posted = false));
                    Image = ReOpen;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;

                    trigger OnAction()
                    begin
                        Rec.Validate(Status, Rec.Status::Open);
                        Rec.Modify(true);
                    end;
                }
            }
            group(Approval)
            {
                Caption = 'Approval';

                action(Approve)
                {
                    ApplicationArea = Suite;
                    Caption = 'Approve';
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTip = 'Approve the requested changes.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        ReqLines: Record "Requisition Lines";
                    begin
                        IF CONFIRM(StrSubstNo(Text000, Rec."No."), false) = true then begin
                            if Rec."Requisition Type" = Rec."Requisition Type"::"Store Requisition" then begin
                                ReqLines.Reset();
                                ReqLines.SetRange("Requisition No", Rec."No.");
                                if ReqLines.FindFirst()then begin
                                    repeat if ReqLines."Quantity Approved" = 0 then Error('You cannot approve store requisition %1 with quantity approved zero.', ReqLines."Line No");
                                    until ReqLines.Next() = 0;
                                end;
                            end;
                            ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                            Message('Requisition Approved.');
                            CurrPage.Update(true);
                        end
                        else
                        begin
                            exit;
                        end;
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = Suite;
                    Caption = 'Reject';
                    Image = Reject;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        ApprovalMgmt_Ext: Codeunit "Approval Mgmt. Ext";
                        ApprovalComments: Record "Approval Comment Line";
                    begin
                        if Confirm(StrSubstNo(Text001, Rec."No."), false) = true then begin
                            //Reject function
                            ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                            Message('Requisition Rejected.');
                            CurrPage.Update(true);
                        end
                        else
                        begin
                            exit;
                        end;
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = Suite;
                    Caption = 'Delegate';
                    Image = Delegate;
                    Promoted = true;
                    PromotedCategory = Category4;
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.DelegateRecordApprovalRequest(Rec.RecordId);
                        Message('Requisition Delegate.');
                    end;
                }
                action(Comment)
                {
                    ApplicationArea = Suite;
                    Caption = 'Comments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Approval Comments";
                    RunPageLink = "Document No."=FIELD("No.");
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.GetApprovalComment(Rec);
                    end;
                }
            }
        }
    }
    trigger OnInit()
    begin
        NotStoreRequest:=false;
        StoreRequest:=false;
    end;
    trigger OnOpenPage()
    begin
        //Not include Store Request from Requisition Type
        if Rec."Requisition Type" <> Rec."Requisition Type"::"Store Requisition" then NotStoreRequest:=true
        else
            NotStoreRequest:=false; //Store Request from Requisition Type
        if Rec."Requisition Type" = Rec."Requisition Type"::"Store Requisition" then StoreRequest:=true
        else
            StoreRequest:=false;
    end;
    trigger OnAfterGetRecord()
    begin
        SetControlAppearance; //Not include Store Request from Requisition Type
        if Rec."Requisition Type" <> Rec."Requisition Type"::"Store Requisition" then NotStoreRequest:=true
        else
            NotStoreRequest:=false; //Store Request from Requisition Type
        if Rec."Requisition Type" = Rec."Requisition Type"::"Store Requisition" then StoreRequest:=true
        else
            StoreRequest:=false;
    end;
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
    //"Requisition Type" := "Requisition Type"::"Store Requisition";
    end;
    var OpenApprovalEntriesExistForCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    ShowWorkflowStatus: Boolean;
    CanCancelApprovalForRecord: Boolean;
    DocumentIsPosted: Boolean;
    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    StoreRequest: Boolean;
    NotStoreRequest: Boolean;
    local procedure SetControlAppearance()
    begin
        OpenApprovalEntriesExistForCurrUser:=ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist:=ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord:=ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
    end;
    var Text000: Label 'Are you sure you want to approve the Requisition %1. Do you want to continue?';
    Text001: Label 'Are you sure you want to reject the Requisition %1. Do you want to continue?';
}

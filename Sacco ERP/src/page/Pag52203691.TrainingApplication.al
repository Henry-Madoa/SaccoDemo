page 52203691 "Training Application"
{
    PageType = Card;
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTable = "Training Application";
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments';

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
                field("Training Need"; Rec."Training Need")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Date of Application"; Rec."Date of Application")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Training Calender"; Rec."Training Calender")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Training Need Description"; Rec."Training Need Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Category Name"; Rec."Category Name")
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
                field("Job Group"; Rec."Job Group")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Job Title"; Rec."Job Title")
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
                field(Period; Format(Rec.Period))
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Expected Cost"; Rec."Expected Cost")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Trainer; Rec.Trainer)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Exceeds Expected Trainees"; Rec."Exceeds Expected Trainees")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Training Start Date"; Rec."Training Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("&Training Feedback")
            {
                field("Training Feedback"; Rec."Training Feedback")
                {
                    ShowCaption = false;
                    MultiLine = true;
                    ApplicationArea = Basic, Suite;
                    Editable = Rec.Status = Rec.Status::"Awaiting Attendance Confirmation";
                }
            }
        }
    }
    actions
    {
        area(Reporting)
        {
            action(Print)
            {
                ApplicationArea = Basic, Suite;
                Image = Print;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.Reset;
                    Rec.SetRange("No.", Rec."No.");
                    Report.Run(Report::"Training Applications", true, false, Rec);
                end;
            }
        }
        area(processing)
        {
            action(Attachments)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attachments';
                Image = Attach;
                Promoted = true;
                PromotedCategory = Category8;
                ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';

                trigger OnAction()
                var
                    DocumentAttachmentDetails: Page "Document Attachment Details";
                    RecRef: RecordRef;
                begin
                    RecRef.GetTable(Rec);
                    DocumentAttachmentDetails.OpenForRecRef(RecRef);
                    DocumentAttachmentDetails.RunModal;
                end;
            }
            group(Confirmation)
            {
                action("Confirm Availability")
                {
                    ApplicationArea = Basic, Suite;
                    Image = Confirm;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Enabled = Rec.Status = Rec.Status::"Awaiting Availability Confirmation";

                    trigger OnAction()
                    begin
                        if Confirm(Text000, false) = true then begin
                            HrTrainingManagement.ConfirmAvailability(Rec."No.");
                            CurrPage.Close();
                        end
                        else
                            exit;
                    end;
                }
                action("Confirm Attendance")
                {
                    ApplicationArea = Basic, Suite;
                    Image = Confirm;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Enabled = Rec.Status = Rec.Status::"Awaiting Attendance Confirmation";

                    trigger OnAction()
                    begin
                        if not Confirm('Are you sure you want to confirm attendance?')then exit;
                        HrTrainingManagement.ConfirmAttendance(Rec."No.");
                        CurrPage.Close();
                    end;
                }
                action("HR Confirm Attendance")
                {
                    ApplicationArea = Basic, Suite;
                    Image = Confirm;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Enabled = Rec.Status = Rec.Status::"Awaiting HR Confirmation";

                    trigger OnAction()
                    begin
                        if not Confirm('Are you sure you want to confirm attendance?')then exit;
                        HrTrainingManagement.HRConfirmAttendance(Rec."No.");
                        CurrPage.Close();
                    end;
                }
            }
        }
    }
    var ApprovalsMgmt: Codeunit "Approval Mgmt. Ext";
    HrTrainingManagement: Codeunit "Training Mgmt";
    OpenApprovalEntriesExist: Boolean;
    OpenApprovalEntriesExistForCurrUser: Boolean;
    TrainingPlanLines: Record "Training Plan Lines";
    Text000: Label 'You are about to confirm availability and request of Training Allowance, Do you wish ro continue?';
    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
        OpenApprovalEntriesExistForCurrUser:=ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist:=ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
    end;
}

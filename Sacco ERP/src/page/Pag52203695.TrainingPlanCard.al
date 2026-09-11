page 52203695 "Training Plan Card"
{
    PageType = Card;
    SourceTable = "Training Plan";
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Calender Code"; Rec."Calender Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Calender Start Date"; Rec."Calender Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Calender End Date"; Rec."Calender End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part(Control9; "Training Plan Sub-Form")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "Plan No."=FIELD("No.");
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(DocAttach)
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
            action("Generate Employee Training Requests")
            {
                ApplicationArea = Basic, Suite;
                Image = GeneralPostingSetup;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if Confirm(StrSubstNo('You are about to create Employee Training Applications for %1', Rec."No."), false) = false then exit;
                    TrainingMgmt.GenerateEmployeeTrainingRequests(Rec);
                end;
            }
        }
    }
    var TrainingMgmt: Codeunit "Training Mgmt";
}

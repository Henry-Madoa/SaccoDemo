page 52203839 "Contract Card"
{
    ApplicationArea = All;
    PageType = Card;
    SourceTable = "Contract Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = CtrlEditable;

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Requisition No"; Rec."Requisition No")
                {
                    ApplicationArea = All;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Tender No."; Rec."Tender No.")
                {
                    ApplicationArea = All;
                }
                field("Tender Title"; Rec."Tender Title")
                {
                    ApplicationArea = All;
                }
                field("Agreement Date"; Rec."Agreement Date")
                {
                    ApplicationArea = All;
                }
                field("Contract Start Date"; Rec."Contract Start Date")
                {
                    ApplicationArea = All;
                }
                field("Contract period"; Rec."Contract period")
                {
                    ApplicationArea = All;
                }
                field("Tender Amount"; Rec."Tender Amount")
                {
                    ApplicationArea = All;
                }
                field("Contract Status"; Rec."Contract Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Contract Signing Date"; Rec."Contract Signing Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Total Milestone Amount"; Rec."Total Milestone Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            part(Control30; "Contract Extension Entries")
            {
                ApplicationArea = All;
                Editable = false;
                SubPageLink = "Contract No"=FIELD("No.");
            }
            part(Control13; "Contract Lines Subform")
            {
                ApplicationArea = All;
                Editable = false;
                SubPageLink = "Contract No."=FIELD("No.");
            }
        }
        area(factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID"=CONST(67020), "No."=FIELD("No.");
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Contract Milestones")
            {
                ApplicationArea = All;
                Image = Agreement;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Contract Milestone List";
                RunPageLink = "Contract No"=FIELD("No.");
            }
            action("Sign Contract")
            {
                ApplicationArea = All;
                Image = Signature;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField("Contract Status", Rec."Contract Status"::New);
                    if not Confirm('Are you sure you want to sign the contract?')then exit;
                    Rec.TestField("Contract End Date");
                    Rec.TestField("Contract Start Date");
                    ContractMilestone.Reset;
                    ContractMilestone.SetRange("Contract No", Rec."No.");
                    ContractMilestone.SetFilter("Milestone Code", '<>%1', '');
                    if not ContractMilestone.FindFirst then if not Confirm('The contract has no signle milestone, Are you sure you still want to proceed?')then exit;
                    Rec."Contract Status":=Rec."Contract Status"::Signed;
                    Rec."Contract Signing Date":=Today;
                    if Rec.Modify then Message('Successfully signed');
                end;
            }
            action("Bind Bond")
            {
                ApplicationArea = All;
                Image = Accounts;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Tender Bidders-Bond";
                RunPageLink = "Reference No"=FIELD("Tender No."), Awarded=CONST(true);
            }
            action("Send Approval Request")
            {
                ApplicationArea = All;
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::Open);
                    if not Confirm('Are you sure you want to send it for approval?')then exit;
                    Rec.CalcFields("Total Milestone Amount");
                    if Rec."Total Milestone Amount" > Rec."Tender Amount" then Message('The milestone amount is higher than the contract amount');
                    //               if ApprovalsMgmt.CheckContractApprovalsWorkflowEnabled(Rec) then
                    //                 ApprovalsMgmt.OnSendContractForApproval(Rec);
                    CurrPage.Close();
                end;
            }
            action("Cancel Approval Request")
            {
                ApplicationArea = All;
                Image = CancelApprovalRequest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::"Pending Approval");
                    if not Confirm('Are you sure you want to cancel approval request?')then exit;
                    //                if ApprovalsMgmt.CheckContractApprovalsWorkflowEnabled(Rec) then
                    //                 ApprovalsMgmt.OnCancelContractApprovalRequest(Rec);
                    CurrPage.Close();
                end;
            }
            action(Attachments)
            {
                ApplicationArea = All;
                Image = Documents;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
            //        RunObject = Page "Contract Documents";
            //        RunPageLink = "Document No."=FIELD("No.");
            }
            action("Print Out")
            {
                ApplicationArea = All;
                Image = "Report";
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.SetRange("No.", Rec."No.");
                    REPORT.Run(53052, true, false, Rec);
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        FnEditable;
    end;
    trigger OnOpenPage()
    begin
        FnEditable;
    end;
    var ContractMilestone: Record "Contract Milestone";
    CtrlEditable: Boolean;
    procedure FnEditable()
    begin
        CtrlEditable:=true;
        if Rec."Contract Status" <> Rec."Contract Status"::New then CtrlEditable:=false;
    end;
}

page 52203572 "SS Purchase Order List"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    PromotedActionCategories = 'New,Process,Report,Approve,Release,Request Approval,Print/Send,Navigate';
    CardPageId = "SS Purchase Order";
    //CardPageId = "Purchase Order";
    UsageCategory = Lists;
    SourceTable = "Purchase Header";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Buy-from Vendor Name"; Rec."Buy-from Vendor Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Buy-from Post Code"; Rec."Buy-from Post Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Buy-from Country/Region Code"; Rec."Buy-from Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Ship-to Post Code"; Rec."Ship-to Post Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Ship-to Country/Region Code"; Rec."Ship-to Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        area(Factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attachments';
                SubPageLink = "Table ID"=CONST(38), "No."=FIELD("No.");
            }
            part("Approval Entries"; "Customize Approval Entries")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Approval Entries';
                SubPageLink = "Table ID"=CONST(38), "Document Type"=filter(Order), "Document No."=FIELD("No.");
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group("Request Approval")
            {
                Caption = 'Request Approval';

                action(SendApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send A&pproval Request';
                    Enabled = Rec.Status = Rec.Status::Open;
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Request approval of the document.';

                    trigger OnAction()
                    begin
                        Rec.TestField("Vendor Invoice No.");
                        BudgetMngt.ConfirmBudgetAvailabilityPO(Rec);
                        if not Rec.DocumentAttachmentsCheck then Error('Please capture the Posting Description before sending for approval.');
                        ApprovalsMgt.OnSendPurchaseDocForApproval(Rec);
                        CurrPage.Close();
                    end;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.SetRange("Raised by", UserId);
    end;
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        CreateDepartmentalOrder;
    end;
    procedure CreateDepartmentalOrder()
    begin
        if QuantumJumpUserSetup.Get(UserId)then begin
            if Emp.Get(QuantumJumpUserSetup."Employee No.")then begin
                Emp.TestField("Global Dimension 1 Code");
                Emp.TestField("Global Dimension 2 Code");
                Rec."Shortcut Dimension 1 Code":=Emp."Global Dimension 1 Code";
                Rec."Shortcut Dimension 2 Code":=Emp."Global Dimension 2 Code";
            end;
        end
        else
            Error(Text003);
    end;
    var ApprovalsMgt: Codeunit "Approvals Mgmt.";
    BudgetMngt: Codeunit "Budget Management";
    Emp: Record Employee;
    QuantumJumpUserSetup: Record "User Setup";
    Text003: Label 'You do not have a setup. Please Contact the Administrator.';
}

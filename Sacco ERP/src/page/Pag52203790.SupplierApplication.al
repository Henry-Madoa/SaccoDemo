page 52203790 "Supplier Application"
{
    Caption = 'Vendor Card';
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments';
    RefreshOnActivate = true;
    SourceTable = "Supplier Application";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                    Visible = NoFieldVisible;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the vendor''s name. You can enter a maximum of 30 characters, both numbers and letters.';
                }
                field("Balance (LCY)"; Rec."Balance (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total value of your completed purchases from the vendor in the current fiscal year. It is calculated from amounts excluding VAT on all completed purchase invoices and credit memos.';
                }
                field("Balance Due (LCY)"; Rec."Balance Due (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total value of your unpaid purchases from the vendor in the current fiscal year. It is calculated from amounts excluding VAT on all open purchase invoices and credit memos.';
                }
                field("Generated Vendor No."; Rec."Generated Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Application Type"; Rec."Application Type")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
            }
            group("Address & Contact")
            {
                Caption = 'Address & Contact';

                group(Address_)
                {
                    ShowCaption = false;

                    field(Address; Rec.Address)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the vendor''s address.';
                    }
                    field("Address 2"; Rec."Address 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies additional address information.';
                    }
                    field("Post Code"; Rec."Post Code")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the postal code.';
                    }
                    field(City; Rec.City)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the vendor''s city.';
                    }
                    field("Country/Region Code"; Rec."Country/Region Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the country/region of the address.';
                    }
                }
                group(Contact)
                {
                    Caption = 'Contact';

                    field("Phone No."; Rec."Phone No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the vendor''s telephone number.';
                    }
                    field("E-Mail"; Rec."E-Mail")
                    {
                        ApplicationArea = All;
                        ExtendedDatatype = EMail;
                        Importance = Promoted;
                        ToolTip = 'Specifies the vendor''s email address.';
                    }
                    field("Fax No."; Rec."Fax No.")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the customer''s fax number.';
                    }
                    field("Home Page"; Rec."Home Page")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the vendor''s web site.';
                    }
                }
            }
            group("Invoicing Setup")
            {
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Vendor Posting Group"; Rec."Vendor Posting Group")
                {
                    ApplicationArea = All;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
            }
            group("Procurement Details")
            {
                field("Supplier Type"; Rec."Supplier Type")
                {
                    ApplicationArea = All;
                }
                field("Application Date"; Rec."Application Date")
                {
                    ApplicationArea = All;
                }
                field("AGPO Certificate"; Rec."AGPO Certificate")
                {
                    ApplicationArea = All;
                }
                field("Trade Licennse No"; Rec."Trade Licennse No")
                {
                    ApplicationArea = All;
                }
                field("Certificate of Incorporation"; Rec."Certificate of Incorporation")
                {
                    ApplicationArea = All;
                }
                field("Registration No."; Rec."Registration No.")
                {
                    ApplicationArea = All;
                }
                field("Registration Date"; Rec."Registration Date")
                {
                    ApplicationArea = All;
                }
                field("Tax Compliance Certificate No."; Rec."Tax Compliance Certificate No.")
                {
                    ApplicationArea = All;
                }
                field("Tax Compliance Expiry Date"; Rec."Tax Compliance Expiry Date")
                {
                    ApplicationArea = All;
                }
                field("VAT Certificate No."; Rec."VAT Certificate No.")
                {
                    ApplicationArea = All;
                }
                field("PIN No."; Rec."PIN No.")
                {
                    ApplicationArea = All;
                }
                field("No. of Businesses at one time"; Rec."No. of  Businesses")
                {
                    Importance = Promoted;
                }
                field("Registration Status"; Rec."Registration Status")
                {
                    ApplicationArea = All;
                }
            }
            group(Payments)
            {
                Caption = 'Payments';

                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies a formula that calculates the payment due date, payment discount date, and payment discount amount.';
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies how to make payment, such as with bank transfer, cash,  or check.';
                }
                field(PortalId; Rec.PortalId)
                {
                    Visible = false;
                }
                field(HasAcceptedTermsAndConditions; Rec.HasAcceptedTermsAndConditions)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group(Approval)
            {
                action("Send Approval Request")
                {
                    ApplicationArea = All;
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedIsBig = true;
                    Enabled = NOT OpenApprovalEntriesExist AND CanRequestApprovalForFlow;

                    trigger OnAction()
                    begin
                        Rec.Testfield(Status, Rec.Status::Open);
                        if not Confirm('Are you sure you want to send it for approval?')then exit;
                        ApprovalsMgmt.OnSendSupplierApplicationForApproval(Rec);
                        CurrPage.Close();
                    end;
                }
                action("Cancel Approval Request")
                {
                    ApplicationArea = All;
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedIsBig = true;
                    Enabled = CanCancelApprovalForRecord OR CanCancelApprovalForFlow;

                    trigger OnAction()
                    begin
                        Rec.TestField(Status, Rec.Status::"Pending Approval");
                        if not Confirm('Are you sure you want to cancel approval request?')then exit;
                        ApprovalsMgmt.OnCancelSupplierApplicationApprovalRequest(Rec);
                        CurrPage.Close();
                    end;
                }
                action("Manual Approve")
                {
                    ApplicationArea = All;
                    Caption = 'Manual Approve';
                    Enabled = Rec.Status <> Rec.Status::Approved;
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        RequisitionLines: Record "Requisition Lines";
                        ProcurementMgmt: Codeunit "Procurement Management";
                    begin
                        Rec.TestField("E-Mail");
                        Rec.TestField("Gen. Bus. Posting Group");
                        Rec.TestField("VAT Bus. Posting Group");
                        Rec.TestField("Vendor Posting Group");
                        Rec.Status:=Rec.Status::Approved;
                        Rec.Modify(true);
                        ProcurementMgmt.CreateVendor(Rec."No.", Rec."E-Mail", rec."Phone No.", Rec."Category of Service");
                    end;
                }
                action(Approve)
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTip = 'Approve the requested changes.';
                    Visible = OpenApprovalEntriesExistCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        if not Confirm('Are you sure you want to Approve the document?')then exit;
                        ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                        CurrPage.Close();
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = All;
                    Caption = 'Reject';
                    Image = Reject;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTip = 'Reject the approval request.';
                    Visible = OpenApprovalEntriesExistCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        if not Confirm('Are you sure you want to Reject the document?')then exit;
                        ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                        CurrPage.Close;
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = All;
                    Caption = 'Delegate';
                    Image = Delegate;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Delegate the approval to a substitute approver.';
                    Visible = OpenApprovalEntriesExistCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        if not Confirm('Are you sure you want to Approve the document?')then exit;
                        ApprovalsMgmt.DelegateRecordApprovalRequest(Rec.RecordId);
                        CurrPage.Close();
                    end;
                }
                action(Comment)
                {
                    ApplicationArea = All;
                    Caption = 'Comments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'View or add comments for the record.';
                    Visible = OpenApprovalEntriesExistCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.GetApprovalComment(Rec);
                    end;
                }
            }
            group("Application Details")
            {
                action(DocAttach)
                {
                    ApplicationArea = All;
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
                action("Partners/Directors Details")
                {
                    ApplicationArea = All;
                    Image = Accounts;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Supplier Partner Details";
                    RunPageLink = "Vendor No"=FIELD("No.");
                }
                action("Bank Account Details")
                {
                    Image = Bank;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Supplier Bank Accounts";
                    RunPageLink = "Vendor No."=FIELD("No.");
                }
                action("Additional Addresses")
                {
                    ApplicationArea = All;
                    Image = Addresses;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Supplier Additional Addresses";
                    RunPageLink = "Supplier No"=FIELD("No.");
                }
                action("Item Categories")
                {
                    ApplicationArea = All;
                    Image = IndustryGroups;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Supplier Item Categories";
                    RunPageLink = "Supplier No."=FIELD("No.");
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
    //ActivateFields;
    end;
    trigger OnInit()
    begin
    //SetVendorNoVisibilityOnFactBoxes;    //ContactEditable := TRUE;
    end;
    trigger OnNewRecord(BelowxRec: Boolean)
    var
        DocumentNoVisibility: Codeunit DocumentNoVisibility;
    begin
        Rec."Application Type":=Rec."Application Type"::Prequalification;
        if GuiAllowed then if Rec."No." = '' then if DocumentNoVisibility.VendorNoSeriesIsDefault then NewMode:=true;
    end;
    trigger OnOpenPage()
    var
        PermissionManager: Codeunit "Permission Manager";
    begin
        //ActivateFields;
        IsOfficeAddin:=OfficeMgt.IsAvailable;
        //SetNoFieldVisible;
        // IsSaaS := PermissionManager.SoftwareAsAService;
        SetControlAppearance;
    end;
    var OfficeMgt: Codeunit "Office Management";
    ApprovalsMgmt: Codeunit "Approval Mgmt. Ext";
    OpenApprovalEntriesExistCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    IsOfficeAddin: Boolean;
    CanCancelApprovalForRecord: Boolean;
    OpenApprovalEntriesExistForCurrUser: Boolean;
    NoFieldVisible: Boolean;
    NewMode: Boolean;
    CanRequestApprovalForFlow: Boolean;
    CanCancelApprovalForFlow: Boolean;
    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
        OpenApprovalEntriesExistForCurrUser:=ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist:=ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord:=ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        WorkflowWebhookMgt.GetCanRequestAndCanCancel(Rec.RecordId, CanRequestApprovalForFlow, CanCancelApprovalForFlow);
    end;
}

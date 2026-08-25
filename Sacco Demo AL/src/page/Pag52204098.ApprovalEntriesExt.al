page 52204098 "Approval Entries Ext"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Approval Entries Ext';
    PageType = List;
    SourceTable = "Approval Entry";
    UsageCategory = Lists;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the total amount (excl. VAT) on the document awaiting approval.';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ToolTip = 'Specifies the total amount (excl. VAT) on the document awaiting approval. The amount is stated in the local currency.';
                }
                field("Approval Code"; Rec."Approval Code")
                {
                    ToolTip = 'Specifies the value of the Approval Code field.', Comment = '%';
                }
                field("Approval Number"; Rec."Approval Number")
                {
                    ToolTip = 'Specifies the value of the Approval Number field.', Comment = '%';
                }
                field("Approval Type"; Rec."Approval Type")
                {
                    ToolTip = 'Specifies which approvers apply to this approval template:';
                }
                field("Approved By"; Rec."Approved By")
                {
                    ToolTip = 'Specifies the value of the Approved By field.', Comment = '%';
                }
                field("Approver ID"; Rec."Approver ID")
                {
                    ToolTip = 'Specifies the ID of the user who must approve the document.';
                }
                field("Approver Name"; Rec."Approver Name")
                {
                    ToolTip = 'Specifies the value of the Approver Name field.', Comment = '%';
                }
                field("Approver No"; Rec."Approver No")
                {
                    ToolTip = 'Specifies the value of the Approver No field.', Comment = '%';
                }
                field("Available Credit Limit (LCY)"; Rec."Available Credit Limit (LCY)")
                {
                    ToolTip = 'Specifies the remaining credit (in LCY) that exists for the customer.';
                }
                field(Comment; Rec.Comment)
                {
                    ToolTip = 'Specifies whether there are comments relating to the approval of the record. If you want to read the comments, choose the field to open the Approval Comment Sheet window.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the code of the currency of the amounts on the sales or purchase lines.';
                }
                field("Date-Time Sent for Approval"; Rec."Date-Time Sent for Approval")
                {
                    ToolTip = 'Specifies the date and the time that the document was sent for approval.';
                }
                field("Delegated By"; Rec."Delegated By")
                {
                    ToolTip = 'Specifies the value of the Delegated By field.', Comment = '%';
                }
                field("Delegated To"; Rec."Delegated To")
                {
                    ToolTip = 'Specifies the value of the Delegated To field.', Comment = '%';
                }
                field("Delegation Date Formula"; Rec."Delegation Date Formula")
                {
                    ToolTip = 'Specifies the value of the Delegation Date Formula field.', Comment = '%';
                }
                field(Department; Rec.Department)
                {
                    ToolTip = 'Specifies the value of the Department field.', Comment = '%';
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the document number copied from the relevant sales or purchase document, such as a purchase order or a sales quote.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the type of document that an approval entry has been created for. Approval entries can be created for six different types of sales or purchase documents:';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ToolTip = 'Specifies when the record must be approved, by one or more approvers.';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.', Comment = '%';
                }
                field("Is Delegated"; Rec."Is Delegated")
                {
                    ToolTip = 'Specifies the value of the Is Delegated field.', Comment = '%';
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ToolTip = 'Specifies the value of the Journal Batch Name field.', Comment = '%';
                }
                field("Last Date-Time Modified"; Rec."Last Date-Time Modified")
                {
                    ToolTip = 'Specifies the date when the approval entry was last modified. If, for example, the document approval is canceled, this field will be updated accordingly.';
                }
                field("Last Modified By User ID"; Rec."Last Modified By User ID")
                {
                    ToolTip = 'Specifies the ID of the user who last modified the approval entry. If, for example, the document approval is canceled, this field will be updated accordingly.';
                }
                field("Limit Type"; Rec."Limit Type")
                {
                    ToolTip = 'Specifies the type of limit that applies to the approval template:';
                }
                field("Number of Approved Requests"; Rec."Number of Approved Requests")
                {
                    ToolTip = 'Specifies the value of the Number of Approved Requests field.', Comment = '%';
                }
                field("Number of Rejected Requests"; Rec."Number of Rejected Requests")
                {
                    ToolTip = 'Specifies the value of the Number of Rejected Requests field.', Comment = '%';
                }
                field("Pending Approvals"; Rec."Pending Approvals")
                {
                    ToolTip = 'Specifies the value of the Pending Approvals field.', Comment = '%';
                }
                field("Record ID to Approve"; Rec."Record ID to Approve")
                {
                    ToolTip = 'Specifies the value of the Record ID to Approve field.', Comment = '%';
                }
                field("Related to Change"; Rec."Related to Change")
                {
                    ToolTip = 'Specifies the value of the Related to Change field.', Comment = '%';
                }
                field("Salespers./Purch. Code"; Rec."Salespers./Purch. Code")
                {
                    ToolTip = 'Specifies the code for the salesperson or purchaser that was in the document to be approved. It is not a mandatory field, but is useful if a salesperson or a purchaser responsible for the customer/vendor needs to approve the document before it is processed.';
                }
                field("Sender ID"; Rec."Sender ID")
                {
                    ToolTip = 'Specifies the ID of the user who sent the approval request for the document to be approved.';
                }
                field("Sender Name"; Rec."Sender Name")
                {
                    ToolTip = 'Specifies the value of the Sender Name field.', Comment = '%';
                }
                field("Sender No"; Rec."Sender No")
                {
                    ToolTip = 'Specifies the value of the Sender No field.', Comment = '%';
                }
                field("Sequence No."; Rec."Sequence No.")
                {
                    ToolTip = 'Specifies the order of approvers when an approval workflow involves more than one approver.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the approval status for the entry:';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.', Comment = '%';
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedBy field.', Comment = '%';
                }
                field(SystemId; Rec.SystemId)
                {
                    ToolTip = 'Specifies the value of the SystemId field.', Comment = '%';
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedAt field.', Comment = '%';
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedBy field.', Comment = '%';
                }
                field("Table ID"; Rec."Table ID")
                {
                    ToolTip = 'Specifies the ID of the table where the record that is subject to approval is stored.';
                }
                field("Workflow Step Instance ID"; Rec."Workflow Step Instance ID")
                {
                    ToolTip = 'Specifies the value of the Workflow Step Instance ID field.', Comment = '%';
                }
            }
        }
    }
}

page 52203560 "Self Service Approval Setup"
{
    SourceTable = "User Setup";

    layout
    {
        area(content)
        {
            repeater(Control16)
            {
                ShowCaption = false;

                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ID of the user who posted the entry, to be used, for example, in the change log.';
                }
                field("Salespers./Purch. Code"; Rec."Salespers./Purch. Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the salesperson or purchaser code that relates to the User ID field.';
                    Visible = false;
                }
                field("Approver ID"; Rec."Approver ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the user ID of the person who must approve records that are made by the user in the User ID field before the record can be released.';
                }
                field("Sales Amount Approval Limit"; Rec."Sales Amount Approval Limit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the maximum amount in LCY that this user is allowed to approve for this record.';
                    Visible = false;
                }
                field("Unlimited Sales Approval"; Rec."Unlimited Sales Approval")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the user on this line is allowed to approve sales records with no maximum amount. If you select this check box, then you cannot fill the Sales Amount Approval Limit field.';
                    Visible = false;
                }
                field("Purchase Amount Approval Limit"; Rec."Purchase Amount Approval Limit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the maximum amount in LCY that this user is allowed to approve for this record.';
                    Visible = false;
                }
                field("Unlimited Purchase Approval"; Rec."Unlimited Purchase Approval")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the user on this line is allowed to approve purchase records with no maximum amount. If you select this check box, then you cannot fill the Purchase Amount Approval Limit field.';
                    Visible = false;
                }
                field("Request Amount Approval Limit"; Rec."Request Amount Approval Limit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the maximum amount in LCY that this user is allowed to approve for this record.';
                    Visible = false;
                }
                field("Unlimited Request Approval"; Rec."Unlimited Request Approval")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the user on this line can approve all purchase quotes regardless of their amount. If you select this check box, then you cannot fill the Request Amount Approval Limit field.';
                    Visible = false;
                }
                field(Substitute; Rec.Substitute)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the User ID of the user who acts as a substitute for the original approver.';
                    Visible = false;
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = EMail;
                    ToolTip = 'Specifies the email address of the approver that you can use if you want to send approval mail notifications.';
                    Visible = false;
                }
                field("Approval Administrator"; Rec."Approval Administrator")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the user who has rights to unblock approval workflows, for example, by delegating approval requests to new substitute approvers and deleting overdue approval requests.';
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control2; Links)
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
            systempart(Control1; Notes)
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.SetFilter("User ID", UserId);
    end;
}

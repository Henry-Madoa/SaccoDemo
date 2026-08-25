page 52204204 "Member Mgmt Role Center"
{
    // CurrPage."Help And Setup List".ShowFeatured;Caption = 'HR Role Center';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            part(Part1; "Sacco Cues")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    actions
    {
        area(embedding)
        {
            action("Member Categories")
            {
                ApplicationArea = Basic, Suite;
                Image = BankAccount;
                RunObject = Page "Member Categories";
            }
            action("Membership Application")
            {
                ApplicationArea = Basic, Suite;
                RunObject = Page "Member Applications";
            }
            action(Members)
            {
                ApplicationArea = Basic, Suite;
                RunObject = page Members;
            }
            action("Member Accounts")
            {
                ApplicationArea = Basic, Suite;
                RunObject = page "Member Accounts List";
            }
            action("&General Ledger Setup")
            {
                ApplicationArea = Basic, Suite;
                RunObject = Page "General Ledger Setup";
                ToolTip = 'Open the list of employees.';
            }
        }
        area(sections)
        {
            group(Approvals)
            {
                Caption = 'Approvals';
                ToolTip = 'Approve requests made by other users.';

                action("Requests to Approve")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Requests to Approve';
                    Image = Approvals;
                    RunObject = Page "Requests to Approve";
                    ToolTip = 'View the number of approval requests that require your approval.';
                }
                action("Approval Requests")
                {
                    RunObject = page "Approval Request Entries";
                }
            }
            group("Membership Applications")
            {
                action(MembershipApplicationsOpen)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'New';
                    RunObject = Page "Member Applications";
                    RunPageView = where(Status = const(Open));
                }
                action(MembershipApplicationsPendingApproval)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pending Approval';
                    RunObject = Page "Member Applications";
                    RunPageView = where(Status = const("Pending Approval"));
                }
                action(MembershipApplicationsApproved)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Approved';
                    RunObject = Page "Member Applications";
                    RunPageView = where(Status = const(Approved), Processed = const(false));
                }
                action(MembershipApplicationsProcessed)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Processed';
                    RunObject = Page "Member Applications";
                    RunPageView = where(Status = const(Approved), Processed = const(true));
                }
                action("Member List")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page Members;
                }
            }
            group("Account Opening")
            {
                action("NewAccountOpening")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Open';
                    RunObject = page "Account Openings";
                    RunPageView = where(Status = const(Open));
                }
                action("Pending Account Opening")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pending Approval';
                    RunObject = page "Account Openings";
                    RunPageView = where(Status = const("Pending Approval"));
                }
                action("Processed Account Opening")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Processed';
                    RunObject = page "Account Openings";
                    RunPageView = where(Status = const(Approved), Processed = const(true));
                }
            }
            group("Account Deactivation")
            {
                action("New Member Account Deactivations")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Open';
                    RunObject = page "Member Account Deactivations";
                    RunPageView = where(Status = const(Open));
                }
                action("Pending Member Account Deactivations")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pending Approval';
                    RunObject = page "Member Account Deactivations";
                    RunPageView = where(Status = const("Pending Approval"));
                }
                action("Approved Member Account Deactivations")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Approved';
                    RunObject = page "Member Account Deactivations";
                    RunPageView = where(Status = const(Approved), Processed = const(false));
                }
                action("Processed Member Account Deactivations")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Processed';
                    RunObject = page "Member Account Deactivations";
                    RunPageView = where(Status = const(Approved), Processed = const(true));
                }
            }
            group("Account Activation")
            {
                action("New Member Account Activations")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Open';
                    RunObject = page "Member Account Activations";
                    RunPageView = where(Status = const(Open));
                }
                action("Pending Member Account Activations")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pending Approval';
                    RunObject = page "Member Account Activations";
                    RunPageView = where(Status = const("Pending Approval"));
                }
                action("Approved Member Account Activations")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Approved';
                    RunObject = page "Member Account Activations";
                    RunPageView = where(Status = const(Approved), Processed = const(false));
                }
                action("Processed Member Account Activations")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Processed';
                    RunObject = page "Member Account Activations";
                    RunPageView = where(Status = const(Approved), Processed = const(true));
                }
            }
            group(MemberUpdate)
            {
                Caption = 'Member Editing';

                action("&New")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Member Editings";
                    RunPageView = where(Status = const(Open));
                }
                action("&Pending Approval")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Member Editings";
                    RunPageView = where(Status = const("Pending Approval"));
                }
                action("&Approved")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Member Editings";
                    RunPageView = where(Status = const(Approved), Processed = const(false));
                }
                action("&Processed")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Member Editings";
                    RunPageView = where(Status = const(Approved), Processed = const(true));
                }
                action("Member Versions")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Member Versions";
                }
            }
            group("Dividend Management")
            {
                action("New Dividends")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Open';
                    RunObject = page "BOSA Dividends";
                    RunPageView = where(Status = const(Open));
                }
                action("Pending Dividends")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pending Approval';
                    RunObject = page "BOSA Dividends";
                    RunPageView = where(Status = const("Pending Approval"));
                }
                action("Approved Dividends")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Approved';
                    RunObject = page "BOSA Dividends";
                    RunPageView = where(Status = const(Approved), Posted = const(false));
                }
                action("Processed Dividends")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted';
                    RunObject = page "BOSA Dividends";
                    RunPageView = where(Status = const(Approved), Posted = const(true));
                }
            }
            group("Member Exit")
            {
                action("New Member Withdrawal")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'New';
                    RunObject = page "Member Exits";
                    RunPageView = where(Status = const(Open));
                }
                action("Pending Member Withdrawal")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pending Approval';
                    RunObject = page "Member Exits";
                    RunPageView = where(Status = const("Pending Approval"));
                }
                action("Approved Member Exits")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Approved';
                    RunObject = page "Member Exits";
                    RunPageView = where(Status = const(Approved), Posted = const(false));
                }
                action("Processed Member Exit")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Processed';
                    RunObject = page "Member Exits";
                    RunPageView = where(Status = const(Approved), Posted = const(true));
                }
            }
            group("Member Reactivations")
            {
                action("New Member Reactivation")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'New';
                    RunObject = Page "Member Activations";
                    RunPageView = where(Status = const(Open));
                }
                action("Pending Member Reactivation")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pending Approval';
                    RunObject = Page "Member Activations";
                    RunPageView = where(Status = const("Pending Approval"));
                }
                action("Approved Member Reactivation")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pending Approval';
                    RunObject = Page "Member Activations";
                    RunPageView = where(Status = const(Approved), Posted = const(false));
                }
                action("Processed Member Reactivation")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pending Approval';
                    RunObject = Page "Member Activations";
                    RunPageView = where(Status = const(Approved), Posted = const(true));
                }
            }
            group("&Receipts")
            {
                action(New_Receipt)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'New';
                    RunObject = Page "Receipts";
                    RunPageView = where(Status = const(Open));
                }
                action(PendingApproval_Receipt)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pending Approval';
                    RunObject = Page "Receipts";
                    RunPageView = where(Status = const("Pending Approval"));
                }
                action(Approved_Receipt)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Approved';
                    RunObject = Page "Receipts";
                    RunPageView = where(Status = const(Approved), Posted = const(false));
                }
                action(Posted_Receipt)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Receipts';
                    RunObject = Page "Receipts";
                    RunPageView = where(Status = const(Approved), Posted = const(true));
                }
            }
            group("Reports & Analysis")
            {
                action("Member &List")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = report "Member List";
                }
                action("Member Statement")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = report "Member Statement";
                }
            }
            group("Bulk SMS")
            {
                action("New Bulk SMS")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'New';
                    RunObject = page "Bulk SMS List";
                    RunPageView = where(Sent = const(false));
                }
                action("Sent Bulk SMS")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sent';
                    RunObject = page "Bulk SMS List";
                    RunPageView = where(Sent = const(true));
                }
            }
            group("Channel Mgmt.")
            {
                group("Mobile Applications")
                {
                    action("New Mobile Applications")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Open';
                        RunObject = page "Mobile Applications";
                        RunPageView = where(Status = const(Open));
                    }
                    action("Pending Mobile Applications")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = page "Mobile Applications";
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("Approved Mobile Applications")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = page "Mobile Applications";
                        RunPageView = where(Status = const(Approved), Processed = const(false));
                    }
                    action("Processed Mobile Applications")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Processed';
                        RunObject = page "Mobile Applications";
                        RunPageView = where(Status = const(Approved), Processed = const(true));
                    }
                }
                action("Mobile Members")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Mobile Members";
                }
                group(Loans)
                {
                    action("Online Guarantor Substitutions")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Channel Guarantor Mgmt.";
                    }
                    action("Online Guarantor Requests")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Channel Guarantor Requests";
                    }
                    action("Online Uploads")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Document Uploads";
                    }
                    action("Guarantor Subsitutions")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Channel Guarantor Sub.";
                    }
                }
                action("Mobile Ledger")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Mobile Ledger";
                }
                action("Mobile Responses")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Mobile Responses";
                }
                action("Mobile Transactions Dump")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Mobile Transactions Dump";
                }
                action("Mobile Transactions Archive")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Archived Channel Transactions";
                }
                group("Channel Loan Applications")
                {
                    Caption = 'Loan Application';

                    action("NewLoanApplications")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New';
                        RunObject = page "Channel Loan Applications";
                        RunPageView = where("Portal Status" = const(New));
                    }
                    action("PendingApprovalLoanApplications")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Submitted';
                        RunObject = page "Channel Loan Applications";
                        RunPageView = where("Portal Status" = const(Submitted));
                    }
                    action("ApprovedLoanApplications")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Processing';
                        RunObject = page "Channel Loan Applications";
                        RunPageView = where("Portal Status" = const(Processing));
                    }
                }
                group("Guarantor Requests")
                {
                    action("NewGuarantorRequests")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New';
                        RunObject = page "Channel Guarantor Requests";
                        RunPageView = where(Status = const(Open));
                    }
                    action("PendingApprovalGuarantorRequests")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = page "Channel Guarantor Requests";
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("ApprovedGuarantorRequests")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Accepted';
                        RunObject = page "Channel Guarantor Requests";
                        RunPageView = where(Status = const(Approved));
                    }
                }
                action("ChannelGuarantorSub")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Channel Guarantor Substitution';
                    RunObject = page "Channel Guarantor Sub.";
                }
                action("Incoming Channels Transactions")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Channels Transactions";
                }
                action("Channel Feedbacks")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Channel Feedbacks";
                }
            }
        }
    }
}

page 52204000 "Role Center"
{
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            part(Part1; "Headline RC Accountant")
            {
                ApplicationArea = Basic, Suite;
            }
            part(Part2; "Sacco Cues")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    actions
    {
        area(embedding)
        {
            action("Change My Role Center")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Change My Role Center';
                Image = PersonInCharge;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Codeunit "User Profile Management";
            }
            action("Approval Status")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                RunObject = page "Approval Status";
            }
            action(ChartofAccounts)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Chart of Accounts';
                RunObject = Page "Chart of Accounts";
                ToolTip = 'Open the chart of accounts.';
            }
            action(Action96)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Financial Reports';
                RunObject = Page "Financial Reports";
                ToolTip = 'Open your account schedules to analyze figures in general ledger accounts or to compare general ledger entries with general ledger budget entries.';
            }
            action(AccountsCategories)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Accounts Categories';
                RunObject = Page "G/L Account Categories";
            }
            action("Bank Accounts")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Bank Accounts';
                Image = BankAccount;
                RunObject = Page "Bank Account List";
                ToolTip = 'View or set up detailed information about your bank account, such as which currency to use, the format of bank files that you import and export as electronic payments, and the numbering of checks.';
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
            group("Products Management")
            {
                group("Product Appplications")
                {
                    action("Open Product Appplications")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Open';
                        RunObject = page "Product Appplications";
                        RunPageView = where(Status = const(Open));
                    }
                    action("Product Appplications Pending Approval")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = page "Product Appplications";
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("Approved Product Appplications")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = page "Product Appplications";
                        RunPageView = where(Status = const(Approved), Processed = const(false));
                    }
                    action("Processed Product Appplications")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Processed';
                        RunObject = page "Product Appplications";
                        RunPageView = where(Status = const(Approved), Processed = const(true));
                    }
                }
                action("Sacco Products")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Sacco Products";
                }
                group("Product Editing")
                {
                    action("Open Product Editings")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Open';
                        RunObject = page "Product Editings";
                        RunPageView = where(Status = const(Open));
                    }
                    action("Product Editings Pending Approval")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = page "Product Editings";
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("Approved Product Editings")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = page "Product Editings";
                        RunPageView = where(Status = const(Approved), Processed = const(false));
                    }
                    action("Processed Product Editings")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Processed';
                        RunObject = page "Product Editings";
                        RunPageView = where(Status = const(Approved), Processed = const(true));
                    }
                }
            }
            group(Membership)
            {
                Caption = 'Client Relationship Management';

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
                }
                action("Member List")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page Members;
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
                group("BOSA Dividend Management")
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
                }
                action("Member Versions")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Member Versions";
                }
                group("Member Refund")
                {
                    action("New Member Refund")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New';
                        RunObject = page "Member Refunds";
                        RunPageView = where("Document Type" = const(Refund), Status = const(Open));
                    }
                    action("Pending Member Refund")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = page "Member Refunds";
                        RunPageView = where("Document Type" = const(Refund), Status = const("Pending Approval"));
                    }
                    action("Approved Member Refund")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = page "Member Refunds";
                        RunPageView = where("Document Type" = const(Refund), Status = const(Approved), Posted = const(false));
                    }
                    action("Processed Member Refund")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Processed';
                        RunObject = page "Member Refunds";
                        RunPageView = where("Document Type" = const(Refund), Status = const(Approved), Posted = const(true));
                    }
                }
                group("Member Exit")
                {
                    action("New Member Exit")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New';
                        RunObject = page "Member Exits";
                        RunPageView = where("Document Type" = const(Withdrawal), Status = const(Open));
                    }
                    action("Pending Member Exit")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = page "Member Exits";
                        RunPageView = where("Document Type" = const(Withdrawal), Status = const("Pending Approval"));
                    }
                    action("Approved Member Exits")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = page "Member Exits";
                        RunPageView = where("Document Type" = const(Withdrawal), Status = const(Approved), Posted = const(false));
                    }
                    action("Processed Member Exit")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Processed';
                        RunObject = page "Member Exits";
                        RunPageView = where("Document Type" = const(Withdrawal), Status = const(Approved), Posted = const(true));
                    }
                }
                group("Benevolent Fund")
                {
                    action("New Benevolent Fund")
                    {
                        Caption = 'Open';
                        RunObject = page "Benevolent Funds";
                        RunPageView = where(Status = const(Open));
                    }
                    action("Pending Benevolent Fund")
                    {
                        Caption = 'Pending Approval';
                        RunObject = page "Benevolent Funds";
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("Approved Benevolent Fund")
                    {
                        Caption = 'Approved';
                        RunObject = page "Benevolent Funds";
                        RunPageView = where(Status = const(Approved), Processed = const(false));
                    }
                    action("Processed Benevolent Fund")
                    {
                        Caption = 'Processed';
                        RunObject = page "Benevolent Funds";
                        RunPageView = where(Status = const(Approved), Processed = const(true));
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
                        Caption = 'Approved';
                        RunObject = Page "Member Activations";
                        RunPageView = where(Status = const(Approved), Posted = const(false));
                    }
                    action("Processed Member Reactivation")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Processed';
                        RunObject = Page "Member Activations";
                        RunPageView = where(Status = const(Approved), Posted = const(true));
                    }
                }
                group("Member Charging")
                {
                    action(NewMemberChargings)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Open';
                        RunObject = page "Member Chargings";
                        RunPageView = where(Posted = const(false));
                    }
                    action(PostedMemberChargings)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted';
                        RunObject = page "Member Chargings";
                        RunPageView = where(Posted = const(true));
                    }
                }
                group("&Receipts")
                {
                    action("&NewReceipt")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New';
                        RunObject = Page "Receipts";
                        RunPageView = where(Status = const(Open), Posted = const(false));
                    }
                    action("Pending Approval Receipt")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = Page "Receipts";
                        RunPageView = where(Status = const("Pending Approval"), Posted = const(false));
                    }
                    action("&ApprovedReceipt")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = Page "Receipts";
                        RunPageView = where(Status = const(Approved), Posted = const(false));
                    }
                    action("&PostedReceipt")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted Receipts';
                        RunObject = Page "Receipts";
                        RunPageView = where(Posted = const(true));
                    }
                }
                group("&Journal Vouchers")
                {
                    action("&Journal Vouchers&")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New';
                        RunObject = Page "Journal Vouchers";
                        RunPageView = where(Status = const(Open), Posted = const(false));
                    }
                    action("Pending Approval Journal Vouchers")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = Page "Journal Vouchers";
                        RunPageView = where(Status = const("Pending Approval"), Posted = const(false));
                    }
                    action("&Approved Journal Vouchers")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = Page "Journal Vouchers";
                        RunPageView = where(Status = const(Approved), Posted = const(false));
                    }
                    action("&Posted Journal Vouchers")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted Receipts';
                        RunObject = Page "Journal Vouchers";
                        RunPageView = where(Posted = const(true));
                    }
                }
                group("Membership Period Activities")
                {
                    Caption = 'Periodic Activities';

                    action("Member Status Update")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Update Member Status";
                    }
                }
                group("Reports & Analysis")
                {
                    action("&Member List")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Member List";
                    }
                    action("Savings & Loan Listing")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Savings And Loan Listing";
                    }
                    action("&GL Balance vs Listing")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "GL Balance vs Listing";
                    }
                    action("Member Next Of KIN")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Member KINS";
                    }
                    action("Member Statement")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Member Statement";
                    }
                    action("Risk Categorization")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Risk Categorization";
                    }
                    action("&Contribution Classification")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Contribution Classification";
                    }
                    action("&Savings and Loans listing Report")
                    {
                        ApplicationArea = Basic, Suite;
                        Visible = false;
                        RunObject = report "Savings And Loan Listing";
                    }
                    action("&GLBalancevs Listing")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'GL Balance vs Listing';
                        RunObject = report "GL Balance vs Listing";
                    }
                }
            }
            group("&Credit")
            {
                Caption = 'Credit';

                action("Loan Calculator")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Loan Calculators";
                }
                group(Collaterals)
                {
                    group("Collateral Applications")
                    {
                        action("New Collateral Applications")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'New';
                            RunObject = page "Collateral Applications";
                            RunPageView = where(Status = const(Open));
                        }
                        action("Pending Approval Collateral Applications")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Pending Approval';
                            RunObject = page "Collateral Applications";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("Approved Collateral Applications")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved';
                            RunObject = page "Collateral Applications";
                            RunPageView = where(Status = const(Approved), Posted = const(false));
                        }
                        action("Posted Collateral Applications")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Posted';
                            RunObject = page "Collateral Applications";
                            RunPageView = where(Status = const(Approved), Posted = const(true));
                        }
                    }
                    action("Collateral Register")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Collateral Registers";
                    }
                    group("Collateral Release")
                    {
                        action("New Collateral Releases")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'New';
                            RunObject = page "Collateral Releases";
                            RunPageView = where(Status = const(Open));
                        }
                        action("Pending Approval Collateral Releases")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Pending Approval';
                            RunObject = page "Collateral Releases";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("Approved Collateral Releases")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved';
                            RunObject = page "Collateral Releases";
                            RunPageView = where(Status = const(Approved), Posted = const(false));
                        }
                        action("Released Collateral Releases")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Released';
                            RunObject = page "Collateral Releases";
                            RunPageView = where(Status = const(Approved), Posted = const(true));
                        }
                    }
                }
                group("Loan Processing")
                {
                    action("New Loan Applications")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New';
                        RunObject = page Loans;
                        RunPageView = where(Status = const(Open));
                    }
                    action("Loans Pending Approval")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = page Loans;
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("Approved Loans")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = page Loans;
                        RunPageView = where(Status = const(Approved), Posted = const(false), "Source Type" = const(CoreBanking));
                    }
                    action("Running Loans")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Running';
                        RunObject = page Loans;
                        RunPageView = where(Status = const(Approved), Posted = const(true), "Loan Balance" = filter(<> 0), Closed = const(False));
                    }
                    action("Cleared Loans")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Cleared';
                        RunObject = page Loans;
                        RunPageView = where(Status = const(Approved), Posted = const(true), "Loan Balance" = filter(= 0), Restructured = const(false));
                    }
                    action("Restructured Loans")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Restructured';
                        RunObject = page Loans;
                        RunPageView = where(Status = const(Approved), Posted = const(true), "Loan Balance" = filter(= 0), Restructured = const(true));
                    }
                    action("Archived Loans")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Archived';
                        RunObject = page Loans;
                        RunPageView = where(Status = const(Archived));
                    }
                }
                group("Loan Disbursements")
                {
                    action("New Loan Disbursements")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New';
                        RunObject = page "Loan Disbursements";
                        RunPageView = where(Status = const(Open));
                    }
                    action("Loan Disbursements Pending Approval")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = page "Loan Disbursements";
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("Approved Loan Disbursements")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = page "Loan Disbursements";
                        RunPageView = where(Status = const(Approved), Processed = const(false));
                    }
                    action("Processed Loan Disbursements")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Processed';
                        RunObject = page "Loan Disbursements";
                        RunPageView = where(Status = const(Approved), Processed = const(true));
                    }
                }
                group("Loan Batching")
                {
                    action("New Loan Batches")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New';
                        RunObject = page "Loan Batches";
                        RunPageView = where(Status = const(Open));
                    }
                    action("Pending Loan Batches")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = page "Loan Batches";
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("Approved Loan Batches")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = page "Loan Batches";
                        RunPageView = where(Status = const(Approved), Posted = const(false));
                    }
                    action("Posted Loan Batches")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted';
                        RunObject = page "Loan Batches";
                        RunPageView = where(Status = const(Approved), Posted = const(true));
                    }
                }
                action("Channels Transactions")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Channels Transactions";
                }
                group("Guarantor Management")
                {
                    action("New Guarantor Substitution")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New';
                        RunObject = page "Loan Security Mgts.";
                        RunPageView = where(Status = const(Open));
                    }
                    action("Pending Guarantor Substitution")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = page "Loan Security Mgts.";
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("Approved Guarantor Substitution")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = page "Loan Security Mgts.";
                        RunPageView = where(Status = const(Approved), Processed = const(false));
                    }
                    action("Posted Guarantor Substitution")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Processed';
                        RunObject = page "Loan Security Mgts.";
                        RunPageView = where(Status = const(Approved), Processed = const(true));
                    }
                }
                group("Loan Moratorium")
                {
                    action("New Loan Moratorium")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New';
                        RunObject = page "Loan Moratoriums";
                        RunPageView = where(Status = const(Open));
                    }
                    action("Pending Loan Moratorium")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = page "Loan Moratoriums";
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("Approved Loan Moratorium")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = page "Loan Moratoriums";
                        RunPageView = where(Status = const(Approved), Posted = const(false));
                    }
                    action("Posted Loan Moratorium")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted';
                        RunObject = page "Loan Moratoriums";
                        RunPageView = where(Status = const(Approved), Posted = const(true));
                    }
                }
                group("&PeriodicActivities")
                {
                    Caption = 'Periodic Activities';

                    group("Periodic Tasks")
                    {
                        action("Generate Ageing")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Generate Loan Ageing";
                            Image = AdjustExchangeRates;
                        }
                        action("Recover Mobi Loans")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Mobi Loans Recovery";
                        }
                        action("Send Mobi Loan Reminders")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Mobi Loans Reminder";
                        }
                        action("Transfer Share Capital")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Share Capital Transfer";
                        }
                        action("Recover Entrance Fee")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Entrance Fee Recovery";
                        }
                    }
                    group("Checkoff Variation")
                    {
                        action("New Checkoff Variations")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Checkoff Variations";
                            RunPageView = where(Status = const(New));
                        }
                        action("Checkoff Variations")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Checkoff Variations";
                            RunPageView = where(Processed = const(false), Status = const(Submitted));
                        }
                        action("Processed Checkoff Variations")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Checkoff Variations";
                            RunPageView = where(Processed = const(true));
                        }
                        action("CheckOff Advice")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Checkoff Advice";
                        }
                    }
                    action("Bill Interest")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Interest Billing";
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
                }
                group("Loan Repayments")
                {
                    action("New Loan Repayments")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New';
                        RunObject = page "Loan Repayments";
                        RunPageView = Where(Posted = const(false));
                    }
                    action("Posted Loan Repayments")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted';
                        RunObject = page "Loan Repayments";
                        RunPageView = Where(Posted = const(true));
                    }
                }
                group("Loan Recovery")
                {
                    group("Demand Notes")
                    {
                        action("Prepare Defaulter Notice")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'New';
                            RunObject = page "Defaulter Notices";
                            RunPageView = where(Processed = const(false));
                        }
                        action("Processed Defaulter Notice")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Processed';
                            RunObject = page "Defaulter Notices";
                            RunPageView = where(Processed = const(true));
                        }
                    }
                    action("New Loan Recovery")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New';
                        RunObject = page "Loan Recovery List";
                        RunPageView = where(Status = const(Open));
                    }
                    action("Pending Loan Recovery")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = page "Loan Recovery List";
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("Approved Loan Recovery")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = page "Loan Recovery List";
                        RunPageView = where(Status = const(Approved), Processed = const(false));
                    }
                    action("Posted Loan Recovery")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted';
                        RunObject = page "Loan Recovery List";
                        RunPageView = where(Processed = const(true));
                    }
                }
                group("Analysis & Reporting")
                {
                    group("&SASRA Reports_")
                    {
                        Caption = '&SASRA Reports';

                        action("&Sectorial Lending Return_")
                        {
                            ApplicationArea = Basic, Suite;
                            Image = "Report";
                            RunObject = Report "Sectorial Lending";
                            Caption = '&Sectorial Lending Return';
                        }
                        action("&Statement of Deposit Return_")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Statement of Deposit Return';
                            Image = VendorLedger;
                            RunObject = report "Statement of Deposit Rtn.";
                        }
                        action("&Risk Classification_")
                        {
                            ApplicationArea = Basic, Suite;
                            Image = Aging;
                            Caption = '&Risk Classification';
                            RunObject = report "Risk Classification";
                        }
                    }
                    action("&Collateral Register")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Collateral Register";
                    }
                    action("&Collateral Release")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Collateral Release";
                    }
                    action("Loan Register")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Loan Register";
                    }
                    action("Posted Loans")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page Loans;
                        RunPageView = where(posted = const(true));
                    }
                    action("Loan Banding")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Loan Banding";
                    }
                    action("Loan Streaming")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Loan Streaming";
                    }
                    action("Loan Processing Perfomance")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Loan Processing Perfomance";
                    }
                    action("Loan Transactions")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Loan Transactions";
                    }
                    action("&Mobile Loan Eligibility")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Mobile Loan Eligibility";
                    }
                    action("&Loan Payments Due")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Payments Due";
                    }
                    action("Loan Defaulters Ageing_")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Loan Defaulters Ageing';
                        RunObject = report "Loan Defaulters";
                    }
                    action("Generate Defaulters_")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Generate Defaulters';
                        RunObject = report "Gen. Loan Defaulters";
                    }
                    action("Loan Aging Analysis_")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Loan Aging Analysis';
                        RunObject = report "Loan Ageing Analysis";
                    }
                    action("Loan Issued Summary report_")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Loan Issued Summary Report';
                        RunObject = report "Disbursement Summary";
                    }
                    action("Loans balances Summary_")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Loans balances Summary';
                        RunObject = report "Loan Balances Summary";
                    }
                    action("Loan guaranteed report_")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Loan guaranteed report';
                        RunObject = report "Member Guarantees";
                    }
                    action("Loan guarantors Report_")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Loan guarantors Report';
                        RunObject = report "Member Guarantors";
                    }
                    action("Savings and Loans listing Report_")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Savings and Loans listing Report';
                        RunObject = report "Savings And Loan Listing";
                    }
                    action("&Contribution Classification&")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Contribution Classification';
                        RunObject = report "Contribution Classification";
                    }
                    action("GLBalancevsListing")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'GL Balance vs Listing';
                        RunObject = report "GL Balance vs Listing";
                    }
                    action("Interest Variance_")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Interest Variance';
                        RunObject = report "Loan Transactions";
                    }
                    action("Underpaid Principal_")
                    {
                        Caption = 'Underpaid Principal';
                        RunObject = report "Underpaid Principal";
                    }
                    action("Progression Report_")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Progression Report';
                        RunObject = report "Progression Report";
                    }
                    action("Guarantor Register_")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Guarantor Register';
                        RunObject = report "Guarantor Register";
                    }
                    action("Loan Defaulters_")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Loan Defaulters';
                        RunObject = report Defaulters;
                    }
                    action("Recovery Advice_")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Recovery Advice';
                        RunObject = report "Checkoff Advise";
                    }
                    action("Loan Recoveries_")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Loan Recoveries';
                        RunObject = report "Loan Recovery";
                    }
                    action("Variance Report_")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Variance Report';
                        RunObject = report "Variance Report";
                    }
                }
            }
            group(FOSA)
            {
                group("Tellering/Treasury")
                {
                    group("Cash Deposit/Withdrawal")
                    {
                        action("New Cash Deposit/Withdrawal")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'New';
                            RunObject = page "Teller Transactions";
                            RunPageView = where(Status = const(Open));
                        }
                        action("Pending Approval Cash Deposit/Withdrawal")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Pending Approval';
                            RunObject = page "Teller Transactions";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("Approved Cash Deposit/Withdrawal")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved';
                            RunObject = page "Teller Transactions";
                            RunPageView = where(Status = const(Approved), Posted = const(false));
                        }
                        action("Posted Teller Transactions")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Posted';
                            RunObject = page "Teller Transactions";
                            RunPageView = where(Status = const(Approved), Posted = const(true));
                        }
                    }
                    group("Receive From Bank")
                    {
                        action("New Receive From Bank")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'New';
                            RunObject = page "Receive From Banks";
                            RunPageView = where(Posted = const(false));
                        }
                        action("Received Receive From Bank")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Received';
                            RunObject = page "Receive From Banks";
                            RunPageView = where(Posted = const(true));
                        }
                    }
                    group("Treasury Requests")
                    {
                        action("New Treasury Requests")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'New';
                            RunObject = page "Treasury Requests";
                            RunPageView = where(Status = const(Open));
                        }
                        action("Treasury Requests Pending Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Pending Approval';
                            RunObject = page "Treasury Requests";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("Approved Treasury Requests")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved';
                            RunObject = page "Treasury Requests";
                            RunPageView = where(Status = const(Approved), Posted = const(false));
                        }
                        action("Received Treasury Requests")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Received';
                            RunObject = page "Treasury Requests";
                            RunPageView = where(Posted = const(true));
                        }
                    }
                    group("Inter Teller Transfer")
                    {
                        action("New Inter Teller Transfer")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'New';
                            RunObject = page "Inter Teller Transfers";
                            RunPageView = where(Status = filter(Open | Approved), Posted = const(false));
                        }
                        action("Inter Teller TransferPending Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Pending Approval';
                            RunObject = page "Inter Teller Transfers";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("Approved Inter Teller Transfer")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved';
                            RunObject = page "Inter Teller Transfers";
                            RunPageView = where(Status = const(Approved), Posted = const(false));
                        }
                        action("Received Inter Teller Transfer")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Received';
                            RunObject = page "Inter Teller Transfers";
                            RunPageView = where(Posted = const(true));
                        }
                    }
                    group("Treasury Returns")
                    {
                        action("New Treasury Returns")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'New';
                            RunObject = page "Treasury Returns";
                            RunPageView = where(Status = const(Open));
                        }
                        action("Treasury Returns Pending Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Pending Approval';
                            RunObject = page "Treasury Returns";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("Approved Treasury Returns")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved';
                            RunObject = page "Treasury Returns";
                            RunPageView = where(Status = const(Approved), Posted = const(false));
                        }
                        action("Received Treasury Returns")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Returned';
                            RunObject = page "Treasury Returns";
                            RunPageView = where(Posted = const(true));
                        }
                    }
                    group("Send to Bank")
                    {
                        action("New Send to Bank")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'New';
                            RunObject = page "Send To Banks";
                            RunPageView = where(Posted = const(false));
                        }
                        action("Sent Send to Bank")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Sent';
                            RunObject = page "Send To Banks";
                            RunPageView = where(Posted = const(true));
                        }
                    }
                }
                group(Lien)
                {
                    action("New Liens")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Open';
                        RunObject = page Liens;
                        RunPageView = where(Status = const(Open));
                    }
                    action("Pending Liens")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = page Liens;
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("Approved Liens")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = page Liens;
                        RunPageView = where(Status = const(Approved), Processed = const(false));
                    }
                    action("Posted Liens")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted';
                        RunObject = page Liens;
                        RunPageView = where(Status = const(Approved), Processed = const(true));
                    }
                }
                group("Inter Account Transfers")
                {
                    action("New Inter Account Transfers")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Open';
                        RunObject = page "Inter Account Transfers";
                        RunPageView = where(Status = const(Open));
                    }
                    action("Pending Inter Account Transfers")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = page "Inter Account Transfers";
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("Approved Inter Account Transfers")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = page "Inter Account Transfers";
                        RunPageView = where(Status = const(Approved), Posted = const(false));
                    }
                    action("Posted Inter Account Transfers")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted';
                        RunObject = page "Inter Account Transfers";
                        RunPageView = where(Status = const(Approved), Posted = const(true));
                    }
                }
                group("Bankers Cheques")
                {
                    action("New Bankers Cheques")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New';
                        RunObject = page "Bankers Cheques";
                        RunPageView = where(Status = const(Open));
                    }
                    action("Bankers Cheques Pending Approval")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = page "Bankers Cheques";
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("Approved Bankers Cheques")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = page "Bankers Cheques";
                        RunPageView = where(Status = const(Approved), Posted = const(false));
                    }
                    action("Received Bankers Cheques")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted';
                        RunObject = page "Bankers Cheques";
                        RunPageView = where(Posted = const(true));
                    }
                    group("Bankers Cheques Setup")
                    {
                        Caption = 'Setups';

                        action("Bankers Cheque Types")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Bankers Cheque Types";
                        }
                    }
                }
                group("Cheque Book Applications")
                {
                    action("New Cheque Book Applications")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New';
                        RunObject = page "Cheque Book Applications";
                        RunPageView = where(Status = const(Open));
                    }
                    action("Cheque Book Applications Pending Approval")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = page "Cheque Book Applications";
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("Approved Cheque Book Applications")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = page "Cheque Book Applications";
                        RunPageView = where(Status = const(Approved), Processed = const(false));
                    }
                    action("Posted Cheque Book Applications")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Collected';
                        RunObject = page "Cheque Book Applications";
                        RunPageView = where(Processed = const(true));
                    }
                }
                action("Check Books")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Cheque Books";
                }
                group("Cheque Clearance")
                {
                    Visible = false;

                    action("New Cheque Clearances")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New';
                        RunObject = page "Cheque Clearances";
                        RunPageView = where(Status = const(Open));
                    }
                    action("Cheque Clearances Pending Approval")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = page "Cheque Clearances";
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("Approved Cheque Clearances")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = page "Cheque Clearances";
                        RunPageView = where(Status = const(Approved));
                    }
                    action("Cleared Cheque Clearance")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Cleared';
                        RunObject = page "Cheque Clearances";
                        RunPageView = where(Status = const(Cleared));
                    }
                    action("Bounced Cheque Clearance")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Bounced';
                        RunObject = page "Cheque Clearances";
                        RunPageView = where(Status = const(Bounced));
                    }
                    group("&Cheque Setup")
                    {
                        Caption = 'Setup';

                        action("&Cheque Types")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Internal Cheque Types";
                        }
                    }
                }
                group("Cheque Deposits")
                {
                    action("New Cheque Deposit")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New';
                        RunObject = page "Cheque Deposits";
                        RunPageView = where(Status = const(Open));
                    }
                    action("Cheque Deposit Pending Approval")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = page "Cheque Deposits";
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("Cheques On Hand")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'On Hand';
                        RunObject = page "Cheque Deposits";
                        RunPageView = where(Status = const(Approved));
                    }
                    action("Cleared Cheques")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Cleared';
                        RunObject = page "Cheque Deposits";
                        RunPageView = where(Status = filter(Cleared | Archived));
                    }
                    action("Bounced Cheques")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Bounced';
                        RunObject = page "Cheque Deposits";
                        RunPageView = where(Status = const(Bounced));
                    }
                    group("Cheque Setup")
                    {
                        Caption = 'Setup';

                        action("Cheque Types")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "External Cheque Types";
                        }
                    }
                }
                group("Money Laundary Mgmt.")
                {
                    Visible = false;

                    action("New Money Laundary Check")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New';
                        RunObject = page "Money Laundary Checks";
                        RunPageView = where(Status = const(Open));
                    }
                    action("Pending Money Laundary Checks")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = page "Money Laundary Checks";
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("Approved Money Laundary Checks")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = page "Money Laundary Checks";
                        RunPageView = where(Status = const(Approved), Cleared = const(false));
                    }
                    action("Processed Money Laundary Checks")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Processed';
                        RunObject = page "Money Laundary Checks";
                        RunPageView = where(Status = const(Approved), Cleared = const(true));
                    }
                }
                group("ATM Management")
                {
                    action("ATM Applications")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New';
                        RunObject = page "ATM Applications";
                        RunPageView = where(Status = const(Open));
                    }
                    action("Pending ATM Applications")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = page "ATM Applications";
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("Approved ATM Applications")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = page "ATM Applications";
                        RunPageView = where(Status = const(Approved), Processed = const(false));
                    }
                    action("ATM Application Ready For Collection")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Ready For Collection';
                        RunObject = page "ATM Applications";
                        RunPageView = where(Status = const(Approved), Processed = const(true), Collected = const(false));
                    }
                    action("Processed ATM Application")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Processed';
                        RunObject = page "ATM Applications";
                        RunPageView = where(Status = const(Approved), Processed = const(true), Collected = const(true));
                    }
                    group(Cards)
                    {
                        action("Unprotected Cards")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "ATM Cards";
                        }
                        action("Protected Cards")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Protected ATM Cards";
                        }
                    }
                    group(Transactions)
                    {
                        action("Pending Transactions")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "ATM Transactions";
                            RunPageView = where(Reversal = const(false));
                        }

                        action("Posted Transactions")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "ATM Posted Transactions";
                        }
                        action("Reversed Transactions")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "ATM Transactions";
                            RunPageView = where(Reversal = const(true));
                        }
                    }
                    group("ATM Setup")
                    {
                        Caption = 'Setups';

                        action("ATM Types")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "ATM Types";
                        }
                    }
                }
                group("Salary Processing")
                {
                    action("New Salary")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New';
                        RunObject = page Salaries;
                        RunPageView = where(Status = const(Open));
                    }
                    action("Pending Salaries")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = page Salaries;
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("Approved Salaries")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = page Salaries;
                        RunPageView = where(Status = const(Approved), Posted = const(false));
                    }
                    action("Posted Salaries")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted';
                        RunObject = page Salaries;
                        RunPageView = where(Status = const(Approved), Posted = const(true));
                    }
                }
                group("Standing Orders")
                {
                    action("New Standing Order")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New';
                        RunObject = page "Standing Orders";
                        RunPageView = where(Status = const(Open));
                    }
                    action("Pending Standing Orders")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = page "Standing Orders";
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("Running Standing Orders")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Running';
                        RunObject = page "Standing Orders";
                        RunPageView = where(Status = const(Approved), Running = const(true), Terminated = const(false));
                        // RunPageView = where(Status=const(Approved));
                    }
                    action("Terminated Standing Orders")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Terminated';
                        RunObject = page "Standing Orders";
                        RunPageView = where(Status = const(Approved), Running = const(false), Terminated = const(true));
                    }
                    group("Standing Order Setup")
                    {
                        Caption = 'Setup';

                        action("Standing Order Types")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Standing Order Types";
                        }
                    }
                }
                group("Fixed Deposit Management")
                {
                    action("New Fixed Deposits")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New';
                        RunObject = page "Member Fixed Deposits";
                        RunPageView = where(Status = const(Open));
                    }
                    action("Fixed Deposits Pending Approval")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = page "Member Fixed Deposits";
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("Approved Fixed Deposits")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = page "Member Fixed Deposits";
                        RunPageView = where(Status = const(Approved), Posted = const(false), Terminated = const(false), Matured = const(false));
                    }
                    action("Running Fixed Deposits")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Running';
                        RunObject = page "Member Fixed Deposits";
                        RunPageView = where(Status = const(Approved), Posted = const(true), Terminated = const(false), Matured = const(false));
                    }
                    action("Terminated Fixed Deposits")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Terminated';
                        RunObject = page "Member Fixed Deposits";
                        RunPageView = where(Status = const(Approved), Posted = const(true), Terminated = const(true));
                    }
                    action("Matured Fixed Deposits")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Matured';
                        RunObject = page "Member Fixed Deposits";
                        RunPageView = where(Status = const(Approved), Posted = const(true), Matured = const(true));
                    }
                    group("Fixed Deposit Setup")
                    {
                        Caption = 'Setup';

                        action("Fixed Deposit Types")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Member Fixed Deposit Types";
                        }
                    }
                }
                group("FOSA Dividend Management")
                {
                    action("New FOSA Dividends")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Open';
                        RunObject = page "FOSA Dividends";
                        RunPageView = where(Status = const(Open));
                    }
                    action("Pending FOSA Dividends")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = page "FOSA Dividends";
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("Approved FOSA Dividends")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = page "FOSA Dividends";
                        RunPageView = where(Status = const(Approved), Posted = const(false));
                    }
                    action("Processed FOSA Dividends")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted';
                        RunObject = page "FOSA Dividends";
                        RunPageView = where(Status = const(Approved), Posted = const(true));
                    }
                }
                group("Periodic Activities")
                {
                    action("&Run Standing Order")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Run Standing Orders";
                    }
                }
                group("&FOSA Reports")
                {
                    action("Member Accounts Lists")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Member Accounts';
                        RunObject = page "Member Accounts List";
                        RunPageView = where("Product Code" = filter('01' | '02' | '03' | '04' | '05' | '06' | '07' | '08'));
                    }
                    action("&Overdrawn Accounts")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Overdrawn Accounts";
                    }
                    action("&Standing Order Register")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Standing Order Register";
                    }
                }
            }
            group(Finance)
            {
                group(BudgetPlanning)
                {
                    Caption = 'Budget Planning';

                    group("Budget Plan")
                    {
                        action("Open Budget Plan")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Budget Plans";
                            RunPageView = where(Status = const(Open));
                        }
                        action("Budget Plan Pending Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Budget Plans";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("Approved & Unscheduled Budget Plan")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Budget Plans";
                            RunPageView = where(Status = const(Approved), Scheduled = const(false));
                        }
                        action("Scheduled & UnPosted Budget Plan")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Budget Plans";
                            RunPageView = where(Status = const(Approved), Scheduled = const(true), Posted = const(false));
                        }
                        action("Posted Budget Plan")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Budget Plans";
                            RunPageView = where(Status = const(Closed));
                        }
                    }
                    action("Draft Budget")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Draft Budget';
                        RunObject = Page "Global Draft Budgets";
                    }
                    action("Approved Budget")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved Budget';
                        RunObject = Page "G/L Budget Names";
                        RunPageView = where(Status = const(Approved));
                    }
                    group("Virement Budget")
                    {
                        action("Open Virement Budget Requests")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'New Virement Budget Requests';
                            RunObject = Page "Virement Budget Requests";
                            RunPageView = where(Status = const(Open));
                        }
                        action("Virement Budget Requests Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Virement Budget Requests Approval';
                            RunObject = Page "Virement Budget Requests";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("Approved Virement Budget Requests")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved Virement Budget Requests';
                            RunObject = Page "Virement Budget Requests";
                            RunPageView = where(Status = const(Approved), Effected = const(false));
                        }
                        action("Effected Virement Budget Requests")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = ' Effected Virement Budget Requests';
                            RunObject = Page "Virement Budget Requests";
                            RunPageView = where(Status = const(Approved), Effected = const(true));
                        }
                    }
                    group("Budget Setups")
                    {
                        Caption = 'Setups';

                        action("User Budget Roles")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Users Budget Roles';
                            RunObject = Page "Budget Users";
                        }
                    }
                }
                group("Journals ")
                {
                    Caption = 'Journals ';

                    action(PurchaseJournals)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Purchase Journals';
                        RunObject = Page "General Journal Batches";
                        RunPageView = WHERE("Template Type" = CONST(Purchases), Recurring = CONST(false));
                    }
                    action(SalesJournals)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Sales Journals';
                        RunObject = Page "General Journal Batches";
                        RunPageView = WHERE("Template Type" = CONST(Sales), Recurring = CONST(false));
                    }
                    action(CashReceiptJournals)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Cash Receipt Journals';
                        RunObject = Page "General Journal Batches";
                        RunPageView = WHERE("Template Type" = CONST("Cash Receipts"), Recurring = CONST(false));
                    }
                    action(PaymentJournals)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Payment Journals';
                        RunObject = Page "General Journal Batches";
                        RunPageView = WHERE("Template Type" = CONST(Payments), Recurring = CONST(false));
                    }
                    action(ICGeneralJournals)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'IC General Journals';
                        RunObject = Page "General Journal Batches";
                        RunPageView = WHERE("Template Type" = CONST(Intercompany), Recurring = CONST(false));
                    }
                    action(GeneralJournals)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'General Journals';
                        RunObject = Page "General Journal Batches";
                        RunPageView = WHERE("Template Type" = CONST(General), Recurring = CONST(false));
                    }
                    action("JFixed Assets G/L Journals")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Fixed Assets G/L Journals';
                        RunObject = Page "General Journal Batches";
                        RunPageView = WHERE("Template Type" = CONST(Assets), Recurring = CONST(false));
                        ToolTip = 'Post fixed asset transactions, such as acquisition and depreciation, in integration with the general ledger. The FA G/L Journal is a general journal, which is integrated into the general ledger.';
                    }
                    action("JFixed Assets Journals")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Fixed Assets Journals';
                        RunObject = Page "FA Journal Batches";
                        RunPageView = WHERE(Recurring = CONST(false));
                        ToolTip = 'Post fixed asset transactions, such as acquisition and depreciation book without integration to the general ledger.';
                    }
                    action("JFixed Assets Reclass. Journals")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Fixed Assets Reclass. Journals';
                        RunObject = Page "FA Reclass. Journal Batches";
                        ToolTip = 'Transfer, split, or combine fixed assets by preparing reclassification entries to be posted in the fixed asset journal.';
                    }
                    action("JInsurance Journals")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Insurance Journals';
                        RunObject = Page "Insurance Journal Batches";
                        ToolTip = 'Post entries to the insurance coverage ledger.';
                    }
                    action("J<Action3>")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Recurring General Journals';
                        RunObject = Page "General Journal Batches";
                        RunPageView = WHERE("Template Type" = CONST(General), Recurring = CONST(true));
                        ToolTip = 'Define how to post transactions that recur with few or no changes to general ledger, bank, customer, vendor, or fixed asset accounts';
                    }
                    action("JRecurring Fixed Asset Journals")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Recurring Fixed Asset Journals';
                        RunObject = Page "FA Journal Batches";
                        RunPageView = WHERE(Recurring = CONST(true));
                        ToolTip = 'Post recurring fixed asset transactions, such as acquisition and depreciation book without integration to the general ledger.';
                    }
                }
                group("Cash Management")
                {
                    action("BankAccountsCash")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Bank Accounts';
                        RunObject = Page "Bank Account List";
                    }
                    action("Bank Export/Import Setup")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Bank Export/Import Setup';
                        RunObject = Page "Bank Export/Import Setup";
                    }
                    action("Data Exch Def List")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Data Exchange Defination';
                        RunObject = Page "Data Exch Def List";
                    }
                    action(BankReconciliation)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Bank Reconciliation';
                        RunObject = Page "Bank Acc. Reconciliation List";
                    }
                    group(Receipts)
                    {
                        action(NewReceipt)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'New';
                            RunObject = Page Receipts;
                            RunPageView = where(Status = const(Open), Posted = const(false));
                        }
                        action(PendingApprovalReceipt)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Pending Approval';
                            RunObject = Page "Receipts";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action(ApprovedReceipt)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved';
                            RunObject = Page "Receipts";
                            RunPageView = where(Status = const(Approved), Posted = const(false));
                        }
                        action(PostedReceipt)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Posted Receipts';
                            RunObject = Page "Receipts";
                            RunPageView = where(Posted = const(true));
                        }
                    }
                    group("Purchases Order")
                    {
                        Caption = 'Purchase Orders';
                        ToolTip = 'List of Purchase Order and Invoice pages'; //action("Purchase Orders")

                        action("CreateNewPurchaseOrder")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Create a New Purchase Orders';
                            //RunObject = Page "SS Purchase Order List";
                            RunObject = Page "Purchase Order List";
                            RunPageView = where(Status = filter(open));
                            ToolTip = 'View the list of purchase orders that await the vendor''s confirmation.';
                        }
                        action("ApprovedPurchaseOrders")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved Purchase Orders';
                            RunObject = page "Purchase Order List";
                            RunPageView = where(status = filter(Released));
                            ToolTip = 'View the list of purchase orders that await the vendor''s confirmation.';
                        }
                        action(OPPurchaseOrdersPendConf)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Pending Confirmation';
                            RunObject = Page "Purchase Order List";
                            RunPageView = WHERE(Status = FILTER("Pending Approval"));
                            ToolTip = 'View the list of purchase orders that await the vendor''s confirmation. ';
                            Visible = false;
                        }
                        action(OPPurchaseOrdersCommitted)
                        {
                            Visible = false;
                            ApplicationArea = Basic, Suite;
                            Caption = 'Committed';
                            RunObject = Page "Purchase Order List";
                            RunPageView = WHERE(Status = FILTER(Released), "Last Receiving No." = FILTER(''));
                            ToolTip = 'View the list of purchase orders that await the vendor''s confirmation. ';
                        }
                        action(OPPurchaseOrdersPartDeliv)
                        {
                            Visible = false;
                            ApplicationArea = Basic, Suite;
                            Caption = 'Partially Delivered';
                            RunObject = Page "Purchase Order List";
                            RunPageView = WHERE(Status = FILTER(Released), Receive = FILTER(true), "Completely Received" = FILTER(false));
                            ToolTip = 'View the list of purchases that are partially received.';
                        }
                        action(OPPurchaseOrdersReceived)
                        {
                            Visible = false;
                            ApplicationArea = Basic, Suite;
                            Caption = 'Fully Delivered';
                            RunObject = Page "Purchase Order List";
                            RunPageView = WHERE(Status = FILTER(Released), "Last Receiving No." = FILTER(<> ''), Invoice = CONST(false));
                            ToolTip = 'View the list of purchases that are partially received.';
                        }
                        action(PurchaseOrdersInvoiced)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Invoiced';
                            RunObject = Page "Purchase Order List";
                            RunPageView = WHERE(Status = FILTER(Released), Invoice = CONST(true));
                            ToolTip = 'View the list of purchases that are partially received.';
                        }
                    }
                    group("Requests For Payment")
                    {
                        Caption = 'Payment Requests';
                        Visible = false;

                        action(PostedPurchaseInvoices)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Posted Purchase Invoices';
                            RunObject = Page "Posted Purchase Invoices";
                        }
                        action("$New Requests for Payment")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'New Payment Requests';
                            RunObject = Page "Payment Requests";
                            RunPageView = where(Status = const(Open));
                        }
                        action("$Requests for Payment Pending Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Payment Requests Pending Approval';
                            RunObject = Page "Payment Requests";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("$Approved Requests for Payment")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved Payment Requests';
                            RunObject = Page "Payment Requests";
                            RunPageView = where(Status = const(Approved), Posted = const(false));
                        }
                        action("$ProcessedRequests for Payment")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Processed Payment Requests';
                            RunObject = Page "Payment Requests";
                            RunPageView = where(Status = const(Approved), Posted = const(true));
                        }
                    }
                    group(Checkoffs)
                    {
                        action("Create Checkoffs")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'New';
                            RunObject = Page Checkoffs;
                            RunPageView = where(Status = const(Open));
                        }
                        action("Pending Approval Checkoffs")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Pending Approval';
                            RunObject = Page Checkoffs;
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("&Approved Checkoffs")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved';
                            RunObject = Page Checkoffs;
                            RunPageView = where(Status = const(Approved), Posted = const(false));
                        }
                        action("&Posted Checkoffs")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Posted';
                            RunObject = Page Checkoffs;
                            RunPageView = where(Posted = const(true));
                        }
                    }
                    group("Payment Voucher")
                    {
                        Caption = 'Payment Vouchers';

                        action("Create Payment Vourcher")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'New Payment Vourchers';
                            RunObject = Page "Payment Vouchers";
                            RunPageView = where(Status = const(Open));
                        }
                        action("Pending Approval Payment Voucher")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Pending Approval Payment Vouchers';
                            RunObject = Page "Payment Vouchers";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("Approved & Unposted Payment Voucher")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved & Unposted Payment Vouchers';
                            RunObject = Page "Payment Vouchers";
                            RunPageView = where(Status = const(Approved), Posted = const(false));
                        }
                        action("Posted Payment Voucher")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Posted Payment Vouchers';
                            RunObject = Page "Payment Vouchers";
                            RunPageView = where(Posted = const(true));
                        }
                        action("Payment Vouchers sent to EFT")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Payment Vouchers sent to EFT';
                            RunObject = Page "Payment Vouchers";
                            RunPageMode = View;
                            RunPageView = WHERE(EFT_No = FILTER(<> ''));
                        }
                    }
                    group("Petty Cash")
                    {
                        Caption = 'Petty Cash';

                        action("New Expense Claim Request")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'New Petty Cash Request';
                            RunObject = Page "Petty Cash List";
                            RunPageView = where(Status = const(Open));
                        }
                        action("Petty Cash Pending Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Petty Cash Pending Approval';
                            RunObject = Page "Petty Cash List";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("Approved PettyCash Requests")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved Petty Cash Requests';
                            RunObject = Page "Petty Cash List";
                            RunPageView = where(Status = const(Approved), Posted = const(false));
                        }
                        action("Posted Petty Cash")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Posted Petty Cash';
                            RunObject = Page "Petty Cash List";
                            RunPageView = where(Status = const(Approved), Posted = const(true), Paid = const(false));
                        }
                        action("Paid Petty Cash")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Paid Petty Cash';
                            RunObject = Page "Petty Cash List";
                            RunPageView = where(Status = const(Approved), Posted = const(true), Paid = const(true));
                        }
                    }
                    group("Staff Claim")
                    {
                        Caption = 'Staff Claim';

                        action("Create New Staff Claim")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'New Staff Claim';
                            RunObject = Page "Staff Claims";
                            RunPageView = where(Status = const(Open));
                        }
                        action("Staff Claim Pending Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Staff Claim Approvals';
                            RunObject = Page "Staff Claims";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("Approved Staff Claim")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved Staff Claim';
                            RunObject = Page "Staff Claims";
                            RunPageView = where(Status = const(Approved), "Claim Posted" = const(false));
                        }
                        action("Posted Staff Claim")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Posted Staff Claim';
                            RunObject = Page "Staff Claims";
                            RunPageView = where(Status = const(Approved), "Claim Posted" = const(true));
                        }
                    }
                    group(CashAdvances)
                    {
                        Caption = 'Imprest Requests';

                        action("New Imprest Requests")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'New Imprest Requests';
                            RunObject = Page "Imprest Requests";
                            RunPageView = where(Status = const(Open));
                        }
                        action("Pending Approval Imprest Requests")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Pending Approval Imprest Requests';
                            RunObject = Page "Imprest Requests";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("Approved Imprest Requests")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved Imprest Requests';
                            RunObject = Page "Imprest Requests";
                            RunPageView = where(Status = const(Approved));
                        }
                        action("Unsurrendered Imprests")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Imprest Surrenders";
                            RunPageView = where(Status = filter(Open), Surrendered = const(false));
                        }
                    }
                    group(CashSurrender)
                    {
                        Caption = 'Imprest Surrender';

                        action("Unposted Imprest Surrender")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Unposted Imprest Surrender';
                            RunObject = Page "Imprest Surrenders";
                            RunPageView = where(Status = const(Approved), Surrendered = const(false));
                        }
                        action("Posted Imprest Surrenders")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Posted Imprest Surrenders';
                            RunObject = Page "Imprest Surrenders";
                            RunPageView = where(Status = const(Closed), Surrendered = const(true));
                        }
                    }
                }
                group("Accounts Receivable")
                {
                    Caption = 'Accounts Receivable';

                    action(Action1000000018)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Customers';
                        RunObject = Page "Customer List";
                    }
                    action(Invoices)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Invoices';
                        RunObject = Page "Sales Invoice List";
                    }
                    action("Sales Credit Memo")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Sales Credit Memo';
                        RunObject = Page "Sales Credit Memos";
                    }
                    action("PostedSalesInvoices")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted Sales Invoices';
                        RunObject = Page "Posted Sales Invoices";
                    }
                    action("PostedSalesCredit Memos")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted Sales Credit Memos';
                        RunObject = Page "Posted Sales Credit Memos";
                    }
                    action("Reminder Terms")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Reminder Terms';
                        RunObject = Page "Reminder Terms";
                    }
                    action("Issue Reminders")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Issue Reminders';
                        RunObject = Page "Reminder List";
                    }
                    action("IssuedReminders")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Issued Reminders';
                        RunObject = Page "Issued Reminder List";
                    }
                    action("Finance Charge Terms")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Finance Charge Terms';
                        RunObject = Page "Finance Charge Terms";
                    }
                    action("Issue Finance Charge Memo")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Issue Finance Charge Memo';
                        RunObject = Page "Finance Charge Memo List";
                    }
                    action("IssuedFin.Charge Memos")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Issued Fin. Charge Memos';
                        RunObject = Page "Issued Fin. Charge Memo List";
                    }
                    action("Sales & Receivables Setup")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Sales & Receivables Setup';
                        RunObject = Page "Sales & Receivables Setup";
                    }
                }
                group("Accounts Payable")
                {
                    Caption = 'Accounts Payable';

                    action(Action1000000023)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Vendors';
                        RunObject = Page "Vendor List";
                    }
                    action(Action1000000025)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Purchase Orders';
                        RunObject = Page "Purchase Order List";
                    }
                    action("Purchase Invoices")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Purchase Invoices';
                        RunObject = Page "Purchase Invoices";
                    }
                    action("Purchase Credit Memos")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Purchase Credit Memos';
                        RunObject = Page "Purchase Credit Memos";
                    }
                    action("&Posted Purchase Invoices")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted Purchase Invoices';
                        RunObject = Page "Posted Purchase Invoices";
                    }
                    action("Posted Purchase Credit Memos")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted Purchase Credit Memos';
                        RunObject = Page "Posted Purchase Credit Memos";
                    }
                    action("Posted Purchase Receipts")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted Purchase Receipts';
                        RunObject = Page "Posted Purchase Receipts";
                    }
                    action("Purch & Payables Setup")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Purch & Payables Setup';
                        RunObject = Page "Purchases & Payables Setup";
                    }
                }
                group("Fixed Assets")
                {
                    Caption = 'Fixed Assets';

                    action(Action17)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Fixed Assets';
                        RunObject = Page "Fixed Asset List";
                    }
                    action("FA Classes")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'FA Classes';
                        RunObject = Page "FA Classes";
                    }
                    action("FA Subclasses")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'FA Subclasses';
                        RunObject = Page "FA Subclasses";
                    }
                    action("FA Locations")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'FA Locations';
                        RunObject = Page "FA Locations";
                    }
                    action("Depreciation Book")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Depreciation Book';
                        RunObject = Page "Depreciation Book List";
                    }
                    action("Fixed Assets Setup")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Fixed Assets Setup';
                        RunObject = Page "Fixed Asset Setup";
                    }
                    action("Fixed Assets Posting Groups")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Fixed Assets Posting Groups';
                        RunObject = Page "FA Posting Groups";
                    }
                    action(Insurance)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Insurance';
                        RunObject = Page "Insurance List";
                    }
                    action("Fixed Assets G/L Journals")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Fixed Assets G/L Journals';
                        RunObject = Page "General Journal Batches";
                        RunPageView = WHERE("Template Type" = CONST(Assets), Recurring = CONST(false));
                    }
                    action("Fixed Assets Journals")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Fixed Assets Journals';
                        RunObject = Page "FA Journal Batches";
                        RunPageView = WHERE(Recurring = CONST(false));
                    }
                    action("Fixed Assets Reclass. Journals")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Fixed Assets Reclass. Journals';
                        RunObject = Page "FA Reclass. Journal Batches";
                    }
                    action("Insurance Journals")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Insurance Journals';
                        RunObject = Page "Insurance Journal Batches";
                    }
                    action("<Action3>")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Recurring General Journals';
                        RunObject = Page "General Journal Batches";
                        RunPageView = WHERE("Template Type" = CONST(General), Recurring = CONST(true));
                    }
                    action("Recurring Fixed Asset Journals")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Recurring Fixed Asset Journals';
                        RunObject = Page "FA Journal Batches";
                        RunPageView = WHERE(Recurring = CONST(true));
                    }
                }
                group(Inventory)
                {
                    Caption = 'Inventory';

                    action("&Inventory Setup")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Inventory Setup';
                        RunObject = Page "Inventory Setup";
                    }
                    action(Action1000000040)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Items';
                        RunObject = Page "Item List";
                    }
                    action("&Item Journal")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Item Journal';
                        RunObject = Page "Item Journal Batches";
                    }
                }
                group("Management Reporting")
                {
                    Caption = 'Management Reporting';
                    Visible = false;

                    action("Account Schedules")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Account Schedules';
                        RunObject = Page "Account Schedule Names";
                    }
                    action("Analysis Views")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Analysis Views';
                        RunObject = Page "Analysis View List";
                    }
                    action("Cash Flow Forecast")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Cash Flow Forecast';
                        RunObject = Page "Cash Flow Forecast List";
                    }
                    action("Cost Types")
                    {
                        ApplicationArea = CostAccounting;
                        Caption = 'Cost Types';
                        RunObject = Page "Chart of Cost Types";
                        ToolTip = 'View the chart of cost types with a structure and functionality that resembles the general ledger chart of accounts. You can transfer the general ledger income statement accounts or create your own chart of cost types.';
                    }
                    action("Cost Centers")
                    {
                        ApplicationArea = CostAccounting;
                        Caption = 'Cost Centers';
                        RunObject = Page "Chart of Cost Centers";
                        ToolTip = 'Manage cost centers, which are departments and profit centers that are responsible for costs and income. Often, there are more cost centers set up in cost accounting than in any dimension that is set up in the general ledger. In the general ledger, usually only the first level cost centers for direct costs and the initial costs are used. In cost accounting, additional cost centers are created for additional allocation levels.';
                    }
                    action("Cost Objects")
                    {
                        ApplicationArea = CostAccounting;
                        Caption = 'Cost Objects';
                        RunObject = Page "Chart of Cost Objects";
                        ToolTip = 'Set up cost objects, which are products, product groups, or services of a company. These are the finished goods of a company that carry the costs. You can link cost centers to departments and cost objects to projects in your company.';
                    }
                    action("Cost Allocations")
                    {
                        ApplicationArea = CostAccounting;
                        Caption = 'Cost Allocations';
                        RunObject = Page "Cost Allocation Sources";
                        ToolTip = 'Manage allocation rules to allocate costs and revenues between cost types, cost centers, and cost objects. Each allocation consists of an allocation source and one or more allocation targets. For example, all costs for the cost type Electricity and Heating are an allocation source. You want to allocate the costs to the cost centers Workshop, Production, and Sales, which are three allocation targets.';
                    }
                    action("Cost Budgets")
                    {
                        ApplicationArea = CostAccounting;
                        Caption = 'Cost Budgets';
                        RunObject = Page "Cost Budget Names";
                        ToolTip = 'Set up cost accounting budgets that are created based on cost types just as a budget for the general ledger is created based on general ledger accounts. A cost budget is created for a certain period of time, for example, a fiscal year. You can create as many cost budgets as needed. You can create a new cost budget manually, or by importing a cost budget, or by copying an existing cost budget as the budget base.';
                    }
                    group(mgmtSetup)
                    {
                        Caption = 'Setups';

                        action(CostAccountingSetup)
                        {
                            ApplicationArea = CostAccounting;
                            Caption = 'Cost Accounting Setup';
                            RunObject = Page "Cost Accounting Setup";
                        }
                    }
                }
                group("Posted Documents")
                {
                    Caption = 'Posted Documents';

                    action("Posted Payment Vouchers")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted Payment Vouchers';
                        RunObject = Page "Payment Vouchers";
                        RunPageView = where(Posted = const(true));
                    }
                    action("Posted Cash Receipts")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted Cash Receipts';
                        RunObject = Page "Receipts";
                        RunPageView = where(Posted = const(true));
                    }
                    action("Processed Requests for Payment")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Processed Payment Requests';
                        RunObject = Page "Payment Requests";
                        RunPageView = where(Posted = const(true));
                    }
                    action("Posted Sales Invoices")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted Sales Invoices';
                        RunObject = Page "Posted Sales Invoices";
                    }
                    action("Posted Sales Credit Memos")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted Sales Credit Memos';
                        RunObject = Page "Posted Sales Credit Memos";
                    }
                    action("&PostedPurchaseInvoices")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted Purchase Invoices';
                        RunObject = Page "Posted Purchase Invoices";
                    }
                    action("PostedPurchaseCreditMemos")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted Purchase Credit Memos';
                        RunObject = Page "Posted Purchase Credit Memos";
                    }
                    action("Issued Reminders")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Issued Reminders';
                        RunObject = Page "Issued Reminder List";
                    }
                    action("Issued Fin. Charge Memos")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Issued Fin. Charge Memos';
                        RunObject = Page "Issued Fin. Charge Memo List";
                    }
                    action("G/L Registers")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'G/L Registers';
                        RunObject = Page "G/L Registers";
                    }
                    action("Cost Accounting Registers")
                    {
                        ApplicationArea = Basic, Suite;
                        Visible = false;
                        Caption = 'Cost Accounting Registers';
                        RunObject = Page "Cost Registers";
                    }
                    action("Cost Accounting Budget Registers")
                    {
                        ApplicationArea = Basic, Suite;
                        Visible = false;
                        Caption = 'Cost Accounting Budget Registers';
                        RunObject = Page "Cost Budget Registers";
                    }
                }
                group(Administration)
                {
                    Caption = 'Administration';

                    action(Action84)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Commercial Banks';
                        RunObject = Page "External Banks";
                    }
                    action(Currencies)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Currencies';
                        RunObject = Page Currencies;
                        ToolTip = 'View the different currencies that you trade in.';
                    }
                    action("Accounting Periods")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Accounting Periods';
                        RunObject = Page "Accounting Periods";
                        ToolTip = 'Set up the number of accounting periods, such as 12 monthly periods, within the fiscal year and specify which period is the start of the new fiscal year.';
                    }
                    action("Number Series")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Number Series';
                        RunObject = Page "No. Series";
                        ToolTip = 'View or edit the number series that are used to organize transactions';
                    }
                    action(Action43)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Analysis Views';
                        RunObject = Page "Analysis View List";
                        ToolTip = 'Analyze amounts in your general ledger by their dimensions using analysis views that you have set up.';
                    }
                    action(Action93)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Account Schedules';
                        RunObject = Page "Account Schedule Names";
                        ToolTip = 'Open your account schedules to analyze figures in general ledger accounts or to compare general ledger entries with general ledger budget entries.';
                    }
                    action(Action94)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Financial Reports';
                        RunObject = Page "Financial Reports";
                        ToolTip = 'Open your account schedules to analyze figures in general ledger accounts or to compare general ledger entries with general ledger budget entries.';
                    }
                    action(Dimensions)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Dimensions';
                        RunObject = Page Dimensions;
                        ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';
                    }
                    action("Bank Account Posting Groups")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Bank Account Posting Groups';
                        RunObject = Page "Bank Account Posting Groups";
                        ToolTip = 'Set up posting groups, so that payments in and out of each bank account are posted to the specified general ledger account.';
                    }
                    action("UserRoles")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Users Budget Roles';
                        RunObject = Page "Budget Users";
                    }
                    action("General Ledger Setup")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'General Ledger Setup';
                        RunObject = Page "General Ledger Setup";
                    }
                    action("Fixed Asset Setup")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Fixed Asset Setup';
                        RunObject = Page "Fixed Asset Setup";
                    }
                    action("Budget User Roles")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'User Budget Roles';
                        RunObject = Page "Budget Users";
                    }
                    action("Expense Codes")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Expense Codes';
                        RunObject = Page "Expense Codes";
                    }
                }
            }
            group("&Procurement")
            {
                group(Budget)
                {
                    Caption = 'Budget';
                    ToolTip = 'Procurement Budget';

                    group("ProcurementPlan")
                    {
                        Caption = 'Procurement Plan';

                        action("Create Procurement Plan")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Create Procurement Plan';
                            ToolTip = 'Create a new Procurement Plan';
                            RunObject = Page "SS Procurement Plans";
                            RunPageView = where(Status = const(Open));
                        }
                        action("Procurement Plan Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Procurement Plan Pending Approval';
                            ToolTip = 'View and approve Procurement Plan';
                            RunObject = Page "Procurement Plans";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("&Approved Procurement Plan&")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved Procurement Plan';
                            ToolTip = 'View approved Procurement Plan';
                            RunObject = Page "Procurement Plans";
                            RunPageView = where(Status = const(Approved), Posted = const(false));
                        }
                        action("Posted Procurement Plan")
                        {
                            ApplicationArea = Basic, Suite;
                            ToolTip = 'View Posted Procurement Plan';
                            RunObject = Page "Procurement Plans";
                            RunPageView = where(Status = const(Approved), Posted = const(true));
                        }
                    }
                }
                group("Procurement Plan")
                {
                    Visible = false;

                    action("New Procurement Plan")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New';
                        RunObject = Page "SS Budget Plans";
                        RunPageView = where(Status = const(Open));
                    }
                    action("Pending Approval Procurement Plan")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = Page "SS Budget Plans";
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("Approved Procurement Plan")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = Page "SS Budget Plan";
                        RunPageView = where(Status = const(Approved));
                    }
                    action("Closed Procurement Plan")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Closed';
                        RunObject = Page "SS Budget Plan";
                        RunPageView = where(Status = const(Closed));
                    }
                    action("&Draft Procurement Budget")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Consolidated Draft Budget';
                        RunObject = Page "Budget Holder Draft Budgets";
                    }
                    action("&Approved Procurement Budget")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved Budget';
                        RunObject = Page "Budget Holder Approved Budgets";
                        ToolTip = 'Prepare, View and Track your Budget Here';
                    }
                }
                // action("Purchase Budget")
                // {
                //     AppliPcationArea = Basic, Suite;
                //     Caption = 'Purchase Budget';
                //     ToolTip = 'Inventory Purchase Budget';
                //     RunObject = Page "Budget Names Purchase";
                // }
                // action("Purchase Analysis Report")
                // {
                //     ApplicationArea = Basic, Suite;
                //     Caption = 'Purchase Analysis Report';
                //     ToolTip = 'Run Purchase Analysis Report';
                //     RunObject = Page "Analysis Report Purchase";
                // }
                //}
                group("Procurement Operations")
                {
                    Caption = 'Procurement Operations';
                    ToolTip = 'Management of Procurement Tasks';

                    group("Purchase Requisition")
                    {
                        Caption = 'Purchase Requisition';
                        ToolTip = 'List of Purchase Requisition pages';

                        action("Open Purchase Requisition")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Purchase Requisitions";
                            RunPageView = where(Status = const(Open));
                            //RunObject = page "Purchase Requisition List";
                        }
                        action("Purchase Requisition Pending Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Purchase Requisitions";
                            RunPageView = where(Status = const("Pending Approval"));
                            //RunObject = page "Purch. Requisition List PA";
                        }
                        action("Purchase Requisition Approved")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Purchase Requisitions";
                            RunPageView = where(Status = const(Approved), "Process Initiated" = const(false));
                            //RunObject = page "App. Purch. Requisition List";
                        }
                        action("Purchase Requisitions Executed")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Purchase Requisitions";
                            RunPageView = where(Status = const(Approved), "Process Initiated" = const(true));
                            //RunObject = page "Proc.Process Request Initiated";
                        }
                        action("Requisitions Review")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Requisitions Review';
                            RunObject = Page "Requisitions Review";
                        }
                    }
                    group("Direct Procurement")
                    {
                        Visible = false;
                        Caption = 'Direct Procurement';
                        ToolTip = 'List of Direct Procurement';

                        action("Open Direct Procurement")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Open Direct Procurement';
                            RunObject = page "Direct Procurement List";
                            RunPageView = WHERE("Procurement Method" = CONST("Direct Procurement"), "Direct Procurement Status" = CONST(New), Archived = CONST(false));
                        }
                        action("Awarded Direct Procurement")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Awarded Direct Procurement';
                            RunObject = page "Awrded Direct Procurement List";
                            RunPageView = WHERE("Procurement Method" = CONST("Direct Procurement"), "Direct Procurement Status" = CONST("Email Sent"), Archived = CONST(false));
                        }
                        action("Order Generated Direct Procurement")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Order Generated Direct Procurement';
                            RunObject = page "Direct Procurement List-Orders";
                            RunPageView = WHERE("Procurement Method" = CONST("Direct Procurement"), "Direct Procurement Status" = CONST("Order Created"), Archived = CONST(false));
                        }
                    }
                    group("Request for Quote")
                    {
                        Caption = 'Request for Quote';
                        ToolTip = 'List of RFQ pages';

                        action("Open RFQ")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Open Quotations';
                            // RunObject = Page "RFQ List";
                            // RunPageView = where(Status = const(Open));
                            RunObject = page "Quotation List";
                        }
                        action("Advertised Quotations")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Advertised Quotations';
                            // RunObject = Page "RFQ List";
                            // RunPageView = where(Status = const(Open));
                            RunObject = page "Sent Quotation List";
                        }
                        action("Evaluation Quotations")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Quotations Under Evaluation';
                            // RunObject = Page "RFQ List";
                            // RunPageView = where(Status = const(Open));
                            RunObject = page "Quotation Evaluation List";
                        }
                        action("Awarded Quotations")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Awarded Quotations';
                            // RunObject = Page "RFQ List";
                            // RunPageView = where(Status = const(Open));
                            RunObject = page "Quotations Awarded";
                        }
                        action("Pending Approval RFQ")
                        {
                            //                            ApplicationArea = Basic, Suite;
                            Caption = 'Pending Approval RFQ/RFP';
                            RunObject = page "RFQ List";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("Approved RFQ")
                        {
                            //                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved RFQ/RFP';
                            RunObject = page "RFQ List";
                            RunPageView = where(Status = const(Approved));
                        }
                    }
                    group("Inspection of Goods/Services")
                    {
                        action("New Inspection of Goods/Services")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'New';
                            RunObject = Page "Procurement Inspections";
                            RunPageView = where(Status = const(Open));
                        }
                        action("Pending Approval Inspection of Goods/Services")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Pending Approval';
                            RunObject = Page "Procurement Inspections";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("Approved Inspection of Goods/Services")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved';
                            RunObject = Page "Procurement Inspections";
                            RunPageView = where(Status = const(Approved), Processed = const(false));
                        }
                        action("Processed Inspection of Goods/Services")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Processed';
                            RunObject = Page "Procurement Inspections";
                            RunPageView = where(Status = const(Approved), Processed = const(true));
                        }
                    }
                    group("Goods Recepits")
                    {
                        Visible = false;

                        action("Open Goods Receipts")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Goods Receipt List";
                        }
                        action("Goods Receipts Pending Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Goods Receipt List-Pending";
                        }
                        action("Goods Receipts Approved")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Goods Receipt List-Approved";
                        }
                        action("Goods Receipts Received")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Goods Receipt List-Received";
                        }
                    }
                    group("&Purchases Order")
                    {
                        Caption = 'Purchase Order/Invoice';
                        ToolTip = 'List of Purchase Order and Invoice pages';

                        action("Vendors/Suppliers")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Suppliers / Service Providers';
                            RunObject = Page "Vendor List";
                            RunPageView = where("Account Type" = const(Supplier));
                        }
                        action(Action52)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Purchase Quotes';
                            RunObject = Page "Purchase Quotes";
                        }
                        group("Purch Orders")
                        {
                            Caption = 'Purchase Orders';

                            action("&OpenPurchase Orders")
                            {
                                ApplicationArea = Basic, Suite;
                                Caption = 'Open Purchase Orders';
                                RunObject = page "Purchase Order List";
                                RunPageView = where(status = filter(Open));
                                ToolTip = 'View the list of purchase orders that await the vendor''s confirmation.';
                            }
                            action("&Pending Purchase Orders")
                            {
                                ApplicationArea = Basic, Suite;
                                Caption = 'Pending Approval Purchase Orders';
                                RunObject = page "Purchase Order List";
                                RunPageView = where(status = filter(Released));
                                ToolTip = 'View the list of purchase orders that await the vendor''s confirmation.';
                            }
                            action("&Approved Purchase Orders")
                            {
                                ApplicationArea = Basic, Suite;
                                Caption = 'Approved Purchase Orders';
                                RunObject = page "Purchase Order List";
                                RunPageView = where(status = filter(Released));
                                ToolTip = 'View the list of purchase orders that await the vendor''s confirmation.';
                            }
                            action("&OPPurchaseOrdersPartDeliv")
                            {
                                ApplicationArea = Basic, Suite;
                                Caption = 'Partially Delivered';
                                RunObject = Page "Purchase Order List";
                                RunPageView = WHERE(Status = FILTER(Released), Receive = FILTER(true), "Completely Received" = FILTER(false));
                                ToolTip = 'View the list of purchases that are partially received.';
                            }
                            action("&OPPurchaseOrdersReceived")
                            {
                                ApplicationArea = Basic, Suite;
                                Caption = 'Fully Delivered';
                                RunObject = Page "Purchase Order List";
                                RunPageView = WHERE(Status = FILTER(Released), "Last Receiving No." = FILTER(<> ''), Invoice = CONST(false));
                                ToolTip = 'View the list of purchases that are partially received.';
                            }
                            action("&PurchaseOrdersInvoiced")
                            {
                                ApplicationArea = Basic, Suite;
                                Caption = 'Invoiced';
                                RunObject = Page "Purchase Order List";
                                RunPageView = WHERE(Status = FILTER(Released), Invoice = CONST(true));
                                ToolTip = 'View the list of purchases that are partially received.';
                            }
                        }
                        action(Action50)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Purchase Invoices';
                            RunObject = Page "Purchase Invoices";
                        }
                        action(Action49)
                        {
                            Visible = false;
                            ApplicationArea = Basic, Suite;
                            Caption = 'Purchase Credit Memos';
                            RunObject = Page "Purchase Credit Memos";
                        }
                        action("Purchase Return")
                        {
                            Visible = false;
                            ApplicationArea = Basic, Suite;
                            Caption = 'Purchase Return';
                            RunObject = Page "Purchase Return Order List";
                        }
                        action("Posted Purchase Invoice")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Posted Purchase Invoices';
                            RunObject = Page "Posted Purchase Invoices";
                            ToolTip = 'Open the list of posted purchase invoices.';
                        }
                        /*action("Transfer Order")
                                            {
                                                ApplicationArea = Basic, Suite;
                                                Caption = 'Transfer Order';
                                                RunObject = Page "Transfer Orders";
                                            }*/
                    }
                    group("Payment Request")
                    {
                        action("&New Requests for Payment")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'New Payment Requests';
                            RunObject = Page "Payment Requests";
                            RunPageView = where(Status = const(Open));
                        }
                        action("&Requests for Payment Pending Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Payment Requests Pending Approval';
                            RunObject = Page "Payment Requests";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("&Approved Requests for Payment")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved Payment Requests';
                            RunObject = Page "Payment Requests";
                            RunPageView = where(Status = const(Approved), Posted = const(false));
                        }
                        action("&ProcessedRequests for Payment")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Processed Payment Requests';
                            RunObject = Page "Payment Requests";
                            RunPageView = where(Status = const(Approved), Posted = const(true));
                        }
                    }
                }
                group("Tendering")
                {
                    action("Supplier Applications")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Supplier Applications";
                    }
                    group(Tenders)
                    {
                        action("Open Tenders")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Tender List";
                            RunPageView = where(Status = const(Open));
                        }
                        action("Tenders Pending Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Tender List";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("Approved Tenders")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Tender List";
                            RunPageView = where(Status = const(Approved));
                        }
                        action("TenderAdvertised")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Advertised Tender List";
                        }
                        action("Tenders on Mandatory Evaluation")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Tender on Mandatory Evaluation";
                        }
                        action("Tenders on Tech. Evaluation")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Tender on Tech. Evaluation";
                        }
                        action("Tenders on Fin. Evaluation")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Tender on Fin. Evaluation";
                        }
                        action("Awarded Tenders")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Awarded Tenders";
                        }
                    }
                    group(Contracts)
                    {
                        action("Open Contracts")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Contract List";
                            RunPageView = where(Status = const(Open));
                        }
                        action("Contract Pending Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Contract List";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("Approved Contracts")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Contract List";
                            RunPageView = where(Status = const(Approved));
                        }
                        action("Signed Contracts")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Contract List";
                            RunPageView = where("Contract Status" = const(Signed));
                        }
                    }
                    group("Contract Extensions")
                    {
                        action("Open Contract Extensions")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Contract Extension List";
                            RunPageView = where(Status = const(Open));
                        }
                        action("Contract Extension Pending Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Contract Extension List";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("Approved Contract Extensions")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Contract Extension List";
                            RunPageView = where(Status = const(Approved));
                        }
                    }
                }
                group("Store Management")
                {
                    Caption = 'Inventory Management';

                    Group(Item)
                    {
                        action(Item1)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Store Items';
                            RunObject = Page "Item List";
                            ToolTip = 'List of items on inventory.';
                        }
                        action("ItemJournal")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Item &Journal';
                            RunObject = Page "Item Journal";
                            ToolTip = 'Adjust the physical quantity of items on inventory.';
                        }
                        action("Item Reclassification Journal")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Item Reclassification Journal';
                            RunObject = Page "Item Reclass. Journal";
                            ToolTip = 'Adjust the physical quantity of items on inventory by location.';
                        }
                        action("Item Physical Inventory Journal")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Item Physical Inventory Journal';
                            RunObject = Page "Phys. Inventory Journal";
                            ToolTip = 'Adjust the physical quantity of items on inventory.';
                        }
                    }
                    group("Store Requisition")
                    {
                        action("Open Store Requisition")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Store Requisitions";
                            RunPageView = where(Status = const(Open));
                        }
                        action("Store Requisition Pending Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Store Requisitions";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("Approved Store Requisition")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Store Requisitions";
                            RunPageView = where(Status = const(Approved), Issued = const(false), Received = const(false));
                        }
                        action("Store Requisition Issued")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Store Requisitions";
                            RunPageView = where(Issued = const(true), Received = const(false));
                        }
                        action("Received Store Requisition")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Store Requisitions";
                            RunPageView = where(Issued = const(true), Received = const(true));
                        }
                    }
                    group("Transfer Order")
                    {
                        action("Transfer Order - Open")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Transfer Order - Open';
                            RunObject = Page "Transfer Orders";
                            RunPageView = where(status = const(Open));
                        }
                        action("Transfer Order - Approved")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Transfer Order - Approved';
                            RunObject = Page "Transfer Orders";
                            RunPageView = where(status = const(Released));
                        }
                    }
                }
                group("&Posted Documents")
                {
                    Caption = 'Posted Documents';

                    action(Action40)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted Purchase Receipts';
                        RunObject = Page "Posted Purchase Receipts";
                        ToolTip = 'Open the list of posted purchase receipts.';
                    }
                    action("Posted Return Shipments")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted Return Shipments';
                        RunObject = Page "Posted Return Shipments";
                        ToolTip = 'Open the list of posted return shipments.';
                    }
                    action("&Posted Purchase Credit Memos")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted Purchase Credit Memos';
                        RunObject = Page "Posted Purchase Credit Memos";
                        ToolTip = 'Open the list of posted purchase credit memos.';
                    }
                    action("Closed Purchase Requisitions")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Purchase Requisitions";
                        RunPageView = where(Status = const(Approved), "PR Closed" = const(true));
                    }
                }
                group("&Administration")
                {
                    Caption = 'Administration';

                    action("Purchases & Payables Setup")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = Page "Purchases & Payables Setup";
                    }
                    action("Inventory Setup")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Inventory Setup';
                        RunObject = Page "Inventory Setup";
                    }
                    action("Procurement Terms Conditions")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Procurement Terms & Conditions';
                        RunObject = Page "Procurement Terms & Conditions";
                    }
                    action("Procurement Committees")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Procurement Committees';
                        RunObject = Page "Procurement Committee";
                    }
                    action("Supplier Application")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Supplier Application';
                        RunObject = page "Supplier Applications";
                    }
                }
            }
            group("Fleet Management")
            {
                Caption = 'Fleet Management';
                Visible = False;

                action("Fleet Management Setup")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Fleet Management Setup";
                }
                group("Fleet Administration")
                {
                    group(Vehicles)
                    {
                        action("Motor Vehicles")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Motor Vehicle List";
                        }
                        action(Drivers)
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Vehicle Drivers List";
                        }
                        action("Vehicle Ledger Entries")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Motor Vehicle Ledger Entries";
                        }
                        action("Vehicle Availability")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Vehicle Availability Status";
                        }
                        action("Vehicle Mileage Tracking")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Vehicle Mileage Tracking";
                        }
                    }
                    group("WorkTickets")
                    {
                        action(WorkTicket)
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Work Ticket List";
                        }
                        action("Work Tickets - Submitted")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Work Tickets - Submitted";
                        }
                    }
                    group(Fueling)
                    {
                        group("Fuel Cards")
                        {
                            action("Fuel Cards List")
                            {
                                ApplicationArea = Basic, Suite;
                                RunObject = page "Fueling Card List";
                            }
                            group("Fuel Card Tops")
                            {
                                action("Fuel Card Top List")
                                {
                                    ApplicationArea = Basic, Suite;
                                    RunObject = page "Fuel Top-Up List";
                                }
                                action("Fuel Card Top List - Submitted")
                                {
                                    ApplicationArea = Basic, Suite;
                                    RunObject = page "Fuel Top-Ups - Submitted";
                                }
                            }
                        }
                        group("Fuel Logs")
                        {
                            action("Fuel Requisitions List")
                            {
                                ApplicationArea = Basic, Suite;
                                RunObject = page "Fuel Requisitions List";
                            }
                            action("Fuel Requisition - Pending Approval")
                            {
                                ApplicationArea = Basic, Suite;
                                RunObject = page "Fuel Requisition Pending A";
                            }
                            action("Fuel Requisition - Approved")
                            {
                                ApplicationArea = Basic, Suite;
                                RunObject = page "Fuel Requisitions Approved";
                            }
                            action("Fuel Requisition - Rejected")
                            {
                                ApplicationArea = Basic, Suite;
                                RunObject = page "Fuel Requisitions Rejected";
                            }
                        }
                    }
                    group("Vehicle Insurance")
                    {
                        action("Insurance List")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Vehicle Insurance List";
                        }
                        action("Insurance List - Posted")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Posted Vehicle Insurance";
                        }
                        action("Insurance List - Expired")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Vehicle Insurance - Expired";
                        }
                    }
                }
                group("Fleet Maintenance")
                {
                    action("Service Proformas")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Service Proformas";
                    }
                    group("Vehicle Repairs")
                    {
                        action("Vehicle Repair List")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Vehicle Repair List";
                        }
                        action("Vehicle Repair List - Pending Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Veh. Repair Pending Approval";
                        }
                        action("Vehicle Repair List - Approved")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Vehicle Repair Approved";
                        }
                        action("Vehicle Repair List - Rejected")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Vehicle Repair Rejected";
                        }
                        action("Vehicle Repair List - Posted")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Posted Vehicle Repair";
                        }
                    }
                }
                group("Fleet Requisitions")
                {
                    group("Fleet Booking")
                    {
                        action("Booking List")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Vehicle Booking List";
                        }
                        action("Booking List - Submitted")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Vehicle Booking - Submitted";
                        }
                        action("Booking List - Pending Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Veh. Booking Pending Approval";
                        }
                        action("Booking List - Approved")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Vehicle Booking Approved";
                        }
                        action("Booking List - Rejected")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Vehicle Booking Rejected";
                        }
                    }
                    group("WorkTicket Form Requests")
                    {
                        action("WorkTicket Form Request")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "WorkTicket Form Requests";
                        }
                        action("WorkTicket Form Request - Submitted")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "WkTkt Form Request - Submitted";
                        }
                        action("WorkTicket Form Request - Pending Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "WorkTicket Form Requests - PA";
                        }
                        action("WorkTicket Form Request - Approved")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "WkTkt Form Request - Approved";
                        }
                        action("WorkTicket Form Request - Completed")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "WkTkt Form Request - Completed";
                        }
                        action("WorkTicket Form Request - Rejected")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "WkTkt Form Request - Rejected";
                        }
                    }
                }
                group("Fleet Reports")
                {
                    action("Fuel Expense")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Fuel Expense Report";
                    }
                    action("Insurance Expense")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Vehicle Insurance Exp. Report";
                    }
                    action("Maintenance Expense")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Maintenance Expense Report";
                    }
                    action("General Expense")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "General Motor V Expense Report";
                    }
                }
            }
            group("Asset Management")
            {
                action("Asset Management Setup")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Asset Management Setup";
                }
                action(Landlords)
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page Landlords;
                }
                action("Property Managers")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Property Managers";
                }
                action(Properties)
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page Properties;
                }
                action("Property Units")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Property Units";
                }
                action("Tenant Booking")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Tenant Bookings";
                }
                action("Billing Schedule")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Billing Schedule";
                }
            }
            group("Custodial Services")
            {
                Caption = 'Custodial Services';

                action("Storage Types")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Storage Types";
                }
                group("Custodial Applications")
                {
                    action("New Custodial Applications")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New';
                        RunObject = Page "Custodial Applications";
                        RunPageView = where("Document Status" = const(New));
                    }
                    action("Holding Custodial Applications")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Holding';
                        RunObject = Page "Custodial Applications";
                        RunPageView = where("Document Status" = const(Instore));
                    }
                    action("Archive Custodial Applications")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Archive';
                        RunObject = Page "Custodial Applications";
                        RunPageView = where("Document Status" = const(Released));
                    }
                }
                action("Custodial Service Types")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Custodial Service Types";
                }
                group("CustodialServicesReport")
                {
                    Caption = 'Reports';

                    action("CustodialHolding")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Custodial Holding';
                        RunObject = report "Custodial Holding";
                    }
                }
            }
            group("Share Trading")
            {
                action("Share Trading Setup")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Share Trading Setup";
                }
                action("Share Floating List")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Share Floatings";
                }
                group("Floated Shares")
                {
                    action("Open Floated Shares")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Open';
                        RunObject = Page "Floated Shares";
                        RunPageView = where(Status = const(Open), Published = const(true));
                    }
                    action("Pending Approval Floated Shares")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = Page "Floated Shares";
                        RunPageView = where(Status = const("Pending Approval"), Published = const(true));
                    }
                    action("Released Floated Shares")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = Page "Floated Shares";
                        RunPageView = where(Status = const(Approved), Awarded = const(false), Published = const(true));
                    }
                    action("Award Floated Shares")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Award';
                        RunObject = Page "Floated Shares";
                        RunPageView = where(Awarded = const(true), Archived = const(false), Published = const(true));
                    }
                    action("Archived Floated Shares")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Archived';
                        RunObject = Page "Floated Shares";
                        RunPageView = where(Archived = const(true));
                    }
                }
                group("Share Transfer")
                {
                    action("Open Share Capital Transfers")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Open';
                        RunObject = Page "Share Capital Transfers";
                        RunPageView = where(Status = const(Open));
                    }
                    action("Pending Share Capital Transfers")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pending Approval';
                        RunObject = Page "Share Capital Transfers";
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("Approved Share Capital Transfers")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved';
                        RunObject = Page "Share Capital Transfers";
                        RunPageView = where(Status = const(Approved), Posted = const(false));
                    }
                    action("Processed Share Capital Transfers")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Processed';
                        RunObject = Page "Share Capital Transfers";
                        RunPageView = where(Posted = const(true));
                    }
                }
                group("Custodial Services Report")
                {
                    Caption = 'Custodial Services';

                    action("Custodial Holding")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Custodial Holding";
                    }
                }
                group("ShareTradingReport")
                {
                    Caption = 'Reports';

                    action("ShareTradingDetails")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Share Trading Details';
                        RunObject = report "Share Trading Details";
                    }
                    action("ShareTransfer")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Share Transfer';
                        RunObject = report "Share Transfer";
                    }
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

                group("Channel Transactions")
                {
                    action("Open Channels Transactions")
                    {
                        Caption = 'Open';
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Channels Transactions";
                    }
                    action("Posted Transactions Archive")
                    {
                        Caption = 'Posted';
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Archived Channel Transactions";
                        RunPageView = where(Posted = const(true));
                    }
                    action("Reversed Transactions Archive")
                    {
                        Caption = 'Reversed';
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Archived Channel Transactions";
                        RunPageView = where(Reversed = const(true));
                    }
                    action("Skipped Transactions Archive")
                    {
                        Caption = 'Skipped';
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Archived Channel Transactions";
                        RunPageView = where(Skip = const(true));
                    }
                }
                group("PesaLink Transactions")
                {
                    action("Open PesaLink Transactions")
                    {
                        Caption = 'New';
                        ApplicationArea = Basic, Suite;
                        RunObject = page "PesaLink Transactions";
                        RunPageView = where(Status = const(New));
                    }
                    action("Processing PesaLink Transactions")
                    {
                        Caption = 'Processing';
                        ApplicationArea = Basic, Suite;
                        RunObject = page "PesaLink Transactions";
                        RunPageView = where(Status = const(Processing));
                    }
                    action("Completed PesaLink Transactions")
                    {
                        Caption = 'Completed';
                        ApplicationArea = Basic, Suite;
                        RunObject = page "PesaLink Transactions";
                        RunPageView = where(Status = const(Complete));
                    }
                    action("Posted PesaLink Transactions")
                    {
                        Caption = 'Posted';
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Archived PesaLink Transactions";
                        RunPageView = where(Status = const(Posted));
                    }
                    action("Skipped PesaLink Archive")
                    {
                        Caption = 'Skipped';
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Archived PesaLink Transactions";
                        RunPageView = where(Skip = const(true));
                    }
                    action("Failed PesaLink Archive")
                    {
                        Caption = 'Failed';
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Archived PesaLink Transactions";
                        RunPageView = where(Status = const(Failed));
                    }
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
                group("Online Guarantorship Mgmt")
                {
                    action("Guarantor Substitutions")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Channel Guarantor Mgmt.";
                    }
                    action("&Guarantor Requests")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Channel Guarantor Requests";
                    }
                    action("Guarantor Subsitutions")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Channel Guarantor Sub.";
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
                action("B2B Transactions")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "B2B Transactions";
                }
                action("ATM Transactions")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "ATM Transactions";
                }
            }
            group("Self Service")
            {
                group("&Inventory")
                {
                    Caption = 'Inventory';

                    action("&OpenStoreRequisition")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Open Store Requisition';
                        RunObject = Page "Store Requisitions";
                        RunPageView = where(Status = const(Open));
                    }
                    action("&StoreRequisitionPending Approval")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Store Requisition Pending Approval';
                        RunObject = Page "Store Requisitions";
                        RunPageView = where(Status = const("Pending Approval"));
                    }
                    action("&ApprovedStoreRequisition")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Approved Store Requisition';
                        RunObject = Page "Store Requisitions";
                        RunPageView = where(Status = const(Approved), Issued = const(false), Received = const(false));
                    }
                    action("&Store Requisition Issued")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = Page "Store Requisitions";
                        RunPageView = where(Status = const(Approved), Issued = const(true), Received = const(false));
                    }
                    action("&Received Store Requisition")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = Page "Store Requisitions";
                        RunPageView = where(Status = const(Approved), Issued = const(true), Received = const(true));
                    }
                }
                group("&Procurement Operations")
                {
                    Caption = 'Procurement';

                    group("&ProcurementPlan")
                    {
                        Caption = 'Procurement Plan';

                        action("&Create Procurement Plan")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Create Procurement Plan';
                            ToolTip = 'Create a new Procurement Plan';
                            RunObject = Page "SS Procurement Plans";
                            RunPageView = where(Status = const(Open));
                        }
                        action("&Procurement Plan Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Procurement Plan Pending Approval';
                            ToolTip = 'View and approve Procurement Plan';
                            RunObject = Page "Procurement Plans";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("&Approved Procurement Plan")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved Procurement Plan';
                            ToolTip = 'View approved Procurement Plan';
                            RunObject = Page "Procurement Plans";
                            RunPageView = where(Status = const(Approved));
                        }
                    }
                    group("&Purchase Requisition")
                    {
                        Caption = 'Purchase Requisition';
                        ToolTip = 'List of Purchase Requisition pages';

                        action("&Open Purchase Requisition")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Purchase Requisitions";
                            RunPageView = where(Status = const(Open));
                        }
                        action("&Purchase Requisition Pending Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Purchase Requisitions";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("&Purchase Requisition Approved")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Purchase Requisitions";
                            RunPageView = where(Status = const(Approved), "PR Closed" = const(false));
                        }
                        action("&Purchase Requisitions Ordered")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Purchase Requisitions";
                            RunPageView = where(Status = const(Approved), "PR Closed" = const(true));
                        }
                        action("&Requisitions Review")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Requisitions Review';
                            RunObject = Page "Requisitions Review";
                        }
                    }
                    group("Purchase Order")
                    {
                        action("&CreateNewPurchaseOrder")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'New/Recalled/Rejected Purchase Orders';
                            RunObject = Page "SS Purchase Order List";
                            //RunObject = page "Purchase Order List";
                            RunPageView = where(status = filter(open));
                            ToolTip = 'View the list of purchase orders that await the vendor''s confirmation.';
                        }
                        action("&PendingApprovalPurchaseOrders")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Pending Approval Purchase Orders';
                            RunObject = Page "SS Purchase Order List";
                            //RunObject = page "Purchase Order List";
                            RunPageView = where(status = filter("Pending Approval"));
                            ToolTip = 'View the list of purchase orders that await approval.';
                        }
                        action("&ApprovedPurchaseOrders")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved Purchase Orders';
                            RunObject = Page "SS Purchase Order List";
                            //RunObject = page "Purchase Order List";
                            RunPageView = where(status = filter(Released));
                            ToolTip = 'View the list of purchase orders that await the vendor''s confirmation.';
                        }
                    }
                }
            }
            group("&Administration&")
            {
                Caption = 'Administration';

                group("User Management")
                {
                    Caption = 'User Management';

                    action(Action30)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Users';
                        Promoted = true;
                        PromotedCategory = Process;
                        RunObject = Page Users;
                        ToolTip = 'View or edit users that will be configured in the database.';
                    }
                    action("User Personalization")
                    {
                        ApplicationArea = Basic, Suite;
                        Promoted = true;
                        PromotedCategory = Process;
                        RunObject = Page "User Settings";
                        ToolTip = 'View or edit users personalization  that will be configured in the database.';
                    }
                    action(Action31)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'User Groups';
                        Promoted = true;
                        PromotedCategory = Process;
                        RunObject = Page "Workflow User Groups";
                        ToolTip = 'Set up or modify user groups as a fast way of giving users access to the functionality that is relevant to their work.';
                    }
                    action(Action28)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Permission Sets';
                        Promoted = true;
                        PromotedCategory = Process;
                        RunObject = Page "Permission Sets";
                        ToolTip = 'View or edit which feature objects that users need to access and set up the related permissions in permission sets that you can assign to the users of the database.';
                    }
                    action(Action27)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Plans';
                        Promoted = true;
                        PromotedCategory = Process;
                        RunObject = Page Plans;
                        RunPageMode = View;
                        ToolTip = 'View subscription plans.';
                    }
                    action(Action29)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'User Review Log';
                        RunObject = Page "Activity Log";
                        RunPageView = WHERE("Table No Filter" = FILTER(9062));
                        ToolTip = 'View a log of users'' activities in the database.';
                    }
                }
                group("App Management")
                {
                    Caption = 'App Management';

                    action("Apps")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Apps';
                        Promoted = true;
                        PromotedCategory = Process;
                        RunObject = Page "AAD Application List";
                        ToolTip = 'View or edit apps.';
                    }
                }
                group("Data Privacy")
                {
                    Caption = 'Data Privacy';
                    ToolTip = 'Manage data privacy classifications, and respond to requests from data subjects.';

                    action("Page Data Classifications")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Data Classifications';
                        RunObject = Page "Data Classification Worksheet";
                        ToolTip = 'View your current data classifications';
                    }
                    action(Classified)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Classified Fields';
                        RunObject = Page "Data Classification Worksheet";
                        ToolTip = 'View only classified fields';
                    }
                    action(Unclassified)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Unclassified Fields';
                        RunObject = Page "Data Classification Worksheet";
                        ToolTip = 'View only unclassified fields';
                    }
                    action("Page Data Subjects")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Data Subjects';
                        RunObject = Page "Data Subject";
                        ToolTip = 'View your potential data subjects';
                    }
                    action("Page Change Log Entries")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Change Log Entries';
                        RunObject = Page "Change Log Entries";
                        ToolTip = 'View the log with all the changes in your system';
                    }
                    action("Member View Logs")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = Page "Member View Logs";
                    }
                }
                group("Data Migration")
                {
                    action("Configuration Packages")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Config. Packages";
                    }
                }
                group(SetupAndExtensions)
                {
                    Caption = 'Setup & Extensions';
                    ToolTip = 'Overview and change system and application settings, and manage extensions and services';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'The new common entry points to all Settings is introduced in the app bar''s cogwheel menu (aligned with the Office apps).';
                    ObsoleteTag = '18.0';

                    action("Assisted Setup")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Assisted Setup';
                        Image = QuestionaireSetup;
                        Promoted = true;
                        PromotedCategory = Process;
                        RunObject = Page "Assisted Setup";
                        ToolTip = 'Set up core functionality such as sales tax, sending documents as email, and approval workflow by running through a few pages that guide you through the information.';
                        ObsoleteState = Pending;
                        ObsoleteReason = 'The new common entry points to all Settings is introduced in the app bar''s cogwheel menu (aligned with the Office apps).';
                        ObsoleteTag = '18.0';
                    }
                    action("Manual Setup")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Manual Setup';
                        Promoted = true;
                        PromotedCategory = Process;
                        RunObject = Page "Manual Setup";
                        ToolTip = 'Define your company policies for business departments and for general activities by filling setup windows manually.';
                        ObsoleteState = Pending;
                        ObsoleteReason = 'The new common entry points to all Settings is introduced in the app bar''s cogwheel menu (aligned with the Office apps).';
                        ObsoleteTag = '18.0';
                    }
                    action("Service Connections")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Service Connections';
                        Image = ServiceTasks;
                        Promoted = true;
                        PromotedCategory = Process;
                        RunObject = Page "Service Connections";
                        ToolTip = 'Enable and configure external services, such as exchange rate updates, Microsoft Social Engagement, and electronic bank integration.';
                        ObsoleteState = Pending;
                        ObsoleteReason = 'The new common entry points to all Settings is introduced in the app bar''s cogwheel menu (aligned with the Office apps).';
                        ObsoleteTag = '18.0';
                    }
                    action(Extensions)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Extensions';
                        Image = NonStockItemSetup;
                        Promoted = true;
                        PromotedCategory = Process;
                        RunObject = Page "Extension Management";
                        ToolTip = 'Install extensions for greater functionality of the system.';
                        ObsoleteState = Pending;
                        ObsoleteReason = 'The new common entry points to all Settings is introduced in the app bar''s cogwheel menu (aligned with the Office apps).';
                        ObsoleteTag = '18.0';
                    }
                    action(Workflows)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Workflows';
                        Promoted = true;
                        PromotedCategory = Process;
                        RunObject = Page Workflows;
                        ToolTip = 'Set up or enable workflows that connect business-process tasks performed by different users. System tasks, such as automatic posting, can be included as steps in workflows, preceded or followed by user tasks. Requesting and granting approval to create new records are typical workflow steps.';
                        ObsoleteState = Pending;
                        ObsoleteReason = 'The new common entry points to all Settings is introduced in the app bar''s cogwheel menu (aligned with the Office apps).';
                        ObsoleteTag = '18.0';
                    }
                }
            }
            group("Section Reports")
            {
                Caption = 'Reports';

                group("Finance Reports")
                {
                    Caption = 'Finance';

                    group("SASRA Reports")
                    {
                        action("Sectorial Lending Return")
                        {
                            ApplicationArea = Basic, Suite;
                            Image = "Report";
                            RunObject = Report "Sectorial Lending";
                        }
                        action("Statement of Deposit Return")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Statement of Deposit Return';
                            Image = VendorLedger;
                            RunObject = report "Statement of Deposit Rtn.";
                        }
                        action("Risk Classification")
                        {
                            ApplicationArea = Basic, Suite;
                            Image = Aging;
                            RunObject = report "Risk Classification";
                        }
                    }
                    group("G/L Reports")
                    {
                        Caption = 'G/L Reports';

                        action("&G/L Trial Balance")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = '&G/L Trial Balance';
                            Image = "Report";
                            RunObject = Report "Trial Balance";
                            ToolTip = 'View, print, or send a report that shows the balances for the general ledger accounts, including the debits and credits. You can use this report to ensure accurate accounting practices.';
                        }
                        action("&Bank Detail Trial Balance")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = '&Bank Detail Trial Balance';
                            Image = "Report";
                            RunObject = Report "Bank Acc. - Detail Trial Bal.";
                            ToolTip = 'View, print, or send a report that shows a detailed trial balance for selected bank accounts. You can use the report at the close of an accounting period or fiscal year.';
                        }
                        action("Financial Reports")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Financial Reports';
                            Image = "Report";
                            RunObject = Page "Financial Reports";
                            ToolTip = 'Open an account schedule to analyze figures in general ledger accounts or to compare general ledger entries with general ledger budget entries.';
                        }
                        action("Bu&dget")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Bu&dget';
                            Image = "Report";
                            RunObject = Report Budget;
                            ToolTip = 'View or edit estimated amounts for a range of accounting periods.';
                        }
                        action("Trial Bala&nce/Budget")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Trial Bala&nce/Budget';
                            Image = "Report";
                            RunObject = Report "Trial Balance/Budget";
                            ToolTip = 'View a trial balance in comparison to a budget. You can choose to see a trial balance for selected dimensions. You can use the report at the close of an accounting period or fiscal year.';
                        }
                        action("Trial Balance by &Period")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Trial Balance by &Period';
                            Image = "Report";
                            RunObject = Report "Trial Balance by Period";
                            ToolTip = 'Show the opening balance by general ledger account, the movements in the selected period of month, quarter, or year, and the resulting closing balance.';
                        }
                        action("&Fiscal Year Balance")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = '&Fiscal Year Balance';
                            Image = "Report";
                            RunObject = Report "Fiscal Year Balance";
                            ToolTip = 'View, print, or send a report that shows balance sheet movements for selected periods. The report shows the closing balance by the end of the previous fiscal year for the selected ledger accounts. It also shows the fiscal year until this date, the fiscal year by the end of the selected period, and the balance by the end of the selected period, excluding the closing entries. The report can be used at the close of an accounting period or fiscal year.';
                        }
                        action("Balance Comp. - Prev. Y&ear")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Balance Comp. - Prev. Y&ear';
                            Image = "Report";
                            RunObject = Report "Balance Comp. - Prev. Year";
                            ToolTip = 'View a report that shows your company''s assets, liabilities, and equity compared to the previous year.';
                        }
                        action("&Closing Trial Balance")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = '&Closing Trial Balance';
                            Image = "Report";
                            RunObject = Report "Closing Trial Balance";
                            ToolTip = 'View, print, or send a report that shows this year''s and last year''s figures as an ordinary trial balance. The closing of the income statement accounts is posted at the end of a fiscal year. The report can be used in connection with closing a fiscal year.';
                        }
                        action("Dimensions - Total")
                        {
                            ApplicationArea = Dimensions;
                            Caption = 'Dimensions - Total';
                            Image = "Report";
                            RunObject = Report "Dimensions - Total";
                            ToolTip = 'View how dimensions or dimension sets are used on entries based on total amounts over a specified period and for a specified analysis view.';
                        }
                    }
                    group("Cash Flow")
                    {
                        Caption = 'Cash Flow';

                        action("Teller Report")
                        {
                            ApplicationArea = Basic, Suite;
                            Image = "Report";
                            RunObject = Report "Cash Book";
                        }
                        action("Cash Flow Date List")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Cash Flow Date List';
                            Image = "Report";
                            RunObject = Report "Cash Flow Date List";
                            ToolTip = 'View forecast entries for a period of time that you specify. The registered cash flow forecast entries are organized by source types, such as receivables, sales orders, payables, and purchase orders. You specify the number of periods and their length.';
                        }
                    }
                    group("Customers and Vendors")
                    {
                        Caption = 'Customers and Vendors';

                        action("Aged Accounts &Receivable")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Aged Accounts &Receivable';
                            Image = "Report";
                            RunObject = Report "Aged Accounts Receivable";
                            ToolTip = 'View an overview of when your receivables from customers are due or overdue (divided into four periods). You must specify the date you want aging calculated from and the length of the period that each column will contain data for.';
                        }
                        action("Aged Accounts Pa&yable")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Aged Accounts Pa&yable';
                            Image = "Report";
                            RunObject = Report "Aged Accounts Payable";
                            ToolTip = 'View an overview of when your payables to vendors are due or overdue (divided into four periods). You must specify the date you want aging calculated from and the length of the period that each column will contain data for.';
                        }
                        action("Reconcile Cus&t. and Vend. Accs")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Reconcile Cus&t. and Vend. Accs';
                            Image = "Report";
                            RunObject = Report "Reconcile Cust. and Vend. Accs";
                            ToolTip = 'View if a certain general ledger account reconciles the balance on a certain date for the corresponding posting group. The report shows the accounts that are included in the reconciliation with the general ledger balance and the customer or the vendor ledger balance for each account and shows any differences between the general ledger balance and the customer or vendor ledger balance.';
                        }
                    }
                    group("VAT Reports")
                    {
                        Caption = 'VAT Reports';

                        action("&VAT Registration No. Check")
                        {
                            ApplicationArea = VAT;
                            Caption = '&VAT Registration No. Check';
                            Image = "Report";
                            RunObject = Report "VAT Registration No. Check";
                            ToolTip = 'Use an EU VAT number validation service to validated the VAT number of a business partner.';
                        }
                        action("VAT E&xceptions")
                        {
                            ApplicationArea = VAT;
                            Caption = 'VAT E&xceptions';
                            Image = "Report";
                            RunObject = Report "VAT Exceptions";
                            ToolTip = 'View the VAT entries that were posted and placed in a general ledger register in connection with a VAT difference. The report is used to document adjustments made to VAT amounts that were calculated for use in internal or external auditing.';
                        }
                        action("VAT &Statement")
                        {
                            ApplicationArea = VAT;
                            Caption = 'VAT &Statement';
                            Image = "Report";
                            RunObject = Report "VAT Statement";
                            ToolTip = 'View a statement of posted VAT and calculate the duty liable to the customs authorities for the selected period.';
                        }
                        action("VAT - VIES Declaration Tax Aut&h")
                        {
                            ApplicationArea = BasicEU;
                            Caption = 'VAT - VIES Declaration Tax Aut&h';
                            Image = "Report";
                            RunObject = Report "VAT- VIES Declaration Tax Auth";
                            ToolTip = 'View information to the customs and tax authorities for sales to other EU countries/regions. If the information must be printed to a file, you can use the VAT- VIES Declaration Disk report.';
                        }
                        action("VAT - VIES Declaration Dis&k")
                        {
                            ApplicationArea = BasicEU;
                            Caption = 'VAT - VIES Declaration Dis&k';
                            Image = "Report";
                            RunObject = Report "VAT- VIES Declaration Disk";
                            ToolTip = 'Report your sales to other EU countries or regions to the customs and tax authorities. If the information must be printed out on a printer, you can use the VAT- VIES Declaration Tax Auth report. The information is shown in the same format as in the declaration list from the customs and tax authorities.';
                        }
                        action("EC Sales &List")
                        {
                            Visible = false;
                            ApplicationArea = BasicEU;
                            Caption = 'EC Sales &List';
                            Image = "Report";
                            RunObject = Report "EC Sales List";
                            ToolTip = 'Calculate VAT amounts from sales, and submit the amounts to a tax authority.';
                        }
                    }
                    group("Cost Accounting")
                    {
                        Caption = 'Cost Accounting';

                        action("Cost Accounting P/L Statement")
                        {
                            ApplicationArea = CostAccounting;
                            Caption = 'Cost Accounting P/L Statement';
                            Image = "Report";
                            RunObject = Report "Cost Acctg. Statement";
                            ToolTip = 'View the credit and debit balances per cost type, together with the chart of cost types.';
                        }
                        action("CA P/L Statement per Period")
                        {
                            ApplicationArea = CostAccounting;
                            Caption = 'CA P/L Statement per Period';
                            Image = "Report";
                            RunObject = Report "Cost Acctg. Stmt. per Period";
                            ToolTip = 'View profit and loss for cost types over two periods with the comparison as a percentage.';
                        }
                        action("CA P/L Statement with Budget")
                        {
                            ApplicationArea = CostAccounting;
                            Caption = 'CA P/L Statement with Budget';
                            Image = "Report";
                            RunObject = Report "Cost Acctg. Statement/Budget";
                            ToolTip = 'View a comparison of the balance to the budget figures and calculates the varCe and the percent varCe in the current accounting period, the accumulated accounting period, and the fiscal year.';
                        }
                        action("Cost Accounting Analysis")
                        {
                            ApplicationArea = CostAccounting;
                            Caption = 'Cost Accounting Analysis';
                            Image = "Report";
                            RunObject = Report "Cost Acctg. Analysis";
                            ToolTip = 'View balances per cost type with columns for seven fields for cost centers and cost objects. It is used as the cost distribution sheet in Cost accounting. The structure of the lines is based on the chart of cost types. You define up to seven cost centers and cost objects that appear as columns in the report.';
                        }
                    }
                    group("Financial Statements")
                    {
                        Caption = 'Financial Statements';

                        action("Balance Sheet")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Balance Sheet';
                            RunObject = Report "Balance Sheet";
                            ToolTip = 'View a report that shows your company''s assets, liabilities, and equity.';
                        }
                        action("Income Statement")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Income Statement';
                            Image = "Report";
                            Promoted = true;
                            PromotedCategory = "Report";
                            PromotedIsBig = true;
                            RunObject = Report "Income Statement";
                            ToolTip = 'View a report that shows your company''s income and expenses.';
                        }
                        action("Statement of Cash Flows")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Statement of Cash Flows';
                            Image = "Report";
                            Promoted = true;
                            PromotedCategory = "Report";
                            PromotedIsBig = true;
                            RunObject = Report "Statement of Cashflows";
                            ToolTip = 'View a financial statement that shows how changes in balance sheet accounts and income affect the company''s cash holdings, displayed for operating, investing, and financing activities respectively.';
                        }
                        action("Statement of Retained Earnings")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Statement of Retained Earnings';
                            Image = "Report";
                            Promoted = true;
                            PromotedCategory = "Report";
                            PromotedIsBig = true;
                            RunObject = Report "Retained Earnings Statement";
                            ToolTip = 'View a report that shows your company''s changes in retained earnings for a specified period by reconciling the beginning and ending retained earnings for the period, using information such as net income from the other financial statements.';
                        }
                    }
                    group("Excel Reports")
                    {
                        Caption = 'Excel Reports';

                        action(ExcelTemplatesBalanceSheet)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Balance Sheet';
                            Image = "Report";
                            RunObject = Codeunit "Run Template Balance Sheet";
                            ToolTip = 'Open a spreadsheet that shows your company''s assets, liabilities, and equity.';
                        }
                        action(ExcelTemplateIncomeStmt)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Income Statement';
                            Image = "Report";
                            RunObject = Codeunit "Run Template Income Stmt.";
                            ToolTip = 'Open a spreadsheet that shows your company''s income and expenses.';
                        }
                        action(ExcelTemplateCashFlowStmt)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Cash Flow Statement';
                            Image = "Report";
                            RunObject = Codeunit "Run Template CashFlow Stmt.";
                            ToolTip = 'Open a spreadsheet that shows how changes in balance sheet accounts and income affect the company''s cash holdings.';
                        }
                        action(ExcelTemplateRetainedEarn)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Retained Earnings Statement';
                            Image = "Report";
                            RunObject = Codeunit "Run Template Retained Earn.";
                            ToolTip = 'Open a spreadsheet that shows your company''s changes in retained earnings based on net income from the other financial statements.';
                        }
                        action(ExcelTemplateTrialBalance)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Trial Balance';
                            Image = "Report";
                            RunObject = Codeunit "Run Template Trial Balance";
                            ToolTip = 'Open a spreadsheet that shows a summary trial balance by account.';
                        }
                        action(ExcelTemplateAgedAccPay)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Aged Accounts Payable';
                            Image = "Report";
                            RunObject = Codeunit "Run Template Aged Acc. Pay.";
                            ToolTip = 'Open a spreadsheet that shows a list of aged remaining balances for each vendor by period.';
                        }
                        action(ExcelTemplateAgedAccRec)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Aged Accounts Receivable';
                            Image = "Report";
                            RunObject = Codeunit "Run Template Aged Acc. Rec.";
                            ToolTip = 'Open a spreadsheet that shows when customer payments are due or overdue by period.';
                        }
                    }
                    action("Run Consolidation")
                    {
                        ApplicationArea = Suite;
                        Caption = 'Run Consolidation';
                        Ellipsis = true;
                        Image = ImportDatabase;
                        RunObject = Report "Import Consolidation from DB";
                        ToolTip = 'Run the Consolidation report.';
                        Visible = false;
                    }
                }
                group(CreditReports)
                {
                    Caption = 'Credit';

                    group("&SASRA Reports")
                    {
                        action("&Sectorial Lending Return")
                        {
                            ApplicationArea = Basic, Suite;
                            Image = "Report";
                            RunObject = Report "Sectorial Lending";
                        }
                        action("&Statement of Deposit Return")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Statement of Deposit Return';
                            Image = VendorLedger;
                            RunObject = report "Statement of Deposit Rtn.";
                        }
                        action("&Risk Classification")
                        {
                            ApplicationArea = Basic, Suite;
                            Image = Aging;
                            RunObject = report "Risk Classification";
                        }
                    }
                    action("Mobile Loan Eligibility")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Mobile Loan Eligibility";
                    }
                    action("Loan Payments Due")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Payments Due";
                    }
                    action("Loan Defaulters Ageing")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Loan Defaulters";
                    }
                    action("Generate Defaulters")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Gen. Loan Defaulters";
                    }
                    action("Loan Aging Analysis")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Loan Ageing Analysis";
                    }
                    action("Loan Issued Summary Report")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Disbursement Summary";
                    }
                    action("Loans balances Summary")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Loan Balances Summary";
                    }
                    action("Loan Guaranteed report")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Member Guarantees";
                    }
                    action("Loan guarantors Report")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Member Guarantors";
                    }
                    action("Savings and Loans listing Report")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Savings And Loan Listing";
                    }
                    action("Contribution Classification")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Contribution Classification";
                    }
                    action("GL Balance vs Listing")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "GL Balance vs Listing";
                    }
                    action("Interest Variance")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Loan Transactions";
                    }
                    action("Underpaid Principal")
                    {
                        RunObject = report "Underpaid Principal";
                    }
                    action("Progression Report")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Progression Report";
                    }
                    action("Guarantor Register")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Guarantor Register";
                    }
                    action("Loans Register")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Loan Register";
                    }
                    action("&Loan Banding")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Loan Banding";
                    }
                    action("&Loan Streaming")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Loan Streaming";
                    }
                    action("&Loan Processing Perfomance")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Loan Processing Perfomance";
                    }
                    action("Loan Defaulters")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report Defaulters;
                    }
                    action("Recovery Advice")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Checkoff Advise";
                    }
                    action("Loan Recoveries")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Loan Recovery";
                    }
                    action("Variance Report")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Variance Report";
                    }
                }
                group("FOSA Reports")
                {
                    Caption = 'FOSA';

                    action("Overdrawn Accounts")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Overdrawn Accounts";
                    }
                    action("Account Listing")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Member Account List";
                    }
                    action("Monthly Receipts")
                    {
                        ApplicationArea = Basic, Suite;
                        Image = Receipt;
                        RunObject = report "Monthly Receipts";
                    }
                    action("Teller & Treasury Statement")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Cash Book";
                    }
                    action("Run Standing Order")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Run Standing Orders";
                    }
                    action("Standing Order Register")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = report "Standing Order Register";
                    }
                }
                group(ProcurementReports)
                {
                    Caption = 'Procurement';

                    action("Store Requisition Summary")
                    {
                        ApplicationArea = Basic, Suite;
                        Image = "Report";
                        RunObject = Report "Store Requisition Summary";
                    }
                    action("Inventory - &Availability Plan")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Inventory - &Availability Plan';
                        Image = ItemAvailability;
                        RunObject = Report "Inventory - Availability Plan";
                        ToolTip = 'View a list of the quantity of each item in customer, purchase, and transfer orders and the quantity available in inventory. The list is divided into columns that cover six periods with starting and ending dates as well as the periods before and after those periods. The list is useful when you are planning your inventory purchases.';
                    }
                    action("Vendor Evaluation report")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Vendor Evaluation Report';
                        Image = Report;
                        RunObject = Report "Vendor Evaluation";
                        ToolTip = 'View vendor list by vendor evaluation.';
                    }
                }
            }
        }
    }
}

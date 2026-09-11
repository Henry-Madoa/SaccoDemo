page 52204264 "Finance Role Center"
{
    // CurrPage."Help And Setup List".ShowFeatured;Caption = 'HR Role Center';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            part(Part1; "Accountant Activities")
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
                        Image = Journals;
                        RunObject = Page "General Journal Batches";
                        RunPageView = WHERE("Template Type" = CONST("Cash Receipts"), Recurring = CONST(false));
                    }
                    action(PaymentJournals)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Payment Journals';
                        Image = Journals;
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
                        Image = Journal;
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
                        Image = PostedOrder;
                        RunObject = Page "Posted Sales Invoices";
                    }
                    action("PostedSalesCredit Memos")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted Sales Credit Memos';
                        Image = PostedOrder;
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
                        Image = OrderReminder;
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
                        Image = PostedMemo;
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
                        Image = PostedOrder;
                        RunObject = Page "Posted Sales Invoices";
                    }
                    action("Posted Sales Credit Memos")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posted Sales Credit Memos';
                        Image = PostedOrder;
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
                        Image = OrderReminder;
                        RunObject = Page "Issued Reminder List";
                    }
                    action("Issued Fin. Charge Memos")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Issued Fin. Charge Memos';
                        Image = PostedMemo;
                        RunObject = Page "Issued Fin. Charge Memo List";
                    }
                    action("G/L Registers")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'G/L Registers';
                        Image = GLRegisters;
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
                        Image = Currency;
                        RunObject = Page Currencies;
                        ToolTip = 'View the different currencies that you trade in.';
                    }
                    action("Accounting Periods")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Accounting Periods';
                        Image = AccountingPeriods;
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
                        Image = Dimensions;
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
                        Image = Setup;
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
                            Image = Journals;
                            RunObject = Page "Item Journal";
                            ToolTip = 'Adjust the physical quantity of items on inventory.';
                        }
                        action("Item Reclassification Journal")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Item Reclassification Journal';
                            Image = Journals;
                            RunObject = Page "Item Reclass. Journal";
                            ToolTip = 'Adjust the physical quantity of items on inventory by location.';
                        }
                        action("Item Physical Inventory Journal")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Item Physical Inventory Journal';
                            Image = Journals;
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

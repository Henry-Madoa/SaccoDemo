pageextension 52203424 "General Ledger Setup" extends "General Ledger Setup"
{
    PromotedActionCategories = 'New,Process,Report,General,Posting,VAT,Bank,Journal Templates,HR & Payroll,Inventory Payables & Receivables, Payments,Sacco';

    layout
    {
        // Add changes to page layout here
        modify(AmountRoundingPrecision)
        {
            Editable = false;
        }
        addbefore(AmountRoundingPrecision)
        {
            field("Rounding Type"; Rec."Rounding Type")
            {
                ApplicationArea = Basic, Suite;
            }
        }
        addafter(General)
        {
            group("Notifications Management")
            {
                field("Login Email Notification"; Rec."Login Email Notification")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Login SMS Notification"; Rec."Login SMS Notification")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Cash Mangement Setup")
            {
                field("Budget Check"; Rec."Budget Check")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Receipt Approval Limit"; Rec."Receipt Approval Limit")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Petty Cash Limit"; Rec."Petty Cash Limit")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Current Budget Start Date"; Rec."Current Budget Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Current Budget End Date"; Rec."Current Budget End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Current Budget"; Rec."Current Budget")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Voucher Template"; Rec."Payment Voucher Template")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Voucher Batch"; Rec."Payment Voucher Batch")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Receipt Template"; Rec."Receipt Template")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Receipt Batch"; Rec."Receipt Batch")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Imprest Template"; Rec."Imprest Template")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Imprest Batch"; Rec."Imprest Batch")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Imprest Surrender Batch"; Rec."Imprest Surrender Batch")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Max No Outstanding Imprests"; Rec."Max No Outstanding Imprests")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Claims Template"; Rec."Claims Template")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Claims Batch"; Rec."Claims Batch")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Petty Cash Template"; Rec."Petty Cash Template")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Petty Cash Batch"; Rec."Petty Cash Batch")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payroll Template"; Rec."Payroll Template")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payroll Batch"; Rec."Payroll Batch")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Post VAT"; Rec."Post VAT")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group(Numbering)
            {
                field("PV Nos"; Rec."PV Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Receipt Nos"; Rec."Receipt Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Reconsiliation Nos."; Rec."Reconsiliation Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Request for Payment Nos."; Rec."Request for Payment Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                }
                field("Imprest Nos"; Rec."Imprest Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Staff Claim Nos"; Rec."Staff Claim Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Salary Advance Nos"; Rec."Salary Advance Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Petty Cash Nos"; Rec."Petty Cash Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Suppl. Budget Request Nos"; Rec."Suppl. Budget Request Nos")
                {
                    Importance = Additional;
                    ApplicationArea = Basic, Suite;
                }
                field("Budget Plan"; Rec."Budget Plan")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        addafter("Gen. Product Posting Groups")
        {
            action("Human Resources Setup")
            {
                ApplicationArea = BasicHR;
                Image = HumanResources;
                Promoted = true;
                PromotedCategory = Category9;
                PromotedIsBig = true;
                RunObject = Page "Human Resources Setup";
            }
            action("Inventory Setup")
            {
                ApplicationArea = Basic, Suite;
                Image = Vendor;
                Promoted = true;
                PromotedCategory = Category10;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Inventory Setup";
                ToolTip = 'Set up the posting groups to select from when you set up vendor cards to link business transactions made for the vendor with the appropriate account in the general ledger.';
            }
            action("Purchases & Payables Setup")
            {
                ApplicationArea = Basic, Suite;
                Image = Vendor;
                Promoted = true;
                PromotedCategory = Category10;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Purchases & Payables Setup";
                ToolTip = 'Set up the posting groups to select from when you set up vendor cards to link business transactions made for the vendor with the appropriate account in the general ledger.';
            }
            action("Vendor Posting Groups")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Vendor Posting Groups';
                Image = Vendor;
                Promoted = true;
                PromotedCategory = Category10;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Vendor Posting Groups";
                ToolTip = 'Set up the posting groups to select from when you set up vendor cards to link business transactions made for the vendor with the appropriate account in the general ledger.';
            }
            action("Customer Posting Groups")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Customer Posting Groups';
                Image = CustomerGroup;
                Promoted = true;
                PromotedCategory = Category10;
                PromotedIsBig = true;
                RunObject = Page "Customer Posting Groups";
                ToolTip = 'Set up the posting groups to select from when you set up customer cards to link business transactions made for the customer with the appropriate account in the general ledger.';
            }
            action("Customer Price Groups")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Customer Price Groups';
                Image = Price;
                Promoted = true;
                PromotedCategory = Category10;
                PromotedIsBig = true;
                RunObject = Page "Customer Price Groups";
                ToolTip = 'Set up the posting groups to select from when you set up customer cards to link business transactions made for the customer with the appropriate account in the general ledger.';
            }
            action("Customer Disc. Groups")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Customer Disc. Groups';
                Image = Discount;
                Promoted = true;
                PromotedCategory = Category10;
                PromotedIsBig = true;
                RunObject = Page "Customer Disc. Groups";
                ToolTip = 'Set up discount group codes that you can use as criteria when you define special discounts on a customer, vendor, or item card.';
            }
            group(Payment)
            {
                Caption = 'Payment';

                action("Expense Code")
                {
                    ApplicationArea = Basic, Suite;
                    Image = PaymentForecast;
                    Promoted = true;
                    PromotedCategory = Category11;
                    PromotedIsBig = true;
                    RunObject = Page "Expense Codes";
                }
                action("Payment Registration Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Payment Registration Setup';
                    Image = PaymentJournal;
                    Promoted = true;
                    PromotedCategory = Category11;
                    PromotedIsBig = true;
                    RunObject = Page "Payment Registration Setup";
                    ToolTip = 'Set up the payment journal template and the balancing account that is used to post received customer payments. Define how you prefer to process customer payments in the Payment Registration window.';
                }
                action("Payment Methods")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Payment Methods';
                    Image = Payment;
                    Promoted = true;
                    PromotedCategory = Category11;
                    PromotedIsBig = true;
                    RunObject = Page "Payment Methods";
                    ToolTip = 'Set up the payment methods that you select from the customer card to define how the customer must pay, for example by bank transfer.';
                }
                action("Payment Terms")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Payment Terms';
                    Image = Payment;
                    Promoted = true;
                    PromotedCategory = Category11;
                    PromotedIsBig = true;
                    RunObject = Page "Payment Terms";
                    ToolTip = 'Set up the payment terms that you select from on customer cards to define when the customer must pay, such as within 14 days.';
                }
                action("Finance Charge Terms")
                {
                    ApplicationArea = Suite;
                    Caption = 'Finance Charge Terms';
                    Image = FinChargeMemo;
                    Promoted = true;
                    PromotedCategory = Category11;
                    PromotedIsBig = true;
                    RunObject = Page "Finance Charge Terms";
                    ToolTip = 'Set up the finance charge terms that you select from on customer cards to define how to calculate interest in case the customer''s payment is late.';
                }
                action("Reminder Terms")
                {
                    ApplicationArea = Suite;
                    Caption = 'Reminder Terms';
                    Image = ReminderTerms;
                    Promoted = true;
                    PromotedCategory = Category11;
                    PromotedIsBig = true;
                    RunObject = Page "Reminder Terms";
                    ToolTip = 'Set up reminder terms that you select from on customer cards to define when and how to remind the customer of late payments.';
                }
                action("Rounding Methods")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Rounding Methods';
                    Image = Calculate;
                    Promoted = true;
                    PromotedCategory = Category11;
                    PromotedIsBig = true;
                    RunObject = Page "Rounding Methods";
                    ToolTip = 'Define how amounts are rounded when you use functions to adjust or suggest item prices or standard costs.';
                }
            }
        }
    }
}

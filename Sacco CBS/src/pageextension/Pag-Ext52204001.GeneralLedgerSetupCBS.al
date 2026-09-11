pageextension 52204001 "General Ledger Setup CBS" extends "General Ledger Setup"
{
    PromotedActionCategories = 'New,Process,Report,General,Posting,VAT,Bank,Journal Templates,HR & Payroll,Inventory Payables & Receivables, Payments,Sacco';

    layout
    {
        addlast(General)
        {
            field("Country Code"; Rec."Country Code")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Opening Balance Acc."; Rec."Opening Balance Acc.")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Opening Balance Posting Date"; Rec."Opening Balance Posting Date")
            {
                ApplicationArea = Basic, Suite;
            }
        }
        addafter("Login SMS Notification")
        {
            field("Block SMS"; Rec."Block SMS")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    actions
    {
        addafter("Gen. Product Posting Groups")
        {
            group(Sacco)
            {
                action("Sacco Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Image = SetupPayment;
                    Promoted = true;
                    PromotedCategory = Category12;
                    PromotedIsBig = true;
                    RunObject = Page "Sacco Setup";
                }
                action("Sacco Products")
                {
                    ApplicationArea = Basic, Suite;
                    Image = PaymentForecast;
                    Promoted = true;
                    PromotedCategory = Category12;
                    PromotedIsBig = true;
                    RunObject = Page "Sacco Products";
                }
            }
        }
    }
}

page 52204001 "Sacco Setup"
{
    PromotedActionCategories = 'New,Process,Report,General,Member Details,Credit,FOSA';
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "General Ledger Setup";
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Next Run Time"; Rec."Next Run Time")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Accrual Type"; Rec."Interest Accrual Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Country Code"; Rec."Country Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Refrence Mandatory"; Rec."Payment Refrence Mandatory")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Mobile Withdrawal Alert Limit"; Rec."Mobile Withdrawal Alert Limit")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Mobile Loan Alert Limit"; Rec."Mobile Loan Alert Limit")
                {
                    ApplicationArea = Basic, Suite;
                }
                label("*****GeneralMembership*****")
                {
                    Caption = '*****Membership*****';
                    Style = Favorable;
                }
                field("Minimum Deposit Cont."; Rec."Minimum Deposit Cont.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Minimum Member Age (Yrs)"; Rec."Minimum Member Age (Yrs)")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Dormancy Period"; Rec."Dormancy Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Withdrawal Period"; Rec."Withdrawal Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Share Capital Grace Period"; Rec."Share Capital Grace Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("NOK Amount"; Rec."NOK Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Principal Member Amount"; Rec."Principal Member Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                label("*****GeneralFOSA*****")
                {
                    Caption = '*****FOSA*****';
                    Style = Favorable;
                }
                field("Min. Interest Earning Balance "; Rec."Min. Interest Earning Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Validate Cash Denomination"; Rec."Validate Cash Denomination")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("PesaLink Settlememt Account"; Rec."PesaLink Settlememt Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("PesaLink Charges"; Rec."PesaLink Charges")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Cash Deposit Charges"; Rec."Cash Deposit Charges")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Cash Withdrawal Charges"; Rec."Cash Withdrawal Charges")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Balance Inquiry Charge"; Rec."Balance Inquiry Charge")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Mini Statement Charge"; Rec."Mini Statement Charge")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Full Statement Charge"; Rec."Full Statement Charge")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Inter Acc Transfer Charges"; Rec."Inter Acc Transfer Charges")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Money Laundary Limit"; Rec."Money Laundary Limit")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                label("*****GeneralCredit*****")
                {
                    Caption = '*****Credit*****';
                    Style = StrongAccent;
                }
                field("Daily Interest Accrual"; Rec."Daily Interest Accrual")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Max No. Of Open Loans"; Rec."Max No. Of Open Loans")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Repayment Charge"; Rec."Loan Repayment Charge")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Guarantor Notice Charge"; Rec."Guarantor Notice Charge")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Guarantor Notice Inc. Acc."; Rec."Guarantor Notice Inc. Acc.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Guarantor Multiplier"; Rec."Guarantor Multiplier")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Self Guarantor Multiplier"; Rec."Self Guarantor Multiplier")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Defaulter Loan Product"; Rec."Defaulter Loan Product")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Repayment Start"; Rec."Loan Repayment Start")
                {
                    ApplicationArea = Basic, Suite;
                }
                group("Mobile Loans Sectorial")
                {
                    ShowCaption = false;

                    label("*****Mobile Loans Sectorial*****")
                    {
                        Caption = '*****Mobile Loans Sectorial*****';
                        Style = StrongAccent;
                    }
                    field("Sector Code"; Rec."Sector Code")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Sub Sector Code"; Rec."Sub Sector Code")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Sub-Susector Code"; Rec."Sub-Subsector Code")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                label("*****&Share Trading&*****")
                {
                    Style = Standard;
                    Caption = '*****Share Trading*****';
                }
                field("Share Trading Dimension Code"; Rec."Share Trading Dimension Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Share Trading Dimension No."; Rec."Share Trading Dimension No.")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Journal Posting Setup")
            {
                field("Inter Acc. Transfer Template"; Rec."Inter Acc. Transfer Template")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Inter Acc. Transfer Batch"; Rec."Inter Acc. Transfer Batch")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group(Channels)
            {
                field("Channel Transactins Nos."; Rec."Channel Transactins Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group(Numbering)
            {
                label("*****Product Mgmt*****")
                {
                    Style = StrongAccent;
                }
                field("Product Application Nos."; Rec."Product Application Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Product Editing Nos."; Rec."Product Editing Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                label("*****Membership*****")
                {
                    Style = Favorable;
                }
                field("Member Application Nos."; Rec."Member Application Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Nos."; Rec."Member Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Editing Nos"; Rec."Member Editing Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Acc. Opening Nos."; Rec."Acc. Opening Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Acc. Activation Nos."; Rec."Member Acc. Activation Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Acc. Deativation Nos."; Rec."Member Acc. Deativation Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Charging Nos."; Rec."Member Charging Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Receipt Nos."; Rec."Receipt Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }

                field("Bulk SMS Nos."; Rec."Bulk SMS Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Channel Application Nos."; Rec."Channel Application Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Benevolent Fund Nos."; Rec."Benevolent Fund Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("BOSA Dividend Nos"; Rec."BOSA Dividend Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Refund Nos"; Rec."Member Refund Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Exit Nos"; Rec."Member Exit Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Reactivation Nos"; Rec."Member Reactivation Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                label("*****Credit*****")
                {
                    Style = StrongAccent;
                }
                field("Collateral Application Nos."; Rec."Collateral Application Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Collateral Release Nos."; Rec."Collateral Release Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Calculator Nos"; Rec."Calculator Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Online Loan Nos."; Rec."Online Loan Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Nos."; Rec."Loan Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Disbursement Nos."; Rec."Loan Disbursement Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Batch Nos"; Rec."Loan Batch Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Repayment Nos."; Rec."Loan Repayment Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Recovery Nos"; Rec."Loan Recovery Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Restructure Nos."; Rec."Loan Restructure Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Guarantor Nos"; Rec."Guarantor Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Checkoff Nos"; Rec."Checkoff Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Checkoff Variation Nos."; Rec."Checkoff Variation Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Defaulter Notice Nos"; Rec."Defaulter Notice Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                label("*****FOSA*****")
                {
                    Style = Favorable;
                }
                field("FOSA Nos"; Rec."FOSA Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Teller Transaction Nos"; Rec."Teller Transaction Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Inter Acc. Trans. Nos."; Rec."Inter Acc. Trans. Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Lien Nos."; Rec."Lien Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Cheque Book App. Nos"; Rec."Cheque Book App. Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Cheque Clearance Nos"; Rec."Cheque Clearance Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Cheque Deposit Nos"; Rec."Cheque Deposit Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("ATM Application Nos"; Rec."ATM Application Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Salary Processing Nos"; Rec."Salary Processing Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Standing Order Nos"; Rec."Standing Order Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("FD Nos."; Rec."FD Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Maintenance Nos"; Rec."Maintenance Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("JV Nos"; Rec."JV Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Money Laundary Nos."; Rec."Money Laundary Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Custodial Nos."; Rec."Custodial Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("FOSA Dividend Nos"; Rec."FOSA Dividend Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                label("*****Share Trading*****")
                {
                    Style = Standard;
                }
                field("Share Trading Nos."; Rec."Share Trading Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Share Bid Nos."; Rec."Share Bid Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Share Capital Trans. Nos."; Rec."Share Capital Trans. Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group(Integration)
            {
                field("Device Id"; Rec."Device Id")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("SMS URL"; Rec."SMS Url")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("EDMS Url"; Rec."EDMS Url")
                {
                    ApplicationArea = Basic, Suite;
                }
                label(IPRS)
                {
                    Caption = '*****IPRS Integration*****';
                    Style = Favorable;
                }
                field("IPRS Url"; Rec."IPRS Url")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("IPRS Phone No."; Rec."IPRS Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Attachment Setups")
            {
                field("Passport Size"; Rec."Passport Size")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Signature Size"; Rec."Signature Size")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Identification Card Size"; Rec."Identification Card Size")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group(Communication)
            {
                field("Block SMS"; Rec."Block SMS")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("ICT Admin Phone No."; Rec."ICT Admin Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("ICT Department Email"; Rec."ICT Department Email")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Credit Department Email"; Rec."Credit Department Email")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Marketing Department Email"; Rec."Marketing Department Email")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group("&General")
            {
                action("Product Categories")
                {
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category4;
                    Image = TaxPayment;
                    RunObject = page "Sacco Product Categories";
                }
                action("Products")
                {
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category4;
                    Image = Accounts;
                    RunObject = Page "Sacco Products";
                }
                action("Channel Transaction Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category4;
                    Image = Setup;
                    RunObject = page "Channel Transaction Setup";
                }
                action("Transaction Charges")
                {
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category4;
                    Image = TaxSetup;
                    RunObject = page "Transaction Charges";
                }
                action("Lookup Values")
                {
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category4;
                    Image = ValidateEmailLoggingSetup;
                    RunObject = page "Sacco Lookup Values";
                }
            }
            group("Member Details")
            {
                action("Member Categories")
                {
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category5;
                    Image = CustomerGroup;
                    RunObject = page "Member Categories";
                }
                action("Member Designations")
                {
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category5;
                    Image = Job;
                    RunObject = page "Member Designations";
                    RunPageLink = Type = const(Individual);
                }
                action("Group Member Designations")
                {
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category5;
                    Image = JobJournal;
                    RunObject = page "Member Designations";
                    RunPageLink = Type = const(Group);
                }
            }
            group("Credit Setups")
            {
                action("Loanees Payroll Earnings")
                {
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category6;
                    Image = PayrollStatistics;
                    RunObject = page "Loanees Payroll Codes";
                    RunPageLink = Type = const(Income);
                }
                action("Loanees Payroll Deductions")
                {
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category6;
                    Image = ExchangeRateAdjustRegister;
                    RunObject = page "Loanees Payroll Codes";
                    RunPageLink = Type = const(Deduction);
                }
                action("Economic Sectors")
                {
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category6;
                    Image = CreateWarehousePick;
                    RunObject = page "Economic Sectors";
                }
                action("Recoveries Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category6;
                    Image = SetupColumns;
                    RunObject = page "External Recoveries Setup";
                }
                action("Collateral Types")
                {
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category6;
                    Image = AdjustEntries;
                    RunObject = page "Collateral Types";
                }
            }
            group("FOSA Setups")
            {
                action("Teller Setup")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Teller Setup";
                    Image = CashFlowSetup;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category7;
                }
                action("Denomination Setup")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Denominations Setup";
                    Image = Currencies;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category7;
                }
                action("Channel Transactions Setup")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Channel Transaction Setup";
                    Image = TransferFunds;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category7;
                }
                action("Standing Order Types")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "Standing Order Types";
                    Image = TransferFunds;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category7;
                }
                action(Counties)
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page Counties;
                    Image = CountryRegion;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category7;
                }
                action(Employers)
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page Employers;
                    Image = Vendor;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category7;
                }
            }
        }
    }
    trigger OnOpenPage()
    var
        SaccoSetup: Record "General Ledger Setup";
    begin
        if SaccoSetup.IsEmpty then begin
            SaccoSetup.Init();
            SaccoSetup.Insert(true);
        end;
    end;
}

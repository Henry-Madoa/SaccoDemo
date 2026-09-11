page 52203708 "Payroll Transaction Code Card"
{
    PageType = Card;
    SourceTable = "Payroll Transaction Code";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Frequency; Rec.Frequency)
                {
                    ApplicationArea = Basic, Suite;
                    ValuesAllowed = Fixed, Varied;
                }
                field("Balance Type"; Rec."Balance Type")
                {
                    ApplicationArea = Basic, Suite;
                    ValuesAllowed = None, Increasing, Reducing;
                }
                field("Is Cash"; Rec."Is Cash")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Taxable; Rec.Taxable)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Do not prorate"; Rec."Do not prorate")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Is Formula"; Rec."Is Formula")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Formula; Rec.Formula)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Has Upper Limit"; Rec."Has Upper Limit")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Upper Limit"; Rec."Upper Limit")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Include Employer Deduction"; Rec."Include Employer Deduction")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employer Deduction"; Rec."Employer Deduction")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Is Formula for employer"; Rec."Is Formula for employer")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Is Pension"; Rec."Is Pension")
                {
                    ApplicationArea = Basic, Suite;
                }
                group(Pension)
                {
                    ShowCaption = false;
                    Visible = Rec."Is Pension";

                    field("Is Voluntary"; Rec."Is Voluntary")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                field("GL Account"; Rec."GL Account No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("GL Employer Account"; Rec."GL Employer Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Sub Ledger Type"; Rec."Sub Ledger Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                group(SubLedgerType)
                {
                    ShowCaption = false;
                    Visible = Rec."Sub Ledger Type" = Rec."Sub Ledger Type"::" ";
                    field("Subledger Account"; Rec."Subledger Account")
                    {
                        ShowMandatory = true;
                        ApplicationArea = Basic, Suite;
                    }
                }
                field("For Every Employee"; Rec."For Every Employee")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Category"; Rec."Employee Category")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Specific Month"; Rec."Specific Month")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Show on Master Roll"; Rec."Show on Master Roll")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Other Set-Ups")
            {
                Caption = 'Other Set-Ups';

                field("Special Transactions"; Rec."Special Transactions")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("P10 Allowance Type"; Rec."P10 Allowance Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Deduct Premium"; Rec."Deduct Premium")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Sacco Loan"; Rec."Sacco Loan")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Coop Parameter"; Rec."Coop Parameter")
                {
                    ApplicationArea = Basic, Suite;
                }
                group(VendorPostingGroups)
                {
                    Visible = Rec."Coop Parameter" = Rec."Coop Parameter"::Shares;
                    ShowCaption = false;

                    field("Vendor Posting Groups"; Rec."Vendor Posting Group")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                }
                field("Principal Loan"; Rec."Principal Loan")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Rate"; Rec."Interest Rate")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Suspended; Rec.Suspended)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part(Control3; "Transaction For Jobs")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Transaction Code" = FIELD(Code);
            }
        }
    }
}

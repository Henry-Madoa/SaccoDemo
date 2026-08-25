page 52204004 "Sacco Product"
{
    PageType = Document;
    RefreshOnActivate = true;
    Editable = false;
    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTable = "Sacco Products";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isChild;
                }
                field(Name; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    Editable = isChild;
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    Visible = isChild;
                }
                field("Product Posting Type"; Rec."Product Posting Type")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    Visible = isChild;
                }
                field("Posting Group"; Rec."Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    Visible = isChild;
                }
                field(Prefix; Rec.Prefix)
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    Visible = isChild;
                }
                field(Suffix; Rec.Suffix)
                {
                    ApplicationArea = Basic, Suite;
                    Visible = isChild;
                }
                field("Print Sequence"; Rec."Print Sequence")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = isChild;
                }
                field("Hide on Statement"; Rec."Hide on Statement")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = isChild;
                }
                field("Loan Recovery Priority"; Rec."Loan Recovery Priority")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = isChild;
                }
            }
            group("Account Controls")
            {
                Visible = isChild and (Rec."Product Posting Type" <> Rec."Product Posting Type"::"Loan Account");

                field("Business Account"; Rec."Business Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Cheque Book Allowed"; Rec."Cheque Book Allowed")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("ATM Use Allowed"; Rec."ATM Use Allowed")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Cash Deposit Allowed"; Rec."Cash Deposit Allowed")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Cash Withdraw Allowed"; Rec."Cash Withdraw Allowed")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Cash Transfer Allowed"; Rec."Cash Transfer Allowed")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("&Checkoff Product"; Rec."Checkoff Product")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Minimum Balance"; Rec."Minimum Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Maximum Balance"; Rec."Maximum Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Minimum Contribution"; Rec."Minimum Contribution")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Credit Controls")
            {
                Visible = isChild and (Rec."Product Posting Type" = Rec."Product Posting Type"::"Loan Account");

                field("Max. Running Loans"; Rec."Max. Running Loans")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Multiplier"; Rec."Loan Multiplier")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Maximum Loan Multiplier"; Rec."Maximum Loan Multiplier")
                {
                    ApplicationArea = Basic, Suite;
                }
                Field("Minimum Loan Amount"; Rec."Minimum Loan Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Maximum Loan Amount"; Rec."Maximum Loan Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Boost Deposits"; Rec."Boost Deposits")
                {
                    ApplicationArea = Basic, Suite;
                }
                group(Boosting)
                {
                    Visible = Rec."Boost Deposits";
                    ShowCaption = false;

                    field("Max. NWD Boost"; Rec."Max. NWD Boost")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Max. NWD Boost %"; Rec."Max. NWD Boost %")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                field("Minimum Deposit Balance"; Rec."Minimum Deposit Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                Field("Minimum Deposit Contribution"; Rec."Minimum Deposit Contribution")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Bridging Commision %"; Rec."Bridging Commision %")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Boosting Commission %"; Rec."Boosting Commission %")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Max. Bridging Commission"; Rec."Max. Bridging Commission")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Commission Account"; Rec."Commission Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Repayment Cutoff Date"; Rec."Repayment Cutoff Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Checkoff Product"; Rec."Checkoff Product")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Unsecured Product"; Rec."Unsecured Product")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Exclude Billing & Interest"; Rec."Exclude Billing & Interest")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Appraise with 0 Deposits"; Rec."Appraise with 0 Deposits")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Special Loan Multiplier"; Rec."Special Loan Multiplier")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("View Online"; Rec."View Online")
                {
                    ApplicationArea = Basic, Suite;
                }
                label("*****Interest Control*****")
                {
                    Style = Favorable;
                }
                field("Charge UpFront Interest"; Rec."Charge UpFront Interest")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Due Account"; Rec."Interest Due Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Paid Account"; Rec."Interest Paid Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Bands"; Rec."Interest Bands")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Rate"; Rec."Interest Rate")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Repayment Method"; Rec."Interest Repayment Method")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Rate Type"; Rec."Rate Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                label("*****Penalty*****")
                {
                    Style = Favorable;
                }
                field("Penalty Rate"; Rec."Penalty Rate")
                {
                    ApplicationArea = All;
                }
                field("Penalty Due Account"; Rec."Penalty Due Account")
                {
                    ApplicationArea = All;
                }
                field("Penalty Paid Account"; Rec."Penalty Paid Account")
                {
                    ApplicationArea = All;
                }
                label("*****FOSA Salary Appraisal*****")
                {
                    Style = Favorable;
                }
                field("Dividend Based"; Rec."Dividend Based")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Salary Based"; Rec."Salary Based")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Min. Salary Count"; Rec."Min. Salary Count")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Salary %"; Rec."Salary %")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Salary Appraisal Type"; Rec."Salary Appraisal Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                label("*****Insurance Control*****")
                {
                    Style = Favorable;
                }
                field("Insurance Rate"; Rec."Insurance Rate")
                {
                    MaxValue = 100;
                    ApplicationArea = Basic, Suite;
                }
                field("Insurance Account"; Rec."Insurance Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Insurance Factor"; Rec."Insurance Factor")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Insurance Income %"; Rec."Insurance Income %")
                {
                    MaxValue = 100;
                    ApplicationArea = Basic, Suite;
                }
                field("Insurance Income Account"; Rec."Insurance Income Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                label("*****Disbursement*****")
                {
                    Style = Favorable;
                }
                field("Mode of Disbursement"; Rec."Mode of Disbursement")
                {
                    ApplicationArea = Basic, Suite;
                }
                group("ModeOfDisbursement")
                {
                    ShowCaption = false;
                    Visible = Rec."Mode of Disbursement" = Rec."Mode of Disbursement"::BOSA;

                    field("Disbursement Account"; Rec."Disbursement Account")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                }
                label("*****Installments*****")
                {
                    Style = Favorable;
                }
                field("Minimum Installments"; Rec."Minimum Installments")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Maximum Installments"; Rec."Maximum Installments")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        Rec."Ordinary Default Intallments" := Rec."Maximum Installments";
                    end;
                }
                field("Ordinary Default Intallments"; Rec."Ordinary Default Intallments")
                {
                    ApplicationArea = Basic, Suite;
                }
                label("*****Mobile Controls*****")
                {
                    Style = Favorable;
                }
                field("Mobile Loan"; Rec."Mobile Loan")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Mobile Appraisal Type"; Rec."Mobile Appraisal Type")
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
            action("Linked Products")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = LinkAccount;
                RunObject = page "Linked Products";
                RunPageLink = "Source Code" = field(Code);
                Visible = (isChild and (Rec."Product Posting Type" = Rec."Product Posting Type"::"Loan Account"));
            }
            action("Loan Interest Bands")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Loaner;
                RunObject = page "Loan Interest Bands";
                RunPageLink = "Source Code" = field(Code);
                Visible = (isChild and (Rec."Product Posting Type" = Rec."Product Posting Type"::"Loan Account"));
            }
            action(Charges)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = SuggestFinancialCharge;
                RunObject = page "Product Charge Setup";
                RunPageLink = "Source Code" = field(Code);
                Visible = (isChild and (Rec."Product Posting Type" = Rec."Product Posting Type"::"Loan Account"));
            }
            action("Update Member Accounts")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = BankAccount;
                Visible = isChild;

                trigger OnAction()
                var
                    MemberMgt: Codeunit "Member Management";
                begin
                    MemberMgt.UpdateMemberAccounts(Rec.Code);
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        SetControlAppearance;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetControlAppearance;
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        SetControlAppearance;
    end;

    trigger OnOpenPage()
    begin
        SetControlAppearance;
        if OpenView then CurrPage.Editable := false;
    end;

    var
        DescriptionStyle: Text;
        isChild: Boolean;
        OpenView: Boolean;

    local procedure SetControlAppearance()
    begin
        isChild := ((Rec.Code <> Rec.Category) or (Rec.Code = ''));
    end;

    procedure SetOpenView(NewOpenView: Boolean)
    begin
        OpenView := NewOpenView
    end;
}

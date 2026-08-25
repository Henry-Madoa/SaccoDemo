page 52204013 "Member Statistics"
{
    PageType = CardPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = Members;

    layout
    {
        area(Content)
        {
            group("Member Details")
            {
                Visible = isProtectedViewable;

                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Full Name"; Rec.FullName)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("National ID No"; Rec."Identification No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Mobile Phone No."; Rec."Mobile Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Part of Group"; Rec."Part of Group")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Has Business Account"; Rec."Has Business Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Goals; Rec.Goals)
                {
                    ApplicationArea = Basic, Suite;
                    Style = Favorable;
                }
                field(SMS; Rec.SMS)
                {
                    ApplicationArea = Basic, Suite;
                    Style = Favorable;
                }
            }
            group("Account Information")
            {
                Visible = isProtectedViewable;

                field("Total Deposits"; Rec."Total Deposits")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Shares"; Rec."Total Shares")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Prior Year Dividend"; Rec."Prior Year Dividend")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Mobi Loan Limit"; Rec."Mobi Loan Limit")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Held Collateral"; Rec."Held Collateral")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Running Loans"; Rec."Running Loans")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Outstanding Loans"; Rec."Outstanding Loans")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Book Value"; BookValue)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Uncleared Funds"; Rec."Uncleared Funds")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Available Balance"; AvailableBalance)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Style = Favorable;
                }
            }
            group(Guarantees)
            {
                Visible = isProtectedViewable;

                field("Self Guarantee"; Rec."Self Guarantee")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Non-Self Guarantee"; Rec."Non-Self Guarantee")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Qualified Self Guarantee"; LoansManagement.GetSelfGuaranteeEligibility(Rec."No."))
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Free Deposits"; LoansManagement.GetNonSelfGuaranteeEligibility(Rec."No."))
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        AvailableBalance := 0;
        BookValue := 0;
        UnclearedFunds := 0;
        MinimumBalance := 0;

        UserSetup.Get(UserId);
        if Rec."Protected Account" then begin
            if (UserSetup."View Protected Account" or (Rec."Account Owner" = UserId)) then
                isProtectedViewable := true
            else
                isProtectedViewable := false;
        end
        else
            isProtectedViewable := true;

        Rec.CalcFields("Uncleared Funds");
        Vendor.RESET;
        Vendor.SETRANGE("Member No.", Rec."No.");
        Vendor.SetRange("Product Posting Type", Vendor."Product Posting Type"::"Withdrawable Deposit");
        Vendor.SetRange(Blocked, Vendor.Blocked::" ");
        if Vendor.FindSet then begin
            repeat
                SaccoProduct.Get(Vendor."Product Code");
                Vendor.CalcFields(Balance, "Uncleared Funds");
                BookValue += Vendor.Balance;
                UnclearedFunds += Vendor."Uncleared Funds";
                MinimumBalance += SaccoProduct."Minimum Balance";
            until Vendor.Next = 0;
        end;
        AvailableBalance := BookValue - UnclearedFunds - MinimumBalance - ChannelsIntegrations.GetPendingChannelsTransactions(Rec."No.");
        if AvailableBalance < 0 then AvailableBalance := 0;
    end;

    var
        LoansManagement: Codeunit "Loans Management";
        isProtectedViewable: Boolean;
        UserSetup: Record "User Setup";
        Vendor: Record Vendor;
        AvailableBalance: Decimal;
        BookValue: Decimal;
        UnclearedFunds: Decimal;
        MinimumBalance: Decimal;
        SaccoProduct: Record "Sacco Products";
        ChannelsIntegrations: Codeunit "Channels Integrations";
}

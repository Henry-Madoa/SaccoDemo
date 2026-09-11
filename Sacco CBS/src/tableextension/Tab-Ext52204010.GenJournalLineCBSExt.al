tableextension 52204010 "Gen. Journal Line CBS Ext." extends "Gen. Journal Line"
{
    fields
    {
        field(52204000; "Member No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Members;
            Editable = false;
        }
        field(52204001; "Transaction Type"; Enum "Sacco Transaction Type")
        {
        }
        field(52204002; "Product Posting Type"; Enum "Product Posting Type")
        {
        }
        field(52204003; "Loan No."; Code[20])
        {
            TableRelation = Loans."No." where("Member No." = field("Member No."));
        }
        modify("Account No.")
        {
            trigger OnAfterValidate()
            var
                Vendor: Record Vendor;
            begin
                if Rec."Account Type" = Rec."Account Type"::Vendor then begin
                    if Vendor.Get(Rec."Account No.") then begin
                        Rec."Member No." := Vendor."Member No.";
                        Rec."Product Posting Type" := Vendor."Product Posting Type";
                    end;
                end;
            end;
        }
        modify("Debit Amount")
        {
            trigger OnAfterValidate()
            begin
                UserSetup.Get(UserId);
                If Vendor.Get("Account No.") then begin
                    if Vendor."Account Type" = Vendor."Account Type"::Sacco then begin
                        If Vendor."Account Type" <> Vendor."Product Posting Type"::"Loan Account" then begin
                            SaccoProduct.Get(Vendor."Product Code");
                            Vendor.CalcFields(Balance, "Uncleared Funds");

                            AvailableBalance := Vendor.Balance - Vendor."Uncleared Funds" - SaccoProduct."Minimum Balance";

                            if AvailableBalance < 0 then
                                AvailableBalance := 0;

                            if ((AvailableBalance - "Debit Amount" < 0) and (not UserSetup."Can Overdraw Account")) then
                                Error('You cannot Overdraw Account!');
                        end;
                    end;
                end;
                If Vendor.Get("Bal. Account No.") then begin
                    SaccoProduct.Get(Vendor."Product Code");
                    Vendor.CalcFields(Balance);
                    if Vendor."Account Type" = Vendor."Account Type"::Sacco then begin
                        if SaccoProduct."Maximum Balance" <> 0 then begin
                            if ((Vendor.Balance + Rec."Debit Amount") > SaccoProduct."Maximum Balance") then
                                Error(StrSubstNo('You cannot exceed %1 which is the Maximum Balance.', Format(SaccoProduct."Maximum Balance")));
                        end;
                    end;
                end;
            end;
        }
        modify("Credit Amount")
        {
            trigger OnAfterValidate()
            begin
                UserSetup.Get(UserId);
                If Vendor.Get("Bal. Account No.") then begin
                    if Vendor."Account Type" = Vendor."Account Type"::Sacco then begin
                        If Vendor."Account Type" <> Vendor."Product Posting Type"::"Loan Account" then begin
                            SaccoProduct.Get(Vendor."Product Code");
                            Vendor.CalcFields(Balance, "Uncleared Funds");
                            AvailableBalance := Vendor.Balance - Vendor."Uncleared Funds" - SaccoProduct."Minimum Balance";
                            if AvailableBalance < 0 then AvailableBalance := 0;

                            if ((AvailableBalance - "Credit Amount" < 0) and (not UserSetup."Can Overdraw Account")) then
                                Error('You cannot Overdraw Account!');
                        end;
                    end;
                end;

                If Vendor.Get("Account No.") then begin
                    SaccoProduct.Get(Vendor."Product Code");
                    Vendor.CalcFields(Balance);
                    if Vendor."Account Type" = Vendor."Account Type"::Sacco then begin
                        if SaccoProduct."Maximum Balance" <> 0 then begin
                            if ((Vendor.Balance + Rec."Credit Amount") > SaccoProduct."Maximum Balance") then
                                Error(StrSubstNo('You cannot exceed %1 which is the Maximum Balance.', Format(SaccoProduct."Maximum Balance")));
                        end;
                    end;
                end;
            end;
        }
    }
    var
        Vendor: Record Vendor;
        AvailableBalance: Decimal;
        SaccoProduct: Record "Sacco Products";
        UserSetup: Record "User Setup";
}

table 52204073 "Dividend Det. Entries"
{
    DrillDownPageID = "Dividend Det. Lines";
    LookupPageID = "Dividend Det. Lines";

    fields
    {
        field(1; "Dividend Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Member No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Members;
        }
        field(3; "Entry Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Int. Earned,Charges,Loan Principal,Share Boost,Loan Interest';
            OptionMembers = "Int. Earned",Charges,"Loan Principal","Share Boost","Loan Interest";
        }
        field(4; Code; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Vendor;
        }
        field(5; Description; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(6; Amount; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                DividendHeader: Record "Dividend Header";
                SaccoSetup: Record "General Ledger Setup";
                MinRunningBal: Decimal;
            begin
                DividendHeader.Get("Dividend Code");
                if DividendHeader."Document Type" = DividendHeader."Document Type"::BOSA then begin
                    if "Month No." <> 1 then begin
                        if (("Net Change" > 0) and ("Current Month Balance" > "Min. Balance")) then
                            Amount := Round("Net Change" * (Rate / 100) * Ratio);
                    end
                    else begin
                        Amount := Round("Net Change" * (Rate / 100) * Ratio);
                    end;
                end else begin
                    CalcFields("Minimum Running Balance");
                    if "Minimum Running Balance" > "Previous Month Balance" then
                        MinRunningBal := "Previous Month Balance"
                    else
                        MinRunningBal := "Minimum Running Balance";

                    SaccoSetup.Get;
                    SaccoSetup.TestField("Min. Interest Earning Balance");

                    if MinRunningBal > 0 then
                        Amount := Round((MinRunningBal - SaccoSetup."Min. Interest Earning Balance") * (Rate / 100) * (1 / 12))
                    else
                        Amount := Round(("Current Month Balance" - SaccoSetup."Min. Interest Earning Balance") * (Rate / 100) * (1 / 12));
                end;
                if Amount < 0 then
                    Amount := 0
            end;
        }
        field(7; "Account Type"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Account Balance"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Month Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Month No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Destination Account"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Boosting Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Net Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "System Entry"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Entry No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Pre Calculated"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Posting Type"; Option)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            OptionCaption = 'Pro Rated,Flat Rate';
            OptionMembers = "Pro Rated","Flat Rate";
        }
        field(18; Rate; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Previous Month"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Previous Month Balance"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Posting Type" = "Posting Type"::"Pro Rated" then begin
                    if "Month No." <> 1 then begin
                        if ("Month No." - 1) in [1, 3, 5, 7, 8, 10, 12] then
                            Edate := DMY2Date(31, ("Month No." - 1), Year)
                        else if ("Month No." - 1) in [4, 6, 9, 11] then
                            Edate := DMY2Date(30, ("Month No." - 1), Year)
                        else begin
                            if Year mod 4 = 0 then
                                Edate := DMY2Date(29, ("Month No." - 1), Year)
                            else
                                Edate := DMY2Date(28, ("Month No." - 1), Year);
                        end;
                        Sdate := DMY2Date(1, ("Month No." - 1), Year);
                        DetailedVendorLedgEntry.Reset;
                        DetailedVendorLedgEntry.SetFilter("Posting Date", '..%1', Edate);
                        DetailedVendorLedgEntry.SetRange("Vendor No.", Code);
                        if DetailedVendorLedgEntry.FindSet then begin
                            DetailedVendorLedgEntry.CalcSums(Amount);
                            "Previous Month Balance" := -1 * DetailedVendorLedgEntry.Amount;
                        end;
                    end
                    else begin
                        "Previous Month" := 'DEC-' + Format(Year - 1);
                        DetailedVendorLedgEntry.Reset;
                        DetailedVendorLedgEntry.SetFilter("Posting Date", '..%1', Edate);
                        DetailedVendorLedgEntry.SetRange("Vendor No.", Code);
                        if DetailedVendorLedgEntry.FindSet then begin
                            DetailedVendorLedgEntry.CalcSums(Amount);
                            "Previous Month Balance" := -1 * DetailedVendorLedgEntry.Amount;
                        end;
                    end;
                end
                else
                    "Previous Month Balance" := 0;
            end;
        }
        field(21; "Current Month"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Current Month Balance"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                RunningBalance: Decimal;
                DividendHeader: Record "Dividend Header";
            begin
                DividendHeader.Get("Dividend Code");
                if "Posting Type" = "Posting Type"::"Pro Rated" then begin
                    if "Month No." in [1, 3, 5, 7, 8, 10, 12] then
                        Edate := DMY2Date(31, "Month No.", Year)
                    else if "Month No." in [4, 6, 9, 11] then
                        Edate := DMY2Date(30, "Month No.", Year)
                    else begin
                        if Year mod 4 = 0 then
                            Edate := DMY2Date(29, "Month No.", Year)
                        else
                            Edate := DMY2Date(28, "Month No.", Year);
                    end;
                    Sdate := DMY2Date(1, "Month No.", Year);

                    DetailedVendorLedgEntry.Reset;
                    DetailedVendorLedgEntry.SetFilter("Posting Date", '..%1', Edate);
                    DetailedVendorLedgEntry.SetRange("Vendor No.", Code);
                    if DetailedVendorLedgEntry.FindSet then begin
                        DetailedVendorLedgEntry.CalcSums(Amount);
                        "Current Month Balance" := -1 * DetailedVendorLedgEntry.Amount;
                    end;

                    if DividendHeader."Document Type" = DividendHeader."Document Type"::FOSA then begin
                        VendorLedgerEntry.Reset;
                        VendorLedgerEntry.SetCurrentKey("Entry No.");
                        VendorLedgerEntry.SetAscending("Entry No.", true);
                        VendorLedgerEntry.SetFilter("Posting Date", '%1..%2', Sdate, Edate);
                        VendorLedgerEntry.SetRange("Vendor No.", Code);
                        VendorLedgerEntry.SetRange(Reversed, false);
                        if VendorLedgerEntry.FindSet then begin
                            RunningBalance := "Previous Month Balance";
                            repeat
                                VendorLedgerEntry.CalcFields(Amount);
                                RunningBalance += (-1 * VendorLedgerEntry.Amount);
                                DividendDetRunningEntries.Init();
                                DividendDetRunningEntries."Entry No" := DividendDetRunningEntries.GetLastEntryNo + 1;
                                DividendDetRunningEntries."Dividend Code" := "Dividend Code";
                                DividendDetRunningEntries."Member No." := "Member No.";
                                DividendDetRunningEntries."Dividend Det. Entry No" := "Entry No";
                                DividendDetRunningEntries."Entry Type" := "Entry Type";
                                DividendDetRunningEntries.Code := Code;
                                DividendDetRunningEntries."Month Code" := "Month Code";
                                DividendDetRunningEntries."Month No." := "Month No.";
                                DividendDetRunningEntries."Posting Date" := VendorLedgerEntry."Posting Date";
                                DividendDetRunningEntries."Document No." := VendorLedgerEntry."Document No.";
                                DividendDetRunningEntries.Amount := -1 * VendorLedgerEntry.Amount;
                                DividendDetRunningEntries."Running Balance" := RunningBalance;
                                DividendDetRunningEntries.Insert(true);
                            until VendorLedgerEntry.Next = 0;
                        end;
                    end;
                end
                else begin
                    DividendHeader.Get("Dividend Code");
                    Edate := DividendHeader."End Date";
                    DetailedVendorLedgEntry.Reset;
                    DetailedVendorLedgEntry.SetFilter("Posting Date", '..%1', Edate);
                    DetailedVendorLedgEntry.SetRange("Vendor No.", Code);
                    if DetailedVendorLedgEntry.FindSet then begin
                        DetailedVendorLedgEntry.CalcSums(Amount);
                        "Current Month Balance" := -1 * DetailedVendorLedgEntry.Amount;
                    end;
                end;
            end;
        }
        field(23; "Net Change"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Month No." <> 1 then
                    "Net Change" := "Current Month Balance" - "Previous Month Balance"
                else
                    "Net Change" := "Current Month Balance";
            end;
        }
        field(24; Year; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(25; Ratio; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Posting Type" = "Posting Type"::"Pro Rated" then begin
                    case "Month No." of
                        1:
                            Ratio := Round(12 / 12);
                        2:
                            Ratio := Round(11 / 12);
                        3:
                            Ratio := Round(10 / 12);
                        4:
                            Ratio := Round(9 / 12);
                        5:
                            Ratio := Round(8 / 12);
                        6:
                            Ratio := Round(7 / 12);
                        7:
                            Ratio := Round(6 / 12);
                        8:
                            Ratio := Round(5 / 12);
                        9:
                            Ratio := Round(4 / 12);
                        10:
                            Ratio := Round(3 / 12);
                        11:
                            Ratio := Round(2 / 12);
                        12:
                            Ratio := Round(1 / 12);
                    end;
                end
                else
                    Ratio := 1;
            end;
        }
        field(26; "Min. Balance"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(27; "Minimum Running Balance"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = min("Dividend Det. Running Entries"."Running Balance" where("Dividend Code" = field("Dividend Code"), "Member No." = field("Member No."), "Entry Type" = field("Entry Type"), "Code" = field(Code), "Month Code" = field("Month Code"), "Dividend Det. Entry No" = field("Entry No")));
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Dividend Code", "Member No.", "Entry Type", Code, "Month Code", "Entry No")
        {
            Clustered = true;
        }
        key(Key2; "Member No.", "Month No.")
        {
        }
    }
    var
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DividendDetRunningEntries: Record "Dividend Det. Running Entries";
        Sdate: Date;
        Edate: Date;
        DividendHeader: Record "Dividend Header";
}

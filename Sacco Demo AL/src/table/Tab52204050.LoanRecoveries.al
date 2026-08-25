table 52204050 "Loan Recoveries"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Loan Recoveries";
    DrillDownPageId = "Loan Recoveries";

    fields
    {
        field(1; "Loan No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Recovery Type"; Enum "Loan Recovery Types")
        {
        }
        field(3; "Recovery Code"; Code[20])
        {
            trigger OnLookup()
            var
                LoanApplication, LoanApplication1 : Record Loans;
                OnlineLoanApplication, OnlineLoanApplication1 : Record "Channel Loan Application";
                Vendor: Record Vendor;
                SaccoProducts: Record "Sacco Products";
                ExternalSetup: Record "External Recoveries Setup";
                LoansMgt: Codeunit "Loans Management";
            begin
                if LoanApplication.Get("Loan No") then begin
                    Case "Recovery Type" of
                        Rec."Recovery Type"::Account:
                            begin
                                Vendor.Reset();
                                Vendor.SetRange("Member No.", LoanApplication."Member No.");
                                Vendor.SetRange("Account Type", Vendor."Account Type"::Sacco);
                                if Page.RunModal(0, Vendor) = Action::LookupOK then begin
                                    Validate("Recovery Code", Vendor."No.");
                                    Vendor.CalcFields(Balance);
                                    "Recovery Description" := Vendor.Name;
                                    SaccoProducts.Get(LoanApplication."Product Code");
                                    "Commission %" := SaccoProducts."Boosting Commission %";
                                    "Commission Account" := SaccoProducts."Commission Account";
                                    "Current Balance" := Vendor.Balance;
                                end;
                            end;
                        Rec."Recovery Type"::Loan:
                            begin
                                LoanApplication1.Reset();
                                LoanApplication1.SetFilter("No.", '<>%1', LoanApplication."No.");
                                LoanApplication1.SetRange("Member No.", LoanApplication."Member No.");
                                LoanApplication1.SetFilter("Loan Balance", '>0');
                                if Page.RunModal(0, LoanApplication1) = Action::LookupOK then begin
                                    SaccoProducts.Get(LoanApplication1."Product Code");
                                    "Recovery Code" := LoanApplication1."No.";
                                    "Recovery Description" := SaccoProducts.Description;
                                    "Commission %" := SaccoProducts."Bridging Commision %";
                                    "Commission Account" := SaccoProducts."Commission Account";
                                    "Max. Commission Amount" := SaccoProducts."Max. Bridging Commission";
                                    LoanApplication1.CalcFields("Loan Balance");
                                    "Current Balance" := LoanApplication1."Loan Balance";
                                    "Prorated Interest" := LoansMgt.GetProratedInterest(LoanApplication1."No.", LoanApplication."Application Date");
                                end;
                            end;
                        Rec."Recovery Type"::External:
                            begin
                                ExternalSetup.Reset();
                                if Page.RunModal(0, ExternalSetup) = Action::LookupOK then begin
                                    "Recovery Code" := ExternalSetup."Recovery Code";
                                    "Recovery Description" := ExternalSetup."Recovery Description";
                                    "Commission %" := ExternalSetup.Commission;
                                    "Commission Account" := ExternalSetup."Commission Account";
                                end;
                            end;
                    end;
                end
                else begin
                    if OnlineLoanApplication.Get("Loan No") then begin
                        Case "Recovery Type" of
                            Rec."Recovery Type"::Account:
                                begin
                                    Vendor.Reset();
                                    Vendor.SetRange("Member No.", OnlineLoanApplication."Member No.");
                                    Vendor.SetRange("Account Type", Vendor."Account Type"::Sacco);
                                    if Page.RunModal(0, Vendor) = Action::LookupOK then begin
                                        Validate("Recovery Code", Vendor."No.");
                                        Vendor.CalcFields(Balance);
                                        "Recovery Description" := Vendor.Name;
                                        SaccoProducts.Get(OnlineLoanApplication."Product Code");
                                        "Commission %" := SaccoProducts."Boosting Commission %";
                                        "Commission Account" := SaccoProducts."Commission Account";
                                        "Current Balance" := Vendor.Balance;
                                    end;
                                end;
                            Rec."Recovery Type"::Loan:
                                begin
                                    LoanApplication1.Reset();
                                    LoanApplication1.SetRange("Member No.", OnlineLoanApplication."Member No.");
                                    LoanApplication1.SetFilter("Loan Balance", '>0');
                                    if Page.RunModal(0, LoanApplication1) = Action::LookupOK then begin
                                        SaccoProducts.Get(LoanApplication1."Product Code");
                                        "Recovery Code" := LoanApplication1."No.";
                                        "Recovery Description" := SaccoProducts.Description;
                                        "Commission %" := SaccoProducts."Bridging Commision %";
                                        "Commission Account" := SaccoProducts."Commission Account";
                                        "Max. Commission Amount" := SaccoProducts."Max. Bridging Commission";
                                        LoanApplication1.CalcFields("Loan Balance");
                                        "Current Balance" := LoanApplication1."Loan Balance";
                                        "Prorated Interest" := LoansMgt.GetProratedInterest(LoanApplication1."No.", OnlineLoanApplication."Application Date");
                                        Validate(Amount, ("Current Balance" + "Prorated Interest"));
                                    end;
                                end;
                            Rec."Recovery Type"::External:
                                begin
                                    ExternalSetup.Reset();
                                    if Page.RunModal(0, ExternalSetup) = Action::LookupOK then begin
                                        "Recovery Code" := ExternalSetup."Recovery Code";
                                        "Recovery Description" := ExternalSetup."Recovery Description";
                                        "Commission %" := ExternalSetup.Commission;
                                        "Commission Account" := ExternalSetup."Commission Account";
                                    end;
                                end;
                        end;
                    end;
                end;
            end;

            trigger OnValidate()
            var
                LoanApplication, LoanApplication1 : Record Loans;
                OnlineLoanApplication, OnlineLoanApplication1 : Record "Channel Loan Application";
                Vendor: Record Vendor;
                SaccoProducts: Record "Sacco Products";
                ExternalSetup: Record "External Recoveries Setup";
                LoansMgt: Codeunit "Loans Management";
            begin
                if LoanApplication.Get("Loan No") then begin
                    Case "Recovery Type" of
                        Rec."Recovery Type"::Account:
                            begin
                                if Vendor.Get("Recovery Code") then begin
                                    Vendor.CalcFields(Balance);
                                    "Recovery Description" := Vendor.Name;
                                    SaccoProducts.Get(LoanApplication."Product Code");
                                    "Commission %" := SaccoProducts."Boosting Commission %";
                                    "Commission Account" := SaccoProducts."Commission Account";
                                    "Current Balance" := Vendor.Balance;
                                end;
                            end;
                        Rec."Recovery Type"::Loan:
                            begin
                                if LoanApplication1.Get("Recovery Code") then begin
                                    SaccoProducts.Get(LoanApplication1."Product Code");
                                    "Recovery Description" := SaccoProducts.Description;
                                    "Commission %" := SaccoProducts."Bridging Commision %";
                                    "Commission Account" := SaccoProducts."Commission Account";
                                    "Max. Commission Amount" := SaccoProducts."Max. Bridging Commission";
                                    LoanApplication1.CalcFields("Loan Balance");
                                    "Current Balance" := LoanApplication1."Loan Balance";
                                    "Prorated Interest" := LoansMgt.GetProratedInterest(LoanApplication1."No.", LoanApplication."Application Date");
                                end;
                            end;
                        Rec."Recovery Type"::External:
                            begin
                                if ExternalSetup.Get("Recovery Code") then begin
                                    "Recovery Description" := ExternalSetup."Recovery Description";
                                    "Commission %" := ExternalSetup.Commission;
                                    "Commission Account" := ExternalSetup."Commission Account";
                                end;
                            end;
                    end;
                end
                else begin
                    if OnlineLoanApplication.Get("Loan No") then begin
                        Case "Recovery Type" of
                            Rec."Recovery Type"::Account:
                                begin
                                    if Vendor.Get("Recovery Code") then begin
                                        Vendor.CalcFields(Balance);
                                        "Recovery Description" := Vendor.Name;
                                        SaccoProducts.Get(OnlineLoanApplication."Product Code");
                                        "Commission %" := SaccoProducts."Boosting Commission %";
                                        "Commission Account" := SaccoProducts."Commission Account";
                                        "Current Balance" := Vendor.Balance;
                                    end;
                                end;
                            Rec."Recovery Type"::Loan:
                                begin
                                    if LoanApplication1.Get("Recovery Code") then begin
                                        SaccoProducts.Get(LoanApplication1."Product Code");
                                        "Recovery Description" := SaccoProducts.Description;
                                        "Commission %" := SaccoProducts."Bridging Commision %";
                                        "Commission Account" := SaccoProducts."Commission Account";
                                        LoanApplication1.CalcFields("Loan Balance");
                                        "Current Balance" := LoanApplication1."Loan Balance";
                                        "Prorated Interest" := LoansMgt.GetProratedInterest(LoanApplication1."No.", OnlineLoanApplication."Application Date");
                                        Validate(Amount, ("Current Balance" + "Prorated Interest"));
                                    end;
                                end;
                            Rec."Recovery Type"::External:
                                begin
                                    if ExternalSetup.Get("Recovery Code") then begin
                                        "Recovery Description" := ExternalSetup."Recovery Description";
                                        "Commission %" := ExternalSetup.Commission;
                                        "Commission Account" := ExternalSetup."Commission Account";
                                    end;
                                end;
                        end;
                    end;
                end;
            end;
        }
        field(4; "Recovery Description"; Text[150])
        {
            Editable = true;
        }
        field(5; Amount; Decimal)
        {
            trigger OnValidate()
            var
                SaccoProducts: Record "Sacco Products";
                Loans: Record Loans;
                DepAportionment: Decimal;
            begin
                If "Commission %" <> 0 then
                    "Commission Amount" := Amount * "Commission %" * 0.01
                else
                    "Commission Amount" := 0;

                if Loans.Get("Loan No") then begin
                    if "Recovery Type" = "Recovery Type"::Account then begin
                        Loans.TestField("Product Code");
                        SaccoProducts.Get(Loans."Product Code");
                        if ((SaccoProducts."Max. NWD Boost" <> 0) AND (SaccoProducts."Max. NWD Boost" < Amount)) then Error('Product %1 Allows a Maximum Deposit Boost of %2', SaccoProducts.Description, SaccoProducts."Max. NWD Boost");
                        if (SaccoProducts."Max. NWD Boost %" <> 0) then begin
                            DepAportionment := 0;
                            DepAportionment := "Current Balance" * SaccoProducts."Max. NWD Boost %" * 0.01;
                            if Amount > DepAportionment then
                                Error('You can only boost upto %1 percent of your deposits', SaccoProducts."Max. NWD Boost %");
                        end;
                    end;
                    if "Recovery Type" = "Recovery Type"::Loan then begin
                        if Loans."Loan Type" = Loans."Loan Type"::"Restructued Loan" then
                            "Commission Amount" := 0;
                    end;
                end;
            end;
        }
        field(6; "Commission %"; decimal)
        {
            Editable = false;
        }
        field(7; "Commission Amount"; decimal)
        {
            Editable = false;
        }
        field(8; "Commission Account"; Code[20])
        {
            Editable = false;
        }
        field(9; "Current Balance"; Decimal)
        {
            Editable = false;
        }
        field(10; "Prorated Interest"; Decimal)
        {
            Editable = false;
        }
        field(11; "Max. Commission Amount"; Decimal)
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Loan No", "Recovery Type", "Recovery Code")
        {
            Clustered = true;
        }
    }
}

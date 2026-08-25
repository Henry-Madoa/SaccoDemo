table 52204097 "Checkoff Variation Header"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Member No"; Code[20])
        {
            TableRelation = Members;

            trigger OnValidate()
            var
                Members: Record Members;
            begin
                if Members.Get("Member No") then "Member Name" := Members."Full Name";
                PopulateCurrentSubscriptions();
            end;
        }
        field(3; "Member Name"; Text[150])
        {
            Editable = false;
        }
        field(4; "Effective Date"; Date)
        {
        }
        field(5; "Created On"; DateTime)
        {
            Editable = false;
        }
        field(6; "Created By"; Code[50])
        {
            TableRelation = "User Setup";
            Editable = false;
        }
        field(7; Processed; Boolean)
        {
            Editable = false;
        }
        field(8; Status; Option)
        {
            Editable = false;
            OptionMembers = New,Submitted;
        }
        field(9; "Source Type"; Option)
        {
            OptionMembers = "Core Banking",Channels;
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
    local procedure PopulateCurrentSubscriptions()
    var
        Products: Record "Sacco Products";
        Subscriptions: Record "Member Subscriptions";
        CheckoffVariationLines: Record "Checkoff Variation Lines";
        CheckoffAdvice: Record "Checkoff Advice";
        Vendor: Record Vendor;
        Loans: Record Loans;
    begin
        CheckoffVariationLines.Reset();
        CheckoffVariationLines.SetRange("No.", "No.");
        if CheckoffVariationLines.FindSet() then CheckoffVariationLines.DeleteAll();
        Loans.Reset();
        Loans.SetFilter("Loan Balance", '<>0');
        Loans.SetRange("Member No.", "Member No");
        if Loans.FindSet() then begin
            repeat
                Loans.CalcFields("Loan Balance");
                if Products.Get(Loans."Product Code") then begin
                    if Products."Checkoff Product" then begin
                        CheckoffVariationLines.Init();
                        CheckoffVariationLines."No." := "No.";
                        CheckoffVariationLines."Product Code" := Loans."Product Code";
                        CheckoffVariationLines.Description := Loans."Product Description";
                        Loans.CalcFields("Monthly Installment", "Monthly Principal");
                        CheckoffAdvice.Reset();
                        CheckoffAdvice.SetRange("Member No", "Member No");
                        CheckoffAdvice.SetRange("Product Code", Loans."Product Code");
                        CheckoffAdvice.SetAscending("Entry No", false);
                        if CheckoffAdvice.FindFirst() then
                            CheckoffVariationLines."Current Contribution" := CheckoffAdvice."Amount On"
                        else begin
                            if Loans."Rescheduled Installment" <> 0 then
                                CheckoffVariationLines."Current Contribution" := Loans."Rescheduled Installment"
                            else if Loans."Interest Repayment Method" = Loans."Interest Repayment Method"::Amortised then
                                CheckoffVariationLines."Current Contribution" := Loans."Monthly Installment"
                            else
                                CheckoffVariationLines."Current Contribution" := Loans."Monthly Principal";
                        end;
                        CheckoffVariationLines."Account Balance" := Loans."Loan Balance"; //Fred
                        CheckoffVariationLines."Application No." := Loans."No."; //Fred
                        CheckoffVariationLines."Loan Account" := Loans."Loan Account"; //Fred
                        CheckoffVariationLines.Insert(true);
                    end;
                end;
            until Loans.Next() = 0;
        end;
        Subscriptions.Reset();
        Subscriptions.SetRange("Source Code", "Member No");
        if Subscriptions.FindSet() then begin
            repeat
                CheckoffVariationLines.Init();
                CheckoffVariationLines."No." := "No.";
                CheckoffVariationLines."Product Code" := Subscriptions."Account Type";
                CheckoffVariationLines.Description := Subscriptions."Account Name";
                CheckoffAdvice.Reset();
                CheckoffAdvice.SetRange("Member No", "Member No");
                CheckoffAdvice.SetRange("Product Code", CheckoffVariationLines."Product Code");
                CheckoffAdvice.SetAscending("Entry No", false);
                if CheckoffAdvice.FindFirst() then
                    CheckoffVariationLines."Current Contribution" := CheckoffAdvice."Amount On"
                else
                    CheckoffVariationLines."Current Contribution" := Subscriptions.Amount;
                Vendor.Reset();
                Vendor.SetRange("Member No.", "Member No");
                Vendor.SetRange("Product Code", Subscriptions."Account Type");
                if Vendor.FindSet() then begin
                    Vendor.CalcFields(Balance);
                    CheckoffVariationLines."Account Balance" := Vendor.Balance;
                end;
                CheckoffVariationLines.Insert();
            until Subscriptions.Next() = 0;
        end;
        Products.Reset();
        Products.SetFilter("Product Posting Type", '%1|%2', Products."Product Posting Type"::"Withdrawable Deposit", Products."Product Posting Type"::"Non Withdrawable Deposit");
        Products.SetRange("Checkoff Product", true);
        if Products.FindSet() then begin
            repeat
                if CheckoffVariationLines.Get("No.", Products.Code) = false then begin
                    CheckoffVariationLines.Init();
                    CheckoffVariationLines."No." := "No.";
                    CheckoffVariationLines."Product Code" := Products.Code;
                    CheckoffVariationLines.Description := Products.Description;
                    CheckoffVariationLines."Current Contribution" := 0;

                    Vendor.Reset();
                    Vendor.SetRange("Member No.", "Member No");
                    Vendor.SetRange("Product Code", Products.Code);
                    if Vendor.FindSet() then begin
                        Vendor.CalcFields(Balance);
                        CheckoffVariationLines."Account Balance" := Vendor.Balance;
                    end;
                    CheckoffVariationLines.Insert();
                end;
            until Products.Next() = 0;
        end;
    end;

    var
        NoSeries: Codeunit NoSeriesManagement;
        SACCOSetup: Record "General Ledger Setup";

    trigger OnInsert()
    begin
        SACCOSetup.Get();
        SACCOSetup.TestField("Checkoff Variation Nos.");
        if "No." = '' then "No." := NoSeries.GetNextNo(SACCOSetup."Checkoff Nos", Today, true);
        if GuiAllowed then
            "Source Type" := "Source Type"::"Core Banking"
        else
            "Source Type" := "Source Type"::Channels;
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
    end;
}

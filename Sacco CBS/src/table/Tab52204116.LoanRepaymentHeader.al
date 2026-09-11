table 52204116 "Loan Repayment Header"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
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
            end;
        }
        field(3; "Member Name"; Text[200])
        {
            Editable = false;
        }
        field(4; "Account No"; Code[20])
        {
            trigger OnLookup()
            var
                Vendor: Record Vendor;
                SaccoProducts: Record "Sacco Products";
                ChannelsIntegrations: Codeunit "Channels Integrations";
            begin
                Vendor.Reset();
                Vendor.SetRange("Member No.", "Member No");
                Vendor.SetFilter("Product Posting Type", '%1|%2|%3|%4', Vendor."Product Posting Type"::"Withdrawable Deposit", Vendor."Product Posting Type"::"Holding Account", Vendor."Product Posting Type"::"Investments Account", Vendor."Product Posting Type"::"School Fee Account");
                if Page.RunModal(0, Vendor) = Action::LookupOK then begin
                    "Account No" := Vendor."No.";
                    "Account Name" := Vendor.Name;
                    Vendor.CalcFields(Balance);
                    SaccoProducts.Get(Vendor."Product Code");
                    "Available Balance" := Vendor.Balance - Vendor."Uncleared Funds" - SaccoProducts."Minimum Balance" - ChannelsIntegrations.GetPendingChannelsTransactions(Vendor."Member No.");
                end;
            end;
        }
        field(5; "Account Name"; Text[100])
        {
            Editable = false;
        }
        field(6; "Available Balance"; Decimal)
        {
            Editable = false;
        }
        field(7; "Created By"; Code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(8; "Created On"; DateTime)
        {
            Editable = false;
        }
        field(9; "Posted"; Boolean)
        {
            Editable = false;
        }
        field(10; "Posting Date"; Date)
        {
            trigger OnValidate()
            begin
                if "Posting Date" > WorkDate then
                    Error('You cannot use a future Date');
            end;
        }
        field(11; "Payment Amount"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Loan Repayment Lines"."Payment Amount" where("No." = field("No.")));
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
    var
        NoSeries: Codeunit NoSeriesManagement;
        SaccoSetup: Record "General Ledger Setup";

    trigger OnInsert()
    begin
        SaccoSetup.Get();
        SaccoSetup.TestField("Loan Repayment Nos.");
        "No." := NoSeries.GetNextNo(SaccoSetup."Loan Repayment Nos.", Today, true);
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
        "Posting Date" := WorkDate;
    end;

    trigger OnModify()
    begin
        TestField(Posted, false);
    end;

    trigger OnDelete()
    begin
        TestField(Posted, false);
    end;
}

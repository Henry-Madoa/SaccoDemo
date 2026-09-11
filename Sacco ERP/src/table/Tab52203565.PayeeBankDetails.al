table 52203565 "Payee Bank Details"
{
    DataCaptionFields = "Ben ID", "Beneficiary Name";

    fields
    {
        field(1; LineNo; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; "Ben ID"; Code[20])
        {
        }
        field(3; "Beneficiary Name"; Text[100])
        {
            Editable = false;
        }
        field(4; "Customer No"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = Customer;

            trigger OnValidate()
            begin
                if Cust.Get("Customer No")then begin
                    "Ben ID":=Cust."No.";
                    "Beneficiary Name":=Cust.Name;
                end;
            end;
        }
        field(5; "Customer Ref"; Text[30])
        {
        }
        field(6; "Vendor No"; Code[20])
        {
            TableRelation = Vendor where("Account Type"=const(Supplier));

            trigger OnValidate()
            begin
                if Vend.Get("Vendor No")then begin
                    "Ben ID":=Vend."No.";
                    "Beneficiary Name":=Vend.Name;
                end;
            end;
        }
        field(7; "Transaction Type"; Code[10])
        {
        }
        field(8; "Bank Code"; Code[10])
        {
            TableRelation = "External Banks";

            trigger OnValidate()
            begin
                if Banks.Get("Bank Code")then begin
                    "Bank Name":=Banks."Bank Name";
                end;
            end;
        }
        field(9; "Bank Name"; Text[80])
        {
            Editable = false;
        }
        field(10; "Branch Code"; Code[10])
        {
            TableRelation = "External Bank Branches"."Branch Code" where("Bank Code"=field("Bank Code"));

            trigger OnValidate()
            begin
                if BankBranches.Get("Bank Code", "Branch Code")then begin
                    "Branch Name":=BankBranches."Branch Name";
                end;
            end;
        }
        field(11; "Branch Name"; Text[80])
        {
            Editable = false;
        }
        field(12; "Branch Address"; Text[80])
        {
            Editable = false;
        }
        field(13; "Bank Account Number"; Code[20])
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Branch Code");
                // if StrLen("Bank Account Number") <> 0 then
                //     Error('Account Number must be 10 digit');
                if Evaluate(TotalPercent, "Bank Account Number") = false then BankDetails.Reset();
                BankDetails.SetRange("Ben ID", "Ben ID");
                BankDetails.SetRange("Bank Account Number", "Bank Account Number");
                if BankDetails.FindFirst()then Error(StrSubstNo(Text000, "Bank Account Number"));
            end;
        }
        field(14; Active; Boolean)
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Bank Account Number");
                if Active = true then begin
                    BankDetails.Reset();
                    BankDetails.SetRange("Vendor No", xRec."Vendor No");
                    BankDetails.SetRange(Active, true);
                    if BankDetails.FindFirst()then begin
                        BankDetails.Active:=false;
                        BankDetails.Modify(true);
                    end;
                end;
            end;
        }
        field(15; Status; Option)
        {
            OptionMembers = Approved, Request;
        }
        field(16; "Bank Telephone No"; Text[20])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Other Bank Details"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; LineNo, "Ben ID", "Vendor No", "Customer No", Status, "Bank Code")
        {
            Clustered = true;
        }
        key(Key2; "Ben ID", LineNo)
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Bank Code", "Bank Name", "Bank Account Number")
        {
        }
        fieldgroup(Brick; "Bank Code", "Bank Name", "Bank Account Number")
        {
        }
    }
    var TotalPercent: Decimal;
    Banks: Record "External Banks";
    BankBranches: Record "External Bank Branches";
    Cust: Record Customer;
    Vend: Record Vendor;
    BankDetails: Record "Payee Bank Details";
    Text000: Label 'Bank Account %1 with %2 Sort Code already exists!';
}

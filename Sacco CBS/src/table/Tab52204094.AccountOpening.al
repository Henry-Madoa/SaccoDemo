table 52204094 "Account Opening"
{
    LookupPageId = "Account Openings";
    DrillDownPageId = "Account Openings";
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; code[20])
        {
            Editable = false;
        }
        field(2; "Member No."; Code[20])
        {
            TableRelation = Members;

            trigger OnValidate()
            begin
                if Member.Get("Member No.") then begin
                    "Member Name" := Member.FullName;
                    Member.CalcFields("Passport Size Photo", Signature);
                    "Passport Size Photo" := Member."Passport Size Photo";
                    "Signature Card" := Member.Signature;
                    "Is Group/Corporate" := Member."Is Group/Corporate";
                end;
            end;
        }
        field(3; "Member Name"; Text[100])
        {
            Editable = false;
        }
        field(4; "Passport Size Photo"; blob)
        {
            Subtype = Bitmap;
        }
        field(5; "Signature Card"; blob)
        {
            Subtype = Bitmap;
        }
        field(6; "Is Group/Corporate"; Boolean)
        {
            Editable = false;
        }
        field(7; "Product Type"; code[20])
        {
            TableRelation = "Sacco Products" where(Indentation = const(1), Blocked = const(false), "Product Posting Type" = filter(<> "Loan Account" & <> "Share Capital Account" & <> "Non Withdrawable Deposit" & <> "Fixed Deposit Account" & <> "Share Trading Account"));

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                SaccoProducts.Get("Product Type");
                "Product Name" := SaccoProducts.Description;
                "Product Posting Type" := SaccoProducts."Product Posting Type";
                "Business Account" := SaccoProducts."Business Account";

                Vendor.Reset();
                Vendor.SetRange("Product Code", "Product Type");
                Vendor.SetFilter("Product Posting Type", '<>%1', Vendor."Product Posting Type"::"Junior Account");
                Vendor.SetRange("Business Account", false);
                Vendor.SetRange("Member No.", "Member No.");
                if Vendor.FindFirst then
                    Error(StrSubstNo('The Member have already %1 Account'), SaccoProducts.Description);
            end;
        }
        field(8; "Product Name"; Text[150])
        {
            Editable = false;
        }
        field(9; "Product Posting Type"; Enum "Product Posting Type")
        {
            Editable = false;
        }
        field(10; "Full Name"; Text[100])
        {
        }
        field(11; "Date of Birth"; Date)
        {
            trigger OnValidate()
            begin
                if "Date of Birth" > WorkDate then
                    Error('Date of Birth cannot be a future date.');
            end;
        }
        field(12; "Birth Certificate No"; Code[20])
        {
        }
        field(13; "Birth Notification No"; Code[100])
        {
        }
        field(14; "Child Image"; Blob)
        {
            Subtype = Bitmap;
        }
        field(15; "Account No."; Code[20])
        {
            Editable = false;
        }
        field(16; "Business Account"; Boolean)
        {
            Editable = false;
        }
        field(17; "Business Location"; Text[100])
        {
        }
        field(18; "Paybill Business Till No."; Code[20])
        {
        }
        field(19; "Business Phone No."; Code[20])
        {
            ExtendedDatatype = PhoneNo;
        }
        field(20; "Created On"; DateTime)
        {
            Editable = false;
        }
        field(21; "Created By"; Code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(22; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(23; Processed; Boolean)
        {
            Editable = false;
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
        SaccoProducts: Record "Sacco Products";
        Member: Record Members;

    trigger OnInsert()
    begin
        SaccoSetup.Get();
        SaccoSetup.TestField("Acc. Opening Nos.");
        if "No." = '' then "No." := NoSeries.GetNextNo(SaccoSetup."Acc. Opening Nos.", Today, true);
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
    end;

    trigger OnDelete()
    begin
        Rec.TestField(Status, Status::Open);
    end;

    procedure OnBeforeSendForApproval()
    begin
        TestField("Member No.");
        TestField("Product Type");
        if "Product Posting Type" = "Product Posting Type"::"Junior Account" then begin
            TestField("Full Name");
            TestField("Date of Birth");
        end;
        if "Business Account" then begin
            TestField("Full Name");
            TestField("Business Location");
        end;
    end;
}

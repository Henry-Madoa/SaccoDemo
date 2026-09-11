tableextension 52203435 "Vendor Ext" extends Vendor
{
    fields
    {
        // Add changes to table fields here
        modify("Vendor Posting Group")
        {
            TableRelation = "Vendor Posting Group" where("Account Type" = field("Account Type"));
        }
        modify(Blocked)
        {
            trigger OnAfterValidate()
            begin
                if Blocked <> Blocked::" " then begin
                    Rec.Testfield("Blocked Reason");
                    Rec."Contract Status" := Rec."Contract Status"::Blocked;
                end
                else begin
                    "Blocked Reason" := '';
                    Rec."Contract Status" := Rec."Contract Status"::Active;
                end;
            end;
        }
        field(52203423; "Account Type"; Enum "Vendor Account Type")
        {
        }
        field(52203424; "Tender No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(52203425; "Vendor Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "",Vendor,"Tender Bidder";
        }
        field(52203426; "Tender Description"; Text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(52203427; "Category of Service"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(52203428; "Sub-Category Code"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Supplier Sub-Category"."Sub-Category Code" WHERE("Category Code" = FIELD("Supplier Category"));

            trigger OnValidate()
            var
                SupplierSubCategory: Record "Supplier Sub-Category";
            begin
                TESTFIELD("Supplier Category");
                IF SupplierSubCategory.GET("Supplier Category", "Sub-Category Code") THEN BEGIN
                    "Sub-Category Description" := SupplierSubCategory."Sub-Category Description";
                END
                ELSE IF "Sub-Category Code" = '' THEN BEGIN
                    "Sub-Category Description" := '';
                END;
            end;
        }
        field(52203429; "Sub-Category Description"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(52203430; "Bank Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(52203431; "Bank Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(52203432; "Bank Branch No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(52203433; "Bank Branch Code"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(52203434; "Bank Branch Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(52203435; "Bank Account No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(52203436; "KRA PIN No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(52203437; "SharePoint Link"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(52203438; "Supplier Category"; Code[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Supplier Category";

            trigger OnValidate()
            begin
                if SupplierCategory.Get("Supplier Category") then begin
                    "Vendor Posting Group" := SupplierCategory."Vendor Posting Group";
                    Validate("Gen. Bus. Posting Group", SupplierCategory."Gen. Bus. Posting Group");
                end;
            end;
        }
        field(52203439; "AGPO Certicicate No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(52203440; "Trade Licence No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(52203441; "VAT Certificate Number"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(52203442; "Certificate Of Incorporation"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Certificate of Incorporation No.';

            trigger OnValidate()
            begin
                VendRec.Reset();
                VendRec.SetRange("Certificate Of Incorporation", "Certificate Of Incorporation");
                if VendRec.FindFirst then Error(StrSubstNo('%1 have already been registered using the same Registration No.', VendRec.Name));
            end;
        }
        field(52203443; "Registration Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(52203444; "Tax ComplCe Cert No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Tax complCe Certificate Number';
        }
        field(52203445; "Tax ComplCe Expiry Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(52203446; "NSSF ComplCe Cert. No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'NSSF ComplCe Certificate No.';
        }
        field(52203447; "SHIF ComplCe Cert. No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'SHIF ComplCe Certificate No.';
        }
        field(52203448; "Certificate of Good Conduct"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(52203449; "Contract Start Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                Validate("Contract Period");
            end;
        }
        field(52203450; "Contract Period"; DateFormula)
        {
            trigger OnValidate()
            begin
                if (("Contract Start Date" <> 0D) and (Format("Contract Period") <> '')) then Validate("Contract End Date", CalcDate(StrSubstNo('%1-1D', "Contract Period"), "Contract Start Date"));
            end;
        }
        field(52203451; "Contract End Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnValidate()
            begin
                if "Contract End Date" < WorkDate then Error('You cannot backdate a contract, The End Date of the Contract should be a future date');
            end;
        }
        field(52203452; "Contract Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ",Active,Inactive,Blocked;
            Editable = false;
        }
        field(52203453; "Blocked Reason"; Text[250])
        {
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = "Blocked Reason".Description;
        }
    }
    trigger OnAfterInsert()
    begin
        if "Pay-to Vendor No." = '' then "Pay-to Vendor No." := Rec."No.";
        Modify(true);
    end;

    var
        VendRec: Record Vendor;
        SupplierCategory: Record "Supplier Category";
}

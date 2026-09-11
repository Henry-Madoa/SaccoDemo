table 52203529 "Prequalified Suppliers"
{
    fields
    {
        field(1; "Ref No."; Code[50])
        {
            DataClassification = ToBeClassified;
        //TableRelation = "Procurement Request";
        }
        field(2; Name; Text[50])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(3; "Physical Address"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Postal Address"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(5; City; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "E-mail"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Telephone No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Mobile No"; Code[15])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Contact Person"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "KBA Bank Code"; Code[5])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Vendor Bank Account".Code;
        }
        field(11; "KBA Branch Code"; Code[3])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Vendor Bank Account"."Bank Branch No." WHERE(Code=FIELD("KBA Bank Code"));
        }
        field(12; "Bank account No"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(13; Category; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Service Category";
        }
        field(14; "Fiscal Year"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(15; Selected; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Pre Qualified"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Fax No"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Category Name"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Registration No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Company PIN No"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Vendor No"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = Vendor where("Account Type"=const(Supplier));
        }
        field(22; "Vendor Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "  ", Medical, Law;
        }
    }
    keys
    {
        key(Key1; "Ref No.")
        {
        }
    }
}

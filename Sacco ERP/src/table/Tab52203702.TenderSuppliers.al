table 52203702 "Tender Suppliers"
{
    Caption = 'Tender Suppliers';

    fields
    {
        field(1; "Reference No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Vendor Name"; Text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(3; Adress; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Post Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(5; City; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Physical Location"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Email Address"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Contact Person Name"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Contact Person Phone No."; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Contact Person E-mail"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Bid Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Security Bid Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Security Bid Receipt No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Technical Score"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Passed Mandatory"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Passed Technical"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(17; Awarded; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Supplier No."; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = IF("Bidder Type"=CONST("Existing Vendor"))Vendor."No." WHERE("Vendor Type"=FILTER(<>"Tender Bidder"), Blocked=FILTER(" "))
            ELSE IF("Bidder Type"=CONST("New Bidder"))Vendor."No." WHERE("Vendor Type"=CONST("Tender Bidder"), "Tender No."=FIELD("Reference No"));

            trigger OnValidate()
            begin
                if Vendor.Get("Supplier No.")then begin
                    "Vendor Name":=Vendor.Name;
                    "Email Address":=Vendor."E-Mail";
                    Adress:=Vendor.Address;
                    "Post Code":=Vendor."Post Code";
                    City:=Vendor.City;
                    "Physical Location":=Vendor."Address 2";
                end;
            // IF "Bidder Type" = "Bidder Type"::"Existing Vendor" THEN BEGIN
            //  MODIFY(TRUE);
            //  END;
            end;
        }
        field(19; "Chose From"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Expressed Interest,Vendor';
            OptionMembers = "Expressed Interest", Vendor;
        }
        field(20; "Financial Score"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Total Score"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Vendor No."; Code[20])
        {
            DataClassification = ToBeClassified;
            //Enabled = false;
            TableRelation = Vendor."No.";
        }
        field(23; "Supplier Application"; Code[50])
        {
            DataClassification = ToBeClassified;
            Enabled = false;
            TableRelation = "Supplier Application" WHERE("Application Type"=CONST("Expression of Interest"));
        }
        field(24; "Bid Bond Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(25; "Bid Bond Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(26; "Bid Bond End Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Bid Bond End Date" < "Bid Bond Start Date" then Error('This Date is not Applicable');
                if "Bid Bond End Date" < Today then "Bond Status":="Bond Status"::Inactive;
                if "Bid Bond End Date" > Today then "Bond Status":="Bond Status"::Active;
                if "Bid Bond End Date" = Today then "Bond Status":="Bond Status"::Active;
            end;
        }
        field(27; "Bond Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Active,Inactive';
            OptionMembers = " ", Active, Inactive;
        }
        field(28; "Response Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(29; "Administrative-Mandatory Score"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Bidder Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Existing Vendor,New Bidder';
            OptionMembers = " ", "Existing Vendor", "New Bidder";
        }
        field(31; "Delivery Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(32; "Delivery Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Reference No", "Vendor Name")
        {
        }
    }
    var Vendor: Record Vendor;
}

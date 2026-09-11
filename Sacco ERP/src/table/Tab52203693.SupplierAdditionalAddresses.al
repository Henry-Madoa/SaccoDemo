table 52203693 "Supplier Additional Addresses"
{
    fields
    {
        field(1; "Supplier No"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Address; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Post Code"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Post Code";

            trigger OnValidate()
            begin
                PostCode.Reset;
                PostCode.SetRange(Code, "Post Code");
                if PostCode.FindFirst then begin
                    City:=PostCode.City;
                    "Country Code":=PostCode."Country/Region Code";
                    Validate("Country Code");
                end
                else
                begin
                    City:='';
                    "Country Code":='';
                    Validate("Country Code");
                end;
            end;
        }
        field(4; City; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Country Code"; Code[50])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if CountryRegion.Get("Country Code")then "Country Name":=CountryRegion.Name
                else
                    "Country Name":='';
            end;
        }
        field(6; "Physical Location"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Telephone No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "E-mail"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Line No."; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
        field(10; "Country Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Supplier No", "Line No.")
        {
        }
    }
    fieldgroups
    {
    }
    var PostCode: Record "Post Code";
    CountryRegion: Record "Country/Region";
}

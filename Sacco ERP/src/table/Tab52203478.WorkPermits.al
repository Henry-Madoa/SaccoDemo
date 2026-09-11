table 52203478 "Work Permits"
{
    fields
    {
        field(1; "Employee No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Permit No"; Code[50])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Permit No" = '' then exit;
                WorkPermits.Reset;
                WorkPermits.SetRange("Permit No", Rec."Permit No");
                if WorkPermits.FindFirst then Error('work permit is already in use');
            end;
        }
        field(3; "Date of Issue"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if("Date of Issue" = 0D) and ("Expiry Date" = 0D)then exit; // IF "Date of Issue">"Expiry Date" THEN
            //  ERROR('Date of issue cannot be higher than expiry date');
            end;
        }
        field(4; "Expiry Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Expiry Date" = 0D then exit;
                Rec.Testfield("Date of Issue");
            //  IF "Date of Issue"<"Expiry Date" THEN
            //   ERROR('Date of issue cannot be higher than expiry date');
            end;
        }
        field(5; "Renewal Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Permit Type"; Text[70])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Work Permit Types";
        }
        field(7; "File Number"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Permit Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Active,Renewed,Expired';
            OptionMembers = Active, Renewed, Expired;
        }
        field(9; "Effective Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Passport Number"; Code[15])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Employee No", "Permit No")
        {
        }
    }
    var WorkPermits: Record "Work Permits";
}

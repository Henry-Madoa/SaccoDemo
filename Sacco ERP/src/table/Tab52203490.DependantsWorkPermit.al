table 52203490 "Dependants Work Permit"
{
    fields
    {
        field(1; "Dependant Name"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Dependant Line No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Line No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Employee No"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Nationality; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Country/Region";
        }
        field(6; "Permit No"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "File No"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Effective Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Expiry Date"; Date)
        {
        // CalcFormula = lookup("Work Permits"."Expiry Date" WHERE ("Employee No"=FIELD("Employee No"),
        //                                                       "Permit Status"=CONST(Active)));
        // FieldClass = FlowField;
        }
        field(10; "Renewal Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(11; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Active,Expired,Renewed';
            OptionMembers = Active, Expired, Renewed;
        }
        field(12; "Date of Issue"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
            // IF ("Date of Issue"=0D) AND ("Expiry Date"=0D) THEN
            //  EXIT;            // IF "Date of Issue">"Expiry Date" THEN
            //  ERROR('Date of issue cannot be higher than expiry date');
            end;
        }
        field(13; "Permit Type"; Text[70])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Work Permit Types";
        }
        field(14; "Passport Number"; Code[15])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Dependant Name", "Dependant Line No", "Line No", "Employee No")
        {
        }
    }
}

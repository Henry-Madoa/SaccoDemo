table 52203638 "Employee Donors"
{
    DrillDownPageID = "Employee Donors";
    LookupPageID = "Employee Donors";

    fields
    {
        field(1; "Employee No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Donor Code"; Code[50])
        {
            Caption = 'Grant Code';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Donors.Get("Donor Code")then "Donor Name":=Donors."Donor Name"
                else
                    "Donor Name":='';
            end;
        }
        field(3; "Donor Name"; Text[100])
        {
            Caption = 'Grant Name';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; Percentage; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Contract Line No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Contract Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Grant Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Grant End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Grant Activity"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Grant Type"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Grant Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Active,Expired,Inactive';
            OptionMembers = " ", Active, Expired, Inactive;
        }
    }
    keys
    {
        key(Key1; "Employee No", "Donor Code", "Contract Line No", "Contract Code")
        {
        }
    }
    var Donors: Record "Employee Donors";
}

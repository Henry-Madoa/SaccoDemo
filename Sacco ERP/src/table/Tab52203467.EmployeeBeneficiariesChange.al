table 52203467 "Employee Beneficiaries Change"
{
    fields
    {
        field(1; "No."; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
        field(2; "Employee No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee;
        }
        field(3; "Full Names"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "ID/Birth Certificate No."; Code[25])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Date of Birth"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Date of Birth" = 0D then begin
                    Age:='';
                    exit;
                end;
                Age:=HRDates.DetermineDatesDiffrence("Date of Birth", Today);
            end;
        }
        field(8; "Phone No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Email Address"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(10; Entitlement; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(11; Relationship; Code[40])
        {
            DataClassification = ToBeClassified;
        }
        field(12; Gender; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Male,Female,Unknown';
            OptionMembers = " ", Male, Female, Unknown;
        }
        field(13; Beneficiary; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(14; Percentage; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(15; Comments; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(16; Age; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(17; Type; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Adult,Minor';
            OptionMembers = Adult, Minor;
        }
        field(70000; "Change No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(70001; "Action"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Retain,Remove,New Addition,Modify Allocation';
            OptionMembers = Retain, Remove, "New Addition", "Modify Allocation";
        }
        field(70002; "New Allocation"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "No.", "Employee No.", "Change No")
        {
        }
    }
    var HRDates: Codeunit "HR Dates";
}

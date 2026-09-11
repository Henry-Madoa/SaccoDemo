table 52203462 "Employee Emergency Contacts"
{
    fields
    {
        field(1; "Line No"; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
        field(2; "Employee No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee;
        //This property is currently not supported
        //TestTableRelation = false;
        }
        field(3; "Full Name"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Relationship; Code[40])
        {
            DataClassification = ToBeClassified;
            TableRelation = Relative;
        }
        field(5; "Phone No."; Code[13])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Phone No." = '' then exit;
                "Phone No.":=UpperCase("Phone No.");
                HasLower:=false;
                HasUpper:=false;
                HasNumeric:=false;
                KeyLen:=StrLen("Phone No.");
                for i:=1 to StrLen("Phone No.")do begin
                    case "Phone No."[i]of 'A' .. 'Z': HasUpper:=true;
                    'a' .. 'z': HasLower:=true;
                    '0' .. '9': HasNumeric:=true;
                    end;
                end;
                if(HasUpper) or (HasLower)then Error('Phone Number must be numeric');
            end;
        }
        field(6; "Email Address"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Alternative Phone No."; Code[13])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Alternative Phone No." = '' then exit;
                "Alternative Phone No.":=UpperCase("Alternative Phone No.");
                HasLower:=false;
                HasUpper:=false;
                HasNumeric:=false;
                KeyLen:=StrLen("Alternative Phone No.");
                for i:=1 to StrLen("Alternative Phone No.")do begin
                    case "Alternative Phone No."[i]of 'A' .. 'Z': HasUpper:=true;
                    'a' .. 'z': HasLower:=true;
                    '0' .. '9': HasNumeric:=true;
                    end;
                end;
                if(HasUpper) or (HasLower)then Error('Phone Number must be numeric');
            end;
        }
    }
    keys
    {
        key(Key1; "Line No", "Employee No.")
        {
        }
    }
    var HasLower: Boolean;
    HasUpper: Boolean;
    HasNumeric: Boolean;
    KeyLen: Integer;
    i: Integer;
}

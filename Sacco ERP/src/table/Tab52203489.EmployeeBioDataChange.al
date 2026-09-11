table 52203489 "Employee Bio Data Change"
{
    fields
    {
        field(1; "Change No."; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                If ChangeRequest.Get("Change No.")then begin
                    Validate("Employee No.", ChangeRequest."Employee No");
                end;
            end;
        }
        field(2; "Employee No."; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Employee.Get("Employee No.")then begin
                    "Phone Number":=Employee."Phone No.";
                    "Personal E-mail":=Employee."E-Mail";
                    "Passport No":=Employee."Passport Number";
                    "Physical Address":=Employee."Physical Address";
                end;
            end;
        }
        field(3; "Phone Number"; Code[13])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Personal E-mail"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Line No."; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
        field(6; "Passport No"; Code[15])
        {
            DataClassification = ToBeClassified;
        }
        field(7; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'New,Current';
            OptionMembers = New, Current;
            Editable = false;
        }
        field(8; "Physical Address"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Change No.", "Line No.")
        {
        }
    }
    var ChangeRequest: Record "Employee Change Request";
    Employee: Record Employee;
}

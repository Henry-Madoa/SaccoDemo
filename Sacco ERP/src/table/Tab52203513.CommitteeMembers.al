table 52203513 "Committee Members"
{
    Caption = 'Commitee Members';

    fields
    {
        field(1; Committee; Code[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(2; "Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
            TableRelation = Employee where(Status=const(Active));

            trigger OnValidate()
            begin
                if Board.Get(Code)then begin
                    SurName:=Board."Last Name";
                    OtherNames:=Board."First Name" + ' ' + Board."Middle Name";
                end;
            end;
        }
        field(3; SurName; Text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(4; OtherNames; Text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Designation; Text[100])
        {
        }
        field(6; Remarks; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Appointment No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; Committee, "Code")
        {
        }
        key(Key2; "Appointment No")
        {
        }
    }
    var Board: Record Employee;
}

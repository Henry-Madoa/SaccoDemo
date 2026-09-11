table 52203460 "Leave Days To Accrue Matrix"
{
    DrillDownPageID = "Leave Days To Accrue Matrix";
    LookupPageID = "Leave Days To Accrue Matrix";

    fields
    {
        field(1; "Leave Type"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Employee Grade Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Employee Payroll Scales".Scale;

            trigger OnValidate()
            begin
                LookupValues.Reset;
                LookupValues.SetRange(Type, LookupValues.Type::Grade);
                LookupValues.SetRange(Code, "Employee Grade Code");
                if LookupValues.FindFirst then "Grade Description":=LookupValues.Description;
            end;
        }
        field(3; "Grade Description"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Days To Accrue"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Leave Day Worth"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Days To Assign"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Leave Type", "Employee Grade Code")
        {
        }
    }
    var LookupValues: Record "Lookup Values";
}

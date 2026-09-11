table 52203704 "Supplier Technical Evaluation"
{
    fields
    {
        field(1; "Reference No"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Requirement Code"; Code[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(3; "Requirement Description"; Text[250])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; "Evaluator ID"; Code[70])
        {
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnValidate()
            begin
                if UserSetup.Get("Evaluator ID")then begin
                    UserSetup.TestField("Employee No.");
                    "Evaluator No.":=UserSetup."Employee No.";
                    if Employee.Get(UserSetup."Employee No.")then begin
                        "Evaluator Name":=Employee."First Name" + ' ' + Employee."Middle Name" + ' ' + Employee."Last Name";
                    end;
                end;
            end;
        }
        field(5; "Evaluator No."; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(6; "Evaluator Name"; Text[250])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(7; "Vendor Name"; Text[200])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(8; Score; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Score > "Max Score" then Error('Score cannot be more than %1', "Max Score");
            end;
        }
        field(9; Comment; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Max Score"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(11; "Vendor No"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Reference No", "Requirement Code", "Evaluator ID", "Vendor Name")
        {
        }
        key(Key2; "Vendor Name")
        {
        }
    }
    var UserSetup: Record "User Setup";
    Employee: Record Employee;
}

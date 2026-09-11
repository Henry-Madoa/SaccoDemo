table 52203703 "Supplier Mandatory Evaluation"
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
        }
        field(3; "Requirement Description"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Evaluator ID"; Code[70])
        {
            DataClassification = ToBeClassified;
            Editable = true;
            TableRelation = "User Setup"."User ID";

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
        }
        field(8; Complied; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(9; Comment; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Vendor No"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Max Score"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(12; Score; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Score > "Max Score" then Error('Score cannot exceed the max weight');
                if Score > "Max Score" / 2 then begin
                    Complied:=true;
                    Modify;
                end
                else
                begin
                    Complied:=false;
                    Modify;
                end;
            end;
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
    var TheAverage: Integer;
    UserSetup: Record "User Setup";
    Employee: Record Employee;
    local procedure CalculateScores(): Decimal var
        AverageScore: Decimal;
    begin
        AverageScore:="Max Score" / 2;
        exit(AverageScore);
    end;
}

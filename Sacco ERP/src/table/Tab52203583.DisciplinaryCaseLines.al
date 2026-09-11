table 52203583 "Disciplinary Case Lines"
{
    fields
    {
        field(1; "Disciplinary No"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Employee No"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No.";

            trigger OnValidate()
            begin
                if Employee.Get("Employee No")then "Employee Name":=Employee.FullName;
            end;
        }
        field(3; "Employee Name"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Offence Code"; Text[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Cases List"."Case Code" WHERE("Case Category"=FIELD("Offence Category"));

            trigger OnValidate()
            begin
                if CasesList.Get("Offence Code")then "Offence Description":=CasesList."Case Desription"
                else
                    "Offence Description":='';
            end;
        }
        field(5; "Offence Category"; Code[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Cases Category"."Category Code";

            trigger OnValidate()
            begin
                if CasesCategory.Get("Offence Category")then "Offence Category Description":=CasesCategory."Category Desription"
                else
                    "Offence Category Description":='';
            end;
        }
        field(6; "Date of offence"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Commitee Decision"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Offence Description"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Offence Category Description"; Text[150])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Grievance Description"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Hr Comments"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Disciplinary No", "Employee No", "Offence Code")
        {
        }
    }
    var CasesList: Record "Cases List";
    CasesCategory: Record "Cases Category";
    Employee: Record Employee;
}

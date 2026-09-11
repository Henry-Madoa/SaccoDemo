table 52203431 "Employee Beneficiaries"
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
        //This property is currently not supported
        //TestTableRelation = false;
        }
        field(3; "Full Names"; Text[150])
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
                if Rec.Type in[Rec.Type::Adult]then begin
                    if CalcDate('18Y', "Date of Birth") > Today then Error('An adult must be 18 years and above');
                end;
            end;
        }
        field(8; "Phone No."; Code[13])
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
            TableRelation = Relative;
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

            trigger OnValidate()
            begin
                EmployeeBeneficiaries.Reset;
                EmployeeBeneficiaries.SetRange("Employee No.", Rec."Employee No.");
                if EmployeeBeneficiaries.FindSet then begin
                    EmployeeBeneficiaries.CalcSums(Percentage);
                    if(EmployeeBeneficiaries.Percentage) > 100 then // +Rec.Percentage)>100 THEN//-xRec.Percentage)>100 THEN
 Error('Total percentage cannot exceed 100');
                end;
            end;
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
        field(7001; "Employment Date"; Date)
        {
            CalcFormula = Lookup(Employee."Employment Date" WHERE("No."=FIELD("Employee No.")));
            FieldClass = FlowField;
        }
        field(7002; Grade; Code[10])
        {
            CalcFormula = Lookup(Employee."Job Scale" WHERE("No."=FIELD("Employee No.")));
            FieldClass = FlowField;
        }
        field(7003; "Employee Gender"; Option)
        {
            CalcFormula = Lookup(Employee.Gender WHERE("No."=FIELD("Employee No.")));
            FieldClass = FlowField;
            OptionCaption = ' ,Female,Male';
            OptionMembers = " ", Female, Male;
        }
    }
    keys
    {
        key(Key1; "No.", "Employee No.")
        {
        }
    }
    var HRDates: Codeunit "HR Dates";
    EmployeeBeneficiaries: Record "Employee Beneficiaries";
}

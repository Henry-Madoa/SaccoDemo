table 52204090 "Cheque Books"
{
    LookupPageId = "Cheque Books";
    DrillDownPageId = "Cheque Books";
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Serial No"; Code[20])
        {
        }
        field(2; "Application No."; Code[20])
        {
            TableRelation = "Cheque Book Applications";
        }
        field(3; "Member No"; Code[20])
        {
        }
        field(4; "Member Name"; Text[100])
        {
        }
        field(5; "Account No"; Code[20])
        {
        }
        field(6; "Account Name"; Text[100])
        {
        }
        field(7; "Applied On"; DateTime)
        {
        }
        field(8; "Collected On"; DateTime)
        {
        }
        field(9; "Drawn"; Integer)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("Cheque Deposits" where("Document Type"=const(Clearance), Processed=const(true)));
        }
        field(10; "No of Leafs"; Integer)
        {
        }
        field(12; Active; Boolean)
        {
        }
    }
    keys
    {
        key(Key1; "Serial No")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Member No", "Serial No", "Account No")
        {
        }
    }
}

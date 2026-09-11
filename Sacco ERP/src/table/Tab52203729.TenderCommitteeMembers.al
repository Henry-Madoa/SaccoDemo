table 52203729 "Tender Committee Members"
{
    fields
    {
        field(1; "Tender No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Employee No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Procurement Committee Members"."Employee No.";

            trigger OnValidate()
            begin
                if ProcurementCommitteeMembers.Get("Employee No.")then begin
                    "Committee UserID":=ProcurementCommitteeMembers."User ID";
                    "Committee Member Name":=ProcurementCommitteeMembers."Employee Name";
                end;
            end;
        }
        field(3; "Committee UserID"; Code[50])
        {
        }
        field(4; "Committee Member Name"; Text[100])
        {
        }
        field(5; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Email Sent"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Tender No.", "Line No.")
        {
        }
    }
    var Employee: Record Employee;
    ProcurementCommitteeMembers: Record "Procurement Committee Members";
}

table 52203727 "RFQ Committee Members"
{
    fields
    {
        field(1; "RFQ No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Employee No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No.";

            trigger OnValidate()
            begin
                /*ProcurementCommitteeMembers.RESET;
                ProcurementCommitteeMembers.SETRANGE("Employee No.","Employee No.");
                IF ProcurementCommitteeMembers.FINDFIRST THEN BEGIN
                  "Committee UserID" := ProcurementCommitteeMembers."User ID";
                  "Committee Member Name" := ProcurementCommitteeMembers."Employee Name";
                  MODIFY(TRUE);
                  END;*/
                UserSetup.Reset;
                UserSetup.SetRange("Employee No.", Rec."Employee No.");
                if UserSetup.FindFirst then "Committee UserID":=UserSetup."User ID";
                if Employee.Get(Rec."Employee No.")then "Committee Member Name":=Employee."First Name" + ' ' + Employee."Middle Name" + ' ' + Employee."Last Name";
            // IF ProcurementCommitteeMembers.GET("Employee No.") THEN BEGIN
            //  "Committee UserID" := ProcurementCommitteeMembers."User ID";
            //  "Committee Member Name" := ProcurementCommitteeMembers."Employee Name";
            //  END;
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
            Editable = false;
        }
        field(7; "Analysis Completed"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(8; "Email Address"; Text[100])
        {
            CalcFormula = Lookup(Employee."Company E-Mail" WHERE("No."=FIELD("Employee No.")));
            Editable = false;
            FieldClass = FlowField;
        }
    }
    keys
    {
        key(Key1; "RFQ No.", "Line No.")
        {
        }
    }
    var Employee: Record Employee;
    ProcurementCommitteeMembers: Record "Procurement Committee Members";
    UserSetup: Record "User Setup";
}

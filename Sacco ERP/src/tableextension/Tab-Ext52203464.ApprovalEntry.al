tableextension 52203464 "Approval Entry" extends "Approval Entry"
{
    fields
    {
        // Add changes to table fields here
        field(70000; "Journal Batch Name"; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(70001; "Approval Number"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(70002; "Sender No"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No.";

            trigger OnValidate()
            begin
                Employee.Get("Sender No");
                "Sender Name" := Employee.FullName;
            end;
        }
        field(70003; "Approver No"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No.";

            trigger OnValidate()
            begin
                Employee.Get("Approver No");
                "Approver Name" := Employee.FullName;
            end;
        }
        field(70004; "Approver Name"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(70005; "Sender Name"; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(70006; "Delegated To"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(70007; "Approved By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(70008; "Delegated By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(70009; "Is Delegated"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(70010; Department; Code[50])
        {
            DataClassification = ToBeClassified;
        }
    }
    var
        Employee: Record Employee;
}

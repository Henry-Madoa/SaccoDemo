table 52204089 "Channel Guarantor Sub."
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Document No"; Code[20])
        {
        }
        field(2; "Guarantor No"; code[20])
        {
        }
        field(3; "Replace With"; Code[20])
        {
            trigger OnValidate()
            var
                Members: Record Members;
            begin
                //send sms
                Members.Reset();
                Members.SetRange("Identification No.", "Replace With");
                Members.SetRange("Guarantee Blocked", false);
                if Members.FindFirst() then
                    "Replace With Name" := Members."Full Name"
                else
                    Error('The Member Doe Not Exist.');
            end;
        }
        field(4; "Replace With Name"; Code[100])
        {
        }
        field(5; "Amount"; Decimal)
        {
        }
        field(6; "Loan Balance"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Loan Security Mgmt Lines"."Loan Balance" where("Security Code" = field("Guarantor No"), "No." = field("Document No")));
            Editable = false;
        }
        field(7; Status; Option)
        {
            OptionMembers = New,Accepted,Rejected;
            OptionCaption = 'New,Accepted,Rejected';
            Editable = false;
        }
        field(8; "Requested On"; DateTime)
        {
        }
        field(9; "Responded On"; DateTime)
        {
        }
        field(10; "Accepted Amount"; Decimal)
        {
        }
        field(11; "Outstanding Guarantee"; Decimal)
        {
        }
    }
    keys
    {
        key(Key1; "Document No", "Guarantor No", "Replace With")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        "Requested On" := CurrentDateTime;
    end;
}

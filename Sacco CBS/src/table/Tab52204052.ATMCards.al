table 52204052 "ATM Cards"
{
    DataClassification = ToBeClassified;

    fields
    {
        Field(1; "Card No."; Code[40])
        {
        }
        Field(2; "ATM Type"; Code[20])
        {
        }
        Field(3; "ATM Type Description"; Text[50])
        {
            Editable = false;
        }
        Field(4; "Expiry Date"; Date)
        {
        }
        Field(5; "Status"; Option)
        {
            OptionMembers = New,Transacting,Blocked,Expired;
            Editable = false;
        }
        Field(6; "Assigned To Member No."; Code[20])
        {
            Editable = false;
            TableRelation = Members;
        }
        Field(7; "Assigned to Account No"; Code[20])
        {
            Editable = false;
            TableRelation = Vendor;
        }
        Field(8; "Account No"; Code[20])
        {
            Editable = false;
            TableRelation = Vendor;
        }
        Field(10; "Added By"; Code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        Field(11; "Added On"; DateTime)
        {
            Editable = false;
        }
        Field(12; "Assigned On"; DateTime)
        {
            Editable = false;
        }
        Field(13; "Assigned By"; Code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        Field(14; "Member Name"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Members."Full Name" where("No." = field("Assigned To Member No.")));
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Card No.", "ATM Type")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        "Added By" := UserId;
        "Added On" := CurrentDateTime;
    end;
}

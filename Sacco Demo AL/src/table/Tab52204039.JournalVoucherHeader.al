table 52204039 "Journal Voucher Header"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(5220400; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5220401; "Posting Description"; Text[50])
        {
        }
        field(5220402; "External Document No."; Code[30])
        {
        }
        field(5220403; "Posting Date"; Date)
        {
        }
        field(5220404; "Global Dimension 1 Code"; code[20])
        {
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(5220405; "Global Dimension 2 Code"; code[20])
        {
            CaptionClass = '1,1,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(5220406; Status; Enum "Document Status")
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5220407; Posted; Boolean)
        {
        }
        Field(9; "Created By"; Code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(5220408; "Created On"; DateTime)
        {
            Editable = false;
        }
        field(5220409; "Total Credit"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Journal Voucher Lines"."Credit Amount" where("Document No." = field("No.")));
        }
        field(5220410; "Total Debit"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Journal Voucher Lines"."Debit Amount" where("Document No." = field("No.")));
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }
    var
        SaccoSetup: Record "General Ledger Setup";
        NoSeries: Codeunit NoSeriesManagement;
        UserSetup: Record "User Setup";
        Employee: Record Employee;

    trigger OnInsert()
    begin
        SaccoSetup.Get();
        SaccoSetup.TestField("JV Nos");
        "No." := NoSeries.GetNextNo(SaccoSetup."JV Nos", Today, true);
        "Posting Date" := WorkDate;
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
        UserSetup.Get(UserId);
        Employee.Get(UserSetup."Employee No.");
        "Global Dimension 1 Code" := Employee."Global Dimension 1 Code";
        "Global Dimension 2 Code" := Employee."Global Dimension 2 Code";
    end;
}

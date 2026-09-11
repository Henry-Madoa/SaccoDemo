table 52203645 "Payroll Allocations"
{
    fields
    {
        field(1; "Transaction Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Payroll Transaction Code".Code;
        }
        field(2; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1));
        }
        field(3; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2));
        }
        field(4; "G/L Account"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No." WHERE("Direct Posting"=CONST(true));
        }
        field(5; "Job Title"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Company Jobs"."Job ID" WHERE(Status=CONST(Approved));
        }
        field(6; "Post to Program Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1));
        }
        field(7; "Post to Department Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2));
        }
        field(8; "Employee No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No.";
        }
    }
    keys
    {
        key(Key1; "Transaction Code", "Global Dimension 1 Code", "Job Title", "Employee No.")
        {
        }
    }
}

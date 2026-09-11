table 52203661 "Career Development Goals"
{
    fields
    {
        field(1; "Line No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Appraisal No."; Code[20])
        {
        }
        field(3; "Employee No."; Code[20])
        {
        }
        field(4; "Career Development Goal"; Text[250])
        {
        }
        field(5; "Estimate Start Date"; Date)
        {
        }
        field(6; "Estimate End Date"; Date)
        {
            trigger OnValidate()
            begin
                if "Estimate End Date" <> 0D then Rec.Testfield("Estimate Start Date");
                Duration:=Format(CreateDateTime("Estimate End Date", 0T) - CreateDateTime("Estimate Start Date", 0T));
            end;
        }
        field(7; Duration; Text[50])
        {
        }
    }
    keys
    {
        key(Key1; "Line No.", "Appraisal No.", "Employee No.")
        {
        }
    }
}

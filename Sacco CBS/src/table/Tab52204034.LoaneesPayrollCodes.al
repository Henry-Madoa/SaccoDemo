table 52204034 "Loanees Payroll Codes"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Loanees Payroll Codes";
    DrillDownPageId = "Loanees Payroll Codes";

    fields
    {
        field(1; Type;Enum "Loanees Payroll Trans Types")
        {
        }
        field(2; Code; Code[20])
        {
            Description = 'Unique Trans line code';
        }
        field(3; Name; Text[100])
        {
            Description = 'Description';
        }
        field(4; "Is Cash"; Boolean)
        {
            Description = 'Does staff receive cash for this transaction';
        }
        field(5; Taxable; Boolean)
        {
            Description = 'Is it taxable or not';
        }
        field(6; "Is Formula"; Boolean)
        {
            Description = 'Is the transaction based on a formula';
        }
        field(7; Formula; Text[200])
        {
            Description = '[Formula] If the above field is "Yes", give the formula';
        }
        field(8; "Transaction Type";Enum "Payroll Transaction Types")
        {
        }
        field(9; "Cleared Effect"; Boolean)
        {
        }
    }
    keys
    {
        key(Key1; Code, Type)
        {
            Clustered = true;
        }
    }
}

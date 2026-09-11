tableextension 52203439 "Employee Ledger Entry" extends "Employee Ledger Entry"
{
    fields
    {
        // Add changes to table fields here
        field(70000; "Document Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(70001; "Due Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
    }
}

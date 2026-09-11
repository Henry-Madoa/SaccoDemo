tableextension 52203438 "Employee Absence" extends "Employee Absence"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Employee Name"; Text[80])
        {
            DataClassification = ToBeClassified;
        }
        field(50001; "Cause of Absence"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(50002; Describe; Text[100])
        {
            DataClassification = ToBeClassified;
        }
    }
}

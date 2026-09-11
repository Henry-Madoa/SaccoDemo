tableextension 52203456 "Bank Acc Statement Line" extends "Bank Account Statement Line"
{
    fields
    {
        // Add changes to table fields here
        field(50000; Reconciled; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50001; "Cheque Number"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }
}

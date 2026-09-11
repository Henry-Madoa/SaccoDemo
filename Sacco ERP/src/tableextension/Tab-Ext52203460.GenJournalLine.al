tableextension 52203460 "Gen. Journal Line" extends "Gen. Journal Line"
{
    fields
    {
        // Add changes to table fields here
        field(8011; "Budget Code"; Code[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Budget Name".Name;
        }
    }
}

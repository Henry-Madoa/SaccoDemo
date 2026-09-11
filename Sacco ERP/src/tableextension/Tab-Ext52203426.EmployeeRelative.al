tableextension 52203426 "Employee Relative" extends "Employee Relative"
{
    fields
    {
        // Add changes to table fields here
        field(70000; "ID/Birth Certificate No."; Code[25])
        {
            DataClassification = ToBeClassified;
        }
        field(70002; "Email Address"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(70003; Entitlement; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(70004; Gender; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Male,Female,Unknown';
            OptionMembers = " ",Male,Female,Unknown;
        }
        field(70005; "Date of Birth"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(70006; Age; Text[40])
        {
            DataClassification = ToBeClassified;
        }
        field(70007; "Next Of Kin/Beneficiary"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Next Of Kin,Beneficiary';
            OptionMembers = "Next Of Kin",Beneficiary;
        }
    }
}

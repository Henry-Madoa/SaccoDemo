tableextension 52203445 "Vendor Bank Account" extends "Vendor Bank Account"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Bank Sort Code"; code[10])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                //Check Bank sort code length
                if (StrLen("Bank Sort Code") < 6) then Error('Bank sort code can not be lesser than six numbers');
                if (StrLen("Bank Sort Code") > 6) then Error('Bank sort code can not be greater than six numbers');
            end;
        }
    }
}

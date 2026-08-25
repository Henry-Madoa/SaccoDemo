pageextension 52204012 "Countries/Regions" extends "Countries/Regions"
{
    layout
    {
        addafter("ISO Numeric Code")
        {
            field("Country Code"; Rec."Country Code")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}

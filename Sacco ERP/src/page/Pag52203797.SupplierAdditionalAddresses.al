page 52203797 "Supplier Additional Addresses"
{
    PageType = List;
    SourceTable = "Supplier Additional Addresses";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Supplier No"; Rec."Supplier No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(City; Rec.City)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Country Code"; Rec."Country Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Physical Location"; Rec."Physical Location")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Telephone No."; Rec."Telephone No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("E-mail"; Rec."E-mail")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

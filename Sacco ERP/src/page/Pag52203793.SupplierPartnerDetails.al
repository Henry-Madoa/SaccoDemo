page 52203793 "Supplier Partner Details"
{
    PageType = List;
    SourceTable = "Supplier Partner Details";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Supplier No"; Rec."Vendor No")
                {
                    Visible = false;
                }
                field("Partner ID No"; Rec."Partner ID No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Partner Name"; Rec."Partner Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Patrner Address"; Rec."Patrner Address")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(City; Rec.City)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Partner Occupation"; Rec."Partner Occupation")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(PIN; Rec.PIN)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Mobile No.(+254)"; Rec."Mobile No.(+254)")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Gender; Rec.Gender)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Shares; Rec.Shares)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Nationality; Rec.Nationality)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Passport No."; Rec."Passport No.")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

page 52203923 "Applicant Offers"
{
    // version THL- HRM 1.0
    PageType = ListPart;
    SourceTable = "Applicant Offers";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Earning Code"; Rec."Earning Code")
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}

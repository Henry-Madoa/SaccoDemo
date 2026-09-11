page 52203710 "Payroll General Setup"
{
    PageType = Card;
    SourceTable = "Payroll Vital Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Tax Relief"; Rec."Tax Relief")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Insurance Relief"; Rec."Insurance Relief %")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

page 52203520 "Suppliers Company Directors"
{
    PageType = ListPart;
    Caption = 'Directors';
    SourceTable = "Suppliers Company Directors";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Title; Rec.Title)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Full Name"; Rec."Full Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Nationality; Rec.Nationality)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Shares; Rec.Shares)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

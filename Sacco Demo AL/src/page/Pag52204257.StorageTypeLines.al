page 52204257 "Storage Type Lines"
{
    PageType = ListPart;
    SourceTable = "Deposit Box Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Length; Rec.Length)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Width; Rec.Width)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Height; Rec.Height)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contents Exist"; Rec."Contents Exist")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Customers; Rec.Customers)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

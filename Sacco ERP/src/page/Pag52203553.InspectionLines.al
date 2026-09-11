page 52203553 "Inspection Lines"
{
    PageType = ListPart;
    SourceTable = "Inspection Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(UoM; Rec.UoM)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Cost"; Rec."Total Cost")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

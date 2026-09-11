page 52203798 "Supplier Item Categories"
{
    PageType = List;
    SourceTable = "Supplier Item Categories";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Supplier No."; Rec."Supplier No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

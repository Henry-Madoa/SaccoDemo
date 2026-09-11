page 52203799 "Item Sub Categories"
{
    PageType = List;
    SourceTable = "Item Sub Categories";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Category Code"; Rec."Category Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("G/l Account"; Rec."G/l Account")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

page 52203792 "Procurement Item Categories"
{
    PageType = List;
    SourceTable = "Item Categories";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Category Code"; Rec."Category Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Sub Categories")
            {
                Image = CoupledOrderList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Item Sub Categories";
                RunPageLink = "Category Code"=FIELD("Category Code");
            }
        }
    }
}

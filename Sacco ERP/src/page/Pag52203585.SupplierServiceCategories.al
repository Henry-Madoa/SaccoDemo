page 52203585 "Supplier Service Categories"
{
    Caption = 'Service Categories';
    AutoSplitKey = true;
    MultipleNewLines = false;
    PageType = ListPart;
    SourceTable = "Supplier Service Categories";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Service Catagory"; Rec."Service Catagory")
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

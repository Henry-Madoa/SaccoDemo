page 52203810 "Requisition Item Categories"
{
    PageType = List;
    SourceTable = "Requisition Services";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Service"; Rec.Service)
                {
                    ApplicationArea = All;
                }
                field("Account No"; Rec."Account No")
                {
                    ApplicationArea = All;
                }
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
    }
}

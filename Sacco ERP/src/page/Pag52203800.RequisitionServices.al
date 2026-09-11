page 52203800 "Requisition Services"
{
    PageType = List;
    SourceTable = "Requisition Services";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Service; Rec.Service)
                {
                }
                field("Account No"; Rec."Account No")
                {
                }
                field("Account Name"; Rec."Account Name")
                {
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                }
            }
        }
    }
    actions
    {
    }
}

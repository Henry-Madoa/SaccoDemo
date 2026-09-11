page 52203566 "Supervisor List"
{
    PageType = List;
    SourceTable = "Grant Approvers";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Emp No"; Rec."Emp No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Level; Rec.Level)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

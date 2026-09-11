page 52203533 "Contract Conditions"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Contract Conditions";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line No"; Rec."Line No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Condition; Rec.Condition)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

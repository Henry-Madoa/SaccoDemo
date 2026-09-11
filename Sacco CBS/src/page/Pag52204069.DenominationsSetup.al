page 52204069 "Denominations Setup"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Denominations Setup";
    SourceTableView = sorting(Value)order(ascending);

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

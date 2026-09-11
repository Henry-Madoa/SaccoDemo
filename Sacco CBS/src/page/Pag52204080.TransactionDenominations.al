page 52204080 "Transaction Denominations"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Transaction Denomination";
    DeleteAllowed = false;
    InsertAllowed = false;
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
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Value"; Rec."Total Value")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

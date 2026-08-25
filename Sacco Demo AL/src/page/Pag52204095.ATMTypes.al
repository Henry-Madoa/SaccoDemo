page 52204095 "ATM Types"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "ATM Types";
    CardPageId = "ATM Type";
    ModifyAllowed = false;
    Editable = false;

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
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("ATM Settlment Account"; Rec."ATM Settlment Account")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

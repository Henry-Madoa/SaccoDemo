page 52203485 "Imprest Surrender Details"
{
    AutoSplitKey = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    MultipleNewLines = false;
    PageType = ListPart;
    SourceTable = "Request Lines";
    SourceTableView = SORTING("No.", "Line No");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Expense Code"; Rec."Expense Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Expense; Rec.Expense)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Narration; Rec.Narration)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Request Amount"; Rec."Request Amount")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Actual Spent"; Rec."Actual Spent")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
            }
        }
    }
}

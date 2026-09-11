page 52203475 "Staff Claim Details"
{
    AutoSplitKey = true;
    Caption = 'Staff Claim Details';
    DeleteAllowed = false;
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
                }
                field(Expense; Rec.Expense)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account No"; Rec."Account No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Narration; Rec.Narration)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Date; Rec.Date)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Claim Quantity"; Rec."Claim Quantity")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Claim Unit Cost"; Rec."Claim Unit Cost")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Actual Spent"; Rec."Actual Spent")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Claim Amount';
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

page 52203478 "Imprest Request Details"
{
    AutoSplitKey = true;
    Caption = 'Imprest Request Details';
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
                field("No."; Rec."No.")
                {
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                }
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
                    Editable = False;
                }
                field("Account No"; Rec."Account No")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = False;
                }
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = False;
                }
                field(Narration; Rec.Narration)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field(UoM; Rec.UoM)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Request Amount"; Rec."Request Amount")
                {
                    ApplicationArea = Basic, Suite;
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

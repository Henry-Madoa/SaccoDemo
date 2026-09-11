page 52204112 "Dividend Det. Lines"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Dividend Det. Entries";
    SourceTableView = SORTING("Member No.", "Month No.") ORDER(Ascending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Month Code"; Rec."Month Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Destination Account"; Rec."Destination Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Year; Rec.Year)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Month No."; Rec."Month No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account Balance"; Rec."Account Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Previous Month"; Rec."Previous Month")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Previous Month Balance"; Rec."Previous Month Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Current Month"; Rec."Current Month")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Current Month Balance"; Rec."Current Month Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Minimum Running Balance"; Rec."Minimum Running Balance")
                {
                    ApplicationArea = Basic, Suite;
                } 
                field("Net Change"; Rec."Net Change")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Ratio; Rec.Ratio)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Rate; Rec.Rate)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

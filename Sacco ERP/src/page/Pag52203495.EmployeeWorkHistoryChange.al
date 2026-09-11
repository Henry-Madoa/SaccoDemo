page 52203495 "Employee Work History Change"
{
    PageType = ListPart;
    SourceTable = "Employee Work History CH";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Work Done"; Rec."Work Done")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Institution/Company"; Rec."Institution/Company")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("From Date"; Rec."From Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("To Date"; Rec."To Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Position Held"; Rec."Position Held")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Key Experience"; Rec."Key Experience")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Salary on Leaving"; Rec."Salary on Leaving")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Reason For Leaving"; Rec."Reason For Leaving")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Comments; Rec.Comments)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Change No"; Rec."Change No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Action"; Rec.Action)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean begin
        Rec.Action:=Rec.Action::"New Addition";
    end;
}

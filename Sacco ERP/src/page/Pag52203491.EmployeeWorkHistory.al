page 52203491 "Employee Work History"
{
    PageType = List;
    SourceTable = "Employee Work History";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Position Held"; Rec."Position Held")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Key Experience"; Rec."Key Experience")
                {
                    ApplicationArea = Basic, Suite;
                }
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
            }
        }
    }
    trigger OnQueryClosePage(CloseAction: Action): Boolean begin
        EmployeeWorkHistory.Reset;
        EmployeeWorkHistory.SetRange("Employee No.", Rec."Employee No.");
        if EmployeeWorkHistory.FindFirst then begin
            repeat EmployeeWorkHistory.TestField("Institution/Company");
                EmployeeWorkHistory.TestField("From Date");
                EmployeeWorkHistory.TestField("To Date");
            until EmployeeWorkHistory.Next = 0;
        end;
    end;
    var EmployeeWorkHistory: Record "Employee Work History";
}

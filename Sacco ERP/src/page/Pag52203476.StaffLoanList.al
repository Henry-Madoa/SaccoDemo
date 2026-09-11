page 52203476 "Staff Loan List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Staff Loans";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Code; Rec.Code)
                {
                }
                field("Loan Name"; Rec."Loan Name")
                {
                    ApplicationArea = All;
                }
                field("Salary Advance"; Rec."Salary Advance")
                {
                    ApplicationArea = All;
                }
                field("Salary in Advance"; Rec."Salary in Advance")
                {
                }
                field(Gratuity; Rec.Gratuity)
                {
                }
            }
        }
        area(Factboxes)
        {
        }
    }
    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin
                end;
            }
        }
    }
}

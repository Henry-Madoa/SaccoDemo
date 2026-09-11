page 52203704 "Employee Donors"
{
    Caption = 'Employee Grants';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Employee Donors";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Grant Code"; Rec."Donor Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Grant Name"; Rec."Donor Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Grant Activity"; Rec."Grant Activity")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Grant Type"; Rec."Grant Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Percentage; Rec.Percentage)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Grant Start Date"; Rec."Grant Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Grant End Date"; Rec."Grant End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Grant Status"; Rec."Grant Status")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contract Line No"; Rec."Contract Line No")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

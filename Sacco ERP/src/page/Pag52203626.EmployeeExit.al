page 52203626 "Employee Exit"
{
    CardPageID = "Employee Exit Card";
    PageType = List;
    SourceTable = "Employee Exit";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Exit No"; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Date of Exit"; Rec."Date of Exit")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interview Conducted By"; Rec."Interview Conducted By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

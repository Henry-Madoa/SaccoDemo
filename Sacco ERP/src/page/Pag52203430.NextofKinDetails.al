page 52203430 "Next of Kin Details"
{
    PageType = List;
    SourceTable = "Employee Relative";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("ID/Birth Certificate No."; Rec."ID/Birth Certificate No.")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

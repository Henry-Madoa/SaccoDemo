page 52203465 "Leave Days To Accrue Matrix"
{
    PageType = List;
    SourceTable = "Leave Days To Accrue Matrix";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Employee Grade Code"; Rec."Employee Grade Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Grade Description"; Rec."Grade Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Days To Assign"; Rec."Days To Assign")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Leave Day Worth"; Rec."Leave Day Worth")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

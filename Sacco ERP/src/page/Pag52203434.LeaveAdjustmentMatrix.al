page 52203434 "Leave Adjustment Matrix"
{
    PageType = ListPart;
    SourceTable = "Leave Adjustment Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'Group';

                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Adjustment Days"; Rec."Adjustment Days")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnDeleteRecord(): Boolean var
        i: Integer;
    begin
    end;
}

page 52203646 "Exit Clearance Setup"
{
    PageType = List;
    SourceTable = "Exit Clearance Setup";
    Extensible = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Section; Rec.Section)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Sequence; Rec.Sequence)
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
                field(Substitute; Rec.Substitute)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

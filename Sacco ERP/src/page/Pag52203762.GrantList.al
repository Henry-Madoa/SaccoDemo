page 52203762 "Grant List"
{
    Caption = 'Grant List';
    PageType = List;
    SourceTable = "Donor List";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Donor Code"; Rec."Donor Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Donor Name"; Rec."Donor Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
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
                field("Grant Start Date"; Rec."Grant Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Grant End Date"; Rec."Grant End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Grant Accountant"; Rec."Grant Accountant")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

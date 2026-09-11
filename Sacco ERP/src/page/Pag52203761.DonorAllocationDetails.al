page 52203761 "Donor Allocation Details"
{
    PageType = List;
    SourceTable = "Donor Allocation Details";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contract Line No"; Rec."Contract Line No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Donor; Rec.Donor)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("End Date of grant"; Rec."End Date of grant")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Donor Name"; Rec."Donor Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Percentage; Rec.Percentage)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Current Donor Details"; Rec."Current Donor Details")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("effective date"; Rec."effective date")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

page 52203759 "Donor Details"
{
    PageType = ListPart;
    SourceTable = "C.Donor Allocation Details";

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
                field("Employee Name"; Rec."Employee Name")
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
                field("Change No"; Rec."Change No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("C. Line No"; Rec."C. Line No")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        DetailsEditable:=false;
        if Rec."Current Donor Details" then DetailsEditable:=false
        else
            DetailsEditable:=true;
    end;
    trigger OnAfterGetRecord()
    begin
        DetailsEditable:=false;
        if Rec."Current Donor Details" then DetailsEditable:=false
        else
            DetailsEditable:=true;
    end;
    var DetailsEditable: Boolean;
}

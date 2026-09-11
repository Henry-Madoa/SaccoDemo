pageextension 52203435 "Employment Contracts" extends "Employment Contracts"
{
    layout
    {
        // Add changes to page layout here
        addafter(Description)
        {
            field("Notice Period"; Rec."Notice Period")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Contract Type"; Rec."Contract Type")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Contract Period"; Rec."Contract Period")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Leave Allowance"; Rec."Leave Allowance")
            {
                ApplicationArea = Basic, Suite;
            }
            field(Gratuity; Rec.Gratuity)
            {
                ApplicationArea = Basic, Suite;
            }
            field(Medical; Rec.Medical)
            {
                ApplicationArea = Basic, Suite;
            }
            field("Probation period"; Rec."Probation period")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}

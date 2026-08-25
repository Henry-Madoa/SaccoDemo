page 52204119 "Checkoff Variation Lines"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Checkoff Variation Lines";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = NoT isWindows;
                }
                field("Product Code"; Rec."Product Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Current Contribution"; Rec."Current Contribution")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("New Contribution"; Rec."New Contribution")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Modified; Rec.Modified)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Account"; Rec."Loan Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Application No."; Rec."Application No.")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        isWindows := GuiAllowed;
    end;

    var
        isWindows: Boolean;
}

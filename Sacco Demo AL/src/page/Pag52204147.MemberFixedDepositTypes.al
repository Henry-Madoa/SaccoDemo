page 52204147 "Member Fixed Deposit Types"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Member Fixed Deposit Types";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Linking Account Type"; Rec."Linking Account Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Calculation Type"; Rec."Interest Calculation Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Provision Account"; Rec."Interest Provision Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Payable Account"; Rec."Interest Payable Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Min. Interest Rate"; Rec."Min. Interest Rate")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Max. Interest Rate"; Rec."Max. Interest Rate")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Charge Code"; Rec."Charge Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Withholding Tax Rate"; Rec."Withholding Tax Rate")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Withholding Tax Account"; Rec."Withholding Tax Account")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

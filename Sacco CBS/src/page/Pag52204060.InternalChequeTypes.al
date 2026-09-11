page 52204060 "Internal Cheque Types"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Cheque Types";
    SourceTableView = where(Type = const("Internal Cheque"));

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
                field("Clearing Account Type"; Rec."Clearing Account Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Clearing Account"; Rec."Clearing Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Clearing Charge Code"; Rec."Clearing Charge")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Bouncing Charge Code"; Rec."Bouncing Charge Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Express Clearing Charge Code"; Rec."Express Clearing Charge Code")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnInit()
    begin
        Rec.Type := Rec.Type::"Internal Cheque";
    end;
}

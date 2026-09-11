page 52203501 "Misc. artical information ch"
{
    PageType = ListPart;
    SourceTable = "Misc. Article Information CH";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Asset Code"; Rec."Asset Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("From Date"; Rec."From Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("To Date"; Rec."To Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Asset Number"; Rec."Asset Number")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Change No"; Rec."Change No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Action"; Rec.Action)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean begin
        Rec.Action:=Rec.Action::"New Addition";
    end;
}

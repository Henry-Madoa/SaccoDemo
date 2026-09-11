page 52203517 "Payroll FMS Data"
{
    PageType = List;
    SourceTable = "Payroll FMS Data";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Document Number"; Rec."Document Number")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account Number"; Rec."Account Number")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Fund code"; Rec."Fund code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Speed Key Code"; Rec."Speed Key Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Activity Code"; Rec."Activity Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Line Item code"; Rec."Line Item code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Location code"; Rec."Location code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(PIBUDHLD; Rec.PIBUDHLD)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payroll Number"; Rec."Payroll Number")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(RESTRICTIONS; Rec.RESTRICTIONS)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(SUBAWARD; Rec.SUBAWARD)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Blank; Rec.Blank)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("External Document Number"; Rec."External Document Number")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Budget Plan Number"; Rec."Budget Plan Number")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Allocation No"; Rec."Allocation No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Balancing Account Type"; Rec."Balancing Account Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Balancing Account Number"; Rec."Balancing Account Number")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Applies To Document Type"; Rec."Applies To Document Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Applies To Document Number"; Rec."Applies To Document Number")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Amount Local currency"; Rec."Amount Local currency")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Currency Factor"; Rec."Currency Factor")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Nature of transaction"; Rec."Nature of transaction")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Sent; Rec.Sent)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Sent On"; Rec."Sent On")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

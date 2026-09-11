page 52203782 "T Bills-Active"
{
    CardPageID = "Treasury Bills Header";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Fixed Deposit Header";
    SourceTableView = WHERE(Status=CONST(Running), "Investment Type"=CONST("Treasury Bills"));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("FD Certificate No."; Rec."FD Certificate No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Investment Institution"; Rec."Investment Institution")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Debit Account Type"; Rec."Debit Account Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Debit Account No."; Rec."Debit Account No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Credit Account Type"; Rec."Credit Account Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Credit Account No"; Rec."Credit Account No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Investment Date"; Rec."Investment Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Investment Period"; Rec."Investment Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Maturity Date"; Rec."Maturity Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Negotiated Intrest"; Rec."Negotiated Intrest")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Last Updated By"; Rec."Last Updated By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("last Updated On"; Rec."last Updated On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Debit Account Name"; Rec."Debit Account Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Credit Account Name"; Rec."Credit Account Name")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

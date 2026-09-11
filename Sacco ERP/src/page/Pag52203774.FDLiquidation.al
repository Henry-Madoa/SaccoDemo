page 52203774 "FD Liquidation"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Fixed Deposit Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = false;

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
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Negotiated Intrest"; Rec."Negotiated Intrest")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group(Receiving)
            {
                field("Receiving Date"; Rec."Receiving Date")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                field("Receiving Account Type"; Rec."Receiving Account Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Receiving Account No"; Rec."Receiving Account No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("External Document No"; Rec."External Document No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Principle Received"; Rec."Principle Received")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Received"; Rec."Interest Received")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Withholding Tax"; Rec."Withholding Tax")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
    // IF "Principle Received" = 0 THEN BEGIN
    //  "Principle Received":=Amount;
    // Rec.Modify;
    // end;
    end;
    trigger OnQueryClosePage(CloseAction: Action): Boolean begin
        if CloseAction in[ACTION::OK, ACTION::LookupOK]then begin
            if not Confirm(StrSubstNo('Are you sure you want to Liquidate FD No. %1', Rec."No."), true)then exit;
            Rec.Testfield("External Document No");
            Rec.Testfield("Receiving Account No");
            Rec.Testfield("Receiving Date");
            Rec.Testfield("Receiving Account Type");
            Rec.Testfield("Principle Received");
            Rec.Testfield("Interest Received");
        //Debit Bank With Principle+Actual Interest
        //Credit *Debit Account* with Principle
        //Credit Interest Receivable Account with Total Interet
        end;
    end;
    var ConfirmManagement: Codeunit "Confirm Management";
}

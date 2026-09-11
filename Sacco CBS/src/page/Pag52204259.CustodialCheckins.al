page 52204259 "Custodial Checkins"
{
    PageType = StandardDialog;
    SourceTable = "Custodial Header";

    layout
    {
        area(content)
        {
            field("Storage Type"; Rec."Storage Type")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
            }
            field("Storage Serial No."; Rec."Storage Serial No.")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
            }
            field("Entry Type"; Rec."Entry Type")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Collected By"; Rec."Collected By")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Expected Return Date"; Rec."Expected Return Date")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Collected By Phone No"; Rec."Collected By Phone No")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Collected By ID  No"; Rec."Collected By ID  No")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction in [ACTION::OK, ACTION::LookupOK] then begin
            CustodialMovement.RESET;
            if CustodialMovement.FINDLAST then
                EntryNo := CustodialMovement."Entry No" + 1
            else
                EntryNo := 1;
            CustodialMovement.INIT;
            CustodialMovement."Entry No" := EntryNo;
            CustodialMovement."Transaction No" := Rec."No.";
            CustodialMovement."Posting Date" := TODAY;
            CustodialMovement."Entry Type" := Rec."Entry Type";
            CustodialMovement.Description := FORMAT(Rec."Entry Type");
            CustodialMovement."Created By" := USERID;
            CustodialMovement."Created On" := CREATEDATETIME(TODAY, TIME);
            CustodialMovement."Collected By" := Rec."Collected By";
            CustodialMovement."Expected Return Date" := Rec."Expected Return Date";
            CustodialMovement."Collected By Phone No" := Rec."Collected By Phone No";
            CustodialMovement."Collected By ID  No" := Rec."Collected By ID  No";
            CustodialMovement.INSERT;
            Rec."Collected By" := '';
            Rec."Collected By ID  No" := '';
            Rec."Collected By Phone No" := '';
            Rec."Expected Return Date" := 0D;
            Rec.MODIFY;
        end;
    end;

    var
        CustodialMovement: Record "Custodial Movement";
        EntryNo: Integer;
}

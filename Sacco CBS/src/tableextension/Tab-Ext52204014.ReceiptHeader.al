tableextension 52204014 "Receipt Header" extends "Receipt Header"
{
    fields
    {
        field(5220400; "Loan Product"; Code[20])
        {
            TableRelation = "Sacco Products" where(Indentation = const(1), Blocked = const(false));
        }
        field(5220401; "Received Amount"; Decimal)
        {
        }
        field(5220402; "Posting Date"; Date)
        {
            trigger OnValidate()
            var
                GeneralLedgerSetup: Record "General Ledger Setup";
            begin
                GeneralLedgerSetup.Get;
                If "Posting Date" < GeneralLedgerSetup."Opening Balance Posting Date" then
                    Error('You cannot Backdate past Go Live Date');
            end;
        }
        field(5220403; "Member No."; Code[20])
        {
            TableRelation = Members where(Status = filter(Active | Dormant | "Not Paid Up"));
            trigger OnValidate()
            var
                Member: Record Members;
            begin
                If Member.Get("Member No.") then "Member Name" := Member.FullName;
            end;
        }
        field(5220404; "Member Name"; Text[80])
        {
            Editable = false;
        }
    }
    procedure OnBeforeSendForApproval()
    begin
        CalcFields(Amount);
        SetRange(Amount, Rec."Received Amount");
    end;

    trigger OnAfterInsert()
    begin
        "Posting Date" := WorkDate;
    end;
}

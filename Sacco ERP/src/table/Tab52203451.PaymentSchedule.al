table 52203451 "Payment Schedule"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "PV No."; Code[20])
        {
            NotBlank = true;
            TableRelation = "Payment Voucher";

            trigger OnValidate()
            begin
                if PVHeader.Get("PV No.")then begin
                    "Payment Type":=PVHeader."Payment Type";
                end;
            end;
        }
        field(2; "PV Line No."; Integer)
        {
            NotBlank = true;

            trigger OnValidate()
            begin
                PVLines.Get("PV No.", "PV Line No.");
                If PVLines."Payment Type" in[PVLines."Payment Type"::"Staff Bulk Payment"]then PVLines.TestField("Account No");
            end;
        }
        field(3; "Line No"; Integer)
        {
            AutoIncrement = true;
        }
        field(4; "Payment Type";Enum "Payment Types")
        {
            Editable = false;
        }
        field(5; "Payroll Period"; Date)
        {
            Editable = false;
            TableRelation = "Accounting Period" where(Closed=const(true));
        }
        field(6; "Petty Cash Account"; Code[20])
        {
            TableRelation = "Bank Account" where("Account Type"=const("Petty Cash"), "Petty Cash Holder"=filter(<>''));

            trigger OnValidate()
            begin
                Banks.Get("Petty Cash Account");
                Validate("Employee No", Banks."Petty Cash Holder");
            end;
        }
        field(7; "Employee No"; Code[20])
        {
            TableRelation = Employee where(Status=filter(Active));

            trigger OnValidate()
            begin
                Employee.Get("Employee No");
                "Employee Name":=Employee.FullName;
            end;
        }
        field(8; "Employee Name"; Text[100])
        {
            Editable = false;
        }
        field(9; Group; Code[20])
        {
            Editable = false;
        }
        field(10; "FOSA Account"; Code[20])
        {
            Editable = false;
        }
        field(12; "Amount"; Decimal)
        {
            trigger OnValidate()
            begin
                if Rec."Payment Type" = Rec."Payment Type"::"Petty Cash Topup" then begin
                    Validate("Line No");
                    Banks.Get("Petty Cash Account");
                    PVLines.Reset;
                    PVLines.SetRange("No.", "PV No.");
                    PVLines.SetRange("Line No", "Line No");
                    if not PVLines.FindFirst()then begin
                        PVLinesInt.Init();
                        PVLinesInt.Validate("No.", "PV No.");
                        PVLinesInt."Line No":="Line No";
                        PVLinesInt.Validate("Account Type", PVLines."Account Type"::"Bank Account");
                        PVLinesInt.Validate("Account No", Rec."Petty Cash Account");
                        PVLinesInt.Validate("Account Name", Banks.Name);
                        PVLinesInt.Amount:=Rec.Amount;
                        PVLinesInt.Validate(Amount);
                        PVLinesInt.Insert(true);
                    end
                    else
                    begin
                        PVLines.Validate("Account No", Rec."Petty Cash Account");
                        PVLines.Validate("Account Name", Banks.Name);
                        PVLines.Amount:=Rec.Amount;
                        PVLines.Validate(Amount);
                        PVLines.Modify(true);
                    end;
                end;
                "Net Allowance Amount":=Amount - "Tax Amount";
            end;
        }
        field(14; "Tax Amount"; Decimal)
        {
            Editable = false;
        }
        field(15; "Net Allowance Amount"; Decimal)
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "PV No.", "PV Line No.", "Employee No")
        {
            Clustered = true;
        }
    }
    trigger OnModify()
    begin
        if PVHeader.Get("PV No.")then begin
            if PVHeader.Status <> PVHeader.Status::Open then Error('You can oly modify/edit a schedule while the status is Open!');
        end;
    end;
    trigger OnDelete()
    begin
        if PVHeader.Get("PV No.")then begin
            if PVHeader.Status <> PVHeader.Status::Open then Error('You can oly delete a schedule while the status is Open!')
            else if PVHeader."Payment Type" = PVHeader."Payment Type"::"Petty Cash Topup" then begin
                    PVLines.Reset;
                    PVLines.SetRange("No.", "PV No.");
                    PVLines.SetRange("Line No", "Line No");
                    if PVLines.FindFirst()then PVLines.Delete(true);
                end;
        end;
    end;
    var PVHeader: Record "Payment Voucher";
    PVLines: Record "Payment Voucher Lines";
    PVLinesInt: Record "Payment Voucher Lines";
    GLAccount: Record "G/L Account";
    Banks: Record "Bank Account";
    Employee: Record Employee;
    VATSetup: Record "VAT Posting Setup";
}

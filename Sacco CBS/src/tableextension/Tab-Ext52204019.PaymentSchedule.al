tableextension 52204019 "Payment Schedule" extends "Payment Schedule"
{
    fields
    {
        field(52204000; "Allowance Code"; Code[20])
        {
            TableRelation = "Allowances Setup".Code where(Group = field(Group));

            trigger OnValidate()
            begin
                if BoardAllowancesSetup.Get(Rec."Allowance Code", Rec.Group) then;
                PVLines.Get("PV No.", "PV Line No.");
                GLAccount.Get(BoardAllowancesSetup."GL Account No.");
                If BoardAllowancesSetup."GL Account No." <> PVLines."Account No" then
                    Error('%1 is mapped to %2 which do not match with the %3 which you intend to Debit in this Voucher', BoardAllowancesSetup.Name, GLAccount.Name, PVLines."Account Name")
                else begin
                    Validate(Amount, BoardAllowancesSetup.Rate);
                    Validate("Tax Code", BoardAllowancesSetup."Tax Code");
                end;
                If "Allowance Code" = 'GRAT' then begin
                    PayrollSalaryCard.Get("Employee No");
                    Rec.Amount := GratuityCalculation.CalculateGratuityAmount("Employee No", Today, PayrollSalaryCard."Basic Pay") //Validate("Tax Code", BoardAllowancesSetup."Tax Code");
                end;
            end;
        }
        field(52204001; "Tax Code"; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = "VAT Product Posting Group" where(Type = const(Allowance));

            trigger OnValidate()
            begin
                if "Tax Code" <> '' then begin
                    BoardAllowancesSetup.Get(Rec."Allowance Code", Rec.Group);
                    VATSetup.Reset;
                    VATSetup.SetRange("VAT Prod. Posting Group", "Tax Code");
                    if not VATSetup.FindFirst then
                        Error('%1 needs a setup in VAT Posting Setup', "Tax Code")
                    else begin
                        VATSetup.TestField("VAT %");
                        VATSetup.TestField("Purchase VAT Account");
                        "Tax Amount" := Round(((Amount - BoardAllowancesSetup."Tax Relief") * (VATSetup."VAT %" / 100)), 0.01, '=');
                        "Net Allowance Amount" := Amount - "Tax Amount";
                    end;
                end;
            end;
        }
    }
    var
        BoardAllowancesSetup: Record "Allowances Setup";
        VATSetup: Record "VAT Posting Setup";
        PVLines: Record "Payment Voucher Lines";
        GLAccount: Record "G/L Account";
        GratuityCalculation: Codeunit "Gratuity Calculation";
        PayrollSalaryCard: Record "Payroll Salary card";
}

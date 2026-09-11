page 52203456 "Payment Voucher Lines"
{
    AutoSplitKey = true;
    MultipleNewLines = false;
    PageType = ListPart;
    Caption = 'Payment Voucher Debit Lines';
    SourceTable = "Payment Voucher Lines";
    SourceTableView = SORTING("No.", "Line No");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Account No"; Rec."Account No")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        SetControlAppearance;
                        CurrPage.Update(true);
                    end;
                }
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Applies to Doc. No"; Rec."Applies to Doc. No")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec."Payment Type" = Rec."Payment Type"::"Supplier Payment";
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Amount To Be Paid';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("VAT Code"; Rec."VAT Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec."Payment Type" = Rec."Payment Type"::"Supplier Payment";

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("WHT Code One"; Rec."WHT Code One")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec."Payment Type" = Rec."Payment Type"::"Supplier Payment";

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("WHT Code Two"; Rec."WHT Code Two")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec."Payment Type" = Rec."Payment Type"::"Supplier Payment";

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("WHT Amount One"; Rec."WHT Amount One")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("WHT Amount Two"; Rec."WHT Amount Two")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Net Amount"; Rec."Net Amount")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Payment Schedule")
            {
                ApplicationArea = Basic, Suite;
                Image = ViewWorksheet;
                Visible = (Rec."Payment Type" = Rec."Payment Type"::"Staff Bulk Payment");
                RunObject = page "Payment Schedule";
                RunPageLink = "PV No."=field("No."), "PV Line No."=field("Line No");
            }
            action("Petty Cash Schedule")
            {
                ApplicationArea = Basic, Suite;
                Image = ViewWorksheet;
                Visible = Rec."Payment Type" = Rec."Payment Type"::"Petty Cash Topup";
                RunObject = page "Petty Cash Reimbursement";
                RunPageLink = "PV No."=field("No."), "PV Line No."=field("Line No");
            }
            action("Copy Schedule")
            {
                ApplicationArea = Basic, Suite;
                Image = ViewWorksheet;
                Visible = Rec."Payment Type" = Rec."Payment Type"::"Staff Bulk Payment";

                trigger OnAction();
                begin
                    Rec.Testfield("Account No");
                    CopySchedule.BoardStaffAllowanceVariableSetting(Rec);
                    CopySchedule.Run();
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        CalculateScheduledAmount;
        SetControlAppearance;
    end;
    trigger OnAfterGetCurrRecord()
    begin
        CalculateScheduledAmount;
    end;
    trigger OnOpenPage()
    begin
        CalculateScheduledAmount;
        SetControlAppearance;
    end;
    local procedure CalculateScheduledAmount()
    begin
        Rec.CalcFields("Scheduled Amount");
        Rec.CalcFields("Net Allowance Amount");
        if Rec."Scheduled Amount" <> 0 then begin
            if Rec."Scheduled Amount" <> Rec.Amount then begin
                Rec.Validate(Amount, Rec."Scheduled Amount");
                Rec.Modify(true);
            end;
        end;
        if Rec."Net Allowance Amount" <> 0 then begin
            if Rec."Net Allowance Amount" <> Rec."Net Amount" then begin
                Rec.Validate("Net Amount", Rec."Net Allowance Amount");
                Rec.Modify(true);
            end;
        end;
        if Rec."Net Allowance Amount" = 0 then begin
            if((Rec."Scheduled Amount" <> 0) and (Rec."Scheduled Amount" <> Rec."Net Amount"))then begin
                Rec.Validate("Net Amount", Rec."Scheduled Amount");
                Rec.Modify(true);
            end;
        end;
    end;
    local procedure SetControlAppearance()
    begin
    end;
    var BeneficiaryBanks: Record "Payee Bank Details";
    PVHeader: Record "Payment Voucher";
    EmpMaster: Record Employee;
    CashMgmt: Codeunit "Cash Management";
    CopySchedule: Report "Copy Payment Schedule";
}

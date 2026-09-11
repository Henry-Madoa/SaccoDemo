report 52203481 "Petty Cash Voucher"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Petty Cash Voucher.rdl';

    dataset
    {
        dataitem(Payments; "Request Header")
        {
            column(Logo; CompInfo.Picture)
            {
            }
            column(Date; Payments.Date)
            {
            }
            column(No; Payments."No.")
            {
            }
            column(Payee; Payments."Employee Name")
            {
            }
            column(AmountInWords; NumberText[1])
            {
            }
            column(Bank; BankName)
            {
            }
            column(ChequeNo; Payments."Payment Tx No.(Cheque No.)")
            {
            }
            column(DaysInTheField; Payments."Total Days in the Field")
            {
            }
            column(FirstApprover; "1stapprover")
            {
            }
            column(SecondApprover; "2ndapprover")
            {
            }
            column(ThirdApprover; "3rdapprover")
            {
            }
            column(FourthApprover; "4thapprover")
            {
            }
            column(FirstApproverDate; "1stapproverdate")
            {
            }
            column(SecondApproverDate; "2ndapproverdate")
            {
            }
            column(ThirdApproverDate; "3rdapproverdate")
            {
            }
            column(FourthApproverDate; "4thapproverdate")
            {
            }
            column(FirstApproverSignature; UserRecApp1."Signature Card")
            {
            }
            column(SecondApproverSignature; UserRecApp2."Signature Card")
            {
            }
            column(ThirdApproverSignature; UserRecApp3."Signature Card")
            {
            }
            column(FourthApproverSignature; UserRecApp4."Signature Card")
            {
            }
            column(DepartureLocation; Payments."Departure Location")
            {
            }
            column(DepartureDate; Payments."Departure Date")
            {
            }
            column(ReturnDate; Payments."Return Date")
            {
            }
            column(Justification; Payments.Justification)
            {
            }
            column(Purpose; Payments.Purpose)
            {
            }
            dataitem("Imprest Details"; "Request Lines")
            {
                DataItemLink = "No."=FIELD("No.");

                column(Description; "Imprest Details".Narration)
                {
                }
                column(GrossAmount; "Imprest Details"."Request Amount")
                {
                }
                column(VAT; "Imprest Details"."Actual Spent")
                {
                }
                column(WHT; "Imprest Details".Claim)
                {
                }
                column(NetAmount; "Imprest Details".Refund)
                {
                }
                column(Project; "Imprest Details"."Global Dimension 2 Code")
                {
                }
                column(Donor; "Imprest Details"."Global Dimension 1 Code")
                {
                }
                column(AccountNo; "Imprest Details"."Account No")
                {
                }
                column(BudgetLine; BudgetLine)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    BudgetLine:='';
                    if DimValues.Get('PROGRAMME', "Imprest Details"."Global Dimension 1 Code")then BudgetLine:=DimValues.Name;
                end;
            }
            trigger OnAfterGetRecord()
            begin
                GLsetup.Get;
                if Payments."Currency Code" <> '' then CurrencyCodeText:=Payments."Currency Code"
                else
                    CurrencyCodeText:=GLsetup."LCY Code";
                Banks.Reset;
                Banks.SetRange(Banks."No.", Payments."Paying Bank Code");
                if Banks.Find('-')then begin
                    BankName:=Banks.Name;
                end
                else
                begin
                    BankName:='';
                end;
                Payments.CalcFields("Request Amount");
                AmountToWords.FormatNoText(NumberText, "Request Amount", CurrencyCodeText);
                //Approvers
                ApprovalEntries.Reset;
                ApprovalEntries.SetRange(ApprovalEntries."Table ID", 51100);
                ApprovalEntries.SetRange(ApprovalEntries."Document No.", Payments."No.");
                ApprovalEntries.SetRange(ApprovalEntries.Status, ApprovalEntries.Status::Approved);
                if ApprovalEntries.Find('-')then begin
                    i:=0;
                    repeat i:=i + 1;
                        if i = 1 then begin
                            Users.Reset;
                            Users.SetRange("User Name", ApprovalEntries."Sender ID");
                            if Users.FindFirst then begin
                                "1stapprover":=Users."Full Name";
                            end;
                            Users.Reset;
                            Users.SetRange("User Name", ApprovalEntries."Approver ID");
                            if Users.FindFirst then begin
                                "2ndapprover":=Users."Full Name";
                                "3rdapprover":=Users."Full Name";
                                "4thapprover":=Users."Full Name";
                            end;
                            "1stapproverdate":=ApprovalEntries."Date-Time Sent for Approval";
                            "2ndapproverdate":=ApprovalEntries."Last Date-Time Modified";
                            "3rdapproverdate":=ApprovalEntries."Last Date-Time Modified";
                            "4thapproverdate":=ApprovalEntries."Last Date-Time Modified";
                            if UserRecApp1.Get(ApprovalEntries."Sender ID")then UserRecApp1.CalcFields(UserRecApp1."Signature Card");
                            if UserRecApp2.Get(ApprovalEntries."Approver ID")then UserRecApp2.CalcFields(UserRecApp2."Signature Card");
                            if UserRecApp3.Get(ApprovalEntries."Approver ID")then UserRecApp3.CalcFields(UserRecApp3."Signature Card");
                            if UserRecApp4.Get(ApprovalEntries."Approver ID")then UserRecApp4.CalcFields(UserRecApp4."Signature Card");
                        end;
                        if i = 2 then begin
                            Users.Reset;
                            Users.SetRange("User Name", ApprovalEntries."Approver ID");
                            if Users.FindFirst then begin
                                "3rdapprover":=Users."Full Name";
                                "4thapprover":=Users."Full Name";
                            end;
                            "3rdapproverdate":=ApprovalEntries."Last Date-Time Modified";
                            "4thapproverdate":=ApprovalEntries."Last Date-Time Modified";
                            if UserRecApp3.Get(ApprovalEntries."Approver ID")then UserRecApp3.CalcFields(UserRecApp3."Signature Card");
                            if UserRecApp4.Get(ApprovalEntries."Approver ID")then UserRecApp4.CalcFields(UserRecApp4."Signature Card");
                        end;
                        if i = 3 then begin
                            Users.Reset;
                            Users.SetRange("User Name", ApprovalEntries."Approver ID");
                            if Users.FindFirst then begin
                                "4thapprover":=Users."Full Name";
                            end;
                            "4thapproverdate":=ApprovalEntries."Last Date-Time Modified";
                            if UserRecApp4.Get(ApprovalEntries."Approver ID")then UserRecApp4.CalcFields(UserRecApp4."Signature Card");
                        end;
                    until ApprovalEntries.Next = 0;
                end;
            end;
        }
    }
    trigger OnPreReport()
    begin
        CompInfo.Get;
        CompInfo.CalcFields(CompInfo.Picture);
    end;
    var CompInfo: Record "Company Information";
    AmountToWords: Codeunit "Amount To Words";
    DimValues: Record "Dimension Value";
    CompName: Text[100];
    BankName: Text[100];
    Banks: Record "Bank Account";
    Bank: Record "Bank Account";
    PayeeBankName: Text[100];
    VendorPG: Record "Vendor Posting Group";
    CustPG: Record "Customer Posting Group";
    FAPG: Record "FA Posting Group";
    BankPG: Record "Bank Account Posting Group";
    PGAccount: Text[50];
    Vend: Record Vendor;
    Cust: Record Customer;
    FA: Record "FA Depreciation Book";
    BankAccountUsed: Text[50];
    BankAccountUsedName: Text[100];
    PGAccountUsedName: Text[50];
    GLAccount: Record "G/L Account";
    SalesSetup: Record "Sales & Receivables Setup";
    OnesText: array[20]of Text[30];
    TensText: array[10]of Text[30];
    ExponentText: array[5]of Text[30];
    GLsetup: Record "General Ledger Setup";
    NumberText: array[2]of Text[80];
    CurrencyCodeText: Code[10];
    ApprovalEntries: Record "Approval Entry";
    "1stapprover": Text[100];
    "2ndapprover": Text[100];
    "3rdapprover": Text[100];
    "4thapprover": Text[100];
    i: Integer;
    "1stapproverdate": DateTime;
    "2ndapproverdate": DateTime;
    "3rdapproverdate": DateTime;
    "4thapproverdate": DateTime;
    UserRec: Record "User Setup";
    UserRecApp1: Record "User Setup";
    UserRecApp2: Record "User Setup";
    UserRecApp3: Record "User Setup";
    UserRecApp4: Record "User Setup";
    x: Integer;
    DimensionRec: Record Dimension;
    DimensionValueRec: Record "Dimension Value";
    AIEHolder: Code[20];
    UserSetup: Record "User Setup";
    Text000: Label 'Preview is not allowed.';
    TXT002: Label '%1, %2 %3';
    Text001: Label 'Last Check No. must be filled in.';
    Text002: Label 'Filters on %1 and %2 are not allowed.';
    Text003: Label 'XXXXXXXXXXXXXXXX';
    Text004: Label 'must be entered.';
    Text005: Label 'The Bank Account and the General Journal Line must have the same currency.';
    Text006: Label 'Salesperson';
    Text007: Label 'Purchaser';
    Text008: Label 'Both Bank Accounts must have the same currency.';
    Text009: Label 'Our Contact';
    Text010: Label 'XXXXXXXXXX';
    Text011: Label 'XXXX';
    Text012: Label 'XX.XXXXXXXXXX.XXXX';
    Text013: Label '%1 already exists.';
    Text014: Label 'Check for %1 %2';
    Text015: Label 'Payment';
    Text016: Label 'In the Check report, One Check per Vendor and Document No.\';
    Text017: Label 'must not be activated when Applies-to ID is specified in the journal lines.';
    Text018: Label 'XXX';
    Text019: Label 'Total';
    Text020: Label 'The total amount of check %1 is %2. The amount must be positive.';
    Text021: Label 'VOID VOID VOID VOID VOID VOID VOID VOID VOID VOID VOID VOID VOID VOID VOID VOID';
    Text022: Label 'NON-NEGOTIABLE';
    Text023: Label 'Test print';
    Text024: Label 'XXXX.XX';
    Text025: Label 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
    Text026: Label 'ZERO';
    Text027: Label 'HUNDRED';
    Text028: Label 'AND';
    Text029: Label '%1 results in a written number that is too long.';
    Text030: Label ' is already applied to %1 %2 for customer %3.';
    Text031: Label ' is already applied to %1 %2 for vendor %3.';
    Text032: Label 'ONE';
    Text033: Label 'TWO';
    Text034: Label 'THREE';
    Text035: Label 'FOUR';
    Text036: Label 'FIVE';
    Text037: Label 'SIX';
    Text038: Label 'SEVEN';
    Text039: Label 'EIGHT';
    Text040: Label 'NINE';
    Text041: Label 'TEN';
    Text042: Label 'ELEVEN';
    Text043: Label 'TWELVE';
    Text044: Label 'THIRTEEN';
    Text045: Label 'FOURTEEN';
    Text046: Label 'FIFTEEN';
    Text047: Label 'SIXTEEN';
    Text048: Label 'SEVENTEEN';
    Text049: Label 'EIGHTEEN';
    Text050: Label 'NINETEEN';
    Text051: Label 'TWENTY';
    Text052: Label 'THIRTY';
    Text053: Label 'FORTY';
    Text054: Label 'FIFTY';
    Text055: Label 'SIXTY';
    Text056: Label 'SEVENTY';
    Text057: Label 'EIGHTY';
    Text058: Label 'NINETY';
    Text059: Label 'THOUSAND';
    Text060: Label 'MILLION';
    Text061: Label 'BILLION';
    Text062: Label 'G/L Account,Customer,Vendor,Bank Account';
    Text063: Label 'Net Amount %1';
    Text064: Label '%1 must not be %2 for %3 %4.';
    Text131: Label 'Please specify which Global Dimension caters for budget\Contact your system admin';
    Text132: Label 'Please specify a dimension that caters for budget';
    Text133: Label 'The AIE Holder %1 doesnt exist ';
    Users: Record User;
    BudgetLine: Text;
}

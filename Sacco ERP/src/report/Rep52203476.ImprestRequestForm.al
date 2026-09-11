report 52203476 "Imprest Request Form"
{
    DefaultLayout = RDLC;
    UsageCategory = ReportsAndAnalysis;
    RDLCLayout = './ssrs/Imprest Request Form.rdl';

    dataset
    {
        dataitem(RequestHeader; "Request Header")
        {
            column(No; RequestHeader."No.")
            {
            }
            column(USER; UserId)
            {
            }
            column(DT; CurrentDateTime)
            {
            }
            column(Created_By; RequestHeader."Created By")
            {
            }
            column(Logo; CompInfo.Picture)
            {
            }
            column(Date; RequestHeader."Surrender Date")
            {
            }
            column(RequestDate; RequestHeader.Date)
            {
            }
            column(BusinessUnit; RequestHeader."Global Dimension 2 Code")
            {
            }
            column(BankCode; RequestHeader."Paying Bank Code")
            {
            }
            column(Bank; BankName)
            {
            }
            column(NetAmount; RequestHeader."Request Amount")
            {
            }
            column(ChequeNo; RequestHeader."Claim Payment Tx No")
            {
            }
            column(Employee_Name; RequestHeader."Employee Name")
            {
            }
            column(Department; Department)
            {
            }
            column(Branch; Branch)
            {
            }
            column(EmployeeNo; RequestHeader."Employee No.")
            {
            }
            column(DueDate; RequestHeader."Due Date")
            {
            }
            column(PaymentDate; RequestHeader."Posted Date")
            {
            }
            column(DaysInTheField; RequestHeader."Total Days in the Field")
            {
            }
            column(AmountInWords; NumberText[1] + ' ' + NumberText[2])
            {
            }
            column(Cashier; RequestHeader."Surrender Posted By")
            {
            }
            column(PrintedDate; CurrentDateTime)
            {
            }
            column(PrintedBy; UserId)
            {
            }
            column(PostedBy; RequestHeader."Surrender Posted By")
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
            column(EmployeeNo_Payments; RequestHeader."Employee No.")
            {
            }
            dataitem("PV Lines1"; "Request Lines")
            {
                DataItemLink = "No."=FIELD("No.");

                column(SN; SN)
                {
                }
                column(AccountNo; "PV Lines1"."Account No")
                {
                }
                column(Narration; "PV Lines1".Narration)
                {
                }
                column(AccountName; "PV Lines1"."Account Name")
                {
                }
                column(WHTCode; "PV Lines1"."Request Amount")
                {
                }
                column(WHTAmount; "PV Lines1"."Actual Spent")
                {
                }
                column(Amount; "PV Lines1"."Request Amount")
                {
                }
                column(Dr; Debit)
                {
                }
                column(Cr; Credit)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    GLsetup.Get;
                    if RequestHeader."Currency Code" <> '' then CurrencyCodeText:=RequestHeader."Currency Code"
                    else
                        CurrencyCodeText:=GLsetup."LCY Code";
                    SN:=SN + 1;
                    Debit:=0;
                    Credit:=0;
                    if "PV Lines1"."Request Amount" > 0 then begin
                        Debit:="PV Lines1"."Request Amount";
                        Credit:=0;
                    end
                    else
                    begin
                        Debit:=0;
                        Credit:=Abs("PV Lines1"."Request Amount");
                    end;
                end;
            }
            trigger OnAfterGetRecord()
            begin
                RequestHeader.CalcFields("Request Amount");
                AmountToWords.FormatNoText(NumberText, "Request Amount", CurrencyCodeText);
                if BankRec.Get(RequestHeader."Paying Bank Code")then BankName:=BankRec.Name;
                SN:=0;
                //Get Dimensions
                if DimValue.Get('DEPARTMENT', RequestHeader."Global Dimension 1 Code")then Department:=DimValue.Name;
                if DimValue.Get('BRANCH', RequestHeader."Global Dimension 2 Code")then Branch:=DimValue.Name; //
                ApprovalEntries.Reset;
                ApprovalEntries.SetRange(ApprovalEntries."Table ID", 51100);
                ApprovalEntries.SetRange(ApprovalEntries."Document No.", RequestHeader."No.");
                ApprovalEntries.SetRange(ApprovalEntries.Status, ApprovalEntries.Status::Approved);
                if ApprovalEntries.Find('-')then begin
                    repeat i:=i + 1;
                        if i = 1 then begin
                            "1stapprover":=ApprovalEntries."Approver ID";
                            "1stapproverdate":=ApprovalEntries."Last Date-Time Modified";
                            if UserRecApp1.Get("1stapprover")then UserRecApp1.CalcFields(UserRecApp1."Signature Card");
                        end;
                        if i = 2 then begin
                            "2ndapprover":=ApprovalEntries."Approver ID";
                            "2ndapproverdate":=ApprovalEntries."Last Date-Time Modified";
                            if UserRecApp2.Get("2ndapprover")then UserRecApp2.CalcFields(UserRecApp2."Signature Card");
                        end;
                        if i = 3 then begin
                            "3rdapprover":=ApprovalEntries."Approver ID";
                            "3rdapproverdate":=ApprovalEntries."Last Date-Time Modified";
                            if UserRecApp3.Get("3rdapprover")then UserRecApp3.CalcFields(UserRecApp3."Signature Card");
                        end;
                        if i = 4 then begin
                            "4thapprover":=ApprovalEntries."Approver ID";
                            "3rdapproverdate":=ApprovalEntries."Last Date-Time Modified";
                            if UserRecApp4.Get("4thapprover")then UserRecApp4.CalcFields(UserRecApp4."Signature Card");
                        end;
                    until ApprovalEntries.Next = 0;
                end;
            //
            end;
        }
    }
    trigger OnPreReport()
    begin
        CompInfo.Get;
        CompInfo.CalcFields(Picture);
    end;
    var CompInfo: Record "Company Information";
    Debit: Decimal;
    Credit: Decimal;
    NumberText: array[2]of Text[250];
    OnesText: array[20]of Text[30];
    TensText: array[10]of Text[30];
    ExponentText: array[5]of Text[30];
    GLsetup: Record "General Ledger Setup";
    CurrencyCodeText: Code[10];
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
    SN: Integer;
    ApprovalEntries: Record "Approval Entry";
    "1stapprover": Code[50];
    "1stapproverdate": DateTime;
    "2ndapprover": Code[50];
    "2ndapproverdate": DateTime;
    "3rdapprover": Code[50];
    "3rdapproverdate": DateTime;
    "4thapprover": Code[50];
    "4thapproverdate": DateTime;
    UserRecApp1: Record "User Setup";
    UserRecApp2: Record "User Setup";
    UserRecApp3: Record "User Setup";
    i: Integer;
    UserRecApp4: Record "User Setup";
    PVLines: Record "Payment Voucher Lines";
    PaymentRequest: Record "Request for Payment";
    Branch: Text;
    Department: Text;
    DimValue: Record "Dimension Value";
    BankRec: Record "Bank Account";
    BankName: Text;
    AmountToWords: Codeunit "Amount To Words";
}

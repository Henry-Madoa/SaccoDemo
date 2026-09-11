report 52203428 "Receipt"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Receipt.rdlc';

    dataset
    {
        dataitem("Bank Account Ledger Entry"; "Bank Account Ledger Entry")
        {
            DataItemTableView = SORTING("Entry No.")WHERE(Amount=FILTER(>0));
            RequestFilterFields = "Entry No.", "Document No.", "Posting Date";

            column(Logo; CompanyInfo.Picture)
            {
            }
            column(CompName; CompanyInfo.Name)
            {
            }
            column(Logo2; CompanyInfo.Picture2)
            {
            }
            column(CompAddress; CompanyInfo.Address)
            {
            }
            column(CompAddress2; CompanyInfo."Address 2")
            {
            }
            column(CompCity; CompanyInfo.City)
            {
            }
            column(CompPhone; CompanyInfo."Phone No.")
            {
            }
            column(CompCountry; CompanyInfo."Country/Region Code")
            {
            }
            column(Address; StrSubstNo(TXT002, CompanyInfo.Address, CompanyInfo."Address 2", CompanyInfo.City))
            {
            }
            column(ReceiptNo; "Bank Account Ledger Entry"."Document No.")
            {
            }
            column(Date; "Bank Account Ledger Entry"."Posting Date")
            {
            }
            column(ChequeNo; "Bank Account Ledger Entry"."External Document No.")
            {
            }
            column(ReceivedFrom; "Bank Account Ledger Entry".Description)
            {
            }
            column(NumberTextOne; NumberText[1])
            {
            }
            column(NumberTextTwo; NumberText[2])
            {
            }
            column(Desc; Desc)
            {
            }
            column(Amount; StrSubstNo('%1  %2', CurrencyCodeText, Amount))
            {
            }
            column(UserName; UserName)
            {
            }
            trigger OnAfterGetRecord()
            begin
                GLsetup.Get;
                if "Currency Code" <> '' then CurrencyCodeText:="Currency Code"
                else
                    CurrencyCodeText:=GLsetup."LCY Code";
                Banks.Reset;
                Banks.SetRange(Banks."No.", "Bank Account Ledger Entry"."Bank Account No.");
                if Banks.Find('-')then begin
                    BankName:=Banks.Name;
                end
                else
                begin
                    BankName:='';
                end;
                InitTextVariable;
                Users.Reset;
                Users.SetCurrentKey("User Name");
                Users.SetRange("User Name", "User ID");
                if Users.FindFirst then UserName:=Users."Full Name"; //Get Description
                GLEntry.SetRange(GLEntry."Transaction No.", "Bank Account Ledger Entry"."Transaction No.");
                GLEntry.SetFilter(GLEntry."Source No.", '<>%1', "Bank Account Ledger Entry"."Bank Account No.");
                if GLEntry.FindFirst then begin
                    repeat Desc:=GLEntry.Description;
                    until GLEntry.Next = 0;
                end;
            end;
        }
    }
    trigger OnPreReport()
    begin
        CompanyInfo.Get;
        CompanyInfo.CalcFields(Picture);
        CompanyInfo.CalcFields(Picture2);
    end;
    var DimValues: Record "Dimension Value";
    CompName: Text[100];
    TypeOfDoc: Text[100];
    BankName: Text[100];
    Banks: Record "Bank Account";
    CompanyInfo: Record "Company Information";
    SalesSetup: Record "Sales & Receivables Setup";
    OnesText: array[20]of Text[30];
    TensText: array[10]of Text[30];
    ExponentText: array[5]of Text[30];
    GLsetup: Record "General Ledger Setup";
    NumberText: array[2]of Text[80];
    CurrencyCodeText: Code[10];
    Users: Record User;
    UserName: Text[130];
    Desc: Text[70];
    GLEntry: Record "G/L Entry";
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
    procedure FormatNoText(var NoText: array[2]of Text[80]; No: Decimal; CurrencyCode: Code[10])
    var
        PrintExponent: Boolean;
        Ones: Integer;
        Tens: Integer;
        Hundreds: Integer;
        Exponent: Integer;
        NoTextIndex: Integer;
    begin
        CLEAR(NoText);
        NoTextIndex:=1;
        NoText[1]:='****';
        IF No < 1 THEN AddToNoText(NoText, NoTextIndex, PrintExponent, Text026)
        ELSE
        BEGIN
            FOR Exponent:=4 DOWNTO 1 DO BEGIN
                PrintExponent:=FALSE;
                Ones:=No DIV POWER(1000, Exponent - 1);
                Hundreds:=Ones DIV 100;
                Tens:=(Ones MOD 100) DIV 10;
                Ones:=Ones MOD 10;
                IF Hundreds > 0 THEN BEGIN
                    AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Hundreds]);
                    AddToNoText(NoText, NoTextIndex, PrintExponent, Text027);
                end;
                IF Tens >= 2 THEN BEGIN
                    AddToNoText(NoText, NoTextIndex, PrintExponent, TensText[Tens]);
                    IF Ones > 0 THEN AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Ones]);
                END
                ELSE IF(Tens * 10 + Ones) > 0 THEN AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Tens * 10 + Ones]);
                IF PrintExponent AND (Exponent > 1)THEN AddToNoText(NoText, NoTextIndex, PrintExponent, ExponentText[Exponent]);
                No:=No - (Hundreds * 100 + Tens * 10 + Ones) * POWER(1000, Exponent - 1);
            end;
        end;
        IF CurrencyCode = 'NGN' THEN BEGIN
            AddToNoText(NoText, NoTextIndex, PrintExponent, ' KSH');
            IF No <> 0 THEN BEGIN
                AddToNoText(NoText, NoTextIndex, PrintExponent, Text028);
                //Translate KOBO to words
                IF(No * 100) > 0 THEN BEGIN
                    No:=No * 100;
                    FOR Exponent:=4 DOWNTO 1 DO BEGIN
                        PrintExponent:=FALSE;
                        Ones:=No DIV POWER(1000, Exponent - 1);
                        Hundreds:=Ones DIV 100;
                        Tens:=(Ones MOD 100) DIV 10;
                        Ones:=Ones MOD 10;
                        IF Hundreds > 0 THEN BEGIN
                            AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Hundreds]);
                            AddToNoText(NoText, NoTextIndex, PrintExponent, Text027);
                        end;
                        IF Tens >= 2 THEN BEGIN
                            AddToNoText(NoText, NoTextIndex, PrintExponent, TensText[Tens]);
                            IF Ones > 0 THEN AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Ones]);
                        END
                        ELSE IF(Tens * 10 + Ones) > 0 THEN AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Tens * 10 + Ones]);
                        IF PrintExponent AND (Exponent > 1)THEN AddToNoText(NoText, NoTextIndex, PrintExponent, ExponentText[Exponent]);
                        No:=No - (Hundreds * 100 + Tens * 10 + Ones) * POWER(1000, Exponent - 1);
                    end;
                end;
                AddToNoText(NoText, NoTextIndex, PrintExponent, ' KOBO');
            end;
            AddToNoText(NoText, NoTextIndex, PrintExponent, ' ONLY****');
        end;
        //End
        IF CurrencyCode <> 'NGN' THEN BEGIN
            AddToNoText(NoText, NoTextIndex, PrintExponent, ' ' + CurrencyCode);
            IF No <> 0 THEN BEGIN
                AddToNoText(NoText, NoTextIndex, PrintExponent, Text028);
                //Translate CENTS to words
                IF(No * 100) > 0 THEN BEGIN
                    No:=No * 100;
                    FOR Exponent:=4 DOWNTO 1 DO BEGIN
                        PrintExponent:=FALSE;
                        Ones:=No DIV POWER(1000, Exponent - 1);
                        Hundreds:=Ones DIV 100;
                        Tens:=(Ones MOD 100) DIV 10;
                        Ones:=Ones MOD 10;
                        IF Hundreds > 0 THEN BEGIN
                            AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Hundreds]);
                            AddToNoText(NoText, NoTextIndex, PrintExponent, Text027);
                        end;
                        IF Tens >= 2 THEN BEGIN
                            AddToNoText(NoText, NoTextIndex, PrintExponent, TensText[Tens]);
                            IF Ones > 0 THEN AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Ones]);
                        END
                        ELSE IF(Tens * 10 + Ones) > 0 THEN AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Tens * 10 + Ones]);
                        IF PrintExponent AND (Exponent > 1)THEN AddToNoText(NoText, NoTextIndex, PrintExponent, ExponentText[Exponent]);
                        No:=No - (Hundreds * 100 + Tens * 10 + Ones) * POWER(1000, Exponent - 1);
                    end;
                end;
                AddToNoText(NoText, NoTextIndex, PrintExponent, ' CENT');
            end;
            AddToNoText(NoText, NoTextIndex, PrintExponent, ' ONLY****');
        end;
    end;
    local procedure AddToNoText(var NoText: array[2]of Text[80]; var NoTextIndex: Integer; var PrintExponent: Boolean; AddText: Text[30])
    begin
        PrintExponent:=true;
        while StrLen(NoText[NoTextIndex] + ' ' + AddText) > MaxStrLen(NoText[1])do begin
            NoTextIndex:=NoTextIndex + 1;
            if NoTextIndex > ArrayLen(NoText)then Error(Text029, AddText);
        end;
        NoText[NoTextIndex]:=DelChr(NoText[NoTextIndex] + ' ' + AddText, '<');
    end;
    procedure InitTextVariable()
    begin
        OnesText[1]:=Text032;
        OnesText[2]:=Text033;
        OnesText[3]:=Text034;
        OnesText[4]:=Text035;
        OnesText[5]:=Text036;
        OnesText[6]:=Text037;
        OnesText[7]:=Text038;
        OnesText[8]:=Text039;
        OnesText[9]:=Text040;
        OnesText[10]:=Text041;
        OnesText[11]:=Text042;
        OnesText[12]:=Text043;
        OnesText[13]:=Text044;
        OnesText[14]:=Text045;
        OnesText[15]:=Text046;
        OnesText[16]:=Text047;
        OnesText[17]:=Text048;
        OnesText[18]:=Text049;
        OnesText[19]:=Text050;
        TensText[1]:='';
        TensText[2]:=Text051;
        TensText[3]:=Text052;
        TensText[4]:=Text053;
        TensText[5]:=Text054;
        TensText[6]:=Text055;
        TensText[7]:=Text056;
        TensText[8]:=Text057;
        TensText[9]:=Text058;
        ExponentText[1]:='';
        ExponentText[2]:=Text059;
        ExponentText[3]:=Text060;
        ExponentText[4]:=Text061;
    end;
}

report 52203429 "Staff Claim Voucher"
{
    DefaultLayout = RDLC;
    UsageCategory = ReportsAndAnalysis;
    RDLCLayout = './ssrs/Staff Claim Voucher.rdl';

    dataset
    {
        dataitem(RequestHeader; "Request Header")
        {
            column(No; RequestHeader."No.")
            {
            }
            column(StaffClaimLabel; StaffClaimLabel)
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
            column(Description; RequestHeader.Description)
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
            column(Address; Address)
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
                column(Request_Amount; "PV Lines1"."Request Amount")
                {
                }
                column(Actual_Spent; "PV Lines1"."Actual Spent")
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
                    SN:=SN + 1;
                    Debit:=0;
                    Credit:=0;
                    if "PV Lines1".Difference > 0 then begin
                        Debit:="PV Lines1".Difference;
                        Credit:=0;
                    end
                    else
                    begin
                        Debit:=0;
                        Credit:=Abs("PV Lines1".Difference);
                    end;
                end;
            }
            trigger OnAfterGetRecord()
            begin
                SN:=0;
                //Claim Header
                StaffClaimLabel:='STAFF CLAIM VOUCHER';
                GLsetup.Get;
                if RequestHeader."Currency Code" <> '' then CurrencyCodeText:=RequestHeader."Currency Code"
                else
                    CurrencyCodeText:=GLsetup."LCY Code";
                if Emp.Get("Employee No.")then RequestHeader.CalcFields("Total Claim");
                AmountToWords.FormatNoText(NumberText, "Total Claim", CurrencyCodeText);
                if BankRec.Get(RequestHeader."Paying Bank Code")then BankName:=BankRec.Name;
                //Get Dimensions
                if DimValue.Get('DEPARTMENT', RequestHeader."Global Dimension 1 Code")then Department:=DimValue.Name;
                if DimValue.Get('BRANCH', RequestHeader."Global Dimension 2 Code")then Branch:=DimValue.Name;
                //
                ApprovalEntries.Reset;
                ApprovalEntries.SetRange(ApprovalEntries."Table ID", Database::"Request Header");
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
    StaffClaimLabel: Text[50];
    Debit: Decimal;
    Credit: Decimal;
    NumberText: array[2]of Text[250];
    OnesText: array[20]of Text[30];
    TensText: array[10]of Text[30];
    ExponentText: array[5]of Text[30];
    GLsetup: Record "General Ledger Setup";
    CurrencyCodeText: Code[10];
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
    Branch: Text;
    Department: Text;
    DimValue: Record "Dimension Value";
    BankRec: Record "Bank Account";
    BankName: Text;
    Address: Text;
    Emp: Record Employee;
    AmountToWords: Codeunit "Amount To Words";
}

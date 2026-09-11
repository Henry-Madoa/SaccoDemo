xmlport 52203427 "Import Bulk Payroll Codes."
{
    Format = VariableText;

    schema
    {
    textelement(Root)
    {
    tableelement("Payroll EDs Upload";
    "Payroll EDs Upload")
    {
    AutoReplace = true;
    AutoUpdate = false;
    XmlName = 'Imports';

    fieldelement(c1;
    "Payroll EDs Upload"."Payroll No.")
    {
    }
    fieldelement(c2;
    "Payroll EDs Upload"."Transaction Code")
    {
    }
    fieldelement(c3;
    "Payroll EDs Upload".Amount)
    {
    }
    fieldelement(c4;
    "Payroll EDs Upload"."Period Code")
    {
    }
    fieldelement(c5;
    "Payroll EDs Upload"."Loan No.")
    {
    MinOccurs = Zero;
    }
    fieldelement(C6;
    "Payroll EDs Upload"."Bosa No.")
    {
    }
    }
    }
    }
    trigger OnInitXmlPort()
    begin
        PayrollEDsUpload.Reset;
        if PayrollEDsUpload.Find then PayrollEDsUpload.DeleteAll;
        Commit;
    end;
    trigger OnPostXmlPort()
    begin
        PayrollEDsUpload.Reset;
        PayrollEDsUpload.SetRange(Appplied, false);
        if PayrollEDsUpload.FindFirst then begin
            repeat PayrollEmployeeTransactions.Init;
                PayrollEmployeeTransactions."Transaction Code":=PayrollEDsUpload."Transaction Code";
                PayrollEmployeeTransactions.Validate("Transaction Code");
                PayrollEmployeeTransactions.Amount:=PayrollEDsUpload.Amount;
                PayrollEmployeeTransactions.Balance:=PayrollEDsUpload."Loan Balance";
                PayrollEmployeeTransactions."Loan Number":=PayrollEDsUpload."Loan No.";
                PayrollEmployeeTransactions."Employee Code":=PayrollEDsUpload."Payroll No.";
                PayrollEmployeeTransactions.Validate("Payroll Period", PayrollEDsUpload."Period Code");
                PeriodMonth:=Date2DMY(PayrollEDsUpload."Period Code", 2);
                PeriodYear:=Date2DMY(PayrollEDsUpload."Period Code", 3);
                PayrollEmployeeTransactions.Membership:=PayrollEDsUpload."Bosa No.";
                if not PayrollEmployeeTransactions.Get(PayrollEDsUpload."Payroll No.", PayrollEDsUpload."Transaction Code", PayrollEDsUpload."Period Code", PeriodMonth, PeriodYear, '')then PayrollEmployeeTransactions.Insert(true)
                else
                begin
                    if PayrollEmployeeTransactions.Get(PayrollEDsUpload."Payroll No.", PayrollEDsUpload."Transaction Code", PayrollEDsUpload."Period Code", PeriodMonth, '')then begin
                        PayrollEmployeeTransactions.Amount:=PayrollEDsUpload.Amount;
                        PayrollEmployeeTransactions.Modify(true);
                    end;
                end;
                PayrollEDsUpload.Appplied:=true;
                PayrollEDsUpload.Modify;
            until PayrollEDsUpload.Next = 0;
        end;
        Message('DONE');
    end;
    var DividendCode: Code[20];
    Vendor: Record Vendor;
    PayrollEDsUpload: Record "Payroll EDs Upload";
    PayrollEmployeeTransactions: Record "Payroll Employee Transaction";
    ObjTransCode: Record "Payroll Transaction Code";
    PayrollEmployeeTransactionsCopy: Record "Payroll Employee Transaction";
    Employee: Record Employee;
    LoanCode: Code[50];
    InterestCode: Code[50];
    PeriodMonth: Integer;
    PeriodYear: Integer;
    procedure SetDivCode(DDCode: Code[50])
    begin
        DividendCode:=DDCode;
    end;
}

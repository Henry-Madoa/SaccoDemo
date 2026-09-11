codeunit 52203443 "Portal Reports"
{
    var Base64Convert: Codeunit "Base64 Convert";
    [Scope('Cloud')]
    procedure GenerateLeaveStatement(EmpNo: Code[20])ReturnValue: Text var
        LeaveLedgerEntries: Record "Leave Ledger Entries";
        RecRef: RecordRef;
        outStreamReport: OutStream;
        inStreamReport: InStream;
        TempBlob: Codeunit "Temp Blob";
    begin
        LeaveLedgerEntries.Reset;
        LeaveLedgerEntries.SetRange("Employee No.", EmpNo);
        If LeaveLedgerEntries.FindSet then RecRef.GetTable(LeaveLedgerEntries);
        TempBlob.CreateOutStream(outStreamReport);
        TempBlob.CreateInStream(inStreamReport);
        Report.SaveAs(Report::"Leave Balances", '', ReportFormat::Pdf, outStreamReport, RecRef);
        ReturnValue:=Base64Convert.ToBase64(inStreamReport);
    end;
    [Scope('Cloud')]
    procedure GenerateP9(EmpNo: Code[20]; SelectedYear: Integer)ReturnValue: Text var
        PayrollEmployeeP9TaxInfo: Record "Payroll Employee P9 Tax Info";
        RecRef: RecordRef;
        outStreamReport: OutStream;
        inStreamReport: InStream;
        TempBlob: Codeunit "Temp Blob";
    begin
        PayrollEmployeeP9TaxInfo.Reset;
        PayrollEmployeeP9TaxInfo.SetRange("Employee Code", EmpNo);
        PayrollEmployeeP9TaxInfo.SetRange("Period Year", SelectedYear);
        if PayrollEmployeeP9TaxInfo.FindSet then begin
            RecRef.GetTable(PayrollEmployeeP9TaxInfo);
            TempBlob.CreateOutStream(outStreamReport);
            TempBlob.CreateInStream(inStreamReport);
            Report.SaveAs(Report::"P9 Report", '', ReportFormat::Pdf, outStreamReport, RecRef);
            ReturnValue:=Base64Convert.ToBase64(inStreamReport);
        end
        else
            Error('No data found');
    end;
    [Scope('Cloud')]
    procedure GeneratePayslip(EmpNo: Code[20]; SelectedPeriod: Date)ReturnValue: Text var
        Emp: Record Employee;
        RecRef: RecordRef;
        outStreamReport: OutStream;
        inStreamReport: InStream;
        TempBlob: Codeunit "Temp Blob";
        Employee: Record Employee;
    begin
        Employee.Reset;
        Employee.SetRange("No.", EmpNo);
        Employee.SetRange("Period Filter", SelectedPeriod);
        if Employee.FindSet then RecRef.GetTable(Employee);
        TempBlob.CreateOutStream(outStreamReport);
        TempBlob.CreateInStream(inStreamReport);
        Report.SaveAs(Report::Payslip, '', ReportFormat::Pdf, outStreamReport, RecRef);
        ReturnValue:=Base64Convert.ToBase64(inStreamReport);
    end;
    [Scope('Cloud')]
    procedure GenerateApraisalReport(AppraisalNo: Code[20])ReturnValue: Text var
        AppraisalHeader: Record "Appraisal Header";
        RecRef: RecordRef;
        outStreamReport: OutStream;
        inStreamReport: InStream;
        TempBlob: Codeunit "Temp Blob";
    begin
        AppraisalHeader.Reset;
        AppraisalHeader.SetRange("No.", AppraisalNo);
        If AppraisalHeader.FindSet then RecRef.GetTable(AppraisalHeader);
        TempBlob.CreateOutStream(outStreamReport);
        TempBlob.CreateInStream(inStreamReport);
        Report.SaveAs(Report::"Appraisal Print Out", '', ReportFormat::Pdf, outStreamReport, RecRef);
        ReturnValue:=Base64Convert.ToBase64(inStreamReport);
    end;
    procedure GetEmployeeImage(var EmpNo: Code[20]; var ResponseCode: Code[20]; var ResponseMessage: BigText)
    var
        Employee: Record Employee;
        Base64Convert: Codeunit "Base64 Convert";
        varInstream: InStream;
        varOutstream: OutStream;
        TempBlob: Codeunit "Temp Blob";
    begin
        CLEAR(responseCode);
        CLEAR(responseMessage);
        IF Employee.GET(EmpNo)THEN BEGIN
            responseCode:='00';
            responseMessage.ADDTEXT('{"Image":"');
            TempBlob.CreateOutStream(varOutstream);
            Employee.Image.ExportStream(varOutstream);
            TempBlob.CreateInStream(varInstream);
            responseMessage.AddText(Base64Convert.ToBase64(varInstream));
            responseMessage.ADDTEXT('"}');
        END
        ELSE
        BEGIN
            responseCode:='01';
            responseMessage.ADDTEXT('{"Response":"The Member Does Not Exist"}');
        END;
    end;
}

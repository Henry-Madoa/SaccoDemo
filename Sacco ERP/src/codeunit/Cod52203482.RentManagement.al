codeunit 52203482 "Rent Management"
{
    trigger OnRun()
    begin
        TenantSalesInvoices;
    end;
    procedure TenantSalesInvoices()
    begin
        Cust.Reset();
        Cust.SetRange("Customer Posting Group", 'TENANT');
        if Cust.FindSet()then repeat begin
                Cust.CalcFields(Rent);
                if Cust.Rent <> 0 then CreateSalesInvoice(Cust);
            end;
            until Cust.Next = 0;
    end;
    local procedure CreateSalesInvoice(Customer: Record Customer)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LineNo: Integer;
    begin
        SalesInvoiceHeader.Reset;
        SalesInvoiceHeader.SetRange("Payment Period", CalcDate('CM', WorkDate));
        SalesInvoiceHeader.SetRange("Bill-to Customer No.", Customer."No.");
        SalesInvoiceHeader.SetRange(Rent, true);
        if not SalesInvoiceHeader.FindFirst then begin
            SalesHeader.Init;
            SalesHeader."Document Type":=SalesHeader."Document Type"::Invoice;
            SalesHeader.Validate("Bill-to Customer No.", Customer."No.");
            SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
            SalesHeader."Payment Period":=CalcDate('CM', WorkDate);
            SalesHeader.Rent:=true;
            SalesHeader.Insert(true);
            CustomerCharges.Reset;
            CustomerCharges.SetRange("Customer No.", Customer."No.");
            CustomerCharges.SetFilter("Amount Excl. Tax", '<>%1', 0);
            if CustomerCharges.FindSet then repeat begin
                    LineNo:=LineNo + 1000;
                    SalesLine.Init;
                    SalesLine."Document Type":=SalesLine."Document Type"::Invoice;
                    SalesLine.Validate("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
                    SalesLine."Line No.":=LineNo;
                    SalesLine.Validate("Bill-to Customer No.", SalesHeader."Bill-to Customer No.");
                    SalesLine.Validate("Document No.", SalesHeader."No.");
                    SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
                    SalesLine.Validate("No.", CustomerCharges."GL Account");
                    SalesLine.Description:=CustomerCharges.Description;
                    SalesLine.Validate(Quantity, 1);
                    SalesLine.Validate("Unit Price", CustomerCharges."Amount Excl. Tax");
                    SalesLine.Validate("VAT Prod. Posting Group", CustomerCharges."VAT Prod. Posting Group");
                    SalesLine.Insert(true);
                end;
                until CustomerCharges.Next = 0;
            SalesHeader.Status:=SalesHeader.Status::Released;
            SalesHeader.Modify(true);
            PostSaleInvoice.Run(SalesHeader);
            SendInvoice(SalesHeader);
        end;
    end;
    procedure SendInvoice(SalesHeader: Record "Sales Header")
    var
        TempBlob: Codeunit "Temp Blob";
        outStreamReport: OutStream;
        inStreamReport: InStream;
        RecRef: RecordRef;
    begin
        Clear(Recipients);
        Subject:='';
        Body:='';
        CompInfo.Get;
        if Cust.Get(SalesHeader."Bill-to Customer No.")then;
        Recipients.Add(Cust."E-Mail");
        Subject:='RENT INVOICE';
        Body+='Hello, ' + Cust.Name;
        Body+='<br><br>';
        Body+=StrSubstNo('This is to bring to your notice that your Rent Invoice for the month of %1 have been processed', Format(WorkDate, 0, '<Month text>-<Year4>'));
        Body+='<br><br>';
        Body+='Please find the attached Invoice';
        Body+='<br><br>';
        Body+='Thank you.';
        Body+='<br><br>';
        Body+='Yours Sincerely,';
        Body+='<br><br>';
        Body+='<b>Finance Department<b>';
        Body+='<br>';
        Body+=CompInfo.Name;
        Mail.Create(Recipients, Subject, Body, true);
        SalesInvoiceHeader.Reset;
        SalesInvoiceHeader.SetRange("Pre-Assigned No.", SalesHeader."No.");
        if SalesInvoiceHeader.FindFirst then RecRef.GetTable(SalesInvoiceHeader);
        //Generate blob from report
        TempBlob.CreateOutStream(outStreamReport);
        TempBlob.CreateInStream(inStreamReport);
        Report.SaveAs(Report::"Standard Sales - Invoice", '', ReportFormat::Pdf, outStreamReport, RecRef);
        Mail.AddAttachment(Format(WorkDate, 0, '<Month text>-<Year4>') + ' Rent Invoice ' + SalesInvoiceHeader."No." + '.pdf', 'PDF', inStreamReport);
        Email.Send(Mail);
    end;
    var Cust: Record Customer;
    CustomerCharges: Record "Customer Charges";
    PostSaleInvoice: Codeunit "Sales-Post";
    Recipients: List of[Text];
    Subject: Text;
    Body: Text;
    CompInfo: Record "Company Information";
    SalesInvoiceHeader: Record "Sales Invoice Header";
    Mail: Codeunit "Email Message";
    Email: Codeunit Email;
}

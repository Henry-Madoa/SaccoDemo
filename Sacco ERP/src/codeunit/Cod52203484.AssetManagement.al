codeunit 52203484 "Asset Management"
{
    trigger OnRun()
    begin
    end;
    [Scope('Personalization')]
    procedure CreateTenant(var TenantBooking: Record "Tenant Booking"; BookingCode: Code[20]): Code[20]var
        Customer: Record Customer;
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        AssetManagementSetup: Record "Asset Management Setup";
        CustomerNo: Code[20];
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        TenantBooking.Reset;
        TenantBooking.SetRange("No.", BookingCode);
        if TenantBooking.FindFirst then begin
            SalesReceivablesSetup.Get;
            SalesReceivablesSetup.TestField("Customer Nos.");
            AssetManagementSetup.Get;
            AssetManagementSetup.TestField("Customer Posting Group");
            AssetManagementSetup.TestField("Gen. Bus. Posting Group");
            AssetManagementSetup.TestField("VAT Bus. Posting Group");
            Customer.Init;
            CustomerNo:=NoSeriesManagement.GetNextNo(SalesReceivablesSetup."Customer Nos.", Today, true);
            Customer."No.":=CustomerNo;
            Customer.Validate("No.");
            Customer.Name:=TenantBooking.Name;
            Customer.Validate(Name);
            Customer.Address:=TenantBooking.Address;
            Customer."Phone No.":=TenantBooking."Phone No.";
            Customer."E-Mail":=TenantBooking."E-Mail";
            Customer."Tenant Booking No.":=BookingCode;
            Customer."Customer Posting Group":=AssetManagementSetup."Customer Posting Group";
            Customer.Validate("Customer Posting Group");
            Customer."VAT Bus. Posting Group":=AssetManagementSetup."VAT Bus. Posting Group";
            Customer.Validate("VAT Bus. Posting Group");
            Customer."Gen. Bus. Posting Group":=AssetManagementSetup."Gen. Bus. Posting Group";
            Customer.Validate("Gen. Bus. Posting Group");
            Customer.Insert;
        end;
        exit(CustomerNo);
    end;
    [Scope('Personalization')]
    procedure GenerateDepositBillingSchedule(BillScheduleNo: Code[20]; BillScheduleDate: Date)
    var
        TenantBooking: Record "Tenant Booking";
        TenantBillSchedule: Record "Tenant Bill Schedule";
        TenantBillScheduleLines: Record "Tenant Bill Schedule Lines";
        AssetManagementSetup: Record "Asset Management Setup";
    begin
        AssetManagementSetup.Get;
        TenantBooking.Reset;
        TenantBooking.SetRange("Tenancy Status", TenantBooking."Tenancy Status"::Booked);
        if TenantBooking.FindSet then begin
            repeat TenantBillSchedule.Init;
                TenantBillSchedule."Schedule No.":=BillScheduleNo;
                TenantBillSchedule."Schedule Date":=BillScheduleDate;
                TenantBillSchedule."Tenant No.":=TenantBooking."Customer No.";
                TenantBillSchedule.Validate("Tenant No.");
                TenantBillSchedule."Property Code":=TenantBooking."Property Booked";
                TenantBillSchedule.Validate("Property Code");
                if TenantBillSchedule.Insert then begin
                    //Deposit
                    TenantBillScheduleLines.Init;
                    TenantBillScheduleLines."Schedule No.":=BillScheduleNo;
                    TenantBillScheduleLines."Schedule Date":=BillScheduleDate;
                    TenantBillScheduleLines."Tenant No.":=TenantBooking."Customer No.";
                    TenantBillScheduleLines."Cost Type":=TenantBillScheduleLines."Cost Type"::Deposit;
                    TenantBillScheduleLines."No.":=AssetManagementSetup."Deposit G/L Account";
                    TenantBillScheduleLines.Description:='Deposit Amount';
                    TenantBooking.Validate("Unit No.");
                    TenantBillScheduleLines.Amount:=TenantBooking."Deposit Amount";
                    TenantBillScheduleLines.Insert;
                    //Deposit
                    //Rent
                    TenantBillScheduleLines.Init;
                    TenantBillScheduleLines."Schedule No.":=BillScheduleNo;
                    TenantBillScheduleLines."Schedule Date":=BillScheduleDate;
                    TenantBillScheduleLines."Tenant No.":=TenantBooking."Customer No.";
                    TenantBillScheduleLines."Cost Type":=TenantBillScheduleLines."Cost Type"::Deposit;
                    TenantBillScheduleLines."No.":=AssetManagementSetup."Rent G/L Account";
                    TenantBillScheduleLines.Description:='Rent Amount';
                    TenantBooking.Validate("Unit No.");
                    TenantBillScheduleLines.Amount:=TenantBooking."Rent Amount";
                    TenantBillScheduleLines.Insert;
                    //Rent
                    //Water Deposit
                    if TenantBooking."Water Deposit" <> 0 then begin
                        TenantBillScheduleLines.Init;
                        TenantBillScheduleLines."Schedule No.":=BillScheduleNo;
                        TenantBillScheduleLines."Schedule Date":=BillScheduleDate;
                        TenantBillScheduleLines."Tenant No.":=TenantBooking."Customer No.";
                        TenantBillScheduleLines."Cost Type":=TenantBillScheduleLines."Cost Type"::Deposit;
                        TenantBillScheduleLines."No.":=AssetManagementSetup."Water G/L Account";
                        TenantBillScheduleLines.Description:='Water Deposit';
                        TenantBooking.Validate("Unit No.");
                        TenantBillScheduleLines.Amount:=TenantBooking."Water Deposit";
                        TenantBillScheduleLines.Insert;
                    end;
                    //Water Deposit
                    //Electricity Deposit
                    if TenantBooking."Electricity Deposit" <> 0 then begin
                        TenantBillScheduleLines.Init;
                        TenantBillScheduleLines."Schedule No.":=BillScheduleNo;
                        TenantBillScheduleLines."Schedule Date":=BillScheduleDate;
                        TenantBillScheduleLines."Tenant No.":=TenantBooking."Customer No.";
                        TenantBillScheduleLines."Cost Type":=TenantBillScheduleLines."Cost Type"::Deposit;
                        TenantBillScheduleLines."No.":=AssetManagementSetup."Electricity G/L Account";
                        TenantBillScheduleLines.Description:='Electricity Deposit';
                        TenantBooking.Validate("Unit No.");
                        TenantBillScheduleLines.Amount:=TenantBooking."Electricity Deposit";
                        TenantBillScheduleLines.Insert;
                    end;
                    //Electricity Deposit
                    //Other Billing
                    if TenantBooking."Other Deposits" <> 0 then begin
                        TenantBillScheduleLines.Init;
                        TenantBillScheduleLines."Schedule No.":=BillScheduleNo;
                        TenantBillScheduleLines."Schedule Date":=BillScheduleDate;
                        TenantBillScheduleLines."Tenant No.":=TenantBooking."Customer No.";
                        TenantBillScheduleLines."Cost Type":=TenantBillScheduleLines."Cost Type"::Deposit;
                        TenantBillScheduleLines."No.":=AssetManagementSetup."Other Amenities G/L A/C";
                        TenantBillScheduleLines.Description:='Other Amenities Deposit';
                        TenantBooking.Validate("Unit No.");
                        TenantBillScheduleLines.Amount:=TenantBooking."Other Deposits";
                        TenantBillScheduleLines.Insert;
                    end;
                //Other Billing
                end;
                TenantBooking."Tenancy Status":=TenantBooking."Tenancy Status"::Active;
                TenantBooking.Modify(true);
            until TenantBooking.Next = 0;
        end;
    end;
    [Scope('Personalization')]
    procedure GenerateMonthlyBillingSchedule(BillScheduleNo: Code[20]; BillScheduleDate: Date)
    var
        TenantBooking: Record "Tenant Booking";
        TenantBillSchedule: Record "Tenant Bill Schedule";
        TenantBillScheduleLines: Record "Tenant Bill Schedule Lines";
        AssetManagementSetup: Record "Asset Management Setup";
    begin
        AssetManagementSetup.Get;
        TenantBooking.Reset;
        TenantBooking.SetRange("Tenancy Status", TenantBooking."Tenancy Status"::Active);
        if TenantBooking.FindSet then begin
            repeat TenantBooking.CalcFields("Bill Water", "Bill Electricity", "Bill Other Amenities");
                TenantBillSchedule.Init;
                TenantBillSchedule."Schedule No.":=BillScheduleNo;
                TenantBillSchedule."Schedule Date":=BillScheduleDate;
                TenantBillSchedule."Tenant No.":=TenantBooking."Customer No.";
                TenantBillSchedule.Validate("Tenant No.");
                TenantBillSchedule."Property Code":=TenantBooking."Property Booked";
                TenantBillSchedule.Validate("Property Code");
                if TenantBillSchedule.Insert then begin
                    //Rent
                    TenantBillScheduleLines.Init;
                    TenantBillScheduleLines."Schedule No.":=BillScheduleNo;
                    TenantBillScheduleLines."Schedule Date":=BillScheduleDate;
                    TenantBillScheduleLines."Tenant No.":=TenantBooking."Customer No.";
                    TenantBillScheduleLines."Cost Type":=TenantBillScheduleLines."Cost Type"::Deposit;
                    TenantBillScheduleLines."No.":=AssetManagementSetup."Rent G/L Account";
                    TenantBillScheduleLines.Description:='Rent Amount';
                    TenantBooking.Validate("Unit No.");
                    TenantBillScheduleLines.Amount:=TenantBooking."Rent Amount";
                    TenantBillScheduleLines.Insert;
                    //Rent
                    //Water Bill
                    if TenantBooking."Bill Water" = true then begin
                        TenantBillScheduleLines.Init;
                        TenantBillScheduleLines."Schedule No.":=BillScheduleNo;
                        TenantBillScheduleLines."Schedule Date":=BillScheduleDate;
                        TenantBillScheduleLines."Tenant No.":=TenantBooking."Customer No.";
                        TenantBillScheduleLines."Cost Type":=TenantBillScheduleLines."Cost Type"::Deposit;
                        TenantBillScheduleLines."No.":=AssetManagementSetup."Water G/L Account";
                        TenantBillScheduleLines.Description:='Water Bill';
                        TenantBooking.Validate("Unit No.");
                        TenantBillScheduleLines.Amount:=0;
                        TenantBillScheduleLines.Insert;
                    end;
                    //Water Bill
                    //Electricity Bill
                    if TenantBooking."Bill Electricity" = true then begin
                        TenantBillScheduleLines.Init;
                        TenantBillScheduleLines."Schedule No.":=BillScheduleNo;
                        TenantBillScheduleLines."Schedule Date":=BillScheduleDate;
                        TenantBillScheduleLines."Tenant No.":=TenantBooking."Customer No.";
                        TenantBillScheduleLines."Cost Type":=TenantBillScheduleLines."Cost Type"::Deposit;
                        TenantBillScheduleLines."No.":=AssetManagementSetup."Electricity G/L Account";
                        TenantBillScheduleLines.Description:='Electricity Bill';
                        TenantBooking.Validate("Unit No.");
                        TenantBillScheduleLines.Amount:=0;
                        TenantBillScheduleLines.Insert;
                    end;
                    //Electricity Bill
                    //Other Billing
                    if TenantBooking."Bill Other Amenities" = true then begin
                        TenantBillScheduleLines.Init;
                        TenantBillScheduleLines."Schedule No.":=BillScheduleNo;
                        TenantBillScheduleLines."Schedule Date":=BillScheduleDate;
                        TenantBillScheduleLines."Tenant No.":=TenantBooking."Customer No.";
                        TenantBillScheduleLines."Cost Type":=TenantBillScheduleLines."Cost Type"::Deposit;
                        TenantBillScheduleLines."No.":=AssetManagementSetup."Other Amenities G/L A/C";
                        TenantBillScheduleLines.Description:='Other Amenities Bill';
                        TenantBooking.Validate("Unit No.");
                        TenantBillScheduleLines.Amount:=0;
                        TenantBillScheduleLines.Insert;
                    end;
                //Other Billing
                end;
            until TenantBooking.Next = 0;
        end;
    end;
    [Scope('Personalization')]
    procedure GenerateSalesInvoices(BillScheduleNo: Code[20]; BillScheduleDate: Date; CustomerNo: Code[20])
    var
        TenantBillSchedule: Record "Tenant Bill Schedule";
        TenantBillScheduleLines: Record "Tenant Bill Schedule Lines";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        InvoiceNo: Code[20];
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        LineNo: Integer;
    begin
        TenantBillSchedule.Reset;
        TenantBillSchedule.CalcFields("Schedule Status");
        TenantBillSchedule.SetRange("Schedule No.", BillScheduleNo);
        TenantBillSchedule.SetRange("Schedule Date", BillScheduleDate);
        TenantBillSchedule.SetRange("Tenant No.", CustomerNo);
        TenantBillSchedule.SetRange("Schedule Status", TenantBillSchedule."Schedule Status"::Generated);
        if TenantBillSchedule.FindFirst then begin
            SalesReceivablesSetup.Get;
            SalesReceivablesSetup.TestField("Invoice Nos.");
            SalesHeader.Init;
            InvoiceNo:=NoSeriesManagement.GetNextNo(SalesReceivablesSetup."Invoice Nos.", Today, true);
            SalesHeader."No.":=InvoiceNo;
            SalesHeader.Validate("No.");
            SalesHeader."Document Type":=SalesHeader."Document Type"::Invoice;
            SalesHeader."Sell-to Customer No.":=TenantBillSchedule."Tenant No.";
            SalesHeader.Validate("Sell-to Customer No.");
            SalesHeader."Document Date":=BillScheduleDate;
            SalesHeader.Validate("Document Date");
            if SalesHeader.Insert then begin
                TenantBillScheduleLines.Reset;
                TenantBillScheduleLines.SetRange("Schedule No.", BillScheduleNo);
                TenantBillScheduleLines.SetRange("Schedule Date", BillScheduleDate);
                TenantBillScheduleLines.SetRange("Tenant No.", CustomerNo);
                TenantBillScheduleLines.SetFilter(Amount, '<>%1', 0);
                if TenantBillScheduleLines.FindFirst then begin
                    repeat SalesLine.Init;
                        SalesLine."Document No.":=InvoiceNo;
                        SalesLine."Document Type":=SalesLine."Document Type"::Invoice;
                        SalesLine.Type:=SalesLine.Type::"G/L Account";
                        SalesLine."No.":=TenantBillScheduleLines."No.";
                        SalesLine.Validate("No.");
                        SalesLine.Quantity:=1;
                        SalesLine.Validate(Quantity);
                        SalesLine."Unit Price":=TenantBillScheduleLines.Amount;
                        SalesLine.Validate("Unit Price");
                        SalesLine."Qty. to Ship":=SalesLine.Quantity;
                        SalesLine."Qty. to Invoice":=SalesLine.Quantity;
                        SalesLine.Insert;
                    until TenantBillScheduleLines.Next = 0;
                end;
            end;
        end;
    end;
}

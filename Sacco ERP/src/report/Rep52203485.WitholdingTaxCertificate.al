report 52203485 "Witholding Tax Certificate"
{
    DefaultLayout = RDLC;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    RDLCLayout = './ssrs/Witholding Tax Certificate.rdlc';

    dataset
    {
        dataitem(Payments; "Payment Voucher")
        {
            DataItemTableView = SORTING("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";

            column(Payments_No; "No.")
            {
            }
            dataitem("PV Lines"; "Payment Voucher Lines")
            {
                DataItemLink = "No."=FIELD("No.");
                DataItemTableView = SORTING("No.", "Line No");
                RequestFilterFields = "Account Type", "Account No";

                column(Company_Information__Name; "Company Information".Name)
                {
                }
                column(PV_Lines1__PV_Lines1___Account_Name_; "PV Lines"."Account Name")
                {
                }
                column(Company_Information__Address; "Company Information".Address)
                {
                }
                column(PV_Lines1___Gross_Amount___VAT_Amount_; "PV Lines".Amount - "VAT Amount")
                {
                }
                column(PV_Lines1__PV_Lines1___WTX_Amount_; "PV Lines"."WHT Amount One")
                {
                }
                column(Company_Information__Picture; "Company Information".Picture)
                {
                }
                column(STRSUBSTNO__Date__1__2__TODAY_TIME_; StrSubstNo('Date %1 %2', Today, Time))
                {
                }
                column(VendorRec__VAT_Registration_No__; VendorRec."VAT Registration No.")
                {
                }
                column(VendorRec__PIN_No__; VendorRec."VAT Registration No.")
                {
                }
                column(CompInfo__Giro_No__; CompInfo."Giro No.")
                {
                }
                column(CompInfo__VAT_Registration_No__; CompInfo."VAT Registration No.")
                {
                }
                column(CertNo; CertNo)
                {
                }
                column(VendInvoiceNo; VendInvoiceNo)
                {
                }
                column(WITHOLDING_TAX_CERTIFICATECaption; WITHOLDING_TAX_CERTIFICATECaptionLbl)
                {
                }
                column(CERTIFICATE_OF_CONSULTANCY_AGENCY_OR_CONTRACTUAL_FEES_PAID_AND_TAX_DEDUCTED_YEARCaption; CERTIFICATE_OF_CONSULTANCY_AGENCY_OR_CONTRACTUAL_FEES_PAID_AND_TAX_DEDUCTED_YEARCaptionLbl)
                {
                }
                column(NAME_OF_PAYER_Caption; NAME_OF_PAYER_CaptionLbl)
                {
                }
                column(NAME_OF_PAYEE_Caption; NAME_OF_PAYEE_CaptionLbl)
                {
                }
                column(ADDRESS_OF_PAYEE_Caption; ADDRESS_OF_PAYEE_CaptionLbl)
                {
                }
                column(GROSS_AMOUNT_KSHS_Caption; GROSS_AMOUNT_KSHS_CaptionLbl)
                {
                }
                column(TAX_DEDUCTED_KSHS_Caption; TAX_DEDUCTED_KSHS_CaptionLbl)
                {
                }
                column(I_certify_that_the_tax_as_indicated_has_been_paid_over_to_the_Commisioner_of_Income_TAX__Nairobi_Caption; I_certify_that_the_tax_as_indicated_has_been_paid_over_to_the_Commisioner_of_Income_TAX__Nairobi_CaptionLbl)
                {
                }
                column(SIGNATURECaption; SIGNATURECaptionLbl)
                {
                }
                column(DATECaption; DATECaptionLbl)
                {
                }
                column(VAT_NO_Caption; VAT_NO_CaptionLbl)
                {
                }
                column(PIN_NO_Caption; PIN_NO_CaptionLbl)
                {
                }
                column(PIN_NO_Caption_Control1000000007; PIN_NO_Caption_Control1000000007Lbl)
                {
                }
                column(VAT_NO_Caption_Control1000000008; VAT_NO_Caption_Control1000000008Lbl)
                {
                }
                column(Certificate_No_Caption; Certificate_No_CaptionLbl)
                {
                }
                column(INVOICE_NO_Caption; INVOICE_NO_CaptionLbl)
                {
                }
                column(KRA_Receipt_No___________________________________________________________Caption; KRA_Receipt_No___________________________________________________________CaptionLbl)
                {
                }
                column(PV_Lines1_PV_No; "No.")
                {
                }
                column(PV_Lines1_Line_No; "Line No")
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if "PV Lines"."WHT Amount One" <= 0 then CurrReport.Skip;
                    PVLines.Reset;
                    PVLines.SetFilter(PVLines."VAT Amount", '<>%1', 0);
                    PVLines.SetFilter(PVLines."No.", '<%1', "PV Lines"."No.");
                    if PVLines.Find('-')then repeat CertNo:=CertNo + 1;
                        until PVLines.Next = 0;
                    //MESSAGE('Before %1',CertNo);                PVLines.Reset;
                    PVLines.SetFilter(PVLines."VAT Amount", '<>%1', 0);
                    PVLines.SetRange(PVLines."No.", "PV Lines"."No.");
                    PVLines.SetRange(PVLines."Line No", 0, "PV Lines"."Line No");
                    if PVLines.Find('-')then repeat CertNo:=CertNo + 1;
                        until PVLines.Next = 0;
                    if VendorRec.Get("Account No")then begin
                        if PostedInvoice.Get("PV Lines"."Applies to Doc. No")then VendInvoiceNo:=PostedInvoice."Vendor Invoice No.";
                    end;
                end;
                trigger OnPreDataItem()
                begin
                    PVLines.Reset;
                    PVLines.SetFilter(PVLines."WHT Amount One", '<>%1', 0);
                    if PVLines.Find('-')then StartingNo:=PVLines."No.";
                end;
            }
            trigger OnAfterGetRecord()
            begin
                RecordNo:=RecordNo + 1;
                ColumnNo:=ColumnNo + 1;
                //CompressArray(Addr[ColumnNo]);
                if RecordNo = NoOfRecords then begin
                    for i:=ColumnNo + 1 to NoOfColumns do Clear(Addr[i]);
                    ColumnNo:=0;
                end
                else
                begin
                    if ColumnNo = NoOfColumns then ColumnNo:=0;
                end;
            end;
            trigger OnPreDataItem()
            begin
                NoOfRecords:=Count;
                NoOfColumns:=3;
                "Company Information".Get;
                "Company Information".CalcFields(Picture);
            end;
        }
    }
    trigger OnPreReport()
    begin
        CompInfo.Get;
    end;
    var Addr: array[3]of Text[250];
    NoOfRecords: Integer;
    RecordNo: Integer;
    NoOfColumns: Integer;
    ColumnNo: Integer;
    i: Integer;
    Payer: Text[100];
    "Company Information": Record "Company Information";
    StartingNo: Code[20];
    PVLines: Record "Payment Voucher Lines";
    CertNo: Integer;
    VendorRec: Record Vendor;
    CompInfo: Record "Company Information";
    PostedInvoice: Record "Purch. Inv. Header";
    VendInvoiceNo: Code[20];
    WITHOLDING_TAX_CERTIFICATECaptionLbl: Label 'WITHOLDING TAX CERTIFICATE';
    CERTIFICATE_OF_CONSULTANCY_AGENCY_OR_CONTRACTUAL_FEES_PAID_AND_TAX_DEDUCTED_YEARCaptionLbl: Label 'CERTIFICATE OF CONSULTANCY AGENCY OR CONTRACTUAL FEES PAID AND TAX DEDUCTED YEAR';
    NAME_OF_PAYER_CaptionLbl: Label 'NAME OF PAYER:';
    NAME_OF_PAYEE_CaptionLbl: Label 'NAME OF PAYEE:';
    ADDRESS_OF_PAYEE_CaptionLbl: Label 'ADDRESS OF PAYEE:';
    GROSS_AMOUNT_KSHS_CaptionLbl: Label 'GROSS AMOUNT KSHS.';
    TAX_DEDUCTED_KSHS_CaptionLbl: Label 'TAX DEDUCTED KSHS:';
    I_certify_that_the_tax_as_indicated_has_been_paid_over_to_the_Commisioner_of_Income_TAX__Nairobi_CaptionLbl: Label 'I certify that the tax as indicated has been paid over to the Commisioner of Income TAX, Nairobi.';
    SIGNATURECaptionLbl: Label 'SIGNATURE';
    DATECaptionLbl: Label 'DATE';
    VAT_NO_CaptionLbl: Label 'VAT NO.';
    PIN_NO_CaptionLbl: Label 'PIN NO.';
    PIN_NO_Caption_Control1000000007Lbl: Label 'PIN NO.';
    VAT_NO_Caption_Control1000000008Lbl: Label 'VAT NO.';
    Certificate_No_CaptionLbl: Label 'Certificate No.';
    INVOICE_NO_CaptionLbl: Label 'INVOICE NO.';
    KRA_Receipt_No___________________________________________________________CaptionLbl: Label 'KRA Receipt No...........................................................';
}

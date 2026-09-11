report 52203443 "GRN"
{
    // version NAVW111.00DefaultLayout = RDLC;
    RDLCLayout = './ssrs/GRN.rdlc';
    Caption = 'Purchase - Receipt';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Purch. Rcpt. Header"; "Purch. Rcpt. Header")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Buy-from Vendor No.", "No. Printed";
            RequestFilterHeading = 'Posted Purchase Receipt';

            column(No_PurchRcptHeader; "No.")
            {
            }
            column(LPONo; "Order No.")
            {
            }
            column(LPODate; "Purch. Rcpt. Header"."Order Date")
            {
            }
            column(DNoteNo; "Vendor Shipment No.")
            {
            }
            column(DocDateCaption; DocDateCaptionLbl)
            {
            }
            column(PageCaption; PageCaptionLbl)
            {
            }
            column(DescCaption; DescCaptionLbl)
            {
            }
            column(QtyCaption; QtyCaptionLbl)
            {
            }
            column(UOMCaption; UOMCaptionLbl)
            {
            }
            column(PaytoVenNoCaption; PaytoVenNoCaptionLbl)
            {
            }
            column(EmailCaption; EmailCaptionLbl)
            {
            }
            column(Logo; CompInfo.Picture)
            {
            }
            column(Logo2; CompInfo.Picture2)
            {
            }
            column(Watermark; AdvancedFinanceSetup."Watermark Portrait")
            {
            }
            column(CompName; CompName)
            {
            }
            column(CompAddress; CompAddress)
            {
            }
            column(CompAddress2; CompAddressTwo)
            {
            }
            column(CompCity; CompCity)
            {
            }
            column(CompPhone; CompPhone)
            {
            }
            column(CompCountry; CompInfo."Country/Region Code")
            {
            }
            column(ReceivedBy; ReceivedBy)
            {
            }
            column(ProjectName; ProjectName)
            {
            }
            column(ReceivedDate; "Purch. Rcpt. Header"."Document Date")
            {
            }
            column(VendorNoCaption; VendNoLbl)
            {
            }
            column(VendName; VendName)
            {
            }
            column(Address; PurchaseHeader."Pay-to Address")
            {
            }
            column(DistributionLbl; DistributionLbl)
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);

                dataitem(PageLoop; "Integer")
                {
                    DataItemTableView = SORTING(Number)WHERE(Number=CONST(1));

                    column(PurchRcptCopyText; StrSubstNo(Text002, CopyText))
                    {
                    }
                    /* column(CurrentReportPageNo;StrSubstNo(Text003,Format(CurrReport.PageNo)))
                     {
                     }*/
                    column(ShipToAddr1; ShipToAddr[1])
                    {
                    }
                    column(CompanyAddr1; CompanyAddr[1])
                    {
                    }
                    column(ShipToAddr2; ShipToAddr[2])
                    {
                    }
                    column(CompanyAddr2; CompanyAddr[2])
                    {
                    }
                    column(ShipToAddr3; ShipToAddr[3])
                    {
                    }
                    column(CompanyAddr3; CompanyAddr[3])
                    {
                    }
                    column(ShipToAddr4; ShipToAddr[4])
                    {
                    }
                    column(CompanyAddr4; CompanyAddr[4])
                    {
                    }
                    column(ShipToAddr5; ShipToAddr[5])
                    {
                    }
                    column(CompanyInfoPhoneNo; CompanyInfo."Phone No.")
                    {
                    }
                    column(ShipToAddr6; ShipToAddr[6])
                    {
                    }
                    column(CompanyInfoHomePage; CompanyInfo."Home Page")
                    {
                    }
                    column(CompanyInfoEmail; CompanyInfo."E-Mail")
                    {
                    }
                    column(CompanyInfoVATRegNo; CompanyInfo."VAT Registration No.")
                    {
                    }
                    column(CompanyInfoGiroNo; CompanyInfo."Giro No.")
                    {
                    }
                    column(CompanyInfoBankName; CompanyInfo."Bank Name")
                    {
                    }
                    column(CompanyInfoBankAccNo; CompanyInfo."Bank Account No.")
                    {
                    }
                    column(DocDate_PurchRcptHeader; Format("Purch. Rcpt. Header"."Document Date", 0, 4))
                    {
                    }
                    column(PurchaserText; PurchaserText)
                    {
                    }
                    column(SalesPurchPersonName; SalesPurchPerson.Name)
                    {
                    }
                    column(No1_PurchRcptHeader; "Purch. Rcpt. Header"."No.")
                    {
                    }
                    column(ReferenceText; ReferenceText)
                    {
                    }
                    column(YourRef_PurchRcptHeader; "Purch. Rcpt. Header"."Your Reference")
                    {
                    }
                    column(ShipToAddr7; ShipToAddr[7])
                    {
                    }
                    column(ShipToAddr8; ShipToAddr[8])
                    {
                    }
                    column(CompanyAddr5; CompanyAddr[5])
                    {
                    }
                    column(CompanyAddr6; CompanyAddr[6])
                    {
                    }
                    column(OutputNo; OutputNo)
                    {
                    }
                    column(PhoneNoCaption; PhoneNoCaptionLbl)
                    {
                    }
                    column(HomePageCaption; HomePageCaptionLbl)
                    {
                    }
                    column(VATRegNoCaption; VATRegNoCaptionLbl)
                    {
                    }
                    column(GiroNoCaption; GiroNoCaptionLbl)
                    {
                    }
                    column(BankNameCaption; BankNameCaptionLbl)
                    {
                    }
                    column(AccNoCaption; AccNoCaptionLbl)
                    {
                    }
                    column(ShipmentNoCaption; ShipmentNoCaptionLbl)
                    {
                    }
                    dataitem(DimensionLoop1; "Integer")
                    {
                        DataItemLinkReference = "Purch. Rcpt. Header";
                        DataItemTableView = SORTING(Number)WHERE(Number=FILTER(1..));

                        column(DimText; DimText)
                        {
                        }
                        column(HeaderDimCaption; HeaderDimCaptionLbl)
                        {
                        }
                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then begin
                                if not DimSetEntry1.FindSet then CurrReport.Break;
                            end
                            else if not Continue then CurrReport.Break;
                            Clear(DimText);
                            Continue:=false;
                            repeat OldDimText:=DimText;
                                if DimText = '' then DimText:=StrSubstNo('%1 - %2', DimSetEntry1."Dimension Code", DimSetEntry1."Dimension Value Code")
                                else
                                    DimText:=StrSubstNo('%1; %2 - %3', DimText, DimSetEntry1."Dimension Code", DimSetEntry1."Dimension Value Code");
                                if StrLen(DimText) > MaxStrLen(OldDimText)then begin
                                    DimText:=OldDimText;
                                    Continue:=true;
                                    exit;
                                end;
                            until DimSetEntry1.Next = 0;
                        end;
                        trigger OnPreDataItem()
                        begin
                            if not ShowInternalInfo then CurrReport.Break;
                        end;
                    }
                    dataitem("Purch. Rcpt. Line"; "Purch. Rcpt. Line")
                    {
                        DataItemLink = "Document No."=FIELD("No.");
                        DataItemLinkReference = "Purch. Rcpt. Header";
                        DataItemTableView = SORTING("Document No.", "Line No.");

                        column(ShowInternalInfo; ShowInternalInfo)
                        {
                        }
                        column(Type_PurchRcptLine; Format(Type, 0, 2))
                        {
                        }
                        column(Desc_PurchRcptLine; Description)
                        {
                        IncludeCaption = false;
                        }
                        column(Qty_PurchRcptLine; Quantity)
                        {
                        IncludeCaption = false;
                        }
                        column(UOM_PurchRcptLine; "Unit of Measure")
                        {
                        IncludeCaption = false;
                        }
                        column(No_PurchRcptLine; "No.")
                        {
                        }
                        column(DocNo_PurchRcptLine; "Document No.")
                        {
                        }
                        column(LineNo_PurchRcptLine; "Line No.")
                        {
                        IncludeCaption = false;
                        }
                        column(No_PurchRcptLineCaption; FieldCaption("No."))
                        {
                        }
                        column(UnitCost; "Unit Cost")
                        {
                        }
                        column(TotalAmount; "Unit Cost" * Quantity)
                        {
                        }
                        dataitem(DimensionLoop2; "Integer")
                        {
                            DataItemTableView = SORTING(Number)WHERE(Number=FILTER(1..));

                            column(DimText1; DimText)
                            {
                            }
                            column(LineDimCaption; LineDimCaptionLbl)
                            {
                            }
                            trigger OnAfterGetRecord()
                            begin
                                begin
                                    if Number = 1 then begin
                                        if not DimSetEntry2.FindSet then CurrReport.Break;
                                    end
                                    else if not Continue then CurrReport.Break;
                                    Clear(DimText);
                                    Continue:=false;
                                    repeat OldDimText:=DimText;
                                        if DimText = '' then DimText:=StrSubstNo('%1 - %2', DimSetEntry2."Dimension Code", DimSetEntry2."Dimension Value Code")
                                        else
                                            DimText:=StrSubstNo('%1; %2 - %3', DimText, DimSetEntry2."Dimension Code", DimSetEntry2."Dimension Value Code");
                                        if StrLen(DimText) > MaxStrLen(OldDimText)then begin
                                            DimText:=OldDimText;
                                            Continue:=true;
                                            exit;
                                        end;
                                    until DimSetEntry2.Next = 0;
                                end;
                            end;
                            trigger OnPreDataItem()
                            begin
                                if not ShowInternalInfo then CurrReport.Break;
                            end;
                        }
                        trigger OnAfterGetRecord()
                        begin
                            if(not ShowCorrectionLines) and Correction then CurrReport.Skip;
                            DimSetEntry2.SetRange("Dimension Set ID", "Dimension Set ID");
                        end;
                        trigger OnPreDataItem()
                        begin
                            MoreLines:=Find('+');
                            while MoreLines and (Description = '') and ("No." = '') and (Quantity = 0)do MoreLines:=Next(-1) <> 0;
                            if not MoreLines then CurrReport.Break;
                            SetRange("Line No.", 0, "Line No.");
                        end;
                    }
                    dataitem(Total; "Integer")
                    {
                        DataItemTableView = SORTING(Number)WHERE(Number=CONST(1));

                        column(BuyfromVenNo_PurchRcptHeader; "Purch. Rcpt. Header"."Buy-from Vendor No.")
                        {
                        }
                        column(BuyfromVenNo_PurchRcptHeaderCaption; "Purch. Rcpt. Header".FieldCaption("Buy-from Vendor No."))
                        {
                        }
                        trigger OnPreDataItem()
                        begin
                            if "Purch. Rcpt. Header"."Buy-from Vendor No." = "Purch. Rcpt. Header"."Pay-to Vendor No." then CurrReport.Break;
                        end;
                    }
                    dataitem(Total2; "Integer")
                    {
                        DataItemTableView = SORTING(Number)WHERE(Number=CONST(1));

                        column(PaytoVenNo_PurchRcptHeader; "Purch. Rcpt. Header"."Pay-to Vendor No.")
                        {
                        }
                        column(VendAddr1; Add1)
                        {
                        }
                        column(VendAddr2; Add2)
                        {
                        }
                        column(VendAddr3; Add3)
                        {
                        }
                        column(VendAddr4; Add4)
                        {
                        }
                        column(VendAddr5; VendAddr[5])
                        {
                        }
                        column(VendAddr6; VendAddr[6])
                        {
                        }
                        column(VendAddr7; VendAddr[7])
                        {
                        }
                        column(VendAddr8; VendAddr[8])
                        {
                        }
                        column(PaytoAddrCaption; PaytoAddrCaptionLbl)
                        {
                        }
                        column(PaytoVenNo_PurchRcptHeaderCaption; "Purch. Rcpt. Header".FieldCaption("Pay-to Vendor No."))
                        {
                        }
                    }
                }
                trigger OnAfterGetRecord()
                begin
                    if Number > 1 then begin
                        CopyText:=FormatDocument.GetCOPYText;
                        OutputNo+=1;
                    end;
                /*CurrReport.PageNo := 1;*/
                end;
                trigger OnPostDataItem()
                begin
                    if not CurrReport.Preview then CODEUNIT.Run(CODEUNIT::"Purch.Rcpt.-Printed", "Purch. Rcpt. Header");
                end;
                trigger OnPreDataItem()
                begin
                    OutputNo:=1;
                    NoOfLoops:=Abs(NoOfCopies) + 1;
                    CopyText:='';
                    SetRange(Number, 1, NoOfLoops);
                end;
            }
            trigger OnAfterGetRecord()
            begin
                // CurrReport.Language := Language.GetLanguageID("Language Code");        
                FormatAddressFields("Purch. Rcpt. Header");
                if LogInteraction then if not CurrReport.Preview then SegManagement.LogDocument(15, "No.", 0, 0, DATABASE::Vendor, "Buy-from Vendor No.", "Purchaser Code", '', "Posting Description", '');
                if "Purch. Rcpt. Header"."Shortcut Dimension 2 Code" = 'KISUMU' then begin
                    CompName:=CompInfo."Branch Name";
                    CompAddress:=CompInfo."Branch Address";
                    CompAddressTwo:=CompInfo."Branch Address 2";
                    CompCity:=CompInfo."Branch City";
                    CompPhone:=CompInfo."Branch Phone No.";
                end;
                Users.Reset;
                Users.SetRange("User Name", "Purch. Rcpt. Header"."User ID");
                if Users.FindFirst then ReceivedBy:=Users."Full Name";
                if DimensionValueRec.Get('Division', "Purch. Rcpt. Header"."Shortcut Dimension 1 Code")then Vendor.Reset;
                Vendor.SetRange("No.", "Purch. Rcpt. Header"."Pay-to Vendor No.");
                if Vendor.FindSet then VendName:=Vendor.Name; /*IF Vendor.FINDSET THEN BEGIN
                  Add1 := Vendor.Name;
                  Add2 := Vendor.Address;
                  Add3 := Vendor."Address 2";
                  Add4 := Vendor."Phone No.";
                end;*/
            end;
        }
    }
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';

                    field(NoOfCopies; NoOfCopies)
                    {
                        ApplicationArea = Advanced;
                        Caption = 'No. of Copies';
                        ToolTip = 'Specifies how many copies of the document to print.';
                    }
                    field(ShowInternalInfo; ShowInternalInfo)
                    {
                        ApplicationArea = Advanced;
                        Caption = 'Show Internal Information';
                        ToolTip = 'Specifies if you want the printed report to show information that is only for internal use.';
                    }
                    field(LogInteraction; LogInteraction)
                    {
                        ApplicationArea = Advanced;
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                        ToolTip = 'Specifies if you want the program to log this interaction.';
                    }
                    field(ShowCorrectionLines; ShowCorrectionLines)
                    {
                        ApplicationArea = Advanced;
                        Caption = 'Show Correction Lines';
                        ToolTip = 'Specifies if the correction lines of an undoing of quantity posting will be shown on the report.';
                    }
                }
            }
        }
        trigger OnInit()
        begin
            LogInteractionEnable:=true;
        end;
        trigger OnOpenPage()
        begin
            InitLogInteraction;
            LogInteractionEnable:=LogInteraction;
        end;
    }
    trigger OnInitReport()
    begin
        CompanyInfo.Get;
    end;
    trigger OnPreReport()
    begin
        if not CurrReport.UseRequestPage then InitLogInteraction;
        CompInfo.Get;
        CompInfo.CalcFields(Picture);
        CompInfo.CalcFields(Picture2);
        CompName:=CompInfo.Name;
        CompAddress:=CompInfo.Address;
        CompAddressTwo:=CompInfo."Address 2";
        CompCity:=CompInfo.City;
        CompPhone:=CompInfo."Phone No.";
        AdvancedFinanceSetup.Get;
        AdvancedFinanceSetup.CalcFields("Watermark Portrait");
    end;
    var Text002: Label 'Purchase - Receipt %1', Comment = '%1 = Document No.';
    Text003: Label 'Page %1';
    CompanyInfo: Record "Company Information";
    SalesPurchPerson: Record "Salesperson/Purchaser";
    DimSetEntry1: Record "Dimension Set Entry";
    DimSetEntry2: Record "Dimension Set Entry";
    TheLanguage: Record Language;
    RespCenter: Record "Responsibility Center";
    FormatAddr: Codeunit 365;
    FormatDocument: Codeunit "Format Document";
    SegManagement: Codeunit SegManagement;
    VendAddr: array[8]of Text[50];
    ShipToAddr: array[8]of Text[50];
    CompanyAddr: array[8]of Text[50];
    PurchaserText: Text[30];
    ReferenceText: Text[80];
    MoreLines: Boolean;
    NoOfCopies: Integer;
    NoOfLoops: Integer;
    CopyText: Text[30];
    DimText: Text[120];
    OldDimText: Text[75];
    ShowInternalInfo: Boolean;
    Continue: Boolean;
    LogInteraction: Boolean;
    ShowCorrectionLines: Boolean;
    OutputNo: Integer;
    [InDataSet]
    LogInteractionEnable: Boolean;
    PhoneNoCaptionLbl: Label 'Phone No.';
    HomePageCaptionLbl: Label 'Home Page';
    VATRegNoCaptionLbl: Label 'VAT Registration No.';
    GiroNoCaptionLbl: Label 'Giro No.';
    BankNameCaptionLbl: Label 'Bank';
    AccNoCaptionLbl: Label 'Account No.';
    ShipmentNoCaptionLbl: Label 'Shipment No.';
    HeaderDimCaptionLbl: Label 'Header Dimensions';
    LineDimCaptionLbl: Label 'Line Dimensions';
    PaytoAddrCaptionLbl: Label 'Pay-to Address';
    DocDateCaptionLbl: Label 'Document Date';
    PageCaptionLbl: Label 'Page';
    DescCaptionLbl: Label 'Description';
    QtyCaptionLbl: Label 'Quantity';
    UOMCaptionLbl: Label 'Unit Of Measure';
    PaytoVenNoCaptionLbl: Label 'Pay-to Vendor Name.';
    EmailCaptionLbl: Label 'Email';
    "**************************": Text;
    CompInfo: Record "Company Information";
    TandC: Record "Procurement Terms & Conditions";
    i: Integer;
    TermAndCondition: array[20]of Text;
    ApprovalEntries: Record "Approval Entry";
    "1stapprover": Text[100];
    "2ndapprover": Text[100];
    "3rdapprover": Text[100];
    "4thapprover": Text[100];
    j: Integer;
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
    Users: Record User;
    PurchaseHeader: Record "Purchase Header";
    Counter: Integer;
    AccountClassification: Text;
    ProcurementSetup: Record "Inventory Setup";
    ShipToAddressText: Text;
    AttentionText: Text;
    CompName: Text;
    CompAddress: Text;
    CompAddressTwo: Text;
    CompCity: Text;
    CompPhone: Text;
    ReceivedBy: Text;
    ProjectName: Text;
    AdvancedFinanceSetup: Record "General Ledger Setup";
    Vendor: Record Vendor;
    Add1: Text;
    Add2: Text;
    Add3: Text;
    Add4: Text;
    VendNoLbl: Label 'Vendor No.';
    VendName: Text;
    DistributionLbl: Label 'Distribution: Original (White) - Accounts,     Duplicate (Pink) - Purchasing,     Triplicate(Blue) - Stores';
    procedure InitializeRequest(NewNoOfCopies: Integer; NewShowInternalInfo: Boolean; NewLogInteraction: Boolean; NewShowCorrectionLines: Boolean)
    begin
        NoOfCopies:=NewNoOfCopies;
        ShowInternalInfo:=NewShowInternalInfo;
        LogInteraction:=NewLogInteraction;
        ShowCorrectionLines:=NewShowCorrectionLines;
    end;
    local procedure InitLogInteraction()
    begin
    //LogInteraction:=SegManagement.FindInteractTmplCode(15) <> '';
    end;
    local procedure FormatAddressFields(var PurchRcptHeader: Record "Purch. Rcpt. Header")
    begin
        FormatAddr.GetCompanyAddr(PurchRcptHeader."Responsibility Center", RespCenter, CompanyInfo, CompanyAddr);
        FormatAddr.PurchRcptShipTo(ShipToAddr, PurchRcptHeader);
        FormatAddr.PurchRcptPayTo(VendAddr, PurchRcptHeader);
    end;
    local procedure FormatDocumentFields(PurchRcptHeader: Record "Purch. Rcpt. Header")
    begin
        with PurchRcptHeader do begin
            FormatDocument.SetPurchaser(SalesPurchPerson, "Purchaser Code", PurchaserText);
            ReferenceText:=FormatDocument.SetText("Your Reference" <> '', FieldCaption("Your Reference"));
        end;
    end;
}

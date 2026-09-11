report 52203586 "Request for Quotation"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Request for Quotation.rdlc';

    dataset
    {
        dataitem("Quotation Bidders"; "Quotation Bidders")
        {
            DataItemTableView = SORTING("Reference No", "Vendor No.", "Vendor Category");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "Reference No", "Vendor No.";

            column(Supplier_Selection1_Reference_No_; "Reference No")
            {
            }
            column(Supplier_Selection1_Supplier_Name; "Vendor Name")
            {
            }
            column(VendorNo_QuotationBidders; "Quotation Bidders"."Vendor No.")
            {
            }
            column(title; title)
            {
            }
            column(ilesikuitaisha; CalcDate('7D', Today))
            {
            }
            column(DocNumberCaption; DocNumber)
            {
            }
            column(CONDITIONSCaption; CONDITIONSCaptionLbl)
            {
            }
            column(ConditionOneCaption; ConditionOneLbl)
            {
            }
            column(ConditionTwoCaption; ConditionTwoLbl)
            {
            }
            column(ConditionThreeCaption; ConditionThreeLbl)
            {
            }
            column(ConditionFourCaption; ConditionFourLbl)
            {
            }
            column(ConditionFiveCaption; ConditionFiveLbl)
            {
            }
            column(ConditionSixCaption; ConditionSixLbl)
            {
            }
            column(ConditionSevenCaption; ConditionSevenLbl)
            {
            }
            column(ConditionEightCaption; ConditionEightLbl)
            {
            }
            column(ConditionNineCaption; ConditionNineLbl)
            {
            }
            column(WitnessTextLbl; WitnessText)
            {
            }
            column(TODAY; Today)
            {
            }
            column(CompInfo_Picture; CompInfo.Picture)
            {
            }
            column(CompInfo_Name; CompInfo.Name)
            {
            }
            column(CompInfo_Fax_No_; CompInfo."Fax No.")
            {
            }
            column(CompInfo_Post_Code; CompInfo."Post Code")
            {
            }
            column(CompInfo_Name_Control1000000095; CompInfo.Name)
            {
            }
            column(CompInfo_Address; CompInfo.Address)
            {
            }
            column(CompInfo_City; CompInfo.City)
            {
            }
            column(CompInfo_Phone_No; CompInfo."Phone No.")
            {
            }
            column(Invitation; StrSubstNo(InvitationLbl, ReturnTime, Format(ReturnDate)))
            {
            }
            column(RefCaption; Ref)
            {
            }
            column(Tel; Tel)
            {
            }
            column(FaxNo; Fax)
            {
            }
            column(PBox; StrSubstNo(Address, CompInfo."Address 2", CompInfo."Post Code"))
            {
            }
            column(bdlbl1; bdlbl1)
            {
            }
            column(bdlbl2; bdlbl2)
            {
            }
            column(bdlbl3; bdlbl3)
            {
            }
            column(bdlbl31; bdlbl31)
            {
            }
            column(bdlbl4; bdlbl4)
            {
            }
            column(bdlbl41; bdlbl41)
            {
            }
            column(bdlbl5; bdlbl5)
            {
            }
            column(bdlbl6; bdlbl6)
            {
            }
            dataitem("Procurement Request Lines"; "Procurement Request Lines")
            {
                DataItemLink = "Procurement No"=FIELD("Reference No");
                DataItemTableView = SORTING("Procurement No", "Line No.");
                PrintOnlyIfDetail = false;

                column(Procurement_Request_Lines1__Procurement_Request_Lines1__No; "Procurement Request Lines"."No.")
                {
                }
                column(Procurement_Request_Lines1_Description; Description)
                {
                }
                column(Procurement_Request_Lines1_Quantity; Quantity)
                {
                }
                column(Procurement_Request_Lines1__Unit_of_Measure_; "Unit of Measure")
                {
                }
                column(UnitPrice_ProcurementRequestLines1; "Procurement Request Lines"."Unit Price")
                {
                }
                column(To_Caption; To_CaptionLbl)
                {
                }
                column(Seller_s_Name_and_AddressCaption; Seller_s_Name_and_AddressCaptionLbl)
                {
                }
                column(EmptyStringCaption; EmptyStringCaptionLbl)
                {
                }
                column(DAYS_TO_DELIVERYCaption; DAYS_TO_DELIVERYCaptionLbl)
                {
                }
                column(Notes_Caption; Notes_CaptionLbl)
                {
                }
                column(UNITCaption; UNITCaptionLbl)
                {
                }
                column(QUANTITY_REQUIREDCaption; QUANTITY_REQUIREDCaptionLbl)
                {
                }
                column(TOTAL_AMOUNTCaption; TOTAL_AMOUNTCaptionLbl)
                {
                }
                column(REMARKSCaption; REMARKSCaptionLbl)
                {
                }
                column(a__THIS_IS_NOT_AN_ORDER_Read_the_conditions_and_instructions_on_reverse_before_quoting_Caption; a__THIS_IS_NOT_AN_ORDER_Read_the_conditions_and_instructions_on_reverse_before_quoting_CaptionLbl)
                {
                }
                column(UNIT_PRICECaption; UNIT_PRICECaptionLbl)
                {
                }
                column(Date_________________________________________________________________________Caption; Date_________________________________________________________________________CaptionLbl)
                {
                }
                column(EmptyStringCaption_Control1000000003; EmptyStringCaption_Control1000000003Lbl)
                {
                }
                column(EmptyStringCaption_Control1000000019; EmptyStringCaption_Control1000000019Lbl)
                {
                }
                column(BRANDCaption; BRANDCaptionLbl)
                {
                }
                column(CODE_No_Caption; CODE_No_CaptionLbl)
                {
                }
                column(ITEM_DESCRIPTIONCaption; ITEM_DESCRIPTIONCaptionLbl)
                {
                }
                column(Quotation_No___________________________________________________________________Caption; Quotation_No___________________________________________________________________CaptionLbl)
                {
                }
                column(From_Caption; From_CaptionLbl)
                {
                }
                column(To_be_endorsed_on_the_envelope_Caption; To_be_endorsed_on_the_envelope_CaptionLbl)
                {
                }
                column(REQUEST_FOR_QUOTATIONCaption; REQUEST_FOR_QUOTATIONCaptionLbl)
                {
                }
                column(COUNTRY_OF_ORIGINCaption; COUNTRY_OF_ORIGINCaptionLbl)
                {
                }
                column(Seller_s_Signature________________________________________________________________Caption; Seller_s_Signature________________________________________________________________CaptionLbl)
                {
                }
                column(Date__________________________________________________________Caption; Date__________________________________________________________CaptionLbl)
                {
                }
                column(Sign_over_Rubber_Stamp_Caption; Sign_over_Rubber_Stamp_CaptionLbl)
                {
                }
                column(Opened_By_Caption; Opened_By_CaptionLbl)
                {
                }
                column(FOR_OFFICIAL_USE_ONLYCaption; FOR_OFFICIAL_USE_ONLYCaptionLbl)
                {
                }
                column(V1__________________________________________________________________________________________Caption; V1__________________________________________________________________________________________CaptionLbl)
                {
                }
                column(Designation_________________________________________________________________________________________Caption; Designation_________________________________________________________________________________________CaptionLbl)
                {
                }
                column(Date_________________________________________________________________________________________Caption; Date_________________________________________________________________________________________CaptionLbl)
                {
                }
                column(V3__________________________________________________________________________________________Caption; V3__________________________________________________________________________________________CaptionLbl)
                {
                }
                column(V2__________________________________________________________________________________________Caption; V2__________________________________________________________________________________________CaptionLbl)
                {
                }
                column(Signature_________________________________________________________________________________________Caption; Signature_________________________________________________________________________________________CaptionLbl)
                {
                }
                column(DataItem1000000066; Signature_____________________________________________________________________________Caption_Control1000000066Lbl)
                {
                }
                column(DataItem1000000067; Signature_______________________________________________________________________Caption_Control1000000067Lbl)
                {
                }
                column(Time_________________________________________________________________________________________Caption; Time_________________________________________________________________________________________CaptionLbl)
                {
                }
                column(DataItem1000000069; Designation_______________________________________________________________________________Caption_Control1000000069Lbl)
                {
                }
                column(DataItem1000000070; Designation________________________________________________________________________________Caption_Control1000000070Lbl)
                {
                }
                column(Procurement_Request_Lines1_Line_No; "Line No.")
                {
                }
                column(LeadTimeCaption; LeadTime)
                {
                }
                column(V4Caption; V4)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    ThisLNAmt:=ThisLNAmt + "Procurement Request Lines"."Total Amount";
                    RecSeq:=RecSeq + 1;
                end;
                trigger OnPreDataItem()
                begin
                    RecSeq:=0;
                end;
            }
            trigger OnAfterGetRecord()
            var
                reqheader: Record "Requisition Header";
            begin
                CompInfo.CalcFields(Picture);
                // MESSAGE('%1',"Supplier Selection1"."Supplier Name");     
                ProcurementRequest.Reset;
                ProcurementRequest.SetRange(ProcurementRequest."No.", "Quotation Bidders"."Reference No");
                if ProcurementRequest.Find('-')then begin
                    DocNumber:=ProcurementRequest."No.";
                    ReturnDate:=ProcurementRequest."Return Date";
                    ReturnTime:=ProcurementRequest."Return Time";
                end;
                //================================================================
                reqheader.Reset;
                if reqheader.Get("Quotation Bidders"."Reference No")then begin
                    title:=reqheader.Description;
                end;
            //================================================================
            end;
        }
    }
    trigger OnInitReport()
    begin
        CompInfo.Get;
    end;
    var Department: Text[30];
    Dimvalues: Record "Dimension Value";
    Vendors: Record Vendor;
    PrevMonthBud: Decimal;
    CurrMonthBud: Decimal;
    TotAvailableBud: Decimal;
    GLAccount: Record "G/L Account";
    GenLedSetup: Record "General Ledger Setup";
    QtyStore: Record Item;
    GenPostGroup: Record "General Posting Setup";
    Budget: Decimal;
    CurrMonth: Code[10];
    CurrYR: Code[10];
    BudgDate: Text[30];
    ReqHeader: Record "Requisition Header";
    BudgetDate: Date;
    YrBudget: Decimal;
    "BudgetB/F": Decimal;
    RequisitionLine: Record "Requisition Lines";
    BudgetGL: Code[20];
    ThisLNAmt: Decimal;
    PeriodTo: Date;
    TotalMonthReq: Decimal;
    RecSeq: Integer;
    DateRequired: Date;
    CompInfo: Record "Company Information";
    CONDITIONSCaptionLbl: Label 'NOTE:';
    ConditionOneLbl: Label '1. Delivery lead-time and validity period of your quotation MUST be indicated';
    ConditionTwoLbl: Label '2. The quotation should be enclosed in plain sealed envelope and the quotation reference number MUST be indicated on the envelope';
    ConditionThreeLbl: Label '3. Prices quoted MUST be inclusive of VAT and all other costs where applicable.';
    ConditionFourLbl: Label '4. The quotation MUST be stamped and signed.';
    ConditionFiveLbl: Label '5. The quotation MUST be placed in the quotation box at NEMA Hqs in South C off Popo Road, Nairobi Kenya.';
    ConditionSixLbl: Label '6. The supplier shall retain a COPY of the quotation on the quotation submission date.';
    ConditionSevenLbl: Label '7. Attach copies of certificate of registration/Incorporation ';
    ConditionEightLbl: Label '8. Failure to observe the above conditions shall lead to automatic disqualification of the bidder';
    ConditionNineLbl: Label '9. NEMA reserves the right to accept or reject any bid wholly or in part and does not bind itself to accept any bid.';
    To_CaptionLbl: Label 'To:';
    Seller_s_Name_and_AddressCaptionLbl: Label 'Seller''s Name and Address';
    EmptyStringCaptionLbl: Label '.....................................................................................................................';
    DAYS_TO_DELIVERYCaptionLbl: Label 'DAYS TO DELIVERY';
    Notes_CaptionLbl: Label 'Notes:';
    UNITCaptionLbl: Label 'UNIT';
    QUANTITY_REQUIREDCaptionLbl: Label 'QTY';
    TOTAL_AMOUNTCaptionLbl: Label 'TOTAL COST';
    REMARKSCaptionLbl: Label 'REMARKS';
    a__THIS_IS_NOT_AN_ORDER_Read_the_conditions_and_instructions_on_reverse_before_quoting_CaptionLbl: Label '(a) THIS IS NOT AN ORDER.Read the conditions and instructions on reverse before quoting.';
    V10_00_a_m__on_______________________________________________________________________________________________________Lbl: Label '10.00 a.m. on.................................................................................................................';
    UNIT_PRICECaptionLbl: Label 'UNITCOST';
    InvitationLbl: Label 'We invite you to quote for the following listed item(s)/services/Works.Your quote should be received on or before %1 on %2';
    Date_________________________________________________________________________CaptionLbl: Label 'Date.........................................................................';
    EmptyStringCaption_Control1000000003Lbl: Label '.....................................................................................................................';
    EmptyStringCaption_Control1000000019Lbl: Label '.....................................................................................................................';
    BRANDCaptionLbl: Label 'BRAND';
    d___Return_the_original_copy_and_retain_the_duplicate_for_your_recordCaptionLbl: Label '(d ) Return the original copy and retain the duplicate for your record';
    c__Your_quotation_should_indicate_final_unit_price_which_includes_alll_costs_for_delivery_discount_duty_CaptionLbl: Label '(c) Your quotation should indicate final unit price which includes alll costs for delivery,discount,duty ';
    b__This_quotation_should_be_submitted_in_palin_wax_sealed_envelope_marked___Quotation_No__________________CLbl: Label '(b) This quotation should be submitted in palin wax sealed envelope marked  "Quotation No....................................';
    CODE_No_CaptionLbl: Label 'ITEM';
    ITEM_DESCRIPTIONCaptionLbl: Label 'DESCRIPTION';
    Quotation_No___________________________________________________________________CaptionLbl: Label 'Quotation No. .................................................................';
    From_CaptionLbl: Label 'From:';
    The_Director_GeneralCaptionLbl: Label 'The Director General';
    To_be_endorsed_on_the_envelope_CaptionLbl: Label '(To be endorsed on the envelope)';
    REQUEST_FOR_QUOTATIONCaptionLbl: Label 'REQUEST FOR QUOTATION';
    and_sales_tax_CaptionLbl: Label 'and sales tax.';
    COUNTRY_OF_ORIGINCaptionLbl: Label 'COUNTRY OF ORIGIN';
    Seller_s_Signature________________________________________________________________CaptionLbl: Label 'SUPPLIER''S SIGNATURE & STAMP................................................................';
    Date__________________________________________________________CaptionLbl: Label 'Date..........................................................';
    Sign_over_Rubber_Stamp_CaptionLbl: Label '(Sign over Rubber Stamp)';
    Opened_By_CaptionLbl: Label 'Opened By:';
    FOR_OFFICIAL_USE_ONLYCaptionLbl: Label 'FOR OFFICIAL USE ONLY';
    V1__________________________________________________________________________________________CaptionLbl: Label '(1).........................................................................................';
    Designation_________________________________________________________________________________________CaptionLbl: Label 'Designation.........................................................................................';
    Date_________________________________________________________________________________________CaptionLbl: Label 'Date.........................................................................................';
    V3__________________________________________________________________________________________CaptionLbl: Label '(3).........................................................................................';
    V2__________________________________________________________________________________________CaptionLbl: Label '(2).........................................................................................';
    Signature_________________________________________________________________________________________CaptionLbl: Label 'Signature.........................................................................................';
    Signature_____________________________________________________________________________Caption_Control1000000066Lbl: Label 'Signature.........................................................................................';
    Signature_______________________________________________________________________Caption_Control1000000067Lbl: Label 'Signature.........................................................................................';
    Time_________________________________________________________________________________________CaptionLbl: Label 'Time.........................................................................................';
    Designation_______________________________________________________________________________Caption_Control1000000069Lbl: Label 'Designation.........................................................................................';
    Designation________________________________________________________________________________Caption_Control1000000070Lbl: Label 'Designation.........................................................................................';
    LeadTime: Label 'DELIVERY LEADTIME';
    Remarks: Label 'REMARKS';
    V4: Label '(4).........................................................................................';
    Tel: Label 'Tel:';
    Fax: Label 'Fax No:';
    Address: Label '%1 - %2';
    DocNumber: Code[30];
    WitnessText: Label 'OPENED IN THE PRESENCE OF (NAME & SIGN)';
    Ref: Label 'REF:';
    ProcurementRequest: Record "Procurement Request";
    ReturnDate: Date;
    ReturnTime: Time;
    bdlbl1: Label 'You are Invited to Submit Quotation on materials below:';
    bdlbl2: Label 'Notes:';
    bdlbl3: Label '                 (a)   THIS IS NOT AN ORDER.';
    bdlbl31: Label '                        Read the Conditions and Instructions below before quoting.';
    bdlbl4: Label '                 (b)  This quotation should be submitted in a plain wax sealed Envelope marked "Quotation No:"';
    bdlbl41: Label '                        to reach the Buyer or be placed in the Quotation/Tender Box not later than 9:30 AM on ';
    bdlbl5: Label '                 (c)   Your Quotation should indicate Final Unit Price, which includes all costs for Delivery, Discount, Duty and Sales Tax.';
    bdlbl6: Label '                 (d)   Return the Original Copy and Retain the Duplicate for your Record.';
    title: Text;
    procedure GetMonthlyTot(var Periodfrom: Date; var Dept: Code[20])TotMonthReq: Decimal begin
    end;
}

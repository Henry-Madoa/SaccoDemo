page 52203827 "Financial Evaluation Window"
{
    ApplicationArea = All;
    PageType = List;
    SourceTable = "Financial Evaluation";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                }
                field("Quoted Amount"; Rec."Quoted Amount")
                {
                    ApplicationArea = All;
                }
                field("Technical Score"; Rec."Technical Score")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Financial Score"; Rec."Financial Score")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Total Score"; Rec."Total Score")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Award; Rec.Award)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Award Selected Vendor")
            {
                ApplicationArea = All;
                Image = CreateDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    Vendor: Record Vendor;
                begin
                    if not Confirm('Are you sure you to proceed')then exit;
                    if ProcurementRequest.Get(Rec."Reference No.")then begin
                        VendorSelection:=StrMenu(Text0002, 2, 'Choose the type of supplier being awarded');
                        if VendorSelection = 1 then begin
                            FinancialEvaluationII.Reset;
                            FinancialEvaluationII.CalcFields(Award);
                            FinancialEvaluationII.SetRange("Reference No.", ProcurementRequest."No.");
                            FinancialEvaluationII.SetAutoCalcFields(Award);
                            FinancialEvaluationII.SetRange(Award, true);
                            if FinancialEvaluationII.FindFirst then begin
                                Vendor.Reset;
                                Vendor.SetRange(Name, FinancialEvaluationII."Vendor Name");
                                if Vendor.FindFirst then VendorNo:=Vendor."No.";
                            //      ProcurementRequest.TESTFIELD("Vendor No");
                            //      VendorNo:=ProcurementRequest."Vendor No"
                            end;
                        end;
                        if VendorSelection = 2 then VendorNo:='';
                    end;
                    FinancialEvaluation.Reset;
                    FinancialEvaluation.SetRange("Reference No.", Rec."Reference No.");
                    FinancialEvaluation.CalcFields(Award);
                    FinancialEvaluation.SetRange(Award, true);
                    if FinancialEvaluation.FindFirst then begin
                        ReferenceNo:=FinancialEvaluation."Reference No.";
                        TypeSelection:=StrMenu(Text0001, 1, 'Which would you like to create?');
                        if TypeSelection = 1 then begin
                            if ProcurementRequest.Get(FinancialEvaluation."Reference No.")then begin
                                if VendorNo = '' then VendorNoCreated:=ProcStoreManagement.IanCreateVendorToAward(FinancialEvaluation."Vendor Name", '', '', ProcurementRequest."Supplier Category")
                                else
                                    VendorNoCreated:=VendorNo;
                                if VendorNoCreated <> '' then begin
                                    OrderNoCreated:=ProcStoreManagement.IanCreatePurchaseHeader(VendorNoCreated, ProcurementRequest."No.", ProcurementRequest."Requisiton No", '', ProcurementRequest."No.", '', false, ProcurementRequest."Global Dimension 1 Code", ProcurementRequest."Global Dimension 2 Code", ProcurementRequest.Currency, ProcurementRequest.Title, ProcurementRequest."Delivery Period (Days)");
                                    if OrderNoCreated <> '' then begin
                                        ProcurementRequest."Awarded Vendor No":=VendorNoCreated;
                                        ProcurementRequest.Modify(true);
                                        ProcurementRequestLines.Reset;
                                        ProcurementRequestLines.SetRange("Procurement No", ProcurementRequest."No.");
                                        if ProcurementRequestLines.FindSet then begin
                                            repeat ProcStoreManagement.IanCreatePurchaseLines(OrderNoCreated, ProcurementRequestLines.Type, ProcurementRequestLines."No.", ProcurementRequestLines.Quantity, ProcurementRequestLines."Unit Price", ProcurementRequestLines."Location Code", ProcurementRequest."Global Dimension 1 Code", ProcurementRequest."Global Dimension 2 Code", ProcurementRequestLines.Description, 0, '', '', '', '', '', '', '', '', ProcurementRequestLines."Unit of Measure");
                                            until ProcurementRequestLines.Next = 0;
                                        end;
                                    end;
                                end;
                            end;
                        end;
                        if TypeSelection = 2 then begin
                            if ProcurementRequest.Get(FinancialEvaluation."Reference No.")then begin
                                VendorNoCreated:=ProcStoreManagement.IanCreateVendorToAward(FinancialEvaluation."Vendor Name", '', '', ProcurementRequest."Supplier Category");
                                if VendorNoCreated <> '' then begin
                                    Message('Vendor No [%1] has been created ', VendorNoCreated);
                                    ContractNoCreated:=ProcStoreManagement.IanCreateContractHeader(VendorNoCreated, ProcurementRequest."No.", ProcurementRequest."Requisiton No");
                                    if ContractNoCreated <> '' then begin
                                        ProcurementRequest."Awarded Vendor No":=VendorNoCreated;
                                        ProcurementRequest.Modify(true);
                                        ProcurementRequestLines.Reset;
                                        ProcurementRequestLines.SetRange("Procurement No", ProcurementRequest."No.");
                                        if ProcurementRequestLines.FindSet then begin
                                            repeat ProcStoreManagement.IanCreateContractLines(ContractNoCreated, ProcurementRequestLines);
                                            until ProcurementRequestLines.Next = 0;
                                        end;
                                    end;
                                end;
                            end;
                        end;
                    end
                    else
                    begin
                        Message('No Vendor was selected');
                        exit;
                    end;
                    if not ProcurementRequest.Get(ReferenceNo)then exit
                    else
                    begin
                        if(ContractNoCreated <> '')then begin
                            ProcStoreManagement.IanChangeStatusToContractCreated(ProcurementRequest, ContractNoCreated);
                            CurrPage.Close;
                        end;
                        if(OrderNoCreated <> '')then begin
                            ProcStoreManagement.IanChangeStatusToOrderCreated(ProcurementRequest, OrderNoCreated);
                            CurrPage.Close;
                        end;
                    end;
                end;
            }
            action("Get Winner")
            {
                ApplicationArea = All;
                Image = Evaluate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not Confirm('Are you sure you want to get winner')then exit;
                    ProcStoreManagement.IanEndTenderProcess(Rec."Reference No.");
                    Message('Successfully evaluated');
                end;
            }
        }
    }
    var Text0001: Label 'LPO,Contract';
    ProcStoreManagement: Codeunit "Proc & Store Management";
    ProcurementRequest: Record "Procurement Request";
    ProcurementRequestLines: Record "Procurement Request Lines";
    FinancialEvaluation: Record "Financial Evaluation";
    VendorNoCreated: Code[50];
    OrderNoCreated: Code[50];
    ContractNoCreated: Code[50];
    ReferenceNo: Code[50];
    VendorNo: Code[100];
    Text0002: Label 'Pre-Existing,New';
    VendorSelection: Integer;
    TypeSelection: Integer;
    FinancialEvaluationII: Record "Financial Evaluation";
}

page 52203817 "Tender Card"
{
    ApplicationArea = All;
    PageType = Card;
    SourceTable = "Procurement Request";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Title; Rec.Title)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Requisiton No"; Rec."Requisiton No")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Current Budget"; Rec."Current Budget")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Supplier Category"; Rec."Supplier Category")
                {
                    ApplicationArea = All;
                    Editable = CtrlEditable;
                }
                field("Tender Date"; Rec."Tender Opening Date")
                {
                    ApplicationArea = All;
                    Editable = CtrlEditable;
                }
                field("Tender Duration"; Rec."Tender Duration")
                {
                    ApplicationArea = All;
                    Editable = CtrlEditable;
                }
                field("Tender Closing Date"; Rec."Tender Closing Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Extension Period"; Rec."Extension Period")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Extended Closing Date"; Rec."Extended Closing Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Requires Inspection"; Rec."Requires Inspection")
                {
                    ApplicationArea = All;
                    Editable = CtrlEditable;
                }
                field("Delivery Period (Days)"; Rec."Delivery Period (Days)")
                {
                    ApplicationArea = All;
                }
                field("Tender Security Amount"; Rec."Tender Security Amount")
                {
                    ApplicationArea = All;
                    Editable = CtrlEditable;
                }
                field("Tender Max Score"; Rec."Tender Max Score")
                {
                    ApplicationArea = All;
                    Editable = CtrlEditable;
                }
                field("Technical Pass Mark"; Rec."Technical Pass Mark")
                {
                    ApplicationArea = All;
                    Editable = CtrlEditable;
                }
                field("Administrative-Mandatory Score"; Rec."Administrative-Mandatory Score")
                {
                    ApplicationArea = All;
                }
                field("Technical Score"; Rec."Technical Score")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Technical Scores"; Rec."Technical Scores")
                {
                    ApplicationArea = All;
                    Caption = 'Technical Score';
                }
                field("Financial Score"; Rec."Financial Score")
                {
                    ApplicationArea = All;
                }
                field("Technical Total Scores"; Rec."Technical Total Scores")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Technical Evaluation Period"; Rec."Technical Evaluation Period")
                {
                    ApplicationArea = All;
                }
                field("Financial Evaluation Period"; Rec."Financial Evaluation Period")
                {
                    ApplicationArea = All;
                }
                field("Procurement Plan"; Rec."Procurement Plan")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Tender Type"; Rec."Tender Type")
                {
                    ApplicationArea = All;
                    Editable = CtrlEditable;
                }
                field("Vendor No"; Rec."Vendor No")
                {
                    ApplicationArea = All;
                    Visible = Visible;
                }
                field("Minimum No. of Suppliers"; Rec."Minimum No. of Suppliers")
                {
                    ApplicationArea = All;
                }
                field("Date of Financial Evaluation"; Rec."Date of Financial Evaluation")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Date of Technical Evaluation"; Rec."Date of Technical Evaluation")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Date of Mandatory Evaluation"; Rec."Date of Mandatory Evaluation")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Date Advertisement"; Rec."Date Advertisement")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Date Awarded"; Rec."Date Awarded")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Committee Meeting Date"; Rec."Committee Meeting Date")
                {
                    ApplicationArea = All;
                }
                field("Committee Meeting Time"; Rec."Committee Meeting Time")
                {
                    ApplicationArea = All;
                }
                field("Committee Meeting Venue"; Rec."Committee Meeting Venue")
                {
                    ApplicationArea = All;
                }
            }
            part(Control17; "Tender Lines Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Procurement No"=FIELD("No.");
            }
        }
    }
    actions
    {
        area(processing)
        {
            group(Approvals)
            {
                action("Send Approval Request")
                {
                    ApplicationArea = All;
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        Rec.TestField(Status, Rec.Status::Open);
                        Rec.TestField("Tender Type");
                        Rec.TestField(Title);
                        Rec.TestField("Tender Opening Date");
                        Rec.TestField("Tender Duration");
                        Rec.TestField("Tender Security Amount");
                        Rec.TestField("Supplier Category");
                        Rec.TestField("Tender Max Score");
                        Rec.TestField("Technical Pass Mark");
                        if not Confirm('Are you sure you want to send it for approval?')then exit;
                        //            if ApprovalsMgmt.CheckProcurementRequestApprovalsWorkflowEnabled(Rec) then
                        //              ApprovalsMgmt.OnSendProcurementRequestForApproval(Rec);
                        CurrPage.Close();
                    end;
                }
                action("Cancel Approval Request")
                {
                    ApplicationArea = All;
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        Rec.TestField(Status, Rec.Status::"Pending Approval");
                        if not Confirm('Are you sure you want to cancel approval request?')then exit;
                        //          if ApprovalsMgmt.CheckProcurementRequestApprovalsWorkflowEnabled(Rec) then
                        //            ApprovalsMgmt.OnSendProcurementRequestForApproval(Rec);
                        CurrPage.Close();
                    end;
                }
                action(Approve)
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTip = 'Approve the requested changes.';
                    Visible = OpenApprovalEntriesExistCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        if not Confirm('Are you sure you want to Approve the document?')then exit;
                        //          ApprovalsMgmt.ApproveRecordApprovalRequest(RecordId);
                        CurrPage.Close();
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = All;
                    Caption = 'Reject';
                    Image = Reject;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTip = 'Reject the approval request.';
                    Visible = OpenApprovalEntriesExistCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        if not Confirm('Are you sure you want to Reject the document?')then exit;
                        //           ApprovalsMgmt.RejectRecordApprovalRequest(RecordId);
                        CurrPage.Close;
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = All;
                    Caption = 'Delegate';
                    Image = Delegate;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Delegate the approval to a substitute approver.';
                    Visible = OpenApprovalEntriesExistCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        if not Confirm('Are you sure you want to Approve the document?')then exit;
                        //            ApprovalsMgmt.DelegateRecordApprovalRequest(RecordId);
                        CurrPage.Close();
                    end;
                }
                action(Comment)
                {
                    ApplicationArea = All;
                    Caption = 'Comments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'View or add comments for the record.';
                    Visible = OpenApprovalEntriesExistCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.GetApprovalComment(Rec);
                    end;
                }
            }
            group("Tender Processing")
            {
                action(Suppliers)
                {
                    ApplicationArea = All;
                    Image = Vendor;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Tender Bidders";
                    RunPageLink = "Reference No"=FIELD("No.");
                    Visible = SuppliersVisible;
                }
                action(Advertise)
                {
                    ApplicationArea = All;
                    Image = AuthorizeCreditCard;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = AdvertiseTenderVisible;

                    trigger OnAction()
                    var
                        MandatoryRequirements: Record "Mandatory Requirements";
                        TechnicalSpecifications: Record "Technical Specifications";
                    begin
                        Rec.TestField("Administrative-Mandatory Score");
                        Rec.TestField("Technical Score");
                        Rec.TestField("Financial Score");
                        Rec.TestField("Technical Pass Mark");
                        Rec.CalcFields("Technical Total Scores");
                        Rec.TestField("Delivery Period (Days)");
                        if Rec."Technical Total Scores" <> Rec."Technical Score" then Message('The technical score for each technical specification must add up to the maximum technical score specified');
                        if not Confirm('Are you sure you want to advertise this tender?')then exit;
                        MandatoryRequirements.Reset;
                        MandatoryRequirements.SetRange("Reference No", Rec."No.");
                        if not MandatoryRequirements.FindFirst then begin
                            Error('Please add the mandatory requirements for the tender %1', Rec."No.");
                        end
                        else
                            repeat MandatoryRequirements.TestField("Max Weight");
                            until MandatoryRequirements.Next = 0;
                        TechnicalSpecifications.Reset;
                        TechnicalSpecifications.SetRange("Reference No.", Rec."No.");
                        if not TechnicalSpecifications.FindFirst then begin
                            Error('Please add the technical specifications for the tender %1', Rec."No.");
                        end
                        else
                            repeat TechnicalSpecifications.TestField("Max Weigth");
                            until TechnicalSpecifications.Next = 0;
                        ProcStoreManagement.IanMoveTenderToAdvertisementStage(Rec);
                        CurrPage.Close;
                    end;
                }
                action("Mandatory Specifications")
                {
                    ApplicationArea = All;
                    Image = CheckList;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Tender Mandatory Specification";
                    RunPageLink = "Reference No"=FIELD("No.");
                    Visible = MandatoryEvaluationVisible;
                }
                action("Technical Specifications")
                {
                    ApplicationArea = All;
                    Image = CheckList;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Technical Specifications";
                    RunPageLink = "Reference No."=FIELD("No.");
                    Visible = TechnicalEvaluationVisible;
                }
                action("Start Mandatory Evaluation")
                {
                    ApplicationArea = All;
                    Image = Start;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = StartMandatoryVisible;

                    trigger OnAction()
                    begin
                        ProcurementSetup.Get;
                        ProcurementSetup.TestField("Procurement Officer User Id", UserId);
                        if not Confirm('Are you sure you want to start mandatory Evaluation?')then exit;
                        TendSupp.Reset;
                        TendSupp.SetRange("Reference No", Rec."No.");
                        if not TendSupp.FindFirst then begin
                            Error('You have not picked any suppliers for evaluation');
                        end
                        else
                            repeat TendSupp.TestField("Bid Amount");
                            until TendSupp.Next = 0;
                        EvaluationCommittee.Reset;
                        EvaluationCommittee.SetRange("Reference No", Rec."No.");
                        EvaluationCommittee.SetRange(Stage, EvaluationCommittee.Stage::Mandatory);
                        if not EvaluationCommittee.FindFirst then begin
                            Error('Kindly pick the committee members for mandatory evaluation before commencing.');
                        end
                        else
                        begin
                            repeat EvaluationCommittee.TestField("Employee No.");
                                EvaluationCommittee.TestField(Stage);
                            until EvaluationCommittee.Next = 0;
                        end;
                        EvaluationCommitteeII.Reset;
                        EvaluationCommitteeII.SetRange("Reference No", Rec."No.");
                        EvaluationCommitteeII.SetFilter(Stage, '%1|%2|%3', EvaluationCommitteeII.Stage::Financial, EvaluationCommitteeII.Stage::Mandatory, EvaluationCommitteeII.Stage::Technical);
                        if not EvaluationCommitteeII.FindSet then begin
                            Error('Kindly fill in the committee members for all the stages of evaluation.');
                        end;
                        SupplierMandatoryEvaluation.Reset;
                        SupplierMandatoryEvaluation.SetRange("Reference No", Rec."No.");
                        if SupplierMandatoryEvaluation.FindSet then begin
                            SupplierMandatoryEvaluation.DeleteAll;
                        end;
                        ProcStoreManagement.IanStartTenderMandatoryEvaluation(Rec);
                    end;
                }
                action("Mandatory Evaluation Window")
                {
                    ApplicationArea = All;
                    Image = Evaluate;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = MandatoryEvaluationWindowVisible;

                    trigger OnAction()
                    begin
                        if not Confirm('Are you sure you want to open the window?')then exit;
                        ProcurementSetup.Get;
                        if ProcurementSetup."Procurement Officer User Id" = UserId then begin
                            SupplierMandatoryEvaluation.Reset;
                            SupplierMandatoryEvaluation.SetRange("Reference No", Rec."No.");
                            if SupplierMandatoryEvaluation.FindSet then begin
                                Clear(MandatoryEvaluationWindow);
                                MandatoryEvaluationWindow.SetTableView(SupplierMandatoryEvaluation);
                                MandatoryEvaluationWindow.RunModal();
                            end;
                        end;
                        SupplierMandatoryEvaluationII.Reset;
                        SupplierMandatoryEvaluationII.SetRange("Reference No", Rec."No.");
                        SupplierMandatoryEvaluationII.SetRange("Evaluator ID", UserId);
                        if SupplierMandatoryEvaluationII.FindSet then begin
                            Clear(MandatoryEvaluationWindow);
                            MandatoryEvaluationWindow.SetTableView(SupplierMandatoryEvaluationII);
                            MandatoryEvaluationWindow.RunModal();
                        end
                        else
                            Message('You are not part of the evaluators');
                        exit;
                    end;
                }
                action("End Mandatory Evaluation")
                {
                    ApplicationArea = All;
                    Image = Start;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = EndMandatoryVisible;

                    trigger OnAction()
                    begin
                        ProcurementSetup.Get;
                        ProcurementSetup.TestField("Procurement Officer User Id", UserId);
                        if not Confirm('Are you sure you want to End Mandatory Evaluation and Start Technical Evaluation?')then exit;
                        EvaluationCommittee.Reset;
                        EvaluationCommittee.SetRange("Reference No", Rec."No.");
                        EvaluationCommittee.SetRange(Stage, EvaluationCommittee.Stage::Mandatory);
                        EvaluationCommittee.SetRange("Submitted Mandatory Evaluation", false);
                        if EvaluationCommittee.FindFirst then begin
                            Error('Some committee members have not submitted their evaluations');
                        end;
                        SupplierMandatoryEvaluation.Reset;
                        SupplierMandatoryEvaluation.SetRange("Reference No", Rec."No.");
                        SupplierMandatoryEvaluation.SetFilter("Requirement Code", '<>%1', '');
                        SupplierMandatoryEvaluation.SetFilter("Vendor Name", '<>%1', '');
                        SupplierMandatoryEvaluation.SetFilter("Evaluator ID", '<>%1', '');
                        if SupplierMandatoryEvaluation.FindSet then begin
                            repeat if SupplierMandatoryEvaluation.Complied = false then SupplierMandatoryEvaluation.TestField(Comment);
                            until SupplierMandatoryEvaluation.Next = 0;
                        end;
                        SupplierTechnicalEvaluation.Reset;
                        SupplierTechnicalEvaluation.SetRange("Reference No", Rec."No.");
                        if SupplierTechnicalEvaluation.FindSet then begin
                            SupplierTechnicalEvaluation.DeleteAll;
                        end;
                        ProcStoreManagement.IanStartTenderTechnicalEvaluation(Rec);
                    end;
                }
                action("Technical Evaluation Window")
                {
                    ApplicationArea = All;
                    Image = Evaluate;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = TechnicalEvaluationWindowVisible;

                    trigger OnAction()
                    begin
                        ProcurementSetup.Get;
                        if ProcurementSetup."Procurement Officer User Id" = UserId then begin
                            SupplierTechnicalEvaluation.Reset;
                            SupplierTechnicalEvaluation.SetRange("Reference No", Rec."No.");
                            if SupplierTechnicalEvaluation.FindSet then begin
                                Clear(TechnicalEvaluationWindow);
                                TechnicalEvaluationWindow.SetTableView(SupplierTechnicalEvaluation);
                                TechnicalEvaluationWindow.RunModal();
                            end;
                        end;
                        SupplierTechnicalEvaluationII.Reset;
                        SupplierTechnicalEvaluationII.SetRange("Reference No", Rec."No.");
                        SupplierTechnicalEvaluationII.SetRange("Evaluator ID", UserId);
                        if SupplierTechnicalEvaluationII.FindSet then begin
                            Clear(TechnicalEvaluationWindow);
                            TechnicalEvaluationWindow.SetTableView(SupplierTechnicalEvaluationII);
                            TechnicalEvaluationWindow.RunModal();
                        end
                        else
                            Message('You are not part of the evaluators');
                        exit;
                    end;
                }
                action("End Technical Evaluation")
                {
                    ApplicationArea = All;
                    Image = Start;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = EndTechnicalVisible;

                    trigger OnAction()
                    begin
                        ProcurementSetup.Get;
                        ProcurementSetup.TestField("Procurement Officer User Id", UserId);
                        if not Confirm('Are you sure you want to End Technical Evaluation and Start Financial Evaluation?')then exit;
                        EvaluationCommittee.Reset;
                        EvaluationCommittee.SetRange("Reference No", Rec."No.");
                        EvaluationCommittee.SetRange(Stage, EvaluationCommittee.Stage::Technical);
                        EvaluationCommittee.SetRange("Submitted Technical Evaluation", false);
                        if EvaluationCommittee.FindFirst then begin
                            Error('Some committee members have not submitted their evaluations');
                        end;
                        SupplierTechnicalEvaluation.Reset;
                        SupplierTechnicalEvaluation.SetRange("Reference No", Rec."No.");
                        SupplierTechnicalEvaluation.SetFilter("Requirement Code", '<>%1', '');
                        SupplierTechnicalEvaluation.SetFilter("Vendor Name", '<>%1', '');
                        SupplierTechnicalEvaluation.SetFilter("Evaluator ID", '<>%1', '');
                        if SupplierTechnicalEvaluation.FindSet then begin
                            repeat if SupplierTechnicalEvaluation.Score = 0 then SupplierTechnicalEvaluation.TestField(Comment);
                            until SupplierTechnicalEvaluation.Next = 0;
                        end;
                        FinancialEvaluation.Reset;
                        FinancialEvaluation.SetRange("Reference No.", Rec."No.");
                        if FinancialEvaluation.FindSet then begin
                            FinancialEvaluation.DeleteAll;
                        end;
                        ProcStoreManagement.IanStartTenderFinancialEvaluation(Rec);
                    end;
                }
                action("Financial Evaluation Window")
                {
                    ApplicationArea = All;
                    Image = Evaluate;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = FinancialEvaluationWindowVisible;

                    trigger OnAction()
                    begin
                        if not Confirm('Are you sure you want to open the window?')then exit;
                        FinancialEvaluation.Reset;
                        FinancialEvaluation.SetRange("Reference No.", Rec."No.");
                        if FinancialEvaluation.FindFirst then begin
                            Clear(FinancialEvaluationWindow);
                            FinancialEvaluationWindow.SetTableView(FinancialEvaluation);
                            FinancialEvaluationWindow.RunModal;
                        end;
                    end;
                }
                action("Evaluation Committee")
                {
                    ApplicationArea = All;
                    Image = PersonInCharge;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Evaluation Committee Window";
                    RunPageLink = "Reference No"=FIELD("No.");
                    Visible = EvaluatingCommiteeVisible;
                }
                action("Evaluation Report")
                {
                    ApplicationArea = All;
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        TenderSuppliers.Reset;
                        TenderSuppliers.SetRange("Reference No", Rec."No.");
                        REPORT.Run(53059, true, false, TenderSuppliers);
                    end;
                }
                action("Extend Tender")
                {
                    ApplicationArea = All;
                    Image = AdjustEntries;
                    Promoted = true;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        ProcurementSetup.Get;
                        if not Confirm('Are you sure you want to extend the Tender closing Date by %1 ?', true, ProcurementSetup."Tender Extension Period")then exit;
                        ProcRequest.Reset;
                        if ProcRequest.Get(Rec."No.")then begin
                            ProcRequest."Extension Period":=ProcurementSetup."Tender Extension Period";
                            ProcRequest."Extended Closing Date":=CalcDate(ProcurementSetup."Tender Extension Period", ProcRequest."Tender Closing Date");
                            ProcRequest.Modify;
                        end;
                    end;
                }
                action("Report")
                {
                    ApplicationArea = All;
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        Rec.Reset;
                        Rec.SetFilter("No.", Rec."No.");
                        REPORT.Run(53028, true, true, Rec);
                    end;
                }
                action(Attachments)
                {
                    Image = Documents;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                // RunObject = Page "Tender Attachements";
                // RunPageLink = "Document No" = FIELD("No.");
                }
                action("Bid Bonds")
                {
                    ApplicationArea = All;
                    Image = Accounts;
                    Promoted = true;
                    PromotedIsBig = true;
                    RunObject = Page "Tender Bidders-Bond";
                    RunPageLink = "Reference No"=FIELD("No.");
                }
                action("Terminate Tender")
                {
                    Image = Close;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        ProcurementSetup: Record "Purchases & Payables Setup";
                    begin
                        if not Confirm('Are you sure you want to terminate the tender?')then exit;
                        ProcurementSetup.Get;
                        ProcurementSetup.TestField("Procurement Officer User Id", UserId);
                        Clear(TenderTermination);
                        TenderTermination.RunModal;
                        Rec."Terminated By":=UserId;
                        Rec."Date of termination":=TenderTermination.IanGetDate;
                        Rec."Reason For Termination":=TenderTermination.IanGetReasons;
                        Rec."Tender Status":=Rec."Tender Status"::Terminated;
                        if Rec.Modify then Message('Successfully terminated');
                    end;
                }
                action("Create Contract")
                {
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        if not Confirm('Are you sure you want to create a contract for this tender?')then exit;
                        FinancialEvaluationII.Reset;
                        FinancialEvaluationII.SetRange("Reference No.", Rec."No.");
                        FinancialEvaluationII.SetRange(Award, true);
                        FinancialEvaluationII.SetRange("New Vendor No.", '');
                        if FinancialEvaluationII.FindFirst then begin
                            TenderSuppliers.Reset;
                            TenderSuppliers.SetRange("Reference No", FinancialEvaluationII."Reference No.");
                            TenderSuppliers.SetRange("Supplier No.", FinancialEvaluationII."Vendor No");
                            if TenderSuppliers.FindFirst then begin
                                case TenderSuppliers."Bidder Type" of TenderSuppliers."Bidder Type"::"Existing Vendor": begin
                                    FinancialEvaluationII."New Vendor No.":=TenderSuppliers."Supplier No.";
                                    FinancialEvaluationII.Modify(true);
                                end;
                                TenderSuppliers."Bidder Type"::"New Bidder": begin
                                    Message('This is a new bidder, the vendor will be created for you to proceed');
                                    FinancialEvaluationII."New Vendor No.":=ProcStoreManagement.IanCreateVendorFromTenderBidder(FinancialEvaluationII, Rec."No.");
                                    if FinancialEvaluationII.Modify(true)then Message('Vendor %1 has been created successfully', FinancialEvaluationII."New Vendor No.");
                                end;
                                end;
                            end;
                            ProcurementRequestLinesCopy.Reset;
                            ProcurementRequestLinesCopy.SetRange("Procurement No", Rec."No.");
                            if ProcurementRequestLinesCopy.FindSet then begin
                                ContractNo:=ProcStoreManagement.IanCreateContractHeader(FinancialEvaluationII."New Vendor No.", Rec."No.", Rec."Requisiton No");
                                Rec."Contract No Generated":=ContractNo;
                                repeat ProcStoreManagement.IanCreateContractLines(ContractNo, ProcurementRequestLinesCopy);
                                    if Rec."Contract No Generated" <> '' then begin
                                        ProcurementRequestLinesCopy."Order/Contract Created":=true;
                                        ProcurementRequestLinesCopy.Modify(true);
                                    end;
                                until ProcurementRequestLinesCopy.Next = 0;
                            end;
                        end;
                        ContractHeader.Reset;
                        ContractHeader.SetRange("Tender No.", Rec."No.");
                        if ContractHeader.FindFirst then begin
                            ProcStoreManagement.IanChangeStatusToContractCreated(Rec, ContractNo);
                        end;
                    end;
                }
                action("Start Committee Fin. Evaluation")
                {
                    ApplicationArea = All;
                    Image = Evaluate;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = FinancialEvaluationWindowVisible;

                    trigger OnAction()
                    var
                        FinancialEvaluationLocal: Record "Financial Evaluation";
                        FinancialCommiteeEvaluation: Record "Financial Commitee Evaluation";
                        EvaluationCommitteeLocal: Record "Evaluation Committee";
                    begin
                        //ERROR('Under Construction');
                        if not Confirm('Do you want to begin the committee financial evaluation?')then exit;
                        FinancialCommiteeEvaluation.Reset;
                        FinancialCommiteeEvaluation.SetRange("Reference No.", Rec."No.");
                        if FinancialCommiteeEvaluation.FindSet then begin
                            if Confirm('The financial committee is already populated, this action will reset the values. Do you wish to proceed?')then begin
                                FinancialCommiteeEvaluation.DeleteAll;
                            end
                            else
                                exit;
                        end;
                        FinancialEvaluationLocal.Reset;
                        FinancialEvaluationLocal.SetRange("Reference No.", Rec."No.");
                        if FinancialEvaluationLocal.FindSet then begin
                            repeat EvaluationCommitteeLocal.Reset;
                                EvaluationCommitteeLocal.SetRange("Reference No", FinancialEvaluationLocal."Reference No.");
                                EvaluationCommitteeLocal.SetRange(Stage, EvaluationCommitteeLocal.Stage::Financial);
                                if EvaluationCommitteeLocal.FindSet then begin
                                    repeat FinancialCommiteeEvaluation.Init;
                                        FinancialCommiteeEvaluation."Reference No.":=FinancialEvaluationLocal."Reference No.";
                                        FinancialCommiteeEvaluation."Vendor Name":=FinancialEvaluationLocal."Vendor Name";
                                        FinancialCommiteeEvaluation."Quoted Amount":=FinancialEvaluationLocal."Quoted Amount";
                                        FinancialCommiteeEvaluation."Vendor No":=FinancialEvaluationLocal."Vendor No";
                                        FinancialCommiteeEvaluation."Commitee Member ID":=EvaluationCommitteeLocal."User Name";
                                        FinancialCommiteeEvaluation."Comittee Member Name":=EvaluationCommitteeLocal."Employee Name";
                                        FinancialCommiteeEvaluation."Committee Emp. No.":=EvaluationCommitteeLocal."Employee No.";
                                        FinancialCommiteeEvaluation.Insert;
                                    until EvaluationCommitteeLocal.Next = 0;
                                end;
                            until FinancialEvaluationLocal.Next = 0;
                        end;
                    end;
                }
                action("Financial Comm. Eval. Window")
                {
                    ApplicationArea = All;
                    Image = Evaluate;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = FinancialEvaluationWindowVisible;

                    trigger OnAction()
                    var
                        FinancialCommiteeEvaluation: Record "Financial Commitee Evaluation";
                        FinancialCommEvalWindow: Page "Financial  Comm. Eval. Window";
                    begin
                        if not Confirm('Are you sure you want to open the window?')then exit;
                        //ERROR('Under Construction');
                        FinancialCommiteeEvaluation.Reset;
                        FinancialCommiteeEvaluation.SetRange("Reference No.", Rec."No.");
                        if FinancialCommiteeEvaluation.FindFirst then begin
                            Clear(FinancialCommEvalWindow);
                            FinancialCommEvalWindow.SetTableView(FinancialCommiteeEvaluation);
                            FinancialCommEvalWindow.RunModal;
                        end;
                    end;
                }
            }
        }
        area(reporting)
        {
            ToolTip = 'View Tender Reports';

            action("Print Mandatory Eval. Report")
            {
                ApplicationArea = All;
                Image = Print;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not Confirm('Do you want to print the evaluation report?')then exit;
                    TenderSuppliers.Reset;
                    TenderSuppliers.SetRange("Reference No", Rec."No.");
                    if TenderSuppliers.FindFirst then begin
                        REPORT.RunModal(53105, true, false, TenderSuppliers);
                    end;
                end;
            }
            action("Print Technical Eval. Report")
            {
                ApplicationArea = All;
                Image = Print;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not Confirm('Do you want to print the evaluation report?')then exit;
                    TenderSuppliers.Reset;
                    TenderSuppliers.SetRange("Reference No", Rec."No.");
                    if TenderSuppliers.FindFirst then begin
                        REPORT.RunModal(53106, true, false, TenderSuppliers);
                    end;
                end;
            }
            action("Print Financial Eval. Report")
            {
                ApplicationArea = All;
                Image = Print;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not Confirm('Do you want to print the evaluation report?')then exit;
                    TenderSuppliers.Reset;
                    TenderSuppliers.SetRange("Reference No", Rec."No.");
                    if TenderSuppliers.FindFirst then begin
                        REPORT.RunModal(53107, true, false, TenderSuppliers);
                    end;
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        SetControlAppearance();
        IanHeaderEditable;
        FnVisible;
    end;
    trigger OnAfterGetRecord()
    begin
        SetControlAppearance();
    end;
    trigger OnOpenPage()
    begin
        SetControlAppearance();
        IanHeaderEditable;
        FnVisible;
    end;
    var ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    OpenApprovalEntriesExistCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    ProcStoreManagement: Codeunit "Proc & Store Management";
    MandatoryEvaluationWindow: Page "Mandatory Evaluation Window";
    FinancialEvaluationWindow: Page "Financial Evaluation Window";
    TechnicalEvaluationWindow: Page "Technical Evaluation Window";
    SupplierMandatoryEvaluation: Record "Supplier Mandatory Evaluation";
    SupplierTechnicalEvaluation: Record "Supplier Technical Evaluation";
    SupplierMandatoryEvaluationII: Record "Supplier Mandatory Evaluation";
    SupplierTechnicalEvaluationII: Record "Supplier Technical Evaluation";
    NewTenderVisible: Boolean;
    AdvertiseTenderVisible: Boolean;
    MandatoryEvaluationVisible: Boolean;
    TechnicalEvaluationVisible: Boolean;
    MandatoryEvaluationWindowVisible: Boolean;
    TechnicalEvaluationWindowVisible: Boolean;
    FinancialEvaluationWindowVisible: Boolean;
    StartMandatoryVisible: Boolean;
    EndTechnicalVisible: Boolean;
    EndMandatoryVisible: Boolean;
    SuppliersVisible: Boolean;
    EvaluatingCommiteeVisible: Boolean;
    CtrlEditable: Boolean;
    Visible: Boolean;
    TenderSuppliers: Record "Tender Suppliers";
    FinancialEvaluation: Record "Financial Evaluation";
    ProcurementSetup: Record "Purchases & Payables Setup";
    ProcRequest: Record "Procurement Request";
    TenderTermination: Page "Tender Termination";
    TenderCommitteeMembers: Record "Tender Committee Members";
    TendSupp: Record "Tender Suppliers";
    ContractNo: Code[50];
    ProcurementRequestLinesCopy: Record "Procurement Request Lines";
    FinancialEvaluationII: Record "Financial Evaluation";
    ContractHeader: Record "Contract Header";
    EvaluationCommittee: Record "Evaluation Committee";
    EvaluationCommitteeII: Record "Evaluation Committee";
    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    //        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
        //        OpenApprovalEntriesExistCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(RecordId);
        //        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(RecordId);
        if(Rec."Tender Status" in[Rec."Tender Status"::New]) and (not IanCheckForMandatorySpecifications) and (not IanCheckForTechnicalSpecifications)then begin
            AdvertiseTenderVisible:=true;
        end
        else
        begin
            AdvertiseTenderVisible:=false;
        end;
        if not(Rec."Tender Status" in[Rec."Tender Status"::New])then EvaluatingCommiteeVisible:=true
        else
            EvaluatingCommiteeVisible:=false;
        if not(Rec."Tender Status" in[Rec."Tender Status"::New]) and (IanCheckIfMandatoryEvaluationComitteeMembersExist) and (IanCheckIfTechnicalEvaluationComitteeMembersExist)then SuppliersVisible:=true
        else
            SuppliersVisible:=false;
        if(Rec."Tender Status" in[Rec."Tender Status"::Advertised]) and (IanCheckIfSuppliersExist) and (IanCheckIfIsProcurementOfficer)then begin
            StartMandatoryVisible:=true;
        end
        else
        begin
            StartMandatoryVisible:=false;
        end;
        if(Rec."Tender Status" in[Rec."Tender Status"::"Mandatory Req Evaluation"]) and (not IanCheckIfAllSubmittedMandatory)then begin
            MandatoryEvaluationVisible:=true end
        else
        begin
            MandatoryEvaluationVisible:=false;
        end;
        if(Rec."Tender Status" in[Rec."Tender Status"::"Mandatory Req Evaluation"]) and (IanCheckIfAllSubmittedMandatory) and (IanCheckIfIsProcurementOfficer)then begin
            EndMandatoryVisible:=true end
        else
        begin
            EndMandatoryVisible:=false;
        end;
        if(Rec."Tender Status" in[Rec."Tender Status"::"Technical Req Evaluation"]) and (not IanCheckIfAllSubmittedTechnical)then begin
            TechnicalEvaluationVisible:=true end
        else
        begin
            TechnicalEvaluationVisible:=false;
        end;
        if(Rec."Tender Status" in[Rec."Tender Status"::"Technical Req Evaluation"]) and (IanCheckIfAllSubmittedTechnical) and (IanCheckIfIsProcurementOfficer)then begin
            EndTechnicalVisible:=true end
        else
        begin
            EndTechnicalVisible:=false;
        end;
        if(Rec."Tender Status" in[Rec."Tender Status"::"Financial Evaluation"])then begin
            FinancialEvaluationWindowVisible:=true end
        else
        begin
            FinancialEvaluationWindowVisible:=false;
        end;
    end;
    local procedure IanCheckForMandatorySpecifications(): Boolean var
        MandatoryRequirements: Record "Mandatory Requirements";
    begin
        MandatoryRequirements.Reset;
        MandatoryRequirements.SetRange("Reference No", Rec."No.");
        MandatoryRequirements.SetRange("Requirement Description", '');
        exit(MandatoryRequirements.FindFirst);
    end;
    local procedure IanCheckForTechnicalSpecifications(): Boolean var
        TechnicalSpecifications: Record "Technical Specifications";
    begin
        TechnicalSpecifications.Reset;
        TechnicalSpecifications.SetRange("Reference No.", Rec."No.");
        TechnicalSpecifications.SetRange("Requirement Specification", '');
        exit(TechnicalSpecifications.FindFirst);
    end;
    local procedure IanCheckIfAllSubmittedMandatory(): Boolean var
        EvaluationCommittee: Record "Evaluation Committee";
    begin
        EvaluationCommittee.Reset;
        EvaluationCommittee.SetRange("Reference No", Rec."No.");
        EvaluationCommittee.SetRange("Submitted Mandatory Evaluation", false);
        EvaluationCommittee.SetRange(Stage, EvaluationCommittee.Stage::Mandatory);
        exit(EvaluationCommittee.IsEmpty);
    end;
    local procedure IanCheckIfAllSubmittedTechnical(): Boolean var
        EvaluationCommittee: Record "Evaluation Committee";
    begin
        EvaluationCommittee.Reset;
        EvaluationCommittee.SetRange("Reference No", Rec."No.");
        EvaluationCommittee.SetRange("Submitted Technical Evaluation", false);
        EvaluationCommittee.SetRange(Stage, EvaluationCommittee.Stage::Technical);
        exit(EvaluationCommittee.IsEmpty);
    end;
    local procedure IanCheckIfMandatoryEvaluationComitteeMembersExist(): Boolean var
        EvaluationCommittee: Record "Evaluation Committee";
    begin
        EvaluationCommittee.Reset;
        EvaluationCommittee.SetRange("Reference No", Rec."No.");
        EvaluationCommittee.SetRange(Stage, EvaluationCommittee.Stage::Mandatory);
        exit(EvaluationCommittee.FindFirst);
    end;
    local procedure IanCheckIfSuppliersExist(): Boolean var
        TenderSuppliers: Record "Tender Suppliers";
    begin
        TenderSuppliers.Reset;
        TenderSuppliers.SetRange("Reference No", Rec."No.");
        exit(TenderSuppliers.FindFirst);
    end;
    local procedure IanCheckIfTechnicalEvaluationComitteeMembersExist(): Boolean var
        EvaluationCommittee: Record "Evaluation Committee";
    begin
        EvaluationCommittee.Reset;
        EvaluationCommittee.SetRange("Reference No", Rec."No.");
        EvaluationCommittee.SetRange(Stage, EvaluationCommittee.Stage::Technical);
        exit(EvaluationCommittee.FindFirst);
    end;
    local procedure IanCheckIfIsProcurementOfficer(): Boolean var
        ProcurementSetup: Record "Purchases & Payables Setup";
    begin
        ProcurementSetup.Get;
        if ProcurementSetup."Procurement Officer User Id" = UserId then exit(true)
        else
            exit(false);
        exit(ProcurementSetup."Procurement Officer User Id" = UserId);
    end;
    local procedure IanHeaderEditable()
    begin
        CtrlEditable:=true;
        if Rec.Status <> Rec.Status::Open then CtrlEditable:=false;
    end;
    procedure FnVisible(): Boolean var
        ProcurementSetup: Record "Purchases & Payables Setup";
    begin
        ProcurementSetup.Get;
        AdvertiseTenderVisible:=true;
        MandatoryEvaluationVisible:=true;
        TechnicalEvaluationVisible:=true;
        MandatoryEvaluationWindowVisible:=true;
        TechnicalEvaluationWindowVisible:=true;
        FinancialEvaluationWindowVisible:=true;
        StartMandatoryVisible:=true;
        EndMandatoryVisible:=true;
        EndTechnicalVisible:=true;
        SuppliersVisible:=true;
        EvaluatingCommiteeVisible:=true;
        Visible:=false;
        if Rec."Tender Status" = Rec."Tender Status"::"Financial Evaluation" then Visible:=true;
        case Rec."Tender Status" of Rec."Tender Status"::New: begin
            AdvertiseTenderVisible:=true;
            MandatoryEvaluationVisible:=true;
            TechnicalEvaluationVisible:=true;
            SuppliersVisible:=false;
            if ProcurementSetup."Procurement Officer User Id" = UserId then EvaluatingCommiteeVisible:=true
            else
                EvaluatingCommiteeVisible:=false;
            MandatoryEvaluationWindowVisible:=false;
            TechnicalEvaluationWindowVisible:=false;
            FinancialEvaluationWindowVisible:=false;
            StartMandatoryVisible:=false;
            EndMandatoryVisible:=false;
            EndTechnicalVisible:=false;
        end;
        Rec."Tender Status"::Advertised: begin
            AdvertiseTenderVisible:=false;
            MandatoryEvaluationVisible:=false;
            TechnicalEvaluationVisible:=false;
            SuppliersVisible:=true;
            EvaluatingCommiteeVisible:=true;
            StartMandatoryVisible:=true;
            MandatoryEvaluationWindowVisible:=false;
            TechnicalEvaluationWindowVisible:=false;
            FinancialEvaluationWindowVisible:=false;
            EndMandatoryVisible:=false;
            EndTechnicalVisible:=false;
        end;
        Rec."Tender Status"::"Mandatory Req Evaluation": begin
            AdvertiseTenderVisible:=false;
            MandatoryEvaluationVisible:=false;
            TechnicalEvaluationVisible:=false;
            SuppliersVisible:=false;
            if ProcurementSetup."Procurement Officer User Id" = UserId then EvaluatingCommiteeVisible:=true
            else
                EvaluatingCommiteeVisible:=false;
            StartMandatoryVisible:=false;
            MandatoryEvaluationWindowVisible:=true;
            EndMandatoryVisible:=true;
            TechnicalEvaluationWindowVisible:=false;
            EndTechnicalVisible:=false;
            FinancialEvaluationWindowVisible:=false;
        end;
        Rec."Tender Status"::"Technical Req Evaluation": begin
            AdvertiseTenderVisible:=false;
            MandatoryEvaluationVisible:=false;
            TechnicalEvaluationVisible:=false;
            SuppliersVisible:=false;
            if ProcurementSetup."Procurement Officer User Id" = UserId then EvaluatingCommiteeVisible:=true
            else
                EvaluatingCommiteeVisible:=false;
            StartMandatoryVisible:=false;
            MandatoryEvaluationWindowVisible:=false;
            EndMandatoryVisible:=false;
            TechnicalEvaluationWindowVisible:=true;
            EndTechnicalVisible:=true;
            FinancialEvaluationWindowVisible:=false;
        end;
        Rec."Tender Status"::"Financial Evaluation": begin
            AdvertiseTenderVisible:=false;
            MandatoryEvaluationVisible:=false;
            TechnicalEvaluationVisible:=false;
            SuppliersVisible:=false;
            if ProcurementSetup."Procurement Officer User Id" = UserId then EvaluatingCommiteeVisible:=true
            else
                EvaluatingCommiteeVisible:=false;
            StartMandatoryVisible:=false;
            MandatoryEvaluationWindowVisible:=false;
            EndMandatoryVisible:=false;
            TechnicalEvaluationWindowVisible:=false;
            EndTechnicalVisible:=false;
            FinancialEvaluationWindowVisible:=true;
        end;
        Rec."Tender Status"::"Order Created", Rec."Tender Status"::"Contract Created": begin
        end;
        end;
    end;
}

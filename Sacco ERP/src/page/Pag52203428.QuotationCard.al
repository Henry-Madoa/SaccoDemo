page 52203428 "Quotation Card"
{
    DeleteAllowed = false;
    InsertAllowed = false;
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
                field(Currency; Rec.Currency)
                {
                    ApplicationArea = All;
                }
                field("Supplier Category"; Rec."Supplier Category")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Expected Delivery Date"; Rec."Expected Delivery Date")
                {
                    ApplicationArea = All;
                }
                field("RFQ Deadlne Date"; Rec."RFQ Deadline Date")
                {
                    ApplicationArea = All;
                }
                field("RFQ Deadline Time"; Rec."RFQ Deadline Time")
                {
                    ApplicationArea = All;
                }
                field("Delivery Period"; Rec."Delivery Period (Days)")
                {
                    ApplicationArea = All;
                }
                field("Procurement Plan"; Rec."Procurement Plan")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Requires Inspection"; Rec."Requires Inspection")
                {
                    ApplicationArea = All;
                }
                field("Reason For Vendor Selection"; Rec."Reason For Vendor Selection")
                {
                    ApplicationArea = All;
                }
                field("Quotation Status"; Rec."Quotation Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            part(Control17; "Quotation Lines Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Procurement No"=FIELD("No.");
            }
        }
        area(factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID"=CONST(66090), "No."=FIELD("No.");
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
                    Visible = false;

                    trigger OnAction()
                    begin
                        Rec.TestField(Status, Rec.Status::Open);
                        Rec.TestField(Archived, false);
                        if not Confirm('Are you sure you want to send it for approval?')then exit;
                        //                if ApprovalsMgmt.CheckProcurementRequestApprovalsWorkflowEnabled(Rec) then
                        //                  ApprovalsMgmt.OnSendProcurementRequestForApproval(Rec);
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
                    Visible = false;

                    trigger OnAction()
                    begin
                        Rec.TestField(Status, Rec.Status::"Pending Approval");
                        if not Confirm('Are you sure you want to cancel approval request?')then exit;
                        ApprovalEntry.Reset;
                        ApprovalEntry.SetRange("Document No.", Rec."No.");
                        if ApprovalEntry.FindSet then begin
                            ApprovalEntry.DeleteAll;
                            Rec.Status:=Rec.Status::Open;
                            if Rec.Modify(true)then begin
                                Message('Approval has been cancelled');
                            end;
                        end;
                        // IF ApprovalsMgmt.CheckProcurementRequestApprovalsWorkflowEnabled(Rec) THEN
                        //  ApprovalsMgmt.OnCancelProcurementRequestApprovalRequest(Rec);
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
                        //               ApprovalsMgmt.ApproveRecordApprovalRequest(RecordId);
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
                        //            ApprovalsMgmt.RejectRecordApprovalRequest(RecordId);
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
                        //              ApprovalsMgmt.DelegateRecordApprovalRequest(RecordId);
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
            group("Quotation Processing")
            {
                action(Suppliers)
                {
                    ApplicationArea = All;
                    Image = Vendor;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Quotation Bidders";
                    RunPageLink = "Reference No"=FIELD("No."), "Vendor Category"=FIELD("Supplier Category");

                    trigger OnAction()
                    begin
                        Rec.TestField("Supplier Category");
                    end;
                }
                action("Send Quotes")
                {
                    ApplicationArea = All;
                    Image = ProductDesign;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        Rec.TestField(Archived, false);
                        Rec.TestField(Status, Rec.Status::Open);
                        if not Confirm('Are you sure you want to send quotes to vendors?')then exit;
                        ProcStoreManagement.IanChangeStatusOnVendorInvitation(Rec);
                    end;
                }
                action("Send To Portal")
                {
                    ApplicationArea = All;
                    Image = Start;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = false;

                    trigger OnAction()
                    begin
                        Rec.TestField(Archived, false);
                        Rec.TestField(Status, Rec.Status::Open);
                        if not Confirm('Are you sure you want to start mandatory Evaluation?')then exit;
                        ProcStoreManagement.IanStartQuotationEvaluation(Rec);
                    end;
                }
                action(Attachments)
                {
                    ApplicationArea = All;
                    Image = Documents;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    // RunObject = Page "Procurement Attachements";
                    // RunPageLink = "Document No" = FIELD("No.");
                    Visible = false;
                }
                action("Pick Committee Members")
                {
                    ApplicationArea = All;
                    Image = Users;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        Rec.TestField(Archived, false);
                        ProcurementSetup.Get;
                        UserSetup.Get(UserId);
                        if not((ProcurementSetup."Procurement Officer User Id" = UserId) or (UserSetup."Is System Admin"))then Rec.TestField("Quotation Status", Rec."Quotation Status"::"Supplier Invitation");
                        RFQCommitteeMembers.Reset;
                        RFQCommitteeMembers.SetRange("RFQ No.", Rec."No.");
                        PAGE.RunModal(PAGE::"RFQ Committee Members", RFQCommitteeMembers);
                    //"Quotation Status":="Quotation Status"::"Supplier Invitation";
                    end;
                }
                action("Start Commitee Analysis")
                {
                    ApplicationArea = All;
                    Image = Start;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = StartEvaluationVisibility;

                    trigger OnAction()
                    begin
                        Rec.TestField(Archived, false);
                        Rec.TestField("Quotation Status", Rec."Quotation Status"::"Supplier Invitation");
                        if not Confirm('Do you want to initiate the committee evaluation?', true)then exit;
                        RFQCommitteeMembersII.Reset;
                        RFQCommitteeMembersII.SetRange("RFQ No.", Rec."No.");
                        if not RFQCommitteeMembersII.FindFirst then begin
                            Error('You have not picked any committee members for the evaluation');
                        end
                        else
                        begin
                            repeat RFQCommitteeMembersII.TestField("Committee UserID");
                            until RFQCommitteeMembersII.Next = 0;
                        end;
                        ProcLines.Reset;
                        ProcLines.SetRange("Procurement No", Rec."No.");
                        if ProcLines.FindFirst then begin
                            repeat RFQItemSpecifications.Reset;
                                RFQItemSpecifications.SetRange(No, ProcLines."No.");
                                if not RFQItemSpecifications.FindFirst then begin
                                    Error('You have not input any line specifications for No.: %1, Description : %2. Please update to proceed.', ProcLines."No.", ProcLines.Name);
                                end;
                            until ProcLines.Next = 0;
                        end;
                        QuotationBiddersII.Reset;
                        QuotationBiddersII.SetRange("Reference No", Rec."No.");
                        QuotationBiddersII.CalcFields("Total Quoted Amount");
                        QuotationBiddersII.SetFilter("Total Quoted Amount", '<>%1', 0);
                        if not QuotationBiddersII.FindSet then begin
                            Error('The amounts quoted by the vendors have not been entered');
                        end;
                        //****Specify number bidders
                        // ELSE BEGIN
                        //    IF QuotationBiddersII.COUNT < 2 THEN
                        //      ERROR('You need atleast two vendors with quoted amounts');
                        //    END;
                        RFQCommitteeEvaluation.Reset;
                        RFQCommitteeEvaluation.SetRange("RFQ No.", Rec."No.");
                        RFQCommitteeEvaluation.SetRange(Award, true);
                        if RFQCommitteeEvaluation.FindFirst then begin
                            if not Confirm('The committee members have already picked vendors, re-starting evaluation will delete existing data. Do you want to continue?')then exit;
                        end;
                        RFQCommitteeEvaluationII.Reset;
                        RFQCommitteeEvaluationII.SetRange("RFQ No.", Rec."No.");
                        if RFQCommitteeEvaluationII.FindSet then begin
                            RFQCommitteeEvaluationII.DeleteAll;
                        end;
                        QuotationBidders.Reset;
                        QuotationBidders.SetRange("Reference No", Rec."No.");
                        QuotationBidders.CalcFields("Total Quoted Amount");
                        QuotationBidders.SetFilter("Total Quoted Amount", '<>%1', 0);
                        if QuotationBidders.FindSet then begin
                            repeat Message(Format(QuotationBidders."Vendor No."));
                                RFQCommitteeMembers.Reset;
                                RFQCommitteeMembers.SetRange("RFQ No.", QuotationBidders."Reference No");
                                if RFQCommitteeMembers.FindFirst then begin
                                    repeat RFQItemSpecifications.Reset;
                                        RFQItemSpecifications.SetRange("RFQ No.", RFQCommitteeMembers."RFQ No.");
                                        if RFQItemSpecifications.FindFirst then begin
                                            repeat RFQCommitteeEvaluation.Init;
                                                RFQCommitteeEvaluation."RFQ No.":=Rec."No.";
                                                RFQCommitteeEvaluation."Line No."+=10;
                                                RFQCommitteeEvaluation.No:=RFQItemSpecifications.No;
                                                RFQCommitteeEvaluation.Description:=RFQItemSpecifications.Description;
                                                RFQCommitteeEvaluation.Specification:=RFQItemSpecifications.Specification;
                                                RFQCommitteeEvaluation."Vendor No.":=QuotationBidders."Vendor No.";
                                                RFQCommitteeEvaluation."Vendor Name":=QuotationBidders."Vendor Name";
                                                QuotationVendorsBids.Reset;
                                                QuotationVendorsBids.SetRange("Quote No", Rec."No.");
                                                QuotationVendorsBids.SetRange("Vendor No", QuotationBidders."Vendor No.");
                                                QuotationVendorsBids.SetRange("Item No", RFQItemSpecifications.No);
                                                if QuotationVendorsBids.FindFirst then RFQCommitteeEvaluation."Quoted Amount":=QuotationVendorsBids."Quoted Amount";
                                                if RFQCommitteeEvaluation."Quoted Amount" = 0 then RFQCommitteeEvaluation."Quoted Amount":=QuotationVendorsBids."Quoted Amount";
                                                RFQCommitteeEvaluation."Committee Member ID":=RFQCommitteeMembers."Committee UserID";
                                                RFQCommitteeEvaluation."Committee Member No":=RFQCommitteeMembers."Employee No.";
                                                RFQCommitteeEvaluation."Committee Member Name":=RFQCommitteeMembers."Committee Member Name";
                                                RFQCommitteeEvaluation.Insert;
                                            until RFQItemSpecifications.Next = 0;
                                        end;
                                    until RFQCommitteeMembers.Next = 0;
                                end
                                else
                                begin
                                    Error('The Procurement Committee List has not been filled');
                                end;
                            until QuotationBidders.Next = 0;
                        end;
                        //PAGE.RUNMODAL(67135,RFQCommitteeEvaluation);
                        ProcurementRequestII.Reset;
                        ProcurementRequestII.SetRange("No.", Rec."No.");
                        if ProcurementRequestII.FindFirst then begin
                            ProcurementRequestII."RFQ Com. Analysis Initiated":=true;
                            ProcurementRequestII."Quotation Status":=Rec."Quotation Status"::"Quote Submission";
                            if ProcurementRequestII.Modify(true)then begin
                                Message('Committee Analysis has been initiated successfully');
                                CurrPage.Close;
                            end;
                        end;
                    end;
                }
                action("Open Commitee Analysis Window")
                {
                    ApplicationArea = All;
                    Image = OpenWorksheet;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = OpenEvalutionWindowVisility;

                    trigger OnAction()
                    begin
                        Rec.TestField(Archived, false);
                        if Rec."RFQ Com. Analysis Initiated" = false then Error('Please Start Committee Analysis before opening the Committee Analysis Window');
                        ProcurementSetup.Get;
                        if UserSetup.Get(UserId)then begin
                            if((ProcurementSetup."Procurement Officer User Id" = UserId) or (UserSetup."Is System Admin")) = false then begin
                                RFQCommitteeMembersII.Reset;
                                RFQCommitteeMembersII.SetRange("RFQ No.", Rec."No.");
                                RFQCommitteeMembersII.SetRange("Committee UserID", UserId);
                                if not RFQCommitteeMembersII.FindFirst then Error('You are not part of the committee for this RFQ');
                            end;
                        end;
                        RFQCommitteeEvaluation.Reset;
                        RFQCommitteeEvaluation.SetRange("RFQ No.", Rec."No.");
                        PAGE.RunModal(PAGE::"RFQ Committee Evaluation", RFQCommitteeEvaluation);
                    end;
                }
                action("End Evaluation & Get Winning Bid")
                {
                    ApplicationArea = All;
                    Image = PickLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = ChooseBiddersVisibility;

                    trigger OnAction()
                    begin
                        Rec.TestField(Archived, false);
                        // RFQCommitteeMembers.Reset;
                        // RFQCommitteeMembers.SetRange("RFQ No.", Rec."No.");
                        // RFQCommitteeMembers.SetRange("Analysis Completed", false);
                        // if RFQCommitteeMembers.FindFirst then begin
                        //     Error('There are committee members who have not submitted their analysis');
                        // end;
                        //Test if A winner exists
                        ProcurementRequestLines.Reset;
                        ProcurementRequestLines.SetRange("Procurement No", Rec."No.");
                        ProcurementRequestLines.SetFilter("Vendor To Award", '<>%1', '');
                        //if ProcurementRequestLines.FindFirst then //
                        ///ERROR('A winner has already been Indentified');
                         //End of Test
                        if not Confirm('Do you want to selected the vendor picked by the committee?', true)then exit;
                        ProcurementRequestLinesCopy.Reset;
                        ProcurementRequestLinesCopy.SetRange("Procurement No", Rec."No.");
                        if ProcurementRequestLinesCopy.FindFirst then begin
                            repeat QuotationVendorsBidsCopy.Reset;
                                QuotationVendorsBidsCopy.SetRange("Quote No", ProcurementRequestLinesCopy."Procurement No");
                                QuotationVendorsBidsCopy.SetRange("Item No", ProcurementRequestLinesCopy."No.");
                                QuotationVendorsBidsCopy.SetCurrentKey("Committee Selection Count");
                                QuotationVendorsBidsCopy.SetAscending("Committee Selection Count", false);
                                if QuotationVendorsBidsCopy.FindFirst then begin
                                    ProcurementRequestLinesCopy."Vendor To Award":=QuotationVendorsBidsCopy."Vendor No";
                                    ProcurementRequestLinesCopy."Unit Price":=QuotationVendorsBidsCopy."Unit Price";
                                    ProcurementRequestLinesCopy.Validate("Unit Price");
                                    ProcurementRequestLinesCopy.Modify(true);
                                end;
                            until ProcurementRequestLinesCopy.Next = 0;
                        end;
                        // RFQCommitteeEvaluation.RESET;
                        // RFQCommitteeEvaluation.SETRANGE("RFQ No.",Rec."No.");
                        // RFQCommitteeEvaluation.SETRANGE(Award,TRUE);
                        // IF RFQCommitteeEvaluation.FINDFIRST THEN BEGIN
                        // //  REPEAT
                        //    RFQCommitteeEvaluation.TESTFIELD("Quoted Amount");
                        //    QuotationVendorsBids.RESET;
                        //    QuotationVendorsBids.SETRANGE("Vendor No",RFQCommitteeEvaluation."Vendor No.");
                        //    IF QuotationVendorsBids.FINDFIRST THEN BEGIN
                        //      REPEAT
                        //        ProcurementRequestLinesCopy.RESET;
                        //        ProcurementRequestLinesCopy.SETRANGE("Procurement No",QuotationVendorsBids."Quote No");
                        //        ProcurementRequestLinesCopy.SETRANGE("Line No.",QuotationVendorsBids."Line No");
                        //        IF ProcurementRequestLinesCopy.FINDFIRST THEN BEGIN
                        //          REPEAT
                        //            ProcurementRequestLinesCopy."Vendor To Award" := RFQCommitteeEvaluation."Vendor No.";
                        // //            RFQCommitteeEvaluation.CALCFIELDS("Unit Price");
                        //            ProcurementRequestLinesCopy."Unit Price" := QuotationVendorsBids."Unit Price";
                        //            ProcurementRequestLinesCopy.VALIDATE("Unit Price");
                        //            ProcurementRequestLinesCopy.MODIFY(TRUE);
                        //            UNTIL ProcurementRequestLinesCopy.NEXT = 0;
                        //          END;
                        //        UNTIL QuotationVendorsBids.NEXT = 0;
                        //      END;
                        // //    UNTIL RFQCommitteeEvaluation.NEXT = 0;
                        //  END;
                        Message('Process successfully completed');
                    end;
                }
                action("End Evaluation & Suggest Winner")
                {
                    ApplicationArea = All;
                    Enabled = false;
                    Image = CalculateLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    //Visible = false;
                    trigger OnAction()
                    begin
                        Rec.TestField(Archived, false);
                        RFQCommitteeMembers.Reset;
                        RFQCommitteeMembers.SetRange("RFQ No.", Rec."No.");
                        RFQCommitteeMembers.SetRange("Analysis Completed", false);
                        if RFQCommitteeMembers.FindFirst then begin
                            Error('There are committee members who have not submitted their analysis');
                        end;
                        //Test if A winner exists
                        ProcurementRequestLines.Reset;
                        ProcurementRequestLines.SetRange("Procurement No", Rec."No.");
                        ProcurementRequestLines.SetFilter("Vendor To Award", '<>%1', '');
                        if ProcurementRequestLines.FindFirst then Error('A winner has already been Indentified');
                        //End of Test
                        if not Confirm('Are you sure you want to end the evaluation stage and suggest the winner(Least quoted amount)?')then exit;
                        ProcurementRequestLines.Reset;
                        ProcurementRequestLines.SetRange("Procurement No", Rec."No.");
                        if ProcurementRequestLines.FindSet then begin
                            repeat Winner:=ProcStoreManagement.IanGetTheLeastQuotedAmount(ProcurementRequestLines."Procurement No", ProcurementRequestLines."No.");
                                WinnerAmount:=ProcStoreManagement.IanGetTheLeastQuotedVendorAmount(ProcurementRequestLines."Procurement No", ProcurementRequestLines."No.");
                                ProcurementRequestLines."Vendor To Award":=Winner;
                                ProcurementRequestLines."Unit Price":=WinnerAmount;
                                ProcurementRequestLines.Validate("Unit Price");
                                ProcurementRequestLines.Modify(true);
                            until ProcurementRequestLines.Next = 0;
                        end;
                        Message('Process successfully completed');
                    end;
                }
                action("Award & Generate Order")
                {
                    ApplicationArea = All;
                    Image = "Order";
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = AwardGenerateOrderVisibility;

                    trigger OnAction()
                    begin
                        Rec.TestField(Archived, false);
                        Rec.TestField("Reason For Vendor Selection");
                        //Rec.TestField(Currency);
                        if Rec."Quotation Status" = Rec."Quotation Status"::"Order Created" then Error('Purchase orders have been generated');
                        if not Confirm('Are you sure you want to create purchase order for the awarded vendors?')then exit;
                        VendorsAwardedRFQ.Reset;
                        VendorsAwardedRFQ.SetRange("RFQ No.", Rec."No.");
                        if VendorsAwardedRFQ.FindSet then VendorsAwardedRFQ.DeleteAll;
                        ProcLineII.Reset;
                        ProcLineII.SetRange("Procurement No", Rec."No.");
                        if ProcLineII.FindFirst then begin
                            repeat ProcLineII.TestField("No.");
                                ProcLineII.TestField(Quantity);
                                ProcLineII.TestField("Unit of Measure");
                                VendorsAwardedRFQ.Reset;
                                VendorsAwardedRFQ.SetRange("RFQ No.", ProcLineII."Procurement No");
                                VendorsAwardedRFQ.SetRange("Vendor Awarded.", ProcLineII."Vendor To Award");
                                if not VendorsAwardedRFQ.FindSet then begin
                                    VendorsAwardedRFQ.Init;
                                    VendorsAwardedRFQ."RFQ No.":=ProcLineII."Procurement No";
                                    VendorsAwardedRFQ."Vendor Awarded.":=ProcLineII."Vendor To Award";
                                    VendorsAwardedRFQ.Insert;
                                end;
                            until ProcLineII.Next = 0;
                        end;
                        VendorsAwardedRFQ.Reset;
                        VendorsAwardedRFQ.SetRange("RFQ No.", Rec."No.");
                        if VendorsAwardedRFQ.FindFirst then begin
                            //ERROR(FORMAT(VendorsAwardedRFQ."RFQ No."));
                            repeat OrderNo:=ProcStoreManagement.IanCreatePurchaseHeader(VendorsAwardedRFQ."Vendor Awarded.", '', Rec."Requisiton No", Rec."No.", '', '', Rec."Requires Inspection", Rec."Global Dimension 1 Code", Rec."Global Dimension 2 Code", Rec.Currency, Rec.Title, Rec."Delivery Period (Days)");
                                ProcLineIII.Reset;
                                ProcLineIII.SetRange("Vendor To Award", VendorsAwardedRFQ."Vendor Awarded.");
                                ProcLineIII.SetRange("Procurement No", VendorsAwardedRFQ."RFQ No.");
                                if ProcLineIII.FindSet then // BEGIN
 repeat // MESSAGE('%1 , %2',ProcLineIII."Procurement No",ProcLineIII.No);
 ProcStoreManagement.IanCreatePurchaseLines(OrderNo, ProcLineIII.Type, ProcLineIII."No.", ProcLineIII.Quantity, ProcLineIII."Unit Price", ProcLineIII."Location Code", Rec."Global Dimension 1 Code", Rec."Global Dimension 2 Code", ProcLineIII.Name, 0, '', '', '', '', '', '', '', '', ProcLineIII."Unit of Measure");
                                        if OrderNo <> '' then begin
                                            ProcLineIII."Order/Contract Created":=true;
                                            ProcLineIII.Modify(true);
                                        end;
                                    until ProcLineIII.Next = 0;
                            // END;
                            until VendorsAwardedRFQ.Next = 0;
                        end;
                        ProcurementRequestLines.Reset;
                        ProcurementRequestLines.SetRange("Order/Contract Created", true);
                        if ProcurementRequestLinesCopy.FindFirst then begin
                            ProcStoreManagement.IanChangeStatusOnQuotationAward(Rec, OrderNo);
                        end;
                        CurrPage.Close;
                    end;
                }
                action("Print Quote")
                {
                    ApplicationArea = All;
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        ProcurementRequest.Reset;
                        ProcurementRequest.SetRange("No.", Rec."No.");
                        if ProcurementRequest.FindFirst then begin
                            REPORT.RunModal(53026, true, false, ProcurementRequest);
                        end;
                    end;
                }
                action("Print Quotation Analysis")
                {
                    ApplicationArea = All;
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        Rec.TestField("Reason For Vendor Selection");
                        RFQCommitteeEvaluation.Reset;
                        RFQCommitteeEvaluation.SetRange("RFQ No.", Rec."No.");
                        if RFQCommitteeEvaluation.FindFirst then begin
                            REPORT.RunModal(53104, true, false, RFQCommitteeEvaluation);
                        end;
                    end;
                }
                action("Re-Open Invitation")
                {
                    ApplicationArea = All;
                    Image = ReopenCancelled;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = ReOpenInvitationVisible;

                    trigger OnAction()
                    begin
                        ProcurementSetup.Get;
                        ProcurementSetup.TestField("Procurement Officer User Id");
                        if UserId <> ProcurementSetup."Procurement Officer User Id" then Error('You are not allowed to re-open the Invitation. Contact the procurement manager for this task.');
                        if Rec."Quotation Status" in[Rec."Quotation Status"::"Order Created"]then Error('The quote has already been used to create an LPO. You cannot re-open it.');
                        if not Confirm('Are you sure you want to re-open the Quote?')then exit;
                        ProcurementRequestCopy.Reset;
                        ProcurementRequestCopy.SetRange("No.", Rec."No.");
                        if ProcurementRequestCopy.FindFirst then begin
                            ProcurementRequestCopy.TestField("Quotation Status", ProcurementRequestCopy."Quotation Status"::"Supplier Invitation");
                            ProcurementRequestCopy."Quotation Status":=ProcurementRequestCopy."Quotation Status"::New;
                            if ProcurementRequestCopy.Modify(true)then begin
                                QuotationBidders.Reset;
                                QuotationBidders.SetRange("Reference No", ProcurementRequestCopy."No.");
                                if QuotationBidders.FindSet then begin
                                    repeat QuotationBidders."Email Sent":=false;
                                        QuotationBidders.Modify(true);
                                    until QuotationBidders.Next = 0;
                                end;
                            end;
                        end;
                        QuotationBiddersCopy.Reset;
                        QuotationBiddersCopy.SetRange("Reference No", Rec."No.");
                        QuotationBiddersCopy.SetRange("Email Sent", true);
                        if not QuotationBiddersCopy.FindFirst then begin
                            Message('Quote has successfully been opened');
                        end;
                        CurrPage.Close;
                    end;
                }
                action("Archive Document")
                {
                    ApplicationArea = All;
                    Image = History;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        if Rec."Quotation Status" = Rec."Quotation Status"::"Order Created" then Error('You cannot archive a document with the purchase order already generated.');
                        if not Confirm('Do you want to archive document no. %1', true, Rec."No.")then exit;
                        //                    IanSoftFactory.IanArchiveProcurementDocument(Rec, Rec."No.", UserId);
                        CurrPage.Close;
                    end;
                }
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        IanSetControlAppearance();
    end;
    trigger OnAfterGetRecord()
    begin
        IanSetControlAppearance();
    end;
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Status:=Rec.Status::Open;
        Rec."Procurement Method":=Rec."Procurement Method"::RFQ;
    end;
    trigger OnOpenPage()
    begin
        IanSetControlAppearance();
        ControlVisibility;
    end;
    var ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    OpenApprovalEntriesExistCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    ProcurementRequestLines: Record "Procurement Request Lines";
    ProcurementRequestLinesCopy: Record "Procurement Request Lines";
    ProcStoreManagement: Codeunit "Proc & Store Management";
    OrderNo: Code[50];
    Winner: Code[50];
    StartEvaluationVisible: Boolean;
    EndEvaluationVisible: Boolean;
    AwardWinnerVisible: Boolean;
    ProReq: Record "Procurement Request";
    Inspection: Boolean;
    RFQCommitteeEvaluation: Record "RFQ Committee Evaluation";
    ProcurementRequest: Record "Procurement Request";
    ConfirmManagement: Codeunit "Confirm Management";
    StartEvaluationVisibility: Boolean;
    OpenEvalutionWindowVisility: Boolean;
    ChooseBiddersVisibility: Boolean;
    AwardGenerateOrderVisibility: Boolean;
    RFQCommitteeMembers: Record "RFQ Committee Members";
    WinnerAmount: Decimal;
    QuotationBidders: Record "Quotation Bidders";
    TotalQuotedAmount: Decimal;
    ProcurementRequestCopy: Record "Procurement Request";
    ReOpenInvitationVisible: Boolean;
    ApprovalEntry: Record "Approval Entry";
    QuotationVendorsBids: Record "Quotation Vendors Bids";
    RFQItemSpecifications: Record "RFQ Item Specifications";
    ProcLines: Record "Procurement Request Lines";
    RFQCommitteeMembersII: Record "RFQ Committee Members";
    ProcLineII: Record "Procurement Request Lines";
    ProcLineIII: Record "Procurement Request Lines";
    VendorsAwardedRFQ: Record "Vendors Awarded RFQ";
    QuotationBiddersCopy: Record "Quotation Bidders";
    ProcurementSetup: Record "Purchases & Payables Setup";
    PurchaseHeader: Record "Purchase Header";
    UserSetup: Record "User Setup";
    RFQCommitteeEvaluationII: Record "RFQ Committee Evaluation";
    QuotationBiddersII: Record "Quotation Bidders";
    QuotationVendorsBidsCopy: Record "Quotation Vendors Bids";
    ProcurementRequestII: Record "Procurement Request";
    //      IanSoftFactory: Codeunit IanSoftFactory;
    local procedure IanSetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    //        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
        //        OpenApprovalEntriesExistCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(RecordId);
        //        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(RecordId);
        if Rec."Quotation Status" in[Rec."Quotation Status"::"Supplier Invitation"]then StartEvaluationVisible:=true
        else
            StartEvaluationVisible:=false;
        if(IanCheckIfWinnersAreSuggested) and (Rec."Quotation Status" in[Rec."Quotation Status"::"Quote Submission"]) and (Rec."Generated Order No" = '')then AwardWinnerVisible:=true
        else
            AwardWinnerVisible:=false;
        if(IanCheckIfBidsHaveBeenSubmitted) and (Rec."Quotation Status" in[Rec."Quotation Status"::"Quote Submission"]) and (Rec."Generated Order No" = '') and not(IanCheckIfWinnersAreSuggested)then EndEvaluationVisible:=true
        else
            EndEvaluationVisible:=false;
    end;
    local procedure IanCheckIfWinnersAreSuggested(): Boolean var
        ProcurementRequestLinesLocal: Record "Procurement Request Lines";
    begin
        ProcurementRequestLinesLocal.Reset;
        ProcurementRequestLinesLocal.SetRange("Procurement No", Rec."No.");
        ProcurementRequestLinesLocal.SetFilter("Vendor To Award", '<>%1', '');
        exit(ProcurementRequestLinesLocal.FindFirst);
    end;
    local procedure IanCheckIfBidsHaveBeenSubmitted(): Boolean var
        QuotationBidders: Record "Quotation Bidders";
    begin
        QuotationBidders.Reset;
        QuotationBidders.SetRange("Reference No", Rec."No.");
        QuotationBidders.CalcFields("Total Quoted Amount");
        QuotationBidders.SetFilter("Total Quoted Amount", '<>%1', 0);
        exit(QuotationBidders.FindFirst);
    end;
    local procedure ControlVisibility(): Boolean begin
        StartEvaluationVisibility:=false;
        OpenEvalutionWindowVisility:=false;
        ChooseBiddersVisibility:=false;
        ReOpenInvitationVisible:=false;
        AwardGenerateOrderVisibility:=false;
        if(Rec."Quotation Status" = Rec."Quotation Status"::New) and (Rec."RFQ Com. Analysis Initiated" = false)then begin
            StartEvaluationVisibility:=false;
            OpenEvalutionWindowVisility:=false;
            ChooseBiddersVisibility:=false;
            ReOpenInvitationVisible:=false;
            AwardGenerateOrderVisibility:=false;
        end
        else if(Rec."Quotation Status" = Rec."Quotation Status"::"Supplier Invitation") and (Rec."RFQ Com. Analysis Initiated" = false)then begin
                StartEvaluationVisibility:=true;
                OpenEvalutionWindowVisility:=false;
                ChooseBiddersVisibility:=false;
                ReOpenInvitationVisible:=true;
                AwardGenerateOrderVisibility:=false;
            end
            else if(Rec."Quotation Status" = Rec."Quotation Status"::"Supplier Invitation") and (Rec."RFQ Com. Analysis Initiated" = true)then begin
                    StartEvaluationVisibility:=false;
                    OpenEvalutionWindowVisility:=true;
                    ChooseBiddersVisibility:=false;
                    ReOpenInvitationVisible:=true;
                    AwardGenerateOrderVisibility:=false;
                end
                else if(Rec."Quotation Status" = Rec."Quotation Status"::"Quote Submission") and (Rec."RFQ Com. Analysis Initiated" = false)then begin
                        StartEvaluationVisibility:=false;
                        OpenEvalutionWindowVisility:=true;
                        ChooseBiddersVisibility:=true;
                        ReOpenInvitationVisible:=false;
                        AwardGenerateOrderVisibility:=true;
                    end
                    else if(Rec."Quotation Status" = Rec."Quotation Status"::"Quote Submission") and (Rec."RFQ Com. Analysis Initiated" = true)then begin
                            StartEvaluationVisibility:=false;
                            OpenEvalutionWindowVisility:=true;
                            ChooseBiddersVisibility:=true;
                            ReOpenInvitationVisible:=false;
                            AwardGenerateOrderVisibility:=true;
                        end
                        else if(Rec."Quotation Status" = Rec."Quotation Status"::"Order Created") and (Rec."RFQ Com. Analysis Initiated" = true)then begin
                                StartEvaluationVisibility:=false;
                                OpenEvalutionWindowVisility:=false;
                                ChooseBiddersVisibility:=false;
                                ReOpenInvitationVisible:=false;
                                AwardGenerateOrderVisibility:=false;
                            end;
    end;
    local procedure CheckPermissionLevel(): Boolean var
        UserSetup: Record "User Setup";
        ProcurementSetup: Record "Purchases & Payables Setup";
        Allowed: Boolean;
    begin
        Allowed:=false;
    end;
}

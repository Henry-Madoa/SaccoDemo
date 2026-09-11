page 52203853 "Direct Procurement Card"
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
                }
                field(Status; Rec.Status)
                {
                }
                field(Title; Rec.Title)
                {
                }
                field("Requisiton No"; Rec."Requisiton No")
                {
                }
                field("Current Budget"; Rec."Current Budget")
                {
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                }
                field("RFQ Deadlne Date"; Rec."RFQ Deadline Date")
                {
                    Caption = 'Deadline Date';
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                }
                field(Currency; Rec.Currency)
                {
                }
                field("Generated Order No"; Rec."Generated Order No")
                {
                    Editable = false;
                }
            }
            group("Vendor Details")
            {
                field("Vendor No"; Rec."Vendor No")
                {
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    Editable = false;
                }
                field("Delivery Period"; Rec."Delivery Period (Days)")
                {
                }
                field("Reason For Vendor Selection"; Rec."Reason For Vendor Selection")
                {
                }
            }
            part(Control17; "D.P Lines Subform")
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
                    Visible = true;

                    trigger OnAction()
                    begin
                        Rec.TestField(Status, Rec.Status::Open);
                        if not Confirm('Are you sure you want to send it for approval?')then exit;
                        //              if ApprovalsMgmt.CheckProcurementRequestApprovalsWorkflowEnabled(Rec) then
                        //               ApprovalsMgmt.OnSendProcurementRequestForApproval(Rec);
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
                    Visible = true;

                    trigger OnAction()
                    begin
                        Rec.TestField(Status, Rec.Status::"Pending Approval");
                        if not Confirm('Are you sure you want to cancel approval request?')then exit;
                        //              if ApprovalsMgmt.CheckProcurementRequestApprovalsWorkflowEnabled(Rec) then
                        //                ApprovalsMgmt.OnSendProcurementRequestForApproval(Rec);
                        CurrPage.Close();
                    end;
                }
                action("Manual Approve")
                {
                    ApplicationArea = All;
                    Caption = 'Manual Approve';
                    Enabled = Rec.Status <> Rec.Status::Approved;
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        RequisitionLines: Record "Requisition Lines";
                    begin
                        Rec.Status:=Rec.Status::Approved;
                        Rec.Modify(true);
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
                        //            ApprovalsMgmt.ApproveRecordApprovalRequest(RecordId);
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
                        //                 ApprovalsMgmt.RejectRecordApprovalRequest(RecordId);
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
            group("Tender Processing")
            {
                action("Award & Generate Order")
                {
                    ApplicationArea = All;
                    Image = "Order";
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        //TESTFIELD(Status,Status::Approved);
                        //Rec.TestField("Direct Procurement Status", Rec."Direct Procurement Status"::"Email Sent");
                        Rec.TestField("Vendor No");
                        Rec.TestField(Archived, false);
                        Rec.TestField("Delivery Period (Days)");
                        Rec.TestField("Reason For Vendor Selection");
                        if not Confirm('Are you sure you want to create purchase order for the awarded vendors?')then exit;
                        OrderNo:=ProcStoreManagement.IanCreatePurchaseHeader(Rec."Vendor No", '', Rec."Requisiton No", '', Rec."No.", '', Rec."Requires Inspection", Rec."Global Dimension 1 Code", Rec."Global Dimension 2 Code", Rec.Currency, Rec.Title, Rec."Delivery Period (Days)");
                        ProcurementRequestLines.Reset;
                        ProcurementRequestLines.SetRange("Procurement No", Rec."No.");
                        if ProcurementRequestLines.FindSet then begin
                            repeat //ProcurementRequestLines.TESTFIELD(No);
 ProcStoreManagement.IanCreatePurchaseLines(OrderNo, ProcurementRequestLines.Type, ProcurementRequestLines."No.", ProcurementRequestLines.Quantity, ProcurementRequestLines."Unit Price", ProcurementRequestLines."Location Code", Rec."Global Dimension 1 Code", Rec."Global Dimension 2 Code", ProcurementRequestLines.Description, 0, '', '', '', '', '', '', '', '', ProcurementRequestLines."Unit of Measure");
                                if OrderNo <> '' then begin
                                    ProcurementRequestLines."Order/Contract Created":=true;
                                    ProcurementRequestLines.Modify(true);
                                end;
                            until ProcurementRequestLines.Next = 0;
                        end;
                        ProcurementRequestLines.Reset;
                        ProcurementRequestLines.SetRange("Order/Contract Created", true);
                        if ProcurementRequestLinesCopy.FindFirst then begin
                            ProcStoreManagement.IanChangeStatusOnDirectProcAward(Rec, OrderNo);
                        end;
                        CurrPage.Close;
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
                        ProcurementRequest.Reset;
                        ProcurementRequest.SetRange("No.", Rec."No.");
                        if ProcurementRequest.FindFirst then begin
                            REPORT.RunModal(53092, true, false, ProcurementRequest);
                        end;
                    end;
                }
                action("Send Email To Vendor")
                {
                    ApplicationArea = All;
                    Image = MailAttachment;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        Rec.TestField("Vendor No");
                        Rec.TestField(Archived, false);
                        Rec.TestField("Reason For Vendor Selection");
                        if not Confirm('Do you want to email vendor %1?', true, Rec."Vendor Name")then exit;
                        SendEmailToVendor(Rec, Rec."No.");
                        Rec."Direct Procurement Status":=Rec."Direct Procurement Status"::"Email Sent";
                        Rec.Modify(true);
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
                        if Rec."Direct Procurement Status" = Rec."Direct Procurement Status"::"Order Created" then Error('You cannot archive a document with the purchase order already generated.');
                        if not Confirm('Do you want to archive document no. %1', true, Rec."No.")then exit;
                        //                   IanSoftFactory.IanArchiveProcurementDocument(Rec, Rec."No.", UserId);
                        CurrPage.Close;
                    end;
                }
            }
        }
    }
    var ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    OpenApprovalEntriesExistCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    ProcurementRequestLines: Record "Procurement Request Lines";
    ProcurementRequestLinesCopy: Record "Procurement Request Lines";
    ProcStoreManagement: Codeunit "Proc & Store Management";
    OrderNo: Code[50];
    Winner: Code[50];
    ProcurementRequest: Record "Procurement Request";
    Category: Code[50];
    //        IanSoftFactory: Codeunit IanSoftFactory;
    local procedure SetControlAppearance()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    //      WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
    //      OpenApprovalEntriesExistCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(RecordId);
    //      OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(RecordId);
    end;
    local procedure SendEmailToVendor(var ProcurementRequest: Record "Procurement Request"; DocumentNo: Code[30])
    var
        Vendor: Record Vendor;
        FileManagement: Codeunit "File Management";
        SMTPMail: Codeunit Mail;
        //        DirectProcurementReport: Report "Direct Procurement Report";
        SenderName: Text;
        SenderAddress: Text;
        Recepient: Text;
        CCRecepient: Text;
        Subject: Text;
        Body: Text;
        FilePath: Text;
        FileName: Text;
        Text001: Label 'C:\Vendors\DirectProc.pdf';
        Company: Record "Company Information";
        ProcurementRequestCopy: Record "Procurement Request";
    begin
        ProcurementRequest.Reset();
        begin
            if Vendor.Get(ProcurementRequest."Vendor No")then begin
                Vendor.TestField("E-Mail");
                FilePath:='';
                //      if not FileManagement.ServerDirectoryExists(Text001) then
                //        FileManagement.ServerCreateDirectory(Text001);
                FilePath:=Text001 + ' ' + ProcurementRequest."No." + ' ' + ProcurementRequest."Vendor Name" + '.PDF';
                FileName:=ProcurementRequest."No." + ' ' + ProcurementRequest."Vendor Name" + ' ' + 'proc.pdf';
                //             Clear(DirectProcurementReport);
                ProcurementRequestCopy.Reset;
                ProcurementRequestCopy.SetRange("No.", DocumentNo);
                if ProcurementRequestCopy.FindFirst then begin
                    //                 DirectProcurementReport.SetTableView(ProcurementRequestCopy);
                    //        DirectProcurementReport.SaveAsPdf(FilePath);
                    //        REPORT.SaveAsPdf(REPORT::"Direct Procurement Report",FileName,ProcurementRequestCopy);
                    // SMTPMailSetup.Get;
                    // SenderAddress := SMTPMailSetup."From Address";
                    // SenderName := SMTPMailSetup."From Name";
                    Subject:='Invitation For Supply of Goods/Service.';
                    Recepient:=Vendor."E-Mail";
                    if Company.Get(CompanyName)then begin
                        Company.TestField("Procurement Email");
                        CCRecepient:=Company."Procurement Email";
                    end;
                    Body:='Dear ' + Format(ProcurementRequest."Vendor Name") + ',' + '<br> You have been invited to supply goods/services in the quoted document.' + ' Please fill in the attached form and submit your quote <br>' + '<Br>Regards,' + '<br>Procurement,' + '<br>' + Format(Company.Name) + '.';
                    if(SenderName <> '') and (SenderAddress <> '') and (Recepient <> '') and (Subject <> '') and (Body <> '')then begin
                        SMTPMail.CreateMessage(Recepient, CCRecepient, '', Subject, Body, true, true);
                        //SMTPMail.AddCC(CCRecepient);
                        //        SMTPMail.AttachFile(FilePath,FileName);
                        //        SMTPMail.Send();
                        //        if Exists(FilePath) then
                        //          Erase(FilePath);
                        Message('E-mail sent successfully');
                    end;
                end;
            end;
        end;
    end;
}

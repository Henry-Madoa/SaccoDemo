page 52203836 "Quotation Bidders"
{
    PageType = List;
    SourceTable = "Quotation Bidders";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Reference No"; Rec."Reference No")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    Editable = PageEditableFields;
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                    Editable = PageEditableFields;
                }
                field("E-mail Address"; Rec."E-mail Address")
                {
                    ApplicationArea = All;
                    Editable = PageEditableFields;
                }
                field("Phone No"; Rec."Phone No")
                {
                    ApplicationArea = All;
                    Editable = PageEditableFields;
                }
                field("Total Quoted Amount"; Rec."Total Quoted Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Delivery Period"; Rec."Delivery Period")
                {
                    ApplicationArea = All;
                    Caption = 'Delivery Period (D,W,M)';
                }
                field("Committee Selection Count"; Rec."Committee Selection Count")
                {
                    ApplicationArea = All;
                }
                field("Email Sent"; Rec."Email Sent")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Vendor Category"; Rec."Vendor Category")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Email Quotation To Vendors")
            {
                Image = SendMail;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                //Visible = EmailSuppliersVisible;
                trigger OnAction()
                var
                begin
                    ProcurementRequest.Reset;
                    ProcurementRequest.SetRange("No.", Rec."Reference No");
                    if ProcurementRequest.FindFirst then begin
                        ProcurementRequest.TestField("Expected Delivery Date");
                        ProcurementRequest.TestField("RFQ Deadline Date");
                        ProcurementRequest.TestField("RFQ Deadline Time");
                        ProcurementRequest.TestField("Delivery Period (Days)");
                    end;
                    ProcurementRequestLines.Reset;
                    ProcurementRequestLines.SetRange("Procurement No", Rec."Reference No");
                    if ProcurementRequestLines.FindFirst then begin
                        repeat RFQItemSpecifications.Reset;
                            RFQItemSpecifications.SetRange("RFQ No.", ProcurementRequestLines."Procurement No");
                            RFQItemSpecifications.SetRange(No, ProcurementRequestLines."No.");
                            if not RFQItemSpecifications.FindFirst then begin
                                Error('Kindly update specifications for item No.: %1 Description : %2', ProcurementRequestLines."No.", ProcurementRequestLines.Name);
                            end
                            else
                            begin
                                RFQItemSpecifications.TestField(Specification);
                            end;
                        until ProcurementRequestLines.Next = 0;
                    end;
                    if not Confirm('Are you sure you want to invite the vendors for quotation?')then exit;
                    QuotationBidders.Reset;
                    QuotationBidders.SetRange("Reference No", Rec."Reference No");
                    QuotationBidders.SetRange("Email Sent", false);
                    if QuotationBidders.FindSet then begin
                        repeat QuotationBidders.TestField("E-mail Address");
                            //MESSAGE('%1',QuotationBidders."E-mail Address");
                            SendQuotesToSuppliers(QuotationBidders, Rec."Reference No", QuotationBidders."Vendor No.", QuotationBidders."E-mail Address", QuotationBidders."Vendor Name");
                            QuotationBidders."Email Sent":=true;
                            QuotationBidders.Modify(true);
                        until QuotationBidders.Next = 0;
                    end;
                    // QuotationBidders.RESET;
                    // QuotationBidders.SETRANGE("Reference No","Reference No");
                    // IF QuotationBidders.FINDFIRST THEN BEGIN
                    //  REPEAT
                    //    UNTIL QuotationBidders.NEXT = 0;
                    //  END;
                    // QuotationBiddersII.RESET;
                    // QuotationBiddersII.SETRANGE("Reference No","Reference No");
                    // QuotationBiddersII.SETRANGE("Vendor No.","Vendor No.");
                    // QuotationBiddersII.SETRANGE("Vendor Category","Vendor Category");
                    // IF QuotationBiddersII.FINDSET THEN BEGIN
                    //  REPEAT
                    //    Fpath := '';
                    //    IF NOT FileManagement.ServerDirectoryExists(Text001) THEN
                    //      FileManagement.ServerCreateDirectory(Text001);
                    //      Fpath := Text001+' '+ QuotationBiddersII."Reference No"+' '+QuotationBiddersII."Vendor No."+' '+QuotationBiddersII."Vendor Name"+'.PDF';
                    //      FileName := QuotationBiddersII."Reference No"+' '+QuotationBiddersII."Vendor No."+' '+QuotationBiddersII."Vendor Name"+' '+'Quote'+'.pdf';
                    //      CLEAR(RCKRequestforQuotation);
                    //      RCKRequestforQuotation.SETTABLEVIEW(QuotationBiddersII);
                    //      RCKRequestforQuotation.Header(QuotationBiddersII);
                    //      RCKRequestforQuotation.SAVEASPDF(Fpath);
                    //      REPORT.SAVEASPDF(REPORT::"RCK Request for Quotation",FileName,QuotationBiddersII);
                    //      SMTPMailSetup.GET;
                    //      SenderAddress:=SMTPMailSetup."User ID";
                    //      SenderName:=SMTPMailSetup."Send As";
                    //      Subject:='Invitation For Quote';
                    //      Recepient := QuotationBiddersII."E-mail Address";
                    //      CCRecepient := 'procurement@rckkenya.org';
                    //      Body:='Dear '+ FORMAT(QuotationBiddersII."Vendor Name")+','+
                    //       '<br> You have been invited for a quotation at RCK.'+
                    //       ' Please fill in the attached form and submit your quote <br>'+
                    //       '<Br>Regards,'+'<br>Procurement,'+'<br>RCK Kenya.';
                    //       IF (SenderName<>'') AND (SenderAddress<>'') AND (Recepient<>'') AND (Subject<>'') AND (Body<>'') THEN
                    //            BEGIN
                    //            SMTPMail.CreateMessage(SenderName,SenderAddress,Recepient,Subject,Body,TRUE);
                    //            SMTPMail.AddCC(CCRecepient);
                    //            SMTPMail.AddAttachment(Fpath,FileName);
                    //            SMTPMail.Send();
                    //            END;
                    // //      ProcStoreManagement.IanSendQuoteToSuppliers(QuotationBidders."Vendor No.",QuotationBidders."Vendor Name",
                    // //                                                  QuotationBidders."E-mail Address",'','');
                    //    UNTIL QuotationBiddersII.NEXT = 0;
                    //  END;
                    ProcurementRequest.Reset;
                    ProcurementRequest.SetRange("No.", Rec."Reference No");
                    if ProcurementRequest.FindFirst then begin
                        ProcStoreManagement.IanChangeStatusOnVendorInvitation(ProcurementRequest);
                        if ProcStoreManagement.IanStartQuotationEvaluation(ProcurementRequest) = true then begin
                            ProcurementRequest.Validate("Quotation Status", ProcurementRequest."Quotation Status"::"Quote Submission");
                            ProcurementRequest.Modify()end;
                    end;
                    CurrPage.Close();
                end;
            }
            action("Quotes Per Item")
            {
                ApplicationArea = All;
                Enabled = QuotesPerVendorVisible;
                Image = Evaluate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not Confirm('Are you sure you want to open this window?')then exit;
                    QuotationVendorsBids.Reset;
                    QuotationVendorsBids.SetRange("Vendor No", Rec."Vendor No.");
                    QuotationVendorsBids.SetRange("Quote No", Rec."Reference No");
                    if QuotationVendorsBids.FindFirst then begin
                        Clear(VendorQuotedAmountPerItem);
                        VendorQuotedAmountPerItem.SetTableView(QuotationVendorsBids);
                        VendorQuotedAmountPerItem.RunModal();
                    end;
                end;
            }
            action("RFQ Print Out")
            {
                ApplicationArea = All;
                Image = Print;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                Visible = false;

                trigger OnAction()
                begin
                    Rec.Reset;
                    Rec.SetRange("Vendor No.", Rec."Vendor No.");
                    Rec.SetRange("Reference No", Rec."Reference No");
                    REPORT.Run(64004, true, false, Rec);
                end;
            }
            action("RFQ Quote Print Out")
            {
                ApplicationArea = All;
                Image = Print;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.Reset;
                    Rec.SetRange("Vendor No.", Rec."Vendor No.");
                    Rec.SetRange("Reference No", Rec."Reference No");
                    REPORT.Run(Report::RFQ, true, false, Rec);
                end;
            }
            action("RFQ Quote Print Out II")
            {
                ApplicationArea = All;
                Image = Print;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.Reset;
                    Rec.SetRange("Vendor No.", Rec."Vendor No.");
                    Rec.SetRange("Reference No", Rec."Reference No");
                    REPORT.Run(Report::RFQ, true, false, Rec);
                end;
            }
            action("Evaluation Report")
            {
                ApplicationArea = All;
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                RunObject = Report "Quotation Evaluation";
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        IanControlPageAppearance();
    end;
    trigger OnAfterGetRecord()
    begin
        IanControlPageAppearance();
    end;
    trigger OnOpenPage()
    begin
        IanControlPageAppearance();
    end;
    var VendorQuotedAmountPerItem: Page "Vendor Quoted Amount Per Item";
    QuotationVendorsBids: Record "Quotation Vendors Bids";
    ProcurementRequest: Record "Procurement Request";
    ProcStoreManagement: Codeunit "Proc & Store Management";
    QuotationBidders: Record "Quotation Bidders";
    EmailSuppliersVisible: Boolean;
    PageEditableFields: Boolean;
    QuotesPerVendorVisible: Boolean;
    //       SMTPMailSetup: Record "SMTP Mail Setup";
    //        SMTPMail: Codeunit "SMTP Mail";
    SenderAddress: Text;
    SenderName: Text;
    Recepient: Text;
    Body: Text;
    Subject: Text;
    //    RCKRequestforQuotation: Report "RCK Request for Quotation";
    Fpath: Text[255];
    FileManagement: Codeunit "File Management";
    FileName: Text[255];
    CCRecepient: Text[255];
    Text001: Label 'C:/RCKSupplierQuotes/Quotes.pdf';
    Vendor: Record Vendor;
    ProcurementRequestLines: Record "Procurement Request Lines";
    RFQItemSpecifications: Record "RFQ Item Specifications";
    local procedure IanControlPageAppearance()
    begin
        if ProcurementRequest.Get(Rec."Reference No")then begin
            if not(ProcurementRequest."Quotation Status" in[ProcurementRequest."Quotation Status"::New])then begin
                EmailSuppliersVisible:=false;
                PageEditableFields:=false;
            end
            else
            begin
                EmailSuppliersVisible:=true;
                PageEditableFields:=true;
            end;
            if not(ProcurementRequest."Quotation Status" in[ProcurementRequest."Quotation Status"::"Quote Submission"])then begin
                QuotesPerVendorVisible:=false;
            end
            else
            begin
                QuotesPerVendorVisible:=true;
            end;
        end;
    end;
    [Scope('Cloud')]
    procedure SendQuotesToSuppliers(var QuotationBiddersII: Record "Quotation Bidders"; QuoteNo: Code[20]; VendorNo: Code[20]; ReceiptEmail: Text[50]; VendorName: Text[100])
    var
        //   SMTPMailSetup: Record "SMTP Mail Setup";
        SMTPMail: Codeunit Mail;
        SenderAddress: Text;
        SenderName: Text;
        Recepient: Text;
        Body: Text;
        Subject: Text;
        //    RCKRequestforQuotation: Report "RCK Request for Quotation";
        Fpath: Text[255];
        FileManagement: Codeunit "File Management";
        FileName: Text[255];
        CCRecepient: Text[255];
        Vendor: Record Vendor;
        QuotationBiddersCopy: Record "Quotation Bidders";
        Company: Record "Company Information";
        VendorN: Text[100];
    begin
        QuotationBiddersII.Reset();
        begin
            Fpath:='';
            //       if not FileManagement.ServerDirectoryExists(Text001) then
            //         FileManagement.ServerCreateDirectory(Text001);
            Fpath:=Text001 + ' ' + QuotationBiddersII."Reference No" + ' ' + QuotationBiddersII."Vendor No." + ' ' + QuotationBiddersII."Vendor Name" + '.PDF';
            FileName:=QuotationBiddersII."Reference No" + ' ' + QuotationBiddersII."Vendor No." + ' ' + QuotationBiddersII."Vendor Name" + ' ' + 'Quote' + '.pdf';
            //       Clear(RCKRequestforQuotation);
            QuotationBiddersCopy.Reset;
            QuotationBiddersCopy.SetRange("Reference No", QuoteNo);
            QuotationBiddersCopy.SetRange("Vendor No.", VendorNo);
            if QuotationBiddersCopy.FindFirst then begin
                //            RCKRequestforQuotation.SetTableView(QuotationBiddersCopy);
                //RCKRequestforQuotation.Header(QuotationBiddersII);
                // RCKRequestforQuotation.SaveAsPdf(Fpath);
                // REPORT.SaveAsPdf(REPORT::"RCK Request for Quotation",FileName,QuotationBiddersCopy);
                // SMTPMailSetup.Get;
                // SenderAddress:=SMTPMailSetup."User ID";
                // SenderName:=SMTPMailSetup."Send As";
                Subject:='Invitation For Quote';
                Recepient:=ReceiptEmail;
                VendorN:='';
                VendorN:=VendorName;
                Company.Get;
                if Company."E-Mail" <> '' then begin
                    CCRecepient:=Company."Procurement Email";
                end
                else
                    Error('Setup Email on Company Information');
                Body:='Dear ' + Format(VendorN) + ',' + '<br> You have been invited for a quotation at AAH.' + ' Please submit your quotation to our offices based on the details attached below. <br>' + '<Br>Regards,' + '<br>Procurement,' + '<br>AAH';
                if(SenderName <> '') and (SenderAddress <> '') and (Recepient <> '') and (Subject <> '') and (Body <> '')then begin
                // SMTPMail.CreateMessage(SenderName,SenderAddress,Recepient,Subject,Body,true);
                // SMTPMail.AddCC(CCRecepient);
                // SMTPMail.AddAttachment(Fpath,FileName);
                // SMTPMail.Send();
                // if Exists(Fpath) then
                //   Erase(Fpath);
                end;
            end;
        //      ProcStoreManagement.IanSendQuoteToSuppliers(QuotationBidders."Vendor No.",QuotationBidders."Vendor Name",
        //                                                  QuotationBidders."E-mail Address",'','');
        end;
    end;
}

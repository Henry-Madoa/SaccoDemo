page 52203813 "Tender Bidder Card"
{
    ApplicationArea = All;
    Caption = 'Tender Bidder Card';
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,Approve,Request Approval,New Document,Navigate,Incoming Documents,Vendor';
    RefreshOnActivate = true;
    SourceTable = Vendor;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Standard;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the vendor''s name. You can enter a maximum of 30 characters, both numbers and letters.';

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord;
                    end;
                }
                field("Tender No."; Rec."Tender No.")
                {
                }
                field("Tender Description"; Rec."Tender Description")
                {
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies when the vendor card was last modified.';
                }
                field("Balance (LCY)"; Rec."Balance (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total value of your completed purchases from the vendor in the current fiscal year. It is calculated from amounts excluding VAT on all completed purchase invoices and credit memos.';

                    trigger OnDrillDown()
                    begin
                    //              OpenVendorLedgerEntries(false);
                    end;
                }
                field("Balance Due (LCY)"; Rec."Balance Due (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total value of your unpaid purchases from the vendor in the current fiscal year. It is calculated from amounts excluding VAT on all open purchase invoices and credit memos.';

                    trigger OnDrillDown()
                    begin
                    //               OpenVendorLedgerEntries(true);
                    end;
                }
                field("Search Name"; Rec."Search Name")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies an alternate name that you can use to search for the record in question when you cannot remember the value in the Name field.';
                }
                field("Purchaser Code"; Rec."Purchaser Code")
                {
                    ApplicationArea = Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies which purchaser is assigned to the vendor.';
                }
            }
            group("Address & Contact")
            {
                Caption = 'Address & Contact';

                group(AddressDetails)
                {
                    Caption = 'Address';

                    field(Address; Rec.Address)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the vendor''s address.';
                    }
                    field("Address 2"; Rec."Address 2")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies additional address information.';
                    }
                    field(City; Rec.City)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the vendor''s city.';
                    }
                    group(Control199)
                    {
                        ShowCaption = false;
                        Visible = IsCountyVisible;

                        field(County; Rec.County)
                        {
                            ApplicationArea = Basic, Suite;
                            ToolTip = 'Specifies the state, province or county as a part of the address.';
                        }
                    }
                    field("Post Code"; Rec."Post Code")
                    {
                        ApplicationArea = Basic, Suite;
                        Importance = Promoted;
                        ToolTip = 'Specifies the postal code.';
                    }
                    field("Country/Region Code"; Rec."Country/Region Code")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the country/region of the address.';

                        trigger OnValidate()
                        begin
                            IsCountyVisible:=FormatAddress.UseCounty(Rec."Country/Region Code");
                        end;
                    }
                    field(ShowMap; ShowMapLbl)
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                        ShowCaption = false;
                        Style = StrongAccent;
                        StyleExpr = TRUE;
                        ToolTip = 'Specifies you can view the vendor''s address on your preferred map website.';

                        trigger OnDrillDown()
                        begin
                            CurrPage.Update(true);
                        //                DisplayMap;
                        end;
                    }
                }
                group(Contact)
                {
                    Caption = 'Contact';

                    field("Primary Contact No."; Rec."Primary Contact No.")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Primary Contact Code';
                        ToolTip = 'Specifies the primary contact number for the vendor.';
                    }
                    field(Control16; Rec.Contact)
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = ContactEditable;
                        Importance = Promoted;
                        ShowCaption = false;
                        ToolTip = 'Specifies the name of the person you regularly contact when you do business with this vendor.';

                        trigger OnValidate()
                        begin
                            ContactOnAfterValidate;
                        end;
                    }
                    field("Phone No."; Rec."Phone No.")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the vendor''s telephone number.';
                    }
                    field("E-Mail"; Rec."E-Mail")
                    {
                        ApplicationArea = Basic, Suite;
                        ExtendedDatatype = EMail;
                        Importance = Promoted;
                        ToolTip = 'Specifies the vendor''s email address.';
                    }
                    field("Fax No."; Rec."Fax No.")
                    {
                        ApplicationArea = Basic, Suite;
                        Importance = Additional;
                        ToolTip = 'Specifies the vendor''s fax number.';
                    }
                    field("Home Page"; Rec."Home Page")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the vendor''s web site.';
                    }
                    field("Our Account No."; Rec."Our Account No.")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies your account number with the vendor, if you have one.';
                    }
                    field("Language Code"; Rec."Language Code")
                    {
                        ApplicationArea = Basic, Suite;
                        Importance = Additional;
                        ToolTip = 'Specifies the language that is used when translating specified text on documents to foreign business partner, such as an item description on an order confirmation.';
                    }
                }
            }
            group("Procurement Details")
            {
                field("Supplier Category"; Rec."Supplier Category")
                {
                    ApplicationArea = All;
                }
                field("Category of Service"; Rec."Category of Service")
                {
                    ApplicationArea = All;
                }
                field("Sub-Category Code"; Rec."Sub-Category Code")
                {
                    ApplicationArea = All;
                }
                field("Sub-Category Description"; Rec."Sub-Category Description")
                {
                }
                field("AGPO Certificate"; Rec."AGPO Certicicate No.")
                {
                    ApplicationArea = All;
                }
                field("Trade Licennse No"; Rec."Trade Licence No.")
                {
                    ApplicationArea = All;
                }
                field("Certificate of Incorporation"; Rec."Certificate of Incorporation")
                {
                    ApplicationArea = All;
                }
                field("Registration No."; Rec."VAT Registration No.")
                {
                    ApplicationArea = All;
                }
                field("Registration Date"; Rec."Registration Date")
                {
                    ApplicationArea = All;
                }
                field("Tax Compliance Certificate No."; Rec."Tax ComplCe Cert No.")
                {
                    ApplicationArea = All;
                }
                field("Tax Compliance Expiry Date"; Rec."Tax ComplCe Expiry Date")
                {
                    ApplicationArea = All;
                }
                field("VAT Certificate No."; Rec."VAT Certificate Number")
                {
                    ApplicationArea = All;
                }
                field("PIN No."; Rec."KRA PIN No.")
                {
                    ApplicationArea = All;
                }
            // field("Share Capital"; Rec."Share Capital")
            // {
            //     ApplicationArea = All;
            // }
            // field("No. of Businesses at one time"; Rec."No. of  Businesses")
            // {
            //     ApplicationArea = All;
            // }
            }
            group(Invoicing)
            {
                Caption = 'Invoicing';

                field("VAT Registration No."; Rec."VAT Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor''s VAT registration number.';

                    trigger OnDrillDown()
                    var
                        VATRegistrationLogMgt: Codeunit "VAT Registration Log Mgt.";
                    begin
                        VATRegistrationLogMgt.AssistEditVendorVATReg(Rec);
                    end;
                }
                field(GLN; Rec.GLN)
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the vendor in connection with electronic document receiving.';
                }
                field("Pay-to Vendor No."; Rec."Pay-to Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the number of a different vendor whom you pay for products delivered by the vendor on the vendor card.';
                }
                field("Invoice Disc. Code"; Rec."Invoice Disc. Code")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    NotBlank = true;
                    ToolTip = 'Specifies the vendor''s invoice discount code. When you set up a new vendor card, the number you have entered in the No. field is automatically inserted.';
                }
                field("Prices Including VAT"; Rec."Prices Including VAT")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the Unit Price and Line Amount fields on document lines should be shown with or without VAT.';
                }
                group("Posting Details")
                {
                    Caption = 'Posting Details';

                    field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                    {
                        ApplicationArea = Basic, Suite;
                        Importance = Additional;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the vendor''s trade type to link transactions made for this vendor with the appropriate general ledger account according to the general posting setup.';
                    }
                    field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                    {
                        ApplicationArea = Basic, Suite;
                        Importance = Additional;
                        ToolTip = 'Specifies the VAT specification of the involved customer or vendor to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                    }
                    field("Vendor Posting Group"; Rec."Vendor Posting Group")
                    {
                        ApplicationArea = Basic, Suite;
                        Importance = Additional;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the vendor''s market type to link business transactions made for the vendor with the appropriate account in the general ledger.';
                    }
                }
                group("Foreign Trade")
                {
                    Caption = 'Foreign Trade';

                    field("Currency Code"; Rec."Currency Code")
                    {
                        ApplicationArea = Suite;
                        Importance = Additional;
                        ToolTip = 'Specifies the currency code that is inserted by default when you create purchase documents or journal lines for the vendor.';
                    }
                }
            }
            group(Payments)
            {
                Caption = 'Payments';

                field("Prepayment %"; Rec."Prepayment %")
                {
                    ApplicationArea = Prepayments;
                    Importance = Additional;
                    ToolTip = 'Specifies a prepayment percentage that applies to all orders for this vendor, regardless of the items or services on the order lines.';
                }
                field("Application Method"; Rec."Application Method")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how to apply payments to entries for this vendor.';
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies a formula that calculates the payment due date, payment discount date, and payment discount amount.';
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies how to make payment, such as with bank transfer, cash, or check.';
                }
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the importance of the vendor when suggesting payments using the Suggest Vendor Payments function.';
                }
                field("Block Payment Tolerance"; Rec."Block Payment Tolerance")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the vendor allows payment tolerance.';

                    trigger OnValidate()
                    var
                        ConfirmManagement: Codeunit "Confirm Management";
                    begin
                    // if Rec."Block Payment Tolerance" then begin
                    //   if Confirm(Text002,true) then
                    //     PaymentToleranceMgt.DelTolVendLedgEntry(Rec);
                    // end else begin
                    //   if Confirm(Text001,true) then
                    //     PaymentToleranceMgt.CalcTolVendLedgEntry(Rec);
                    // end;
                    end;
                }
                field("Preferred Bank Account Code"; Rec."Preferred Bank Account Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor bank account that will be used by default on payment journal lines for export to a payment bank file.';
                }
                field("Partner Type"; Rec."Partner Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the vendor is a person or a company.';
                }
                field("Cash Flow Payment Terms Code"; Rec."Cash Flow Payment Terms Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a payment term that will be used for calculating cash flow.';
                }
                field("Creditor No."; Rec."Creditor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the vendor.';
                }
            }
            group("Payment Details")
            {
                field("Bank Code"; Rec."Bank Code")
                {
                }
                field("Bank Name"; Rec."Bank Name")
                {
                    Editable = false;
                }
                field("Bank Branch No."; Rec."Bank Branch No.")
                {
                    Visible = false;
                }
                field("Bank Branch Code"; Rec."Bank Branch Code")
                {
                }
                field("Bank Branch Name"; Rec."Bank Branch Name")
                {
                    Editable = false;
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                }
            }
            group(Receiving)
            {
                Caption = 'Receiving';

                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Location;
                    Importance = Promoted;
                    ToolTip = 'Specifies the warehouse location where items from the vendor must be received by default.';
                }
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the delivery conditions of the related shipment, such as free on board (FOB).';
                }
                field("Lead Time Calculation"; Rec."Lead Time Calculation")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies a date formula for the amount of time it takes to replenish the item.';
                }
                field("Base Calendar Code"; Rec."Base Calendar Code")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    ToolTip = 'Specifies a customizable calendar for delivery planning that holds the vendor''s working days and holidays.';
                }
            //  field("Customized Calendar";CalendarMgmt.CustomizedCalendarExistText(CustomizedCalendar."Source Type"::Vendor,Rec."No.",'',Rec."Base Calendar Code"))
            // {
            //     ApplicationArea = Basic,Suite;
            //     Caption = 'Customized Calendar';
            //     Editable = false;
            //     ToolTip = 'Specifies if you have set up a customized calendar for the vendor.';
            //     trigger OnDrillDown()
            //     begin
            //         CurrPage.SaveRecord;
            //         Rec.TestField("Base Calendar Code");
            //         CalendarMgmt.ShowCustomizedCalendar(CustomizedCalEntry."Source Type"::Vendor,"No.",'',"Base Calendar Code");
            //     end;
            // }
            }
        }
    }
    actions
    {
    }
    trigger OnAfterGetRecord()
    begin
        ActivateFields;
    end;
    trigger OnInit()
    begin
        ContactEditable:=true;
    end;
    trigger OnNewRecord(BelowxRec: Boolean)
    var
        DocumentNoVisibility: Codeunit DocumentNoVisibility;
    begin
        Rec."Vendor Type":=Rec."Vendor Type"::"Tender Bidder";
    end;
    trigger OnOpenPage()
    var
        PermissionManager: Codeunit "Permission Manager";
    begin
    end;
    var CustomizedCalEntry: Record "Customized Calendar Entry";
    CustomizedCalendar: Record "Customized Calendar Change";
    OfficeMgt: Codeunit "Office Management";
    CalendarMgmt: Codeunit "Calendar Management";
    PaymentToleranceMgt: Codeunit "Payment Tolerance Management";
    //        WorkflowWebhookManagement: Codeunit "Workflow Webhook Management";
    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    Text001: Label 'Do you want to allow payment tolerance for entries that are currently open?';
    Text002: Label 'Do you want to remove payment tolerance from entries that are currently open?';
    FormatAddress: Codeunit "Format Address";
    [InDataSet]
    ContactEditable: Boolean;
    [InDataSet]
    SocialListeningSetupVisible: Boolean;
    [InDataSet]
    SocialListeningVisible: Boolean;
    OpenApprovalEntriesExistCurrUser: Boolean;
    OpenApprovalEntriesExist: Boolean;
    ShowWorkflowStatus: Boolean;
    ShowMapLbl: Label 'Show on Map';
    IsOfficeAddin: Boolean;
    CanCancelApprovalForRecord: Boolean;
    SendToOCREnabled: Boolean;
    SendToOCRVisible: Boolean;
    SendToIncomingDocEnabled: Boolean;
    SendIncomingDocApprovalRequestVisible: Boolean;
    SendToIncomingDocumentVisible: Boolean;
    NoFieldVisible: Boolean;
    NewMode: Boolean;
    CanRequestApprovalForFlow: Boolean;
    CanCancelApprovalForFlow: Boolean;
    IsSaaS: Boolean;
    IsCountyVisible: Boolean;
    local procedure ActivateFields()
    begin
        SetSocialListeningFactboxVisibility;
        ContactEditable:=Rec."Primary Contact No." = '';
        IsCountyVisible:=FormatAddress.UseCounty(Rec."Country/Region Code");
        if OfficeMgt.IsAvailable then ActivateIncomingDocumentsFields;
    end;
    local procedure ContactOnAfterValidate()
    begin
        ActivateFields;
    end;
    local procedure SetSocialListeningFactboxVisibility()
    var
    //        SocialListeningMgt: Codeunit "Social Listening Management";
    begin
    //       SocialListeningMgt.GetVendFactboxVisibility(Rec,SocialListeningSetupVisible,SocialListeningVisible);
    end;
    local procedure SetVendorNoVisibilityOnFactBoxes()
    begin
    // CurrPage.VendorHistBuyFromFactBox.PAGE.SetVendorNoVisibility(FALSE);
    // CurrPage.VendorHistPayToFactBox.PAGE.SetVendorNoVisibility(FALSE);
    // CurrPage.VendorStatisticsFactBox.PAGE.SetVendorNoVisibility(FALSE);
    end;
    local procedure RunReport(ReportNumber: Integer)
    var
        Vendor: Record Vendor;
    begin
        Vendor.SetRange("No.", Rec."No.");
        REPORT.RunModal(ReportNumber, true, true, Vendor);
    end;
    local procedure ActivateIncomingDocumentsFields()
    var
        IncomingDocument: Record "Incoming Document";
    begin
        if OfficeMgt.OCRAvailable then begin
            SendToIncomingDocumentVisible:=true;
            SendToIncomingDocEnabled:=OfficeMgt.EmailHasAttachments;
            SendToOCREnabled:=OfficeMgt.EmailHasAttachments;
            SendToOCRVisible:=IncomingDocument.OCRIsEnabled and not IsIncomingDocApprovalsWorkflowEnabled;
            SendIncomingDocApprovalRequestVisible:=IsIncomingDocApprovalsWorkflowEnabled;
        end;
    end;
    local procedure IsIncomingDocApprovalsWorkflowEnabled(): Boolean var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowDefinition: Query "Workflow Definition";
    begin
        WorkflowDefinition.SetRange(Table_ID, DATABASE::"Incoming Document");
        WorkflowDefinition.SetRange(Entry_Point, true);
        WorkflowDefinition.SetRange(Enabled, true);
        WorkflowDefinition.SetRange(Type, WorkflowDefinition.Type::"Event");
        WorkflowDefinition.SetRange(Function_Name, WorkflowEventHandling.RunWorkflowOnSendIncomingDocForApprovalCode);
        WorkflowDefinition.Open;
        while WorkflowDefinition.Read do exit(true);
        exit(false);
    end;
    local procedure CreateVendorFromTemplate()
    var
        //        MiniVendorTemplate: Record "Mini Vendor Template";
        Vendor: Record Vendor;
        VATRegNoSrvConfig: Record "VAT Reg. No. Srv Config";
        ConfigTemplateHeader: Record "Config. Template Header";
        EUVATRegistrationNoCheck: Page "EU VAT Registration No Check";
        VendorRecRef: RecordRef;
    begin
        OnBeforeCreateVendorFromTemplate(NewMode);
        if NewMode then begin
            //   if MiniVendorTemplate.NewVendorFromTemplate(Vendor) then begin
            //     if VATRegNoSrvConfig.VATRegNoSrvIsEnabled then
            //       if Vendor."Validate EU Vat Reg. No." then begin
            //         EUVATRegistrationNoCheck.SetRecordRef(Vendor);
            //         Commit;
            //         EUVATRegistrationNoCheck.RunModal;
            //         EUVATRegistrationNoCheck.GetRecordRef(VendorRecRef);
            //         VendorRecRef.SetTable(Vendor);
            //       end;
            Rec.Copy(Vendor);
            CurrPage.Update;
        end
        else
        begin
            ConfigTemplateHeader.SetRange("Table ID", DATABASE::Vendor);
            ConfigTemplateHeader.SetRange(Enabled, true);
            if not ConfigTemplateHeader.IsEmpty then CurrPage.Close;
        end;
        NewMode:=false;
    end;
    //   end;
    local procedure SetNoFieldVisible()
    var
        DocumentNoVisibility: Codeunit DocumentNoVisibility;
    begin
        NoFieldVisible:=DocumentNoVisibility.VendorNoIsVisible;
    end;
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateVendorFromTemplate(var NewMode: Boolean)
    begin
    end;
}

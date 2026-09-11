pageextension 52203423 "Vendor Card" extends "Vendor Card"
{
    layout
    {
        modify("IC Partner Code")
        {
            Visible = false;
        }
        modify("Purchaser Code")
        {
            Visible = false;
        }
        modify("Responsibility Center")
        {
            Visible = false;
        }
        modify("Disable Search by Name")
        {
            Visible = false;
        }
        modify(GLN)
        {
            Visible = false;
        }
        modify("Cash Flow Payment Terms Code")
        {
            Visible = false;
        }
        modify("Creditor No.")
        {
            Visible = false;
        }
        modify(Receiving)
        {
            Visible = false;
        }
        modify("E-Mail")
        {
            ShowMandatory = true;
        }
        addafter(Name)
        {
            field("Account Type"; Rec."Account Type")
            {
                ApplicationArea = Basic, Suite;
                ShowMandatory = true;
            }
            field("Supplier Category"; Rec."Supplier Category")
            {
                ApplicationArea = All;
                ShowMandatory = true;
            }
        }
        modify(Blocked)
        {
            Visible = false;
        }
        addbefore(Payments)
        {
            group(Administration)
            {
                field("Registration Date"; Rec."Registration Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Certificate Of Incorporation"; Rec."Certificate Of Incorporation")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("AGPO Certicicate No."; Rec."AGPO Certicicate No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Trade Licence No."; Rec."Trade Licence No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Tax ComplCe Cert No."; Rec."Tax ComplCe Cert No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Tax ComplCe Expiry Date"; Rec."Tax ComplCe Expiry Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("VAT Certificate Number"; Rec."VAT Certificate Number")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("NSSF ComplCe Cert. No."; Rec."NSSF ComplCe Cert. No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("SHIF ComplCe Cert. No."; Rec."SHIF ComplCe Cert. No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Certificate of Good Conduct"; Rec."Certificate of Good Conduct")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Contract Details")
            {
                field("Contract Start Date"; Rec."Contract Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contract Period"; Rec."Contract Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contract End Date"; Rec."Contract End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Contract Status"; Rec."Contract Status")
                {
                    Importance = Promoted;
                    ApplicationArea = Basic, Suite;
                }
                field("Blocked Reason"; Rec."Blocked Reason")
                {
                    ApplicationArea = Basic, Suite;
                    MultiLine = true;

                    trigger OnAssistEdit()
                    var
                        BloackedReason: Record "Blocked Reason";
                    begin
                        BloackedReason.Reset();
                        if Page.RunModal(Page::"Blocked Reasons", BloackedReason) = ACTION::LookupOK then Rec."Blocked Reason" := BloackedReason.Description;
                    end;
                }
                field(Blocked_Mod; Rec.Blocked)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Blocked';
                    Style = Attention;
                }
            }
        }
        addafter(Payments)
        {
            part("Suppliers Company Directors"; "Suppliers Company Directors")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Vendor No" = field("No.");
            }
            part("Vendor Payment Details"; "Vendor Payment Details")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Vendor No" = field("No.");
            }
            part("Supplier Service Categories"; "Supplier Service Categories")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Vendor No" = field("No.");
            }
        }
    }
    actions
    {
        // Add changes to page actions here    
        addafter(ApplyTemplate)
        {
            action("View SharePoint Documents")
            {
                ApplicationArea = Basic, Suite;
                PromotedCategory = New;
                Image = ViewDocumentLine;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if Rec."SharePoint Link" = '' then
                        Error('There is no link to documents uploaded in SharePoint. Please contact the SharePoint Administrator.')
                    else
                        HyperLink(Rec."SharePoint Link");
                end;
            }
        }
        modify(SendApprovalRequest)
        {
            trigger OnBeforeAction()
            begin
                if (Rec.Blocked = Rec.Blocked::Payment) or (Rec.Blocked = Rec.Blocked::All) then Rec.Testfield("Blocked Reason");
            end;
        }
    }
    trigger OnOpenPage()
    begin
        if ((Rec."Contract End Date" <> 0D) And (Rec."Contract Status" <> Rec."Contract Status"::Blocked)) then begin
            if Rec."Contract End Date" < WorkDate then
                Rec."Contract Status" := Rec."Contract Status"::Inactive
            else
                Rec."Contract Status" := Rec."Contract Status"::Active;
            Rec.Modify;
        end;
    end;
}

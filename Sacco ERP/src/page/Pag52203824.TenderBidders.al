page 52203824 "Tender Bidders"
{
    ApplicationArea = All;
    PageType = List;
    SourceTable = "Tender Suppliers";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Bidder Type"; Rec."Bidder Type")
                {
                    ApplicationArea = All;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Supplier No."; Rec."Supplier No.")
                {
                    ApplicationArea = All;
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field("Physical Location"; Rec."Physical Location")
                {
                    ApplicationArea = All;
                }
                field("Email Address"; Rec."Email Address")
                {
                    ApplicationArea = All;
                }
                field("Reference No"; Rec."Reference No")
                {
                    ApplicationArea = All;
                }
                field("Bid Amount"; Rec."Bid Amount")
                {
                    ApplicationArea = All;
                }
                field("Delivery Period"; Rec."Delivery Period")
                {
                    ApplicationArea = All;
                }
                field("Delivery Date"; Rec."Delivery Date")
                {
                    ApplicationArea = All;
                }
                field("Security Bid Receipt No."; Rec."Security Bid Receipt No.")
                {
                    ApplicationArea = All;
                }
                field("Response Date"; Rec."Response Date")
                {
                    ApplicationArea = All;
                }
                field("Supplier Application"; Rec."Supplier Application")
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
            action("Email Tender To Vendors")
            {
                Image = SendMail;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = false;

                trigger OnAction()
                begin
                    if not Confirm('Are you sure you want to invite the vendors for tendering?')then exit;
                    TenderSuppliers.Reset;
                    TenderSuppliers.SetRange("Reference No", Rec."Reference No");
                    if TenderSuppliers.FindSet then begin
                        repeat if ProcurementRequest.Get(TenderSuppliers."Reference No")then ProcStoreManagement.IanSendTenderToSuppliers(TenderSuppliers."Vendor No.", TenderSuppliers."Vendor Name", TenderSuppliers."Email Address", '', '', ProcurementRequest."Tender Closing Date");
                        until TenderSuppliers.Next = 0;
                    end;
                    Message('Successfully sent');
                    CurrPage.Close();
                end;
            }
        }
    }
    var TenderSuppliers: Record "Tender Suppliers";
    ProcStoreManagement: Codeunit "Proc & Store Management";
    ProcurementRequest: Record "Procurement Request";
}

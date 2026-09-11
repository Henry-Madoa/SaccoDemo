pageextension 52203450 "Purchases & Payables Setup" extends "Purchases & Payables Setup"
{
    layout
    {
        addafter(General)
        {
            group("Procurement Setups")
            {
                field("Item Budget Name"; Rec."Item Budget Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Check Budget"; Rec."Check Budget")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Enable Email Notification"; Rec."Enable Email Notification")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Procurement Officer User Id"; Rec."Procurement Officer User Id")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Tender Extension Period"; Rec."Tender Extension Period")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Stores Control Email"; Rec."Stores Control Email")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Store Issue Template"; Rec."Store Issue Template")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Store Issue Batch"; Rec."Store Issue Batch")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Inspection Reviewer"; Rec."Inspection Reviewer")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("International PO Address"; Rec."International PO Address")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        addlast("Number Series")
        {
            field("Supplier Application Nos"; Rec."Supplier Application Nos")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Tender Nos"; Rec."Tender Nos")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Contract Nos"; Rec."Contract Nos")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Contract Extension Nos"; Rec."Contract Extension Nos")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Purchase Req No"; Rec."Purchase Req No")
            {
                ApplicationArea = Basic, Suite;
            }
            field("RFP Nos"; Rec."RFP Nos")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Direct Procurement Nos"; Rec."Direct Procurement Nos")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Store Requisition Nos."; Rec."Store Requisition Nos.")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Store Receipt Nos."; Rec."Store Receipt Nos.")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Store Issue Nos."; Rec."Store Issue Nos.")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Store Transfer Nos."; Rec."Store Transfer Nos.")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Request for Quotation Nos."; Rec."Request for Quotation Nos.")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Inspection Nos."; Rec."Inspection Nos.")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Request for Proposals Nos."; Rec."Request for Proposals Nos.")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Appointment Nos."; Rec."Appointment Nos.")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Procurement Plan No."; Rec."Procurement Plan No.")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Repair Requisition No."; Rec."Repair Requisition No.")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Work Order No."; Rec."Work Order No.")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Goods Receipt Nos"; Rec."Goods Receipt Nos")
            {
                ApplicationArea = All;
            }
            field("Fuel No."; Rec."Fuel No.")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addafter("Incoming Documents Setup")
        {
            action("User Budget Roles")
            {
                ApplicationArea = All;
                RunObject = page "Budget User Roles";

                trigger OnAction()
                begin
                end;
            }
        }
    }
}

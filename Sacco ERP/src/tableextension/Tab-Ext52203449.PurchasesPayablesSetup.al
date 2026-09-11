tableextension 52203449 "Purchases & Payables Setup" extends "Purchases & Payables Setup"
{
    fields
    {
        // Add changes to table fields here
        field(52203423; "Item Budget Name"; Code[10])
        {
            TableRelation = "Item Budget Name".Name where("Analysis Area" = const(Purchase));
        }
        field(52203424; "Purchase Req No"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(52203425; "Store Requisition Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(52203426; "Stores Control Email"; Text[80])
        {
        }
        field(52203427; "Store Issue Template"; Code[20])
        {
            TableRelation = "Item Journal Template";
        }
        field(52203428; "Store Issue Batch"; Code[20])
        {
        }
        field(52203429; "Enable Email Notification"; Boolean)
        {
        }
        field(52203430; "Store Receipt Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(52203431; "Store Issue Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(52203432; "Store Transfer Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(52203433; "Request for Quotation Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(52203434; "Inspection Nos."; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(52203435; "Inspection Reviewer"; Text[50])
        {
        }
        field(52203436; "Tender Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203437; "Appointment Nos."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203438; "Request for Proposals Nos."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203439; "Supplier Application Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(52203440; "Procurement Plan No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(52203441; "Repair Requisition No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(52203442; "Work Order No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(52203443; "International PO Address"; Text[250])
        {
        }
        field(52203444; "Check Budget"; Boolean)
        {
        }
        field(52203445; "Procurement Officer User Id"; Code[50])
        {
            TableRelation = "User Setup";
        }
        field(52203446; "Contract Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(52203447; "Contract Extension Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(52203448; "Tender Extension Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(52203449; "RFP Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203450; "Direct Procurement Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203451; "Disposal Nos"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203452; "Disposal Request Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203453; "Goods Receipt Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203454; "Bid Bond No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(52203455; "Fuel No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
    }
}

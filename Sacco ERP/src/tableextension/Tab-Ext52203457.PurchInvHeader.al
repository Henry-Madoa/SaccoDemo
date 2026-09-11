tableextension 52203457 "Purch. Inv. Header" extends "Purch. Inv. Header"
{
    fields
    {
        // Add changes to table fields here
        modify("Order No.")
        {
            trigger OnAfterValidate()
            begin
                OrderHeader.Reset();
                OrderHeader.SetRange("Document Type", OrderHeader."Document Type"::Order);
                OrderHeader.SetRange("No.", Rec."Order No.");
                if OrderHeader.FindFirst() then begin
                    "Order Created By" := OrderHeader."Raised By";
                end;
            end;
        }
        modify("Buy-from Vendor No.")
        {
            TableRelation = Vendor where("Account Type" = const(Supplier));

            trigger OnAfterValidate()
            var
                PayBankDetail: Record "Payee Bank Details";
                Text000: Label 'Please make sure the Payment Details have been set on Vendor Card!';
                Text001: Label 'Vendor No.: %1, SLA Validity Status is invalid, kindly contact Admin Dept to update the vendor card.';
                Text002: Label 'Vendor No.: %1, classification can not be empty.';
                Text003: Label 'Vendor No.: %1, SLA Validity Status is Expired, kindly contact Admin Dept to update the vendor card.';
                Text004: Label 'Vendor No.: %1, SLA Validity Status is Terminated, kindly contact Admin Dept to update the vendor card.';
            begin
                //Check Bank Detail
                // PayBankDetail.Reset();
                // PayBankDetail.SetRange("Vendor No", "Buy-from Vendor No.");
                // if PayBankDetail.FindSet() then begin
                // end
                // else
                //     Error(Text000);
                //VOO: 24th Dec 2021 - To address clearing of Dimensions when Vendor Records are updated
                if UserSetup.Get(UserId) then begin
                    if Empl.Get(UserSetup."Employee No.") then begin
                        Validate("Shortcut Dimension 1 Code", Empl."Global Dimension 1 Code");
                        Validate("Shortcut Dimension 2 Code", Empl."Global Dimension 2 Code");
                    end;
                end;
                //
            end;
        }
        modify("No.")
        {
            trigger OnAfterValidate()
            begin
                Validate("Shortcut Dimension 1 Code");
                Validate("Shortcut Dimension 2 Code");
            end;
        }
        field(50000; "Requisition No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50001; "Last Printed by"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50002; "Last Print Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(50003; "Last Print Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(50004; "Last Print No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(50005; Printed; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50006; "International LPO"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50008; Remarks; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(50009; Committed; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50010; Uncommitted; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50423; "Order Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Local Purchase Order, Local Service Order';
            OptionMembers = "Local Purchase Order","Local Service Order";
        }
        field(50424; "RFQ Status"; Option)
        {
            DataClassification = CustomerContent;
            OptionCaption = 'Created, Sent, Accepted, Rejected, Returned';
            OptionMembers = Created,Sent,Accepted,Rejected,Returned;
        }
        field(50425; "Reply Progress"; Option)
        {
            DataClassification = CustomerContent;
            OptionCaption = 'Purchase is updating, Vendor is updating, Submitted by purchaser, Submitted by vendor';
            OptionMembers = "Purchase is updating","Vendor is updating","Submitted by purchaser","Submitted by vendor";
        }
        field(50426; "Purchase Order Status"; Option)
        {
            DataClassification = CustomerContent;
            OptionCaption = 'Open order, Received, Canceled, Invoiced';
            OptionMembers = "Open order",Received,Canceled,Invoiced;
        }
        field(50427; "Cost Center"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = FILTER(1), Blocked = const(false));
        }
        field(50428; "Raised By"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = User."User Name";
        }
        field(50431; "Last Date Modified"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(50200; "Payment Requested"; Boolean)
        {
            Editable = false;
        }
        field(50201; Decision; Option)
        {
            OptionMembers = " ",New,"Append";

            trigger OnValidate()
            begin
                "Decision By" := UserId;
                if Decision <> Decision::"Append" then
                    Target := ''
                else if Decision = Decision::Append then Error(Text000);
            end;
        }
        field(50202; Target; Code[20])
        {
            TableRelation = "Request for Payment" where("Creditor No." = field("Buy-from Vendor No."), "PV Generated" = const(false), Status = const(Open));
        }
        field(50203; "Partial Payment Request"; Boolean)
        {
            Editable = false;
        }
        field(50204; "Amount Remaining To Request"; Decimal)
        {
            Editable = false;
            Caption = 'Remaining Amount';
        }
        field(50205; "Amount To Request"; Decimal)
        {
            Caption = 'Requested Amount';

            trigger OnValidate()
            begin
                if "Amount To Request" > "Amount Remaining To Request" then Error('You cant request more than the Remaining Amount!');
            end;
        }
        field(50206; "Decision By"; Code[50])
        {
            TableRelation = User."User Name";
        }
        field(50016; "Order Created By"; Code[50])
        {
            TableRelation = User."User Name";
        }
    }
    trigger OnAfterInsert()
    begin
        if UserSetup.Get(UserId) then begin
            if Empl.Get(UserSetup."Employee No.") then begin
                Validate("Shortcut Dimension 1 Code", Empl."Global Dimension 1 Code");
                Validate("Shortcut Dimension 2 Code", Empl."Global Dimension 2 Code");
            end;
        end;
    end;

    var
        Text000: Label 'Append Option have been deactivated Please use New Option to create a new Payment Request';
        OrderHeader: Record "Purchase Header";
        dimval: Record "Dimension Value";
        GLSetup: Record "General Ledger Setup";
        UserSetup: Record "User Setup";
        Vend: Record Vendor;
        Empl: Record Employee;
        UsersRec: Record "User Setup";
}

tableextension 52203452 "Purchase Header" extends "Purchase Header"
{
    fields
    {
        modify("Buy-from Vendor No.")
        {
            TableRelation = Vendor where("Account Type" = filter(Supplier));

            trigger OnAfterValidate()
            var
                PayBankDetail: Record "Payee Bank Details";
                Text000: Label 'Please make sure the Payment Details have been set on Vendor Card!';
                Text001: Label 'Vendor No.: %1, SLA Validity Status is invalid, kindly contact Admin Dept to update the vendor card.';
                Text002: Label 'Vendor No.: %1, classification can not be empty in the vendor card.';
                Text003: Label 'Vendor No.: %1, SLA Validity Status is Expired, kindly contact Admin Dept to update the vendor card.';
                Text004: Label 'Vendor No.: %1, SLA Validity Status is Terminated, kindly contact Admin Dept to update the vendor card.';
            begin
                //Check Bank Detail
                // PayBankDetail.Reset();
                // PayBankDetail.SetRange("Vendor No", "Buy-from Vendor No.");
                // if not PayBankDetail.FindSet then Error(Text000);
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
        field(52203423; "Requisition No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(52203424; "Last Printed by"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(52203425; "Last Print Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(52203426; "Last Print Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(52203427; "Last Print No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(52203428; Printed; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203429; "International LPO"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203430; Remarks; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(52203431; Committed; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203432; Uncommitted; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203433; Inspected; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203434; "Order Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Local Purchase Order, Local Service Order';
            OptionMembers = "Local Purchase Order","Local Service Order";
        }
        field(52203435; "RFQ Status"; Option)
        {
            DataClassification = CustomerContent;
            OptionCaption = 'Created, Sent, Accepted, Rejected, Returned';
            OptionMembers = Created,Sent,Accepted,Rejected,Returned;
        }
        field(52203436; "Reply Progress"; Option)
        {
            DataClassification = CustomerContent;
            OptionCaption = 'Purchase is updating, Vendor is updating, Submitted by purchaser, Submitted by vendor';
            OptionMembers = "Purchase is updating","Vendor is updating","Submitted by purchaser","Submitted by vendor";
        }
        field(52203437; "Purchase Order Status"; Option)
        {
            DataClassification = CustomerContent;
            OptionCaption = 'Open order, Received, Canceled, Invoiced';
            OptionMembers = "Open order",Received,Canceled,Invoiced;
        }
        field(52203438; "Cost Center"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = FILTER(1), Blocked = const(false));
        }
        field(52203439; "Raised By"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = User."User Name";
        }
        field(52203440; "Medical Claim"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203441; "Last Date Modified"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(52203442; "Tender No"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(52203443; "Contract No"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(52203444; "Requires Inspection"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203445; "Procurement Doc. No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(52203446; "Delivery Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(52203447; "Created By"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(52203448; "Employee No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee;

            trigger OnValidate()
            var
                Employee: Record Employee;
            begin
                If Employee.Get("Employee No.") then "Employee Name" := Employee.FullName;
            end;
        }
        field(52203449; "Employee Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
    trigger OnBeforeDelete()
    begin
        if Rec.Status = Rec.Status::Open then
            Rec.Testfield("Raised By", UserId)
        else
            Error('You cannot delete header at this stage.');
        //Rec.TestField(Status, Rec.Status::Open);
    end;

    trigger OnAfterModify()
    begin
        "Last Date Modified" := WorkDate;
    end;

    trigger OnAfterRename()
    begin
        "Last Date Modified" := WorkDate;
    end;

    trigger OnAfterInsert()
    begin
        if UserSetup.Get(UserId) then begin
            if Empl.Get(UserSetup."Employee No.") then begin
                Validate("Shortcut Dimension 1 Code", Empl."Global Dimension 1 Code");
                Validate("Shortcut Dimension 2 Code", Empl."Global Dimension 2 Code");
            end;
        end;
    end;
    //IB 22/08/2021
    trigger OnBeforeInsert()
    begin
        "Raised By" := UserId;
        "Assigned User ID" := UserId;
        if Rec.Status = Rec.Status::Open then
            Rec.Testfield("Raised By", UserId)
        else
            Error('You cannot add more to the header at this stage.');
    end;

    procedure DocumentAttachmentsCheck(): Boolean
    begin
        DocumentAttachment.Reset();
        DocumentAttachment.SetRange("Table ID", 38);
        DocumentAttachment.SetRange("No.", Rec."No.");
        DocumentAttachment.SetFilter("File Name", '<>%1', '');
        if DocumentAttachment.FindSet() then
            exit(true)
        else
            exit(false);
    end;

    procedure ValidatorResponse(): Text
    begin
        exit(Validator_Err);
    end;

    var
        Requisition: Record "Requisition Header";
        UserSetup: Record "User Setup";
        Empl: Record Employee;
        DocumentAttachment: Record "Document Attachment";
        Validator_Err: Label 'You have not attached any document. Please attach some documents';
        Vend: Record Vendor;
        UsersRec: Record "User Setup";
}

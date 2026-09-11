tableextension 52203453 "Purchase Lines" extends "Purchase Line"
{
    fields
    {
        modify("Direct Unit Cost")
        {
            trigger OnAfterValidate()
            begin
                if Type <> Type::"Fixed Asset" then BudgetMgt.ValidatePurchaseLinesBudget(Rec, "Amount Including VAT");
            end;
        }
        field(52203423; "RFQ No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(52203424; MFR; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(52203425; "Catalog No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(52203426; Status; Enum "Purchase Document Status")
        {
            DataClassification = ToBeClassified;
        }
        field(52203427; "Cost Center"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = FILTER(1), Blocked = const(false));
        }
        field(52203428; "Asset No"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Fixed Asset";
        }
        field(52203429; Committed; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203430; "Budget Available"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52203431; "Shortcut Dimension 3 Code"; Code[10])
        {
            CaptionClass = '1,2,3';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3));
        }
        field(52203432; "Procurement Plan No."; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(52203433; "VAT Amount"; Decimal)
        {
            Editable = false;
        }
    }
    trigger OnAfterDelete()
    begin
        if PurchHeader.Get("Document Type"::Order, "Document No.") then begin
            if PurchHeader.Status = PurchHeader.Status::Open then
                PurchHeader.TestField("Raised By", UserId)
            else
                Error('You cannot delete header at this stage.');
        end;
    end;

    trigger OnBeforeInsert()
    begin
        if PurchHeader.Get("Document Type"::Order, "Document No.") then begin
            if PurchHeader.Status = PurchHeader.Status::Open then
                PurchHeader.TestField("Raised By", UserId)
            else
                Error('You cannot add more to the header at this stage.');
        end;
    end;

    var
        PurchHeader: Record "Purchase Header";
        Expense: Record "Expense Codes";
        BudgetMgt: Codeunit "Budget Management";
}

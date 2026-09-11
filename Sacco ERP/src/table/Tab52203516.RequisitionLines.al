table 52203516 "Requisition Lines"
{
    fields
    {
        field(1; "Requisition No"; Code[22])
        {
            trigger OnValidate()
            begin
                if ReqHeader.Get("Requisition No")then begin
                    "Global Dimension 1 Code":=ReqHeader."Global Dimension 1 Code";
                    "Global Dimension 2 Code":=ReqHeader."Global Dimension 2 Code";
                    "Location Code":=ReqHeader."Location Code";
                    "Global Dimension 3 Code":=ReqHeader."Global Dimension 3 Code";
                    "Requisition Type":=ReqHeader."Requisition Type";
                    "Procurement Plan":=ReqHeader."Procurement Plan";
                end;
            end;
        }
        field(2; "Line No"; Integer)
        {
            trigger OnValidate()
            begin
                if ReqHeader.Get("Requisition No")then begin
                    "Procurement Plan":=ReqHeader."Procurement Plan";
                    "Location Code":=ReqHeader."Location Code";
                    "Global Dimension 2 Code":=ReqHeader."Global Dimension 2 Code";
                end;
            end;
        }
        field(3; Type;Enum "Purchase Line Type")
        {
            DataClassification = CustomerContent;
        }
        field(4; "No."; Code[50])
        {
            TableRelation = if(type=const("G/L Account"))"G/L Account"
            else IF(Type=CONST(Item))Item
            ELSE IF(Type=CONST("Fixed Asset"))"Fixed Asset";

            trigger OnValidate()
            begin
                //Rec.TestField(Status, Rec.Status::Open);
                RequisitionLines.Reset();
                RequisitionLines.SetRange("Requisition No", "Requisition No");
                RequisitionLines.SetRange(Type, Type);
                RequisitionLines.SetRange("No.", "No.");
                if RequisitionLines.FindFirst then Error('The record already exist');
                if ReqHeader.Get("Requisition No")then begin
                    "Global Dimension 1 Code":=ReqHeader."Global Dimension 1 Code";
                    "Global Dimension 2 Code":=ReqHeader."Global Dimension 2 Code";
                    "Location Code":=ReqHeader."Location Code";
                    "Global Dimension 3 Code":=ReqHeader."Global Dimension 3 Code";
                end;
                if Type = Type::Item then begin
                    if ItemRec.Get("No.")then begin
                        ItemRec.TestField("Item Status", ItemRec."Item Status"::Active);
                        if ItemRec."Item Status" = ItemRec."Item Status"::Active then begin
                            //if Description = '' then
                            Description:=ItemRec.Description;
                            "Unit of Measure":=ItemRec."Base Unit of Measure";
                            if "Location Code" <> '' then ItemRec.SetFilter("Location Filter", '%1', "Location Code");
                            ItemRec.CalcFields(ItemRec.Inventory);
                            ItemRec.CalcFields(Inventory);
                            "Quantity in Store":=ItemRec.Inventory;
                            "Unit Price":=ItemRec."Unit Cost";
                            /*if ((ItemRec."Gen. Prod. Posting Group" = 'FUEL') and (ReqHeader."Global Dimension 2 Code" = '')) then
                         Error('FA Code Must have a Value');*/
                            if StockkeepingUnit.Get("Location Code", "No.", '')then begin
                                if StockkeepingUnit."Unit Cost" <> 0 then "Unit Price":=StockkeepingUnit."Unit Cost"
                                else
                                    "Unit Price":=StockkeepingUnit."Last Direct Cost";
                            end
                            else
                            begin
                                if ItemRec."Unit Cost" <> 0 then "Unit Price":=ItemRec."Unit Cost"
                                else
                                    "Unit Price":=ItemRec."Last Direct Cost";
                            end;
                            ItemBudgetEntry.Reset();
                            ItemBudgetEntry.SetRange("Budget Name", "Procurement Plan");
                            ItemBudgetEntry.SetRange("Item No.", "No.");
                            ItemBudgetEntry.SetRange("Global Dimension 1 Code", "Global Dimension 1 Code");
                            if ItemBudgetEntry.FindSet()then begin
                                ItemBudgetEntry.CalcSums(Quantity);
                                ItemBudgetEntry.CalcFields("Items Requested");
                                "Items In Budget":=ItemBudgetEntry.Quantity - ItemBudgetEntry."Items Requested";
                            end;
                        end
                        else if ItemRec."Item Status" = ItemRec."Item Status"::Inactive then begin
                                Error('An item is not active.');
                            end;
                    end;
                end
                else
                begin
                    "Quantity in Store":=0;
                    "Unit Price":=0;
                end;
                if Type = Type::"Fixed Asset" then begin
                    if FA.Get("No.")then begin
                        Description:=FA.Description;
                        FA.TestField("FA Posting Group");
                        FAPostingGr.Get(FA."FA Posting Group");
                        FAPostingGr.TestField("Acquisition Cost Account");
                        "Asset Acquisition Account":=FAPostingGr."Acquisition Cost Account";
                    end;
                end
                else
                begin
                    "Asset Acquisition Account":='';
                end;
                if Type = Type::"G/L Account" then begin
                    if GLAccount.Get("No.")then Description:=GLAccount.Name;
                end;
            end;
        }
        field(5; Description; Text[250])
        {
        }
        field(6; Quantity; Decimal)
        {
            Caption = 'Quantity Requested';

            trigger OnValidate()
            begin
                PurchPayablesSetup.Get;
                if ReqHeader.Get("Requisition No")then begin
                    if ReqHeader."Requisition Type" = ReqHeader."Requisition Type"::"Store Requisition" then begin
                        Validate("Quantity Approved", Quantity);
                        Validate("Unit Price");
                        if "Quantity in Store" < Quantity then begin
                            Message('Procurement Notified! The stock item: %1 is out of stock, The quantity in store is %2', RequisitionLines.Description, RequisitionLines."Quantity in Store");
                            Error('Your Request for Item %1 cannot proceed because of low stock quantity, Kindly reduce the Quantity', Description);
                        end;
                        exit;
                    end;
                    Validate(Amount);
                // if (("Requisition Type" = "Requisition Type"::"Purchase Requisition") and (Rec.Type = Rec.Type::Item)) then begin
                //     Rec.Testfield("Procurement Plan");
                //     Rec.Testfield("Items In Budget");
                //     if PurchPayablesSetup."Check Budget" then
                //         if (Quantity > "Items In Budget") then
                //             Error(StrSubstNo('You cannot request more than items than what is in the Procurement Plan, Quantity available in the Plan is %1', Format("Items In Budget")));
                // end;
                end;
            end;
        }
        field(7; "Unit of Measure"; Code[10])
        {
            TableRelation = "Item Unit of Measure".Code where("Item No."=field("No."));

            trigger OnValidate()
            Var
                ItemUoM: Record "Item Unit of Measure";
            begin
                if Type = Type::Item then If not ItemUoM.Get("No.", "Unit of Measure")then Error('%1 is not a valid Unit of Measure for Item %2', "Unit of Measure", Description)
                    else
                    begin
                        if ItemRec.Get("No.")then begin
                            if ItemRec."Base Unit of Measure" <> "Unit of Measure" then begin
                                if ItemRec."Unit Cost" <> 0 then "Unit Price":=ItemUoM."Qty. per Unit of Measure" * ItemRec."Unit Cost"
                                else
                                    "Unit Price":=ItemUoM."Qty. per Unit of Measure" * ItemRec."Last Direct Cost";
                                ItemRec.SetFilter("Location Filter", '%1', "Location Code");
                                ItemRec.CalcFields(Inventory);
                                "Quantity in Store":=Round(ItemRec.Inventory / ItemUoM."Qty. per Unit of Measure", 0.01);
                            end;
                        end;
                    end;
                Validate("Unit Price");
            end;
        }
        field(8; "Unit Price"; Decimal)
        {
            trigger OnValidate()
            begin
                if Quantity <> 0 then begin
                    Amount:=Quantity * "Unit Price";
                    Validate(Amount);
                end;
            end;
        }
        field(9; Amount; Decimal)
        {
            Editable = false;

            trigger OnValidate()
            begin
                if ReqHeader.Get("Requisition No")then if ReqHeader."Requisition Type" = ReqHeader."Requisition Type"::"Purchase Requisition" then begin
                        if Amount <> 0 then BudgetMgt.ValidatePurchaseRequisitionBudget(Rec, Amount);
                    end;
            end;
        }
        field(10; "Procurement Plan"; Code[10])
        {
            TableRelation = "G/L Budget Name";
        }
        field(11; "Quantity Approved"; Decimal)
        {
            Editable = true;

            trigger OnValidate()
            begin
                if "Quantity Approved" > Quantity then Error('Quantity Approved cannot be higher than the quantity requested!')
                else
                    Validate("Quantity To Issue", ("Quantity Approved" - "Quantity Issued"));
            end;
        }
        field(12; "Quantity in Store"; Decimal)
        {
            Editable = false;
        }
        field(13; "Location Code"; Code[10])
        {
            TableRelation = Location WHERE("Use As In-Transit"=CONST(false));

            trigger OnValidate()
            begin
                if ItemRec.Get("No.")then begin
                    ItemRec.SetFilter("Location Filter", '%1', "Location Code");
                    ItemRec.CalcFields(ItemRec.Inventory);
                    "Quantity in Store":=ItemRec.Inventory;
                end;
            end;
        }
        field(14; "GL Account"; Code[10])
        {
        }
        field(15; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
        }
        field(16; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));
        }
        field(17; "Global Dimension 3 Code"; Code[20])
        {
            CaptionClass = '1,2,3';
            Caption = 'Global Dimension 3 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(3), Blocked=const(false));
        }
        field(18; "Global Dimension 4 Code"; Code[20])
        {
            CaptionClass = '1,2,4';
            Caption = 'Global Dimension 4 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(4), Blocked=const(false));
        }
        field(19; "Global Dimension 5 Code"; Code[20])
        {
            CaptionClass = '1,2,5';
            Caption = 'Global Dimension 5 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(5), Blocked=const(false));
        }
        field(20; MFR; Text[30])
        {
        }
        field(21; "Catalog No."; Code[20])
        {
        }
        field(22; "Currency Code"; Code[10])
        {
            TableRelation = Currency;
        }
        field(23; Decision; Option)
        {
            OptionCaption = ' ,RFQ,Order,Append to Order,Blanket Order,Append to Blanket Order,Inventory';
            OptionMembers = " ", RFQ, "Order", "Append to Order", "Blanket Order", "Append to Blanket Order", Inventory;

            trigger OnValidate()
            begin
                "Decision By":=UserId;
            end;
        }
        field(24; "Target No."; Code[20])
        {
            Caption = 'Target No.';
            Editable = true;
            TableRelation = IF(Decision=FILTER(RFQ|Order|"Blanket Order"))Vendor where("Account Type"=const(Supplier))
            ELSE IF(Decision=FILTER("Append to Order"))"Purchase Header"."No." WHERE("Document Type"=CONST(Order), Status=CONST(Open))
            ELSE IF(Decision=FILTER("Append to Blanket Order"))"Purchase Header"."No." WHERE("Document Type"=CONST("Blanket Order"))
            ELSE IF(Decision=FILTER(Inventory))Location;
        }
        field(25; Processed; Boolean)
        {
        }
        field(26; Status;Enum "Document Status")
        {
            DataClassification = CustomerContent;
        }
        field(27; "Order No"; Code[20])
        {
        }
        field(28; "Items In Budget"; Integer)
        {
            Editable = false;
        }
        field(29; "Decision By"; Code[50])
        {
        }
        field(30; "Quantity To Issue"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if("Quantity To Issue") > ("Quantity Approved" - "Quantity Issued")then Error('You Cant Issue More than Requested');
            end;
        }
        field(31; "Quantity Issued"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(32; "Issued Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(33; "Issued By"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(34; "Out of Store Bal."; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(35; "Requisition Type";Enum "Procurement Requisition Types")
        {
            Editable = false;
        }
        field(36; "Budget Available"; Boolean)
        {
            Editable = false;
        }
        field(37; "Asset Acquisition Account"; Code[10])
        {
        }
        field(38; "FA Transaction Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Transfer, Lease;
        }
        field(39; "Lease Period(Months=M,Years=Y)"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(40; "Lease Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(41; "Available Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(42; "Asset No."; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Fixed Asset"."No.";
        }
        field(43; "Qty. to Issue"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(44; "Item Category"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Item Category";
        }
        field(45; "Total Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(46; "Commitment Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(47; "Budget Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(48; "Used Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(49; "Remaining Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Requisition No", "Line No")
        {
        }
        key(Key2; "Requisition No")
        {
        }
    }
    trigger OnDelete()
    begin
        Rec.TestField(Status, Rec.Status::Open);
    end;
    var ReqHeader: Record "Requisition Header";
    ItemBudgetEntry: Record "Item Budget Entry";
    PurchPayablesSetup: Record "Purchases & Payables Setup";
    ItemRec: Record Item;
    GLAccount: Record "G/L Account";
    ExpenseCodes: Record "Expense Codes";
    FA: Record "Fixed Asset";
    FAPostingGr: Record "FA Posting Group";
    StockkeepingUnit: Record "Stockkeeping Unit";
    BudgetMgt: Codeunit "Budget Management";
    UserPersonalization: Record "User Personalization";
    RequisitionLines: Record "Requisition Lines";
}

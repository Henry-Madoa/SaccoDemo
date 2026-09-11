report 52203451 "Inventory Consumption"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Inventory Consumption.rdlc';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Item Ledger Entry"; "Item Ledger Entry")
        {
            DataItemTableView = WHERE("Entry Type"=CONST("Negative Adjmt."));
            RequestFilterFields = "Item No.", "Posting Date", "Document No.", "Global Dimension 1 Code", "Job No.", "Order No.";

            column(ItemNo_ItemLedgerEntry; "Item Ledger Entry"."Item No.")
            {
            }
            column(PostingDate_ItemLedgerEntry; "Item Ledger Entry"."Posting Date")
            {
            }
            column(Description_ItemLedgerEntry; "Item Ledger Entry".Description)
            {
            }
            column(Quantity_ItemLedgerEntry; "Item Ledger Entry".Quantity)
            {
            }
            column(JobNo_ItemLedgerEntryr; "Item Ledger Entry"."Job No.")
            {
            }
            column(CostAmountActual_ItemLedgerEntry; "Item Ledger Entry"."Cost Amount (Actual)")
            {
            }
            column(OrderNo_ItemLedgerEntry; "Item Ledger Entry"."Order No.")
            {
            }
            column(GlobalDimension1Code_ItemLedgerEntry; "Item Ledger Entry"."Global Dimension 1 Code")
            {
            }
            column(GlobalDimension2Code_ItemLedgerEntry; "Item Ledger Entry"."Global Dimension 2 Code")
            {
            }
            column(Desc; Desc)
            {
            }
            column(UnitCost; UnitCost)
            {
            }
            column(FA_Desc; "FA Desc")
            {
            }
            column(ServOrderNo; "Service Order No")
            {
            }
            column(DocumentNo_ItemLedgerEntry; "Item Ledger Entry"."Document No.")
            {
            }
            column(UnitofMeasureCode_ItemLedgerEntry; "Item Ledger Entry"."Unit of Measure Code")
            {
            }
            trigger OnAfterGetRecord()
            begin
                Item.Reset;
                Item.SetRange("No.", "Item Ledger Entry"."Item No.");
                if Item.FindSet then Desc:=Item.Description;
                ValueEntry.Reset;
                ValueEntry.SetRange("Document No.", "Item Ledger Entry"."Document No.");
                ValueEntry.SetRange("Item No.", "Item Ledger Entry"."Item No.");
                if ValueEntry.FindSet then UnitCost:=ValueEntry."Cost per Unit";
                FixedAsset.Reset;
                FixedAsset.SetRange("No.", "Item Ledger Entry"."Global Dimension 2 Code");
                if FixedAsset.FindSet then "FA Desc":=FixedAsset.Description;
            end;
        }
    }
    var Item: Record Item;
    Desc: Text;
    ValueEntry: Record "Value Entry";
    UnitCost: Decimal;
    FixedAsset: Record "Fixed Asset";
    "FA Desc": Text;
    RequisitionLines: Record "Requisition Lines";
    "Service Order No": Code[30];
}

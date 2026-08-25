page 52204045 "Loan Interest Bands"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Product Interest Bands";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Min Installments"; Rec."Min Installments")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Max Installments"; Rec."Max Installments")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interest Rate"; Rec."Interest Rate")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Processing Fee"; Rec."Processing Fee")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Post to Account Type"; Rec."Post to Account Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Post-to Account No."; Rec."Post-to Account No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Excise Duty Rate"; Rec."Excise Duty Rate")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Excise Duty Account Type"; Rec."Excise Duty Account Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Excise Duty Account No."; Rec."Excise Duty Account No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnModifyRecord(): Boolean
    begin
        If SaccoProducts.Get(Rec."Source Code") then
            Error('You cannot update Product Details');
        if ProductsManagement.Get(Rec."Source Code") then
            ProductsManagement.TestField(Status, ProductsManagement.Status::Open);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        If SaccoProducts.Get(Rec."Source Code") then Error('You cannot delete Product Details');
        if ProductsManagement.Get(Rec."Source Code") then
            ProductsManagement.TestField(Status, ProductsManagement.Status::Open);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        If SaccoProducts.Get(Rec."Source Code") then
            Error('You cannot add a new record');
        if ProductsManagement.Get(Rec."Source Code") then
            ProductsManagement.TestField(Status, ProductsManagement.Status::Open);
    end;

    var
        SaccoProducts: Record "Sacco Products";
        ProductsManagement: Record "Products Management";
}

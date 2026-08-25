page 52204187 "Linked Products"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Loan Product Linking";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Linked Product Code"; Rec."Linked Product Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Linked Product Name"; Rec."Linked Product Name")
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

page 52204091 "Transaction Calc. Scheme"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Transaction Calc. Scheme";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Lower Limit"; Rec."Lower Limit")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Upper Limit"; Rec."Upper Limit")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Rate Type"; Rec."Rate Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Rate; Rec.Rate)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Upper Charge Limit"; Rec."Upper Charge Limit")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec."Rate Type" = Rec."Rate Type"::Percentage;
                }
                field("Lower Charge Limit"; Rec."Lower Charge Limit")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec."Rate Type" = Rec."Rate Type"::Percentage;
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

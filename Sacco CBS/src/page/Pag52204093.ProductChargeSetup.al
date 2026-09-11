page 52204093 "Product Charge Setup"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Product Charge Setup";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Charge Code"; Rec."Charge Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Charge Description"; Rec."Charge Description")
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
                field("Calculation Type"; Rec."Calculation Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Source Charge"; Rec."Source Charge")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec."Calculation Type" = Rec."Calculation Type"::"Percentage of Charge";
                }
                field(Editable; Rec.Editable)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group("Calculation Scheme")
            {
                action("Rates Scheme")
                {
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Image = StepInto;
                    Ellipsis = true;
                    Scope = Repeater;
                    RunObject = page "Transaction Calc. Scheme";
                    RunPageLink = "Source Code" = field("Source Code"), "Charge Code" = field("Charge Code");
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

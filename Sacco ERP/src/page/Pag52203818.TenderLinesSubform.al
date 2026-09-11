page 52203818 "Tender Lines Subform"
{
    PageType = ListPart;
    SourceTable = "Procurement Request Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field(No; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                }
                field(Location; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Create Item/Fixed Asset")
            {
                trigger OnAction()
                var
                    FixedAsset: Record "Fixed Asset";
                    Item: Record Item;
                    NoSeriesManagement: Codeunit NoSeriesManagement;
                    FASetup: Record "FA Setup";
                    InventorySetup: Record "Inventory Setup";
                begin
                    if not Confirm('Are you sure you want to create ' + Format(Rec.Type))then exit;
                    if Rec.Type in[Rec.Type::"Fixed Asset"]then begin
                        FASetup.Get;
                        FASetup.TestField("Fixed Asset Nos.");
                        if Rec."No." = '' then begin
                            Rec."No.":=NoSeriesManagement.GetNextNo(FASetup."Fixed Asset Nos.", 0D, true);
                            Rec.Modify(true);
                            FixedAsset.Init;
                            FixedAsset.Validate("No.", Rec."No.");
                            FixedAsset.Validate(Description, Rec.Name);
                            FixedAsset.Validate("Location Code", Rec."Location Code");
                            FixedAsset.Validate("FA Location Code", Rec."Location Code");
                            FixedAsset.Insert;
                        end;
                        Commit;
                        if FixedAsset.Get(Rec."No.")then PAGE.RunModal(PAGE::"Fixed Asset Card", FixedAsset);
                    end;
                    if Rec.Type in[Rec.Type::Item]then begin
                        if Rec."No." = '' then begin
                            InventorySetup.Get;
                            InventorySetup.TestField("Item Nos.");
                            Rec."No.":=NoSeriesManagement.GetNextNo(InventorySetup."Item Nos.", 0D, true);
                            Rec.Modify(true);
                            Item.Init;
                            Item."No.":=Rec."No.";
                            Item.Validate(Description, Rec.Name);
                            Item.Insert;
                        end;
                        Commit;
                        if Item.Get(Rec."No.")then PAGE.RunModal(PAGE::"Item Card", Item);
                    end;
                end;
            }
        }
    }
}

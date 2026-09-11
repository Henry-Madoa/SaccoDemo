page 52203855 "D.P Lines Subform"
{
    InsertAllowed = false;
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
                    Editable = false;
                }
                field(No; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
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
                    Caption = 'Unit Price';
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                }
                // field("Car Repair/Maintenance"; Rec."Car Repair/Maintenance")
                // {
                //     ApplicationArea = All;
                //     Editable = false;
                // }
                // field("Vehicle Reg. No"; Rec."Vehicle Reg. No")
                // {
                //     ApplicationArea = All;
                //     Editable = false;
                // }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            // field("FA Transaction Type"; Rec."FA Transaction Type")
            // {
            //     ApplicationArea = All;
            //     Editable = false;
            // }
            // field("Project Code"; Rec."Project Code")
            // {
            //     ApplicationArea = All;
            // }
            // field("Grant No."; Rec."Grant No.")
            // {
            //     ApplicationArea = All;
            // }
            // field("Objective Code"; Rec."Objective Code")
            // {
            //     ApplicationArea = All;
            // }
            // field("Output Code"; Rec."Output Code")
            // {
            //     ApplicationArea = All;
            // }
            // field("Outcome Code"; Rec."Outcome Code")
            // {
            //     ApplicationArea = All;
            // }
            // field("Activity Code"; Rec."Activity Code")
            // {
            //     ApplicationArea = All;
            // }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Create Item/Fixed Asset")
            {
                ApplicationArea = All;

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

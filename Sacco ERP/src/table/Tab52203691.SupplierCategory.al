table 52203691 "Supplier Category"
{
    DrillDownPageID = "Supplier Category";
    LookupPageID = "Supplier Category";

    fields
    {
        field(1; "Category Code"; Code[10])
        {
            NotBlank = true;
        }
        field(2; Description; Text[250])
        {
        }
        field(3; "Vendor Posting Group"; Code[10])
        {
            TableRelation = "Vendor Posting Group";
        }
        field(4; "Gen. Bus. Posting Group"; Code[10])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";

            trigger OnValidate()
            begin
                if xRec."Gen. Bus. Posting Group" <> "Gen. Bus. Posting Group" then if GenBusPostingGrp.ValidateVatBusPostingGroup(GenBusPostingGrp, "Gen. Bus. Posting Group")then Validate("VAT Bus. Posting Group", GenBusPostingGrp."Def. VAT Bus. Posting Group");
            end;
        }
        field(5; "VAT Bus. Posting Group"; Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
    }
    keys
    {
        key(Key1; "Category Code")
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Category Code", Description, "Vendor Posting Group", "Gen. Bus. Posting Group", "Vendor Posting Group")
        {
        }
        fieldgroup(Brick; "Category Code", Description, "Vendor Posting Group", "Gen. Bus. Posting Group", "Vendor Posting Group")
        {
        }
    }
    var GenBusPostingGrp: Record "Gen. Business Posting Group";
}

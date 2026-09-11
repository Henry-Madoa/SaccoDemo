page 52203949 "Asset Management Setup"
{
    PageType = Card;
    SourceTable = "Asset Management Setup";
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
            }
            group("Transaction A/C's")
            {
                field("Deposit G/L Account"; Rec."Deposit G/L Account")
                {
                    ApplicationArea = All;
                }
                field("Rent G/L Account"; Rec."Rent G/L Account")
                {
                    ApplicationArea = All;
                }
                field("Water G/L Account"; Rec."Water G/L Account")
                {
                    ApplicationArea = All;
                }
                field("Electricity G/L Account"; Rec."Electricity G/L Account")
                {
                    ApplicationArea = All;
                }
                field("Repairs G/L Account"; Rec."Repairs G/L Account")
                {
                    ApplicationArea = All;
                }
                field("Other Amenities G/L A/C"; Rec."Other Amenities G/L A/C")
                {
                    ApplicationArea = All;
                }
            }
            group(Numbering)
            {
                field("LandLord Nos"; Rec."LandLord Nos")
                {
                    ApplicationArea = All;
                }
                field("Tenants Booking Nos"; Rec."Tenants Booking Nos")
                {
                    ApplicationArea = All;
                }
                field("Property Nos"; Rec."Property Nos")
                {
                    ApplicationArea = All;
                }
                field("Receipt Nos"; Rec."Receipt Nos")
                {
                    ApplicationArea = All;
                }
                field("Bill Schedule Nos"; Rec."Bill Schedule Nos")
                {
                    ApplicationArea = All;
                }
                field("Property Manager Nos"; Rec."Property Manager Nos")
                {
                    ApplicationArea = All;
                }
            }
            group("Tenant Posting")
            {
                field("Customer Posting Group"; Rec."Customer Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
    }
    trigger OnOpenPage()
    var
        AssetMgmtSeup: Record "Asset Management Setup";
    begin
        if AssetMgmtSeup.IsEmpty then begin
            AssetMgmtSeup.Init();
            AssetMgmtSeup.Insert(true);
        end;
    end;
}

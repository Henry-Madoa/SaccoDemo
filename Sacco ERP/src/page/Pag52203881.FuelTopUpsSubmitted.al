page 52203881 "Fuel Top-Ups - Submitted"
{
    ApplicationArea = All;
    Caption = 'Fuel Card Top-Up - Submitted';
    CardPageID = "Fuel Top-Up Card";
    PageType = List;
    SourceTable = "Fuel Card Top-Up";
    SourceTableView = WHERE(Submitted=CONST(true));
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Card No."; Rec."Card No.")
                {
                    ApplicationArea = All;
                }
                field("Top-Up Amount"; Rec."Top-Up Amount")
                {
                    ApplicationArea = All;
                }
                field("Top-Up Date"; Rec."Top-Up Date")
                {
                    ApplicationArea = All;
                }
                field(Submitted; Rec.Submitted)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
    }
}

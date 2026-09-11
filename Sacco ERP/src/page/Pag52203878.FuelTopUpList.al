page 52203878 "Fuel Top-Up List"
{
    ApplicationArea = All;
    Caption = 'Fuel Card Top-Up';
    CardPageID = "Fuel Top-Up Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Fuel Card Top-Up";
    SourceTableView = WHERE(Submitted=CONST(false));
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

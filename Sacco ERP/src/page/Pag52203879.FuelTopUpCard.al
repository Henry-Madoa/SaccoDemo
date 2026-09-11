page 52203879 "Fuel Top-Up Card"
{
    ApplicationArea = All;
    Caption = 'Fuel Card Top-Up';
    PageType = Card;
    SourceTable = "Fuel Card Top-Up";
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Card No."; Rec."Card No.")
                {
                    ApplicationArea = All;
                }
                field("Card Description"; Rec."Card Description")
                {
                    ApplicationArea = All;
                }
                field("Card Type"; Rec."Card Type")
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
        area(processing)
        {
            action(Submit)
            {
                ApplicationArea = All;
                Image = SendConfirmation;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Submitted, false);
                    Rec.TestField("Card No.");
                    Rec.TestField("Card Type");
                    Rec.TestField("Card Description");
                    Rec.TestField("Top-Up Amount");
                    Rec.TestField("Top-Up Date");
                    if not Confirm('Are you sure you want to submit the fuel top-up?')then exit;
                    Rec.Submitted:=true;
                    Rec.Modify(true);
                    CurrPage.Close;
                end;
            }
        }
    }
}

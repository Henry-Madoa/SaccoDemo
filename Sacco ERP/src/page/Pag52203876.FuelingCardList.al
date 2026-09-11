page 52203876 "Fueling Card List"
{
    ApplicationArea = All;
    CardPageID = "Fueling Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Fueling Card";
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
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Amount Usage"; Rec."Amount Usage")
                {
                    ApplicationArea = All;
                }
                field("Expiry Date"; Rec."Expiry Date")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
    }
    trigger OnAfterGetCurrRecord()
    begin
        Rec.CalcFields(Amount, "Amount Usage");
        Rec."Amount Balance":=Rec.Amount - Rec."Amount Usage";
    end;
    trigger OnOpenPage()
    begin
        Rec.CalcFields(Amount, "Amount Usage");
        Rec."Amount Balance":=Rec.Amount - Rec."Amount Usage";
    end;
}

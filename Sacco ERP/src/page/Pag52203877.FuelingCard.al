page 52203877 "Fueling Card"
{
    ApplicationArea = All;
    PageType = Card;
    SourceTable = "Fueling Card";
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
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field("Vehicle REG. No."; Rec."Vehicle REG. No.")
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Amount Usage"; Rec."Amount Usage")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Amount Balance"; Rec."Amount Balance")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Reminder If Low"; Rec."Reminder If Low")
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
    trigger OnInit()
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

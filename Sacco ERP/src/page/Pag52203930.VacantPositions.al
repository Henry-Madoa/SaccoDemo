page 52203930 "Vacant Positions"
{
    Editable = false;
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Company Jobs";

    layout
    {
        area(content)
        {
            repeater(Control5)
            {
                ShowCaption = false;

                field("Job ID"; Rec."Job ID")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field("No of Posts"; Rec."No of Posts")
                {
                    ApplicationArea = All;
                }
                field("Occupied Position"; Rec."Occupied Position")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.Reset;
        if Rec.Find('-')then begin
            repeat Rec.CalcFields("Occupied Position");
                // MESSAGE('%1',"Occupied Position");
                Rec."Vacant Posistions":=Rec."No of Posts" - Rec."Occupied Position";
                Rec.Modify;
            until Rec.Next = 0;
        end;
        Rec.Reset;
        Rec.SetCurrentKey("Vacant Posistions");
        Rec.SetFilter("Vacant Posistions", '>%1', 0);
    end;
}

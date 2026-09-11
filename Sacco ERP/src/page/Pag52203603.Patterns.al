page 52203603 "Patterns"
{
    PageType = List;
    SourceTable = "RegEx Pattern";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(rep)
            {
                field(RegEx; Rec.RegEx)
                {
                    ApplicationArea = Basic, Suite;
                    Width = 5;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                //MultiLine = true;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.create();
    end;
}

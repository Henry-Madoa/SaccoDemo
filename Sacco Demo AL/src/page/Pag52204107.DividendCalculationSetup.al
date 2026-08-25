page 52204107 "Dividend Calculation Setup"
{
    PageType = ListPart;
    SourceTable = "Dividend Calculation Params";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posting Description"; Rec."Posting Description")
                {
                    ShowMandatory = true;
                }
                field(Rate; Rec.Rate)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Rate Type"; Rec."Rate Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Share Capital"; Rec."Share Capital")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Minimum Balance"; Rec."Minimum Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

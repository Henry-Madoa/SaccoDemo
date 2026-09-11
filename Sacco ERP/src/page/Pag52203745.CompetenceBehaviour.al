page 52203745 "Competence Behaviour"
{
    PageType = List;
    SourceTable = "Competence Behaviour";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line No"; Rec."Line No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Behaviour; Rec.Behaviour)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Behaviour Description"; Rec."Behaviour Description")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Weight; Rec.Weigths)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Weight';
                }
            }
        }
    }
}

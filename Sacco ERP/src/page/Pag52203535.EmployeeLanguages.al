page 52203535 "Employee Languages"
{
    PageType = List;
    SourceTable = "Employee Languages";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Language; Rec.Language)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Read; Rec.Read)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Write; Rec.Write)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Speak; Rec.Speak)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

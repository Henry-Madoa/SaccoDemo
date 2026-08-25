page 52204134 "Employer Departments"
{
    PageType = ListPart;
    SourceTable = "Employer Departments";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Employer Code"; Rec."Employer Code")
                {
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                }
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

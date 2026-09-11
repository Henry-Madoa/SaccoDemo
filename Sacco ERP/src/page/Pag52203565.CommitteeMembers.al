page 52203565 "Committee Members"
{
    SourceTable = "Committee Members";
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control6)
            {
                ShowCaption = false;

                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(SurName; Rec.SurName)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(OtherNames; Rec.OtherNames)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Designation; Rec.Designation)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

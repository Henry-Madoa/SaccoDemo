page 52203959 "Job Professional Bodies"
{
    PageType = ListPart;
    SourceTable = "Job Professional Bodies";
    Caption = 'Professional Bodies';

    layout
    {
        area(content)
        {
            repeater(Control6)
            {
                ShowCaption = false;

                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                }
                field("Score ID"; Rec."Score ID")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}

page 52203977 "Applicant Languages"
{
    PageType = ListPart;
    SourceTable = "Applicant Languages";
    Caption = 'Languages';

    layout
    {
        area(content)
        {
            repeater(Control6)
            {
                ShowCaption = false;

                field("Applicant No."; Rec."Applicant No.")
                {
                    ApplicationArea = All;
                    Visible = WebServiceVisibility;
                }
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Language; Rec.Language)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    var WebServiceVisibility: Boolean;
}

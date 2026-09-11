page 52203976 "Applicant Hobbies"
{
    PageType = ListPart;
    SourceTable = "Applicant Hobbies";
    Caption = 'Hobbies';

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
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Visible = WebServiceVisibility;
                }
                field(Hobby; Rec.Hobby)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    var WebServiceVisibility: Boolean;
}

page 52203975 "Applicant Referees"
{
    PageType = ListPart;
    SourceTable = "Applicant Referees";
    Caption = 'Referees';

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
                field(Referee; Rec.Referee)
                {
                    ApplicationArea = All;
                }
                field(Occupation; Rec.Occupation)
                {
                    ApplicationArea = All;
                }
                field("Mobile Phone"; Rec."Mobile Phone")
                {
                    ApplicationArea = All;
                }
                field(Email; Rec.Email)
                {
                    ApplicationArea = All;
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                }
                field(Insititution; Rec.Insititution)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    var WebServiceVisibility: Boolean;
}

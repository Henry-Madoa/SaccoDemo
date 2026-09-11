page 52203978 "Applicant Employment History"
{
    PageType = ListPart;
    SourceTable = "Applicant Current Employment";

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
                field("Currently Employment"; Rec."Currently Employment")
                {
                    ApplicationArea = All;
                    Visible = WebServiceVisibility;
                }
                field(Position; Rec."Substantive Post")
                {
                    ApplicationArea = All;
                }
                field(Institution; Rec."Employer/Institution Name")
                {
                    ApplicationArea = All;
                }
                field(Sector; Rec.Sector)
                {
                    ApplicationArea = All;
                }
                field("Sector Specification"; Rec."Sector Specification")
                {
                    Editable = Rec.Sector = Rec.Sector::Others;
                    ApplicationArea = All;
                }
                field("From Date"; Rec."From Date")
                {
                    ApplicationArea = All;
                }
                field("To Date"; Rec."To Date")
                {
                    ApplicationArea = All;
                }
                field("Employment Period"; Rec."Employment Period")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    var WebServiceVisibility: Boolean;
}

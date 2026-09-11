page 52203963 "Applicant Work Experience"
{
    PageType = ListPart;
    SourceTable = "Applicant Work Experience";
    Caption = 'Work Experience';

    layout
    {
        area(content)
        {
            repeater(Control6)
            {
                field("Applicant No."; Rec."Applicant No.")
                {
                    ApplicationArea = All;
                //Visible = WebServiceVisibility;
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                }
                field("From Date"; Rec."From Date")
                {
                    ApplicationArea = All;
                }
                field("Currently Working Here"; Rec."Currently Working Here")
                {
                    ApplicationArea = All;
                }
                field("To Date"; Rec."To Date")
                {
                    ApplicationArea = All;
                }
                field("Job Title"; Rec."Job Title")
                {
                    ApplicationArea = All;
                }
                field("Key Experience"; Rec."Key Experience")
                {
                    ApplicationArea = All;
                }
                field("Salary On Leaving"; Rec."Salary On Leaving")
                {
                    ApplicationArea = All;
                }
                field("Postal Address"; Rec."Postal Address")
                {
                    ApplicationArea = All;
                }
                field("Address 2"; Rec."Address 2")
                {
                    ApplicationArea = All;
                }
                field("Reason For Leaving"; Rec."Reason For Leaving")
                {
                    ApplicationArea = All;
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    var WebServiceVisibility: Boolean;
}

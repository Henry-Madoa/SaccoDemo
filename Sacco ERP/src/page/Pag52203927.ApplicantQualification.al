page 52203927 "Applicant Qualification"
{
    PageType = ListPart;
    SourceTable = "Applicants Qualification";

    layout
    {
        area(content)
        {
            repeater(Control9)
            {
                ShowCaption = false;

                field("Applicant No."; Rec."Applicant No.")
                {
                    ApplicationArea = All;
                //Visible = isWebService;
                }
                field("Qualification Type"; Rec."Qualification Type")
                {
                    ApplicationArea = All;
                //Visible = isWebService;
                }
                field("Qualification Code"; Rec."Qualification Code")
                {
                    ApplicationArea = All;
                }
                field(Qualification; Rec.Qualification)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
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
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field("Institution/Company"; Rec."Institution/Company")
                {
                    ApplicationArea = All;
                }
                field("Attachment Link"; Rec."Attachment Link")
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

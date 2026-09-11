page 52203961 "Applicant Professional Bodies"
{
    PageType = ListPart;
    SourceTable = "Applicant Professional Bodies";
    Caption = 'Professional Bodies';

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
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Membership No."; Rec."Membership No.")
                {
                    ApplicationArea = All;
                }
                field("Membership Status"; Rec."Membership Status")
                {
                    ApplicationArea = All;
                }
            // field(Priority; Rec.Priority)
            // {
            //     ApplicationArea = All;
            // }
            // field("Score ID"; Rec."Score ID")
            // {
            //     ApplicationArea = All;
            // }
            }
        }
    }
    var WebServiceVisibility: Boolean;
}

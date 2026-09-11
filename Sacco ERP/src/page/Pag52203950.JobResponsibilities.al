page 52203950 "&Job Responsibilities"
{
    PageType = ListPart;
    SourceTable = "Job Responsibilities";
    Caption = 'Responsibilities';

    layout
    {
        area(content)
        {
            repeater(Control6)
            {
                ShowCaption = false;

                field("Line No"; Rec."Line No")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = WebServiceVisibility;
                }
                field("Job Id"; Rec."Job Id")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = WebServiceVisibility;
                }
                field("Responsibility Description"; Rec."Responsibility Description")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Specifications")
            {
                ApplicationArea = All;
                Image = PayrollStatistics;
                RunObject = page "Job Responsibilities Specs";
                RunPageLink = "Job Id"=FIELD("Job Id"), "Line No"=field("Line No");
            }
        }
    }
    var WebServiceVisibility: Boolean;
}

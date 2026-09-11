page 52203953 "Job Responsibilities Specs"
{
    PageType = ListPart;
    SourceTable = "Job Responsibilities Specs";
    Caption = 'Responsibilities Specifications';

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
                    Visible = IsVisible;
                }
                field("Job Id"; Rec."Job Id")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = IsVisible;
                }
                field(Specification; Rec.Specification)
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
    var IsVisible: Boolean;
}

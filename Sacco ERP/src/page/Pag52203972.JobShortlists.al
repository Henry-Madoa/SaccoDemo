page 52203972 "Job Shortlists"
{
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Job Shortlisting";
    PageType = List;
    CardPageId = "Job Shortlisting";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Requisition No."; Rec."Requisition No.")
                {
                    ApplicationArea = All;
                }
                field("Job ID"; Rec."Job ID")
                {
                    ApplicationArea = All;
                }
                field("Job Title"; Rec."Job Title")
                {
                    ApplicationArea = All;
                }
                field("No of Positions"; Rec."No of Positions")
                {
                    ApplicationArea = All;
                }
                field("No of Applicants"; Rec."No of Applicants")
                {
                    ApplicationArea = All;
                }
                field(Date; Rec.Date)
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Reporting)
        {
            action(Report)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                Image = Report;

                trigger OnAction()
                begin
                    Rec.Reset();
                    Rec.SetRange("No.", Rec."No.");
                    Report.Run(Report::"Job Shortlisting", true, false, Rec);
                end;
            }
        }
    }
}

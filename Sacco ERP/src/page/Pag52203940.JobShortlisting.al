page 52203940 "Job Shortlisting"
{
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Job Shortlisting";
    PageType = Card;
    Caption = 'Listing';

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = Rec.Status = Rec.Status::Open;

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                field("Requisition No."; Rec."Requisition No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
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
                field("Pass Mark"; Rec."Pass Mark")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Preferred Gender"; Rec."Preferred Gender")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    Editable = Rec.Type = Rec.Type::"Long List";
                }
                field("Work Experience"; Rec."Work Experience")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    Editable = Rec.Type = Rec.Type::"Long List";
                }
                field("Age Limit"; Rec."Age Limit")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    Editable = Rec.Type = Rec.Type::"Long List";
                }
            }
            part(ShortlistingCriteria; "Job Shortlisting Criteria")
            {
                Editable = Rec.Status = Rec.Status::Open;
                ApplicationArea = All;
                SubPageLink = "No."=FIELD("No.");
            }
            part(LonglistedApplicants; "Job Applications")
            {
                ApplicationArea = All;
                Caption = 'Qualified';
                SubPageLink = "Requisition No."=FIELD("Requisition No."), Status=const("Long Listed");
                Visible = Rec.Type = Rec.Type::"Long List";
            }
            part("&ShortlistedApplicants"; "Job Applications")
            {
                ApplicationArea = All;
                Caption = 'Qualified';
                SubPageLink = "Requisition No."=FIELD("Requisition No."), Status=const(Shortlisted);
                Visible = Rec.Type = Rec.Type::"Short List";
            }
            part(FailedLonglistedApplicants; "Job Applications")
            {
                ApplicationArea = All;
                Caption = 'Un-Qualified';
                SubPageLink = "Requisition No."=FIELD("Requisition No."), Status=const(Unsuccessful);
            }
            part(ShortlistedApplicants; "Job Shortlisted Applicants")
            {
                Editable = Rec.Status = Rec.Status::Open;
                Visible = Rec.Type = Rec.Type::"Short List";
                ApplicationArea = All;
                SubPageLink = "No."=FIELD("No.");
            }
            group(Trail)
            {
                field("Created By"; Rec."Created By")
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
        area(Processing)
        {
            action("Longlisting")
            {
                ApplicationArea = All;
                Image = LinesFromTimesheet;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = ((Rec.Status = Rec.Status::Open) and (Rec.Type = Rec.Type::"Long List"));

                trigger OnAction()
                begin
                    JobApplicationMgmt.GetLongListedApplicants(Rec);
                end;
            }
            action("Close LongListing")
            {
                ApplicationArea = All;
                Image = Close;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = ((Rec.Status = Rec.Status::Open) and (Rec.Type = Rec.Type::"Long List"));

                trigger OnAction()
                begin
                    JobApplicationMgmt.CloseLonglisting(Rec);
                end;
            }
            action("ReOpen LongList")
            {
                ApplicationArea = All;
                Image = ReOpen;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = ((Rec.Status = Rec.Status::Open) and (Rec.Type = Rec.Type::"Short List"));

                trigger OnAction()
                begin
                    JobApplicationMgmt.ReOpenLonglisting(Rec);
                end;
            }
            action("Shortlisting")
            {
                ApplicationArea = All;
                Image = LinesFromTimesheet;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = ((Rec.Status = Rec.Status::Open) and (Rec.Type = Rec.Type::"Short List"));

                trigger OnAction()
                begin
                    JobApplicationMgmt.Shortlisting(Rec);
                end;
            }
            action("Close ShortListing")
            {
                ApplicationArea = All;
                Image = Close;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = ((Rec.Status = Rec.Status::Open) and (Rec.Type = Rec.Type::"Short List"));

                trigger OnAction()
                begin
                    JobApplicationMgmt.CloseShortlisting(Rec);
                end;
            }
            action("ReOpen ShortList")
            {
                ApplicationArea = All;
                Image = ReOpen;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = ((Rec.Status = Rec.Status::Closed) and (Rec.Type = Rec.Type::"Short List"));

                trigger OnAction()
                begin
                    JobApplicationMgmt.ReopenShortlisting(Rec);
                end;
            }
        }
    }
    var JobApplicationMgmt: Codeunit "Job Application Management";
}

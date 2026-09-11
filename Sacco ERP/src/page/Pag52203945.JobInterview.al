page 52203945 "Job Interview"
{
    PageType = Card;
    SourceTable = "Job Interview";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                field("Shortlisting No."; Rec."Shortlisting No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
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
                field(Committee; Rec.Committee)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Commitee Name"; Rec."Commitee Name")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                field("Pass Mark"; Rec."Pass Mark")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
            }
            group("Closing Details")
            {
                Visible = Rec.Status = Rec.Status::Open;

                field("Subsequent Interview Mail"; Rec."Subsequent Interview Mail")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    Visible = Rec.Subsequent;
                }
                field("Discussion Date"; Rec."Discussion Date")
                {
                    ApplicationArea = All;
                }
                field("Discussion Time"; Rec."Discussion Time")
                {
                    ApplicationArea = All;
                }
            }
            part(Interviwees; "Job Interview Applicants")
            {
                ApplicationArea = All;
                SubPageLink = "No."=FIELD("No.");
            }
            part("&QualifiedApplicants"; "Job Applications")
            {
                ApplicationArea = All;
                Caption = 'Qualified';
                SubPageLink = "Requisition No."=FIELD("Requisition No."), Status=const(Interview);
            }
            part(UnQualifiedApplicants; "Job Interview Applicants")
            {
                ApplicationArea = All;
                Caption = 'Un-Qualified';
                SubPageLink = "No."=FIELD("No."), Qualified=const(false);
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
                field("Closed By"; Rec."Closed By")
                {
                    ApplicationArea = All;
                }
                field("Closed Date"; Rec."Closed Date")
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
                    Report.Run(Report::"Job Interview", true, false, Rec);
                end;
            }
        }
        area(processing)
        {
            action(AssignInterviewers)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Assign Interviewers';
                Image = CreateRating;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = Rec.Status = Rec.Status::Created;

                trigger OnAction()
                begin
                    JobApplicationMgmt.AssignInterviewers(Rec);
                end;
            }
            action("Send Invitations")
            {
                ApplicationArea = Basic, Suite;
                Image = SendEmailPDF;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = Rec.Status = Rec.Status::Created;

                trigger OnAction()
                begin
                    JobApplicationMgmt.SendInterviewEmailInvitations(Rec);
                end;
            }
            separator(Separator13)
            {
            }
            action(GetQualified)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Get Qualified';
                Image = EmployeeAgreement;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = Rec.Status = Rec.Status::Open;

                trigger OnAction()
                begin
                    JobApplicationMgmt.GetQualifiedInterviwee(Rec);
                end;
            }
            action("Close & Open Next Interview")
            {
                ApplicationArea = Basic, Suite;
                Image = NextSet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                //Visible = Rec.Status = Rec.Status::Open;
                Visible = false;

                trigger OnAction()
                begin
                    JobApplicationMgmt."Close&CreateNextInterview"(Rec);
                end;
            }
            action(Close)
            {
                ApplicationArea = Basic, Suite;
                Image = CloseDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = Rec.Status = Rec.Status::Open;

                trigger OnAction()
                begin
                    JobApplicationMgmt.CloseInterview(Rec);
                end;
            }
        }
    }
    var JobApplicationMgmt: Codeunit "Job Application Management";
}

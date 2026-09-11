page 52203935 "Job Applications"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate';
    Editable = false;
    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Job Application";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Applicant No."; Rec."Applicant No.")
                {
                    ApplicationArea = All;
                }
                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = All;
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ApplicationArea = All;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = All;
                }
                field(Initials; Rec.Initials)
                {
                    ApplicationArea = All;
                }
                field("Search Name"; Rec."Search Name")
                {
                    ApplicationArea = All;
                }
                field(Address; Rec.Address)
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
                field(Date; Rec.Date)
                {
                    ApplicationArea = All;
                }
                field(Score; Rec.Score)
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field(Remark; Rec.Remark)
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
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
                RunObject = report "Job Applications";
            }
            action("Excel Report")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                Image = Excel;
                RunObject = report "Job Applications Listing";
            }
        }
        area(Processing)
        {
            action("Applicant")
            {
                ApplicationArea = All;
                Image = Employee;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page Applicant;
                RunPageMode = View;
                RunPageLink = "No."=field("Applicant No.");
            }
            action("Job Card")
            {
                ApplicationArea = All;
                Image = Job;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Company Job";
                RunPageMode = View;
                RunPageLink = "Job ID"=field("Job ID");
            }
            action("&Requirements")
            {
                ApplicationArea = All;
                Image = AbsenceCategory;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Job Requirements";
                RunPageMode = View;
                RunPageLink = "Job Id"=field("Job ID");
            }
            action("&Responsibilities")
            {
                ApplicationArea = All;
                Image = Responsibility;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "&Job Responsibilities";
                RunPageMode = View;
                RunPageLink = "Job Id"=field("Job ID");
            }
            action("&Competencies")
            {
                ApplicationArea = All;
                Image = CompleteLine;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Job Compitencies";
                RunPageMode = View;
                RunPageLink = "Job Id"=field("Job ID");
            }
            action("&Professional Certificates")
            {
                ApplicationArea = All;
                Image = JobListSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Job Professional Certs";
                RunPageMode = View;
                RunPageLink = "Job Id"=field("Job ID");
            }
            action("&Professional Bodies")
            {
                ApplicationArea = All;
                Image = BOM;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Job Professional Bodies";
                RunPageMode = View;
                RunPageLink = "Job Id"=field("Job ID");
            }
        }
    }
}

page 52203947 "Job Shortlisted Applicants"
{
    Editable = false;
    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Job Shortlisted Applicants";
    Caption = 'Shortlisted Applicants';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
                field(Score; Rec.Score)
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
            action("Applicant")
            {
                ApplicationArea = All;
                Image = Employee;
                RunObject = Page Applicant;
                RunPageMode = View;
                RunPageLink = "No."=field("Applicant No.");
            }
            action("Job Card")
            {
                ApplicationArea = All;
                Image = Job;
                RunObject = Page "Company Job";
                RunPageMode = View;
                RunPageLink = "Job ID"=field("Job ID");
            }
            action("&Requirements")
            {
                ApplicationArea = All;
                Image = AbsenceCategory;
                RunObject = Page "Job Requirements";
                RunPageMode = View;
                RunPageLink = "Job Id"=field("Job ID");
            }
            action("&Responsibilities")
            {
                ApplicationArea = All;
                Image = Responsibility;
                RunObject = Page "&Job Responsibilities";
                RunPageMode = View;
                RunPageLink = "Job Id"=field("Job ID");
            }
            action("&Competencies")
            {
                ApplicationArea = All;
                Image = CompleteLine;
                RunObject = Page "Job Compitencies";
                RunPageMode = View;
                RunPageLink = "Job Id"=field("Job ID");
            }
            action("&Professional Certificates")
            {
                ApplicationArea = All;
                Image = JobListSetup;
                RunObject = Page "Job Professional Certs";
                RunPageMode = View;
                RunPageLink = "Job Id"=field("Job ID");
            }
            action("&Professional Bodies")
            {
                ApplicationArea = All;
                Image = BOM;
                RunObject = Page "Job Professional Bodies";
                RunPageMode = View;
                RunPageLink = "Job Id"=field("Job ID");
            }
        }
    }
}

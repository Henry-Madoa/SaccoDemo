page 52203971 "Job Interview Applicants"
{
    InsertAllowed = false;
    DeleteAllowed = false;
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Job Interview Applicants";
    Caption = 'Interviwees';

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
                field("Interview Venue"; Rec."Interview Venue")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Interview Date"; Rec."Interview Date")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Interview Time"; Rec."Interview Time")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group("Interview Marks")
            {
                action("Allocate Marks")
                {
                    ApplicationArea = All;
                    Image = Allocate;
                    RunObject = Page "Job Interview Rating";
                    RunPageLink = "No."=FIELD("No."), "Applicant No"=field("Applicant No.");
                }
            }
        }
    }
}

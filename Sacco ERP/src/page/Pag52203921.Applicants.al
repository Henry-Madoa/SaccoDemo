page 52203921 Applicants
{
    // version THL- HRM 1.0
    CardPageID = Applicant;
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Applicant;
    Editable = true;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a number for the employee.';
                }
                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the employee''s first name.';
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the employee''s middle name.';
                }
                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the employee''s last name.';
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the employee''s email address.';
                }
                field("Applicant Type"; Rec."Applicant Type")
                {
                    ApplicationArea = All;
                }
                field("Highest Level Of Education"; Rec."Highest Level Of Education")
                {
                    ApplicationArea = All;
                }
                field("Job Applied For"; Rec."Job ID")
                {
                    ApplicationArea = All;
                }
                field("Vacany No."; Rec."Vacany No.")
                {
                    ToolTip = 'Specifies the value of the Vacany No. field.';
                }
                field("Job Description"; Rec."Position Applied For")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the postal code of the address.';
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the last day this entry was modified.';
                }
                field(Shortlisting; Rec.Shortlisting)
                {
                    ApplicationArea = All;
                }
                field(Interview; Rec.Interview)
                {
                    ApplicationArea = All;
                }
                field("Total Interview Marks"; Rec."Total Interview Marks")
                {
                    ApplicationArea = All;
                }
                field("Offer Status"; Rec."Offer Status")
                {
                    ApplicationArea = All;
                }
                field("Offer Signed By"; Rec."Offer Signed By")
                {
                    ApplicationArea = All;
                }
                field("Years Of Experience"; Rec."Years Of Experience")
                {
                    ApplicationArea = All;
                }
                /*field("Years Of Relevant Experience"; Rec."Years Of Relevant Experience")
                {
                    ApplicationArea = All;
                }
                field("Current/Expected Salary"; Rec."Current/Expected Salary")
                {
                    ApplicationArea = All;
                }*/
                field("Current Salary"; Rec."Current Salary")
                {
                    ApplicationArea = All;
                }
                field("Expected Salary"; Rec."Expected Salary")
                {
                    ApplicationArea = All;
                }
                field("Portal ID"; Rec."Portal ID")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID"=CONST(Database::Applicant), "No."=FIELD("No.");
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = All;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Offer of Employment")
            {
                ApplicationArea = All;
                Image = "Report";
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Rec.Reset;
                    Rec.SetRange("No.", Rec."No.");
                    REPORT.Run(Report::"Offer of Employment", true, false, Rec);
                end;
            }
            action("Offer Accepted")
            {
                ApplicationArea = All;
                Image = Confirm;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = Rec."Offer Status" = Rec."Offer Status"::"Offer Made";

                trigger OnAction()
                begin
                    OnboardingMgt.OfferAccepted(Rec);
                end;
            }
            action("Offer Rejected")
            {
                ApplicationArea = All;
                Image = Reject;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = Rec."Offer Status" = Rec."Offer Status"::"Offer Made";

                trigger OnAction()
                begin
                    OnboardingMgt.OfferRejected(Rec);
                end;
            }
            action("Reported To Work")
            {
                ApplicationArea = All;
                Image = JobTimeSheet;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = Rec."Offer Status" = Rec."Offer Status"::"Accepted Offer";

                trigger OnAction()
                begin
                    OnboardingMgt.ReportedToWork(Rec);
                end;
            }
            action("No Show")
            {
                ApplicationArea = All;
                Image = Absence;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = Rec."Offer Status" = Rec."Offer Status"::"Accepted Offer";

                trigger OnAction()
                begin
                    OnboardingMgt.NoShow(Rec);
                end;
            }
        }
    }
    var OnboardingMgt: Codeunit "Onboarding Management";
}

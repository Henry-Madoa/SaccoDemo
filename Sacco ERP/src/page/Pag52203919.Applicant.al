page 52203919 "Applicant"
{
    // version THL- HRM 1.0
    PageType = Card;
    SourceTable = Applicant;

    layout
    {
        area(content)
        {
            field("No."; Rec."No.")
            {
                ApplicationArea = All;
                Visible = false;
            }
            group("A. VACANCY DETAILS")
            {
                field("Job Requisition"; Rec."Job Requisition")
                {
                    ApplicationArea = All;
                }
                field("Job ID"; Rec."Job ID")
                {
                    ApplicationArea = All;
                }
                field("Position Applied For"; Rec."Position Applied For")
                {
                    ApplicationArea = All;
                }
                field("Vacany No."; Rec."Vacany No.")
                {
                    ApplicationArea = All;
                }
            }
            group("B. PERSONAL DETAILS")
            {
                field(Initials; Rec.Initials)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the employee''s initials. : Mr, Ms, Mrs,Dr, Prof, Other';
                }
                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the employee''s first name.';
                }
                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the employee''s last name.';
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ApplicationArea = All;
                    Caption = 'Middle Name/Initials';
                    ToolTip = 'Specifies the employee''s middle name.';
                }
                field("Birth Date"; Rec."Birth Date")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if not LoginMgmt.IsWebServiceUser then Age:=Dates.DetermineDatesDiffrence(Rec."Birth Date", Today);
                    end;
                }
                field(Age; Age)
                {
                    ApplicationArea = All;
                    Editable = IsWebservice;
                }
                field(Gender; Rec.Gender)
                {
                    ApplicationArea = All;
                }
                group(Gender_Gr)
                {
                    ShowCaption = false;
                    Visible = Rec.Gender = Rec.Gender::Other;

                    field("Gender Specification"; Rec."Gender Specification")
                    {
                        ApplicationArea = All;
                    }
                }
                field(Nationality; Rec.Nationality)
                {
                    ApplicationArea = All;
                }
                group(Nationality_GR)
                {
                    ShowCaption = false;
                    Visible = Rec.Nationality = Rec.Nationality::Others;

                    field("Country Code"; Rec."Country Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Country Name"; Rec."Country Name")
                    {
                        ApplicationArea = All;
                    }
                }
                field("Applicant Type"; Rec."Applicant Type")
                {
                    ApplicationArea = All;
                }
                group(External_)
                {
                    ShowCaption = false;
                    Visible = Rec."Applicant Type" = Rec."Applicant Type"::External;

                    field("National ID"; Rec."National ID")
                    {
                        ApplicationArea = All;
                    }
                    field("KRA PIN"; Rec."KRA PIN")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Internal_)
                {
                    ShowCaption = false;
                    Visible = Rec."Applicant Type" = Rec."Applicant Type"::Internal;

                    field("Staff No."; Rec."Staff No.")
                    {
                        ApplicationArea = All;
                    }
                }
                field("Home County"; Rec."Home County")
                {
                    ApplicationArea = All;
                }
                field("Ethnic Group"; Rec."Ethnic Group")
                {
                    ApplicationArea = All;
                }
                group("Passport Details")
                {
                    field("Passport No."; Rec."Passport No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Passport Issue Date"; Rec."Passport Issue Date")
                    {
                        ApplicationArea = All;
                    }
                    field("Passport Expiry Date"; Rec."Passport Expiry Date")
                    {
                        ApplicationArea = All;
                    }
                }
                group("Entry Permit (Non Kenyan Living in Kenya)")
                {
                    field("Permit No."; Rec."Permit No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Permit Issue Date"; Rec."Permit Issue Date")
                    {
                        ApplicationArea = All;
                    }
                    field("Permit Validity Period"; Rec."Permit Validity Period")
                    {
                        ApplicationArea = All;
                    }
                }
                field("Marital Status"; Rec."Marital Status")
                {
                    ApplicationArea = All;
                }
                field(Disability; Rec.Disability)
                {
                    ApplicationArea = All;
                }
                group(Disability_Gr)
                {
                    ShowCaption = false;
                    Visible = Rec.Disability;

                    field("NCPWD Certificate No."; Rec."NCPWD Certificate No.")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Disability Description"; Rec."Disability Description")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                }
            }
            group("C. Salary & Years of Experience")
            {
                field("Years Of Experience"; Rec."Years Of Experience")
                {
                    ApplicationArea = All;
                    Enabled = false;
                }
                field("Current Salary"; Rec."Current Salary")
                {
                    ApplicationArea = All;
                    Enabled = false;
                }
                field("Expected Salary"; Rec."Expected Salary")
                {
                    ApplicationArea = All;
                    Enabled = false;
                }
            }
            part("Languages Written & Spoken"; "Applicant Languages")
            {
                Caption = 'D. Languages Written & Spoken';
                ApplicationArea = All;
                SubPageLink = "Applicant No."=FIELD("No.");
            }
            group("E. PRESENT ADDRESS")
            {
                field("Postal Address"; Rec."Postal Address")
                {
                    ApplicationArea = All;
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = All;
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                }
                field("Physical Address"; Rec."Physical Address")
                {
                    ApplicationArea = All;
                }
                field("Mobile Phone No."; Rec."Mobile Phone No.")
                {
                    ApplicationArea = All;
                }
                field("Alternative Phone No."; Rec."Alternative Phone No.")
                {
                    ApplicationArea = All;
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the employee''s email address.';
                }
                field("Portal ID"; Rec."Portal ID")
                {
                    ApplicationArea = All;
                    Enabled = false;
                    ToolTip = 'Specifies the value applicant unique ID on the portal.';
                }
            }
            part(WorkExperience; "Applicant Current Employment")
            {
                Caption = 'F. CURRENT EMPLOYMENT DETAILS (Where applicable)';
                SubPageLink = "Applicant No."=field("No."), "Currently Employment"=const(true);
                ApplicationArea = All;
            }
            part(Qualification; "Applicant Qualification")
            {
                Caption = 'G. ACADEMIC QUALIFICATIONS (Starting with The Highest)';
                ApplicationArea = All;
                SubPageLink = "Applicant No."=FIELD("No.");
            }
            part(ProfessionalCertifications; "Applicant Professional Certs")
            {
                Caption = 'H. PROFESIONAL/TECHNICAL QUALIFICATIONS (Starting with The Highest)';
                SubPageLink = "Applicant No."=field("No.");
                ApplicationArea = All;
            }
            part(ProfessionalBodies; "Applicant Professional Bodies")
            {
                Caption = 'I. REGISTRATION / MEMBERSHIP TO PROFESSIONAL BODIES (Where applicable)';
                SubPageLink = "Applicant No."=field("No.");
                ApplicationArea = All;
            }
            part(EmploymentHistory; "Applicant Employment History")
            {
                Caption = 'J. EMPLOYMENT DETAILS - WHERE APPLICABLE (Starting with the Current or Most Recent)';
                SubPageLink = "Applicant No."=field("No.");
                ApplicationArea = All;
            }
            group("K. OTHER PERSONAL DETAILS")
            {
                field("Criminal Declaration"; Rec."Criminal Declaration")
                {
                    ApplicationArea = All;
                }
                group(Criminal_Gr)
                {
                    ShowCaption = false;
                    Visible = Rec."Criminal Declaration";

                    field("Criminal Declaration Specification"; Rec."Criminal Declaration Spec")
                    {
                        ApplicationArea = All;
                        MultiLine = true;
                    }
                }
                field("Dismissal Declaration"; Rec."Dismissal Declaration")
                {
                    ApplicationArea = All;
                }
                group(Dismissal_Gr)
                {
                    ShowCaption = false;
                    Visible = Rec."Dismissal Declaration";

                    field("Dismissal Declaration Specification"; Rec."Dismissal Declaration Spec")
                    {
                        ApplicationArea = All;
                        MultiLine = true;
                    }
                }
            }
            group("L. OTHER ATTACHMENTS")
            {
                label("Use this checklist to confirm that you have attached all documents that are required. (Kindly upload Pdf Documents)")
                {
                    ApplicationArea = All;
                }
                field("Application Letter"; Rec."Application Letter")
                {
                    ApplicationArea = All;
                }
                field("Curriculum Vitae"; Rec."Curriculum Vitae")
                {
                    ApplicationArea = All;
                }
                field(Testimonials; Rec.Testimonials)
                {
                    ApplicationArea = All;
                }
                field("Passport Photo"; Rec."Passport Photo")
                {
                    ApplicationArea = All;
                }
                field("Identification Document"; Rec."Identification Document")
                {
                    ApplicationArea = All;
                }
                field("Certificate of Admission"; Rec."Certificate of Admission")
                {
                    ApplicationArea = All;
                }
            }
            group("M. FINAL DECLARATION & SIGNATURE")
            {
                field("Final Declaration"; Rec."Final Declaration")
                {
                    ApplicationArea = All;
                }
                field("Declaration Date"; Rec."Declaration Date")
                {
                    ApplicationArea = All;
                }
                field(Signature; Rec.Signature)
                {
                    ApplicationArea = All;
                }
            }
            part(Control15; "Applicant Offers")
            {
                ApplicationArea = All;
                Visible = false;
                SubPageLink = "Applicant No."=FIELD("No.");
            }
            part(Competencies; "Applicant Competencies")
            {
                Visible = false;
                SubPageLink = "Applicant No."=field("No.");
                ApplicationArea = All;
            }
            part(Referees; "Applicant Referees")
            {
                Visible = false;
                SubPageLink = "Applicant No."=field("No.");
                ApplicationArea = All;
            }
            part(Hobbies; "Applicant Hobbies")
            {
                Visible = false;
                SubPageLink = "Applicant No."=field("No.");
                ApplicationArea = All;
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
        area(Reporting)
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
        }
        area(processing)
        {
            action(Apply)
            {
                ApplicationArea = All;
                Image = PostDocument;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = Rec."Offer Status" = Rec."Offer Status"::Applicant;

                trigger OnAction()
                var
                    JobApplication: Codeunit "Job Application Management";
                begin
                    if Confirm(StrSubstNo('You are about to Apply for the %1 Position, Do you wish to continue', Rec."Position Applied For"))then JobApplication.SubmitJobApplication(Rec."No.", Rec."Job Requisition")end;
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
    trigger OnAfterGetCurrRecord()
    begin
        ControlPageAppearance();
    end;
    trigger OnAfterGetRecord()
    begin
        ControlPageAppearance();
        if Rec."Birth Date" <> 0D then Age:=Dates.DetermineDatesDiffrence(Rec."Birth Date", Today);
    end;
    trigger OnOpenPage()
    begin
        ControlPageAppearance();
        if Rec."Birth Date" <> 0D then Age:=Dates.DetermineDatesDiffrence(Rec."Birth Date", Today);
    end;
    var LoginMgmt: Codeunit "User Management Ext";
    OnboardingMgt: Codeunit "Onboarding Management";
    IsWebservice: Boolean;
    Dates: Codeunit "HR Dates";
    Age: Text;
    procedure ControlPageAppearance()
    begin
        if LoginMgmt.IsWebServiceUser then IsWebservice:=true
        else
            IsWebservice:=false;
    end;
}

pageextension 52203426 "Human Resource Setup" extends "Human Resources Setup"
{
    PromotedActionCategories = 'New,Process,Report,Employee,Documents,Payroll Setup';

    layout
    {
        // Add changes to page layout here
        modify("Automatically Create Resource")
        {
            Visible = false;
        }
        modify(Numbering)
        {
            Caption = 'General';
        }
        modify("Employee Nos.")
        {
            Caption = 'New Employee Nos';
        }
        addbefore("Employee Nos.")
        {
            field("Applicant Nos."; Rec."Applicant Nos.")
            {
                ApplicationArea = Basic, Suite;
            }
        }
        addafter("Automatically Create Resource")
        {
            field("Retirement Age"; Rec."Retirement Age")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Union Retirement Age"; Rec."Union Retirement Age")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Working Hours in a Day"; Rec."Working Hours in a Day")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Contract Exp. Not. Period"; Rec."Contract Exp. Not. Period")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Appraisal Notification Period"; Rec."Appraisal Notification Period")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Maximum No. of Trainings"; Rec."Maximum No. of Trainings")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Training Expense Code"; Rec."Training Expense Code")
            {
                ApplicationArea = Basic, Suite;
                ShowMandatory = true;
            }
            field("Training Notification"; Rec."Training Notification")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Overtime Expense Code"; Rec."Overtime Expense Code")
            {
                ApplicationArea = Basic, Suite;
                ShowMandatory = true;
            }
            field("Laptop Expense Code"; Rec."Laptop Expense Code")
            {
                ApplicationArea = Basic, Suite;
                ShowMandatory = true;
            }
            field("Laptop Facilitation %"; Rec."Laptop Facilitation %")
            {
                ApplicationArea = Basic, Suite;
                ShowMandatory = true;
            }
            field("Laptop Facilitation Limit"; Rec."Laptop Facilitation Limit")
            {
                ApplicationArea = Basic, Suite;
                ShowMandatory = true;
            }
            field("Web Client Link"; Rec."Web Client Link")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Probation Notifications"; Rec."Probation Notifications")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Delete Apps Period"; Rec."Delete Apps Period")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Leave Allowance Min. Days"; Rec."Leave Allowance Min. Days")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Imprest Limits"; Rec."Imprest Limits")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Maximum Imprest Amount"; Rec."Maximum Imprest Amount")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Medical Expense Account"; Rec."Medical Expense Account")
            {
                ApplicationArea = Basic, Suite;
            }
            field("KRA Percentage"; Rec."KRA Percentage")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Competencies Percentage"; Rec."Competencies Percentage")
            {
                ApplicationArea = Basic, Suite;
            }
            field("One Point Eligibility"; Rec."One Point Eligibility")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Basic Pay Divider Union"; Rec."Basic Pay Divider Union")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Basic Pay Divider Professional"; Rec."Basic Pay Divider Professional")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Dependant Age Limit"; Rec."Dependant Age Limit")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Payslip Message"; Rec."Payslip Message")
            {
                ApplicationArea = Basic, Suite;
            }
        }
        addafter(Numbering)
        {
            group(Numbering_)
            {
                Caption = 'Numbering';

                field("Document Upload Nos."; Rec."Document Upload Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Job Nos"; Rec."Job Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Job Requisition Nos"; Rec."Job Requisition Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Training Need"; Rec."Training Need")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Trainers Nos"; Rec."Trainers Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Training Application Nos"; Rec."Training Application Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Training Plan Nos"; Rec."Training Plan Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Interview Nos"; Rec."Interview Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Exit Nos"; Rec."Exit Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Disciplinary Cases Nos"; Rec."Disciplinary Cases Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Job Application Nos"; Rec."Job Application Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Overtime Nos."; Rec."Overtime Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Appraisal Nos"; Rec."Appraisal Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Profile Nos"; Rec."Profile Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Grievances Nos"; Rec."Grievances Nos")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Work Start Time"; Rec."Work Start Time")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Work End Time"; Rec."Work End Time")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Change Request Nos."; Rec."Change Request Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Exit Form Nos."; Rec."Exit Form Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        addafter("Employee Statistics Groups")
        {
            action("Allowances Setup")
            {
                ApplicationArea = BasicHR;
                Image = TaxSetup;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                RunObject = Page "Allowances Setup";
            }
            action("Employee Payroll Scale")
            {
                ApplicationArea = BasicHR;
                Image = Payroll;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                RunObject = Page "Employee Payroll Scales";
            }
        }
    }
}

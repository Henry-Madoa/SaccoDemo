report 52203603 "Job Interview"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Job Interview.rdl';

    dataset
    {
        dataitem(JobInterview; "Job Interview")
        {
            column(CompanyName; CompanyInformation.Name)
            {
            }
            column(CompanyPicture; CompanyInformation.Picture)
            {
            }
            column(CompanyAddress; CompanyInformation.Address)
            {
            }
            column(CompanyPhone; CompanyInformation."Phone No.")
            {
            }
            column(CompanyEmail; CompanyInformation."E-Mail")
            {
            }
            column(CompanyWebsite; CompanyInformation."Home Page")
            {
            }
            column(CompanyPostCode; CompanyInformation."Post Code")
            {
            }
            column(ReportFilters; ReportFilters)
            {
            }
            column(JobInterview_No_; JobInterview."No.")
            {
            }
            column(JobInterview_Date; JobInterview.Date)
            {
            }
            column(JobInterview_Requisition_No_; JobInterview."Requisition No.")
            {
            }
            column(JobInterview_Shortlisting_No_; JobInterview."Shortlisting No.")
            {
            }
            column(JobInterview_Job_ID; JobInterview."Job ID")
            {
            }
            column(JobInterview_Job_Title; JobInterview."Job Title")
            {
            }
            column(JobInterview_No_of_Positions; JobInterview."No of Positions")
            {
            }
            column(JobInterview_No_of_Applicants; JobInterview."No of Applicants")
            {
            }
            column(JobInterview_Pass_Mark; JobInterview."Pass Mark")
            {
            }
            column(JobInterview_Committee; JobInterview.Committee)
            {
            }
            column(JobInterview_Commitee_Name; JobInterview."Commitee Name")
            {
            }
            column(JobInterview_Status; JobInterview.Status)
            {
            }
            dataitem(JobInterviewRating; "Job Interview Rating")
            {
                DataItemLink = "No."=field("No.");

                column(JobInterviewRating_Applicant_No; JobInterviewRating."Applicant No")
                {
                }
                column(JobInterviewRating_Interviewer; JobInterviewRating.Interviewer)
                {
                }
                column(JobInterviewRating_Interviewer_Name; JobInterviewRating."Interviewer Name")
                {
                }
                column(JobInterviewRating_Description; JobInterviewRating.Description)
                {
                }
                column(JobInterviewRating_Marks; JobInterviewRating.Marks)
                {
                }
                column(JobInterviewRating_RatingSN; RatingSN)
                {
                }
                dataitem(Applicant; Applicant)
                {
                    DataItemLink = "No."=field("Applicant No");

                    column(JobInterviewRating_FullName; Applicant.FullName)
                    {
                    }
                }
                trigger OnAfterGetRecord()
                begin
                    RatingSN:=RatingSN + 1;
                end;
            }
            dataitem(JobInterviewApplicants; "Job Interview Applicants")
            {
                DataItemLink = "No."=field("No.");

                column(JobInterviewApplicants_Applicant_No_; JobInterviewApplicants."Applicant No.")
                {
                }
                column(JobInterviewApplicants_Fullname; StrSubstNo('%1 %2 %3', JobInterviewApplicants."First Name", JobInterviewApplicants."Middle Name", JobInterviewApplicants."Last Name"))
                {
                }
                column(JobInterviewApplicants_Initials; JobInterviewApplicants.Initials)
                {
                }
                column(JobInterviewApplicants_Interview_enue; JobInterviewApplicants."Interview Venue")
                {
                }
                column(JobInterviewApplicants_Interview_Time; JobInterviewApplicants."Interview Time")
                {
                }
                column(JobInterviewApplicants_Interview_Date; JobInterviewApplicants."Interview Date")
                {
                }
                column(JobInterviewApplicants_Score; JobInterviewApplicants.Score)
                {
                }
                column(JobInterviewApplicants_ApplicantsSN; ApplicantsSN)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    ApplicantsSN:=ApplicantsSN + 1;
                end;
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.GET;
                CompanyInformation.CALCFIELDS(Picture);
                ReportFilters:=JobInterview.GetFilters;
                RatingSN:=0;
                ApplicantsSN:=0;
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    ReportFilters: Text;
    RatingSN: Integer;
    ApplicantsSN: Integer;
}

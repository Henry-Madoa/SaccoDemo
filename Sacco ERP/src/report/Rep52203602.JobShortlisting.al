report 52203602 "Job Shortlisting"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Job Shortlisting.rdl';

    dataset
    {
        dataitem(JobShortlisting; "Job Shortlisting")
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
            column(JobShortlisting_No_; JobShortlisting."No.")
            {
            }
            column(JobShortlisting_Date; JobShortlisting.Date)
            {
            }
            column(JobShortlisting_Requisition_No_; JobShortlisting."Requisition No.")
            {
            }
            column(JobShortlisting_Job_ID; JobShortlisting."Job ID")
            {
            }
            column(JobShortlisting_Job_Title; JobShortlisting."Job Title")
            {
            }
            column(JobShortlisting_No_of_Positions; JobShortlisting."No of Positions")
            {
            }
            column(JobShortlisting_No_of_Applicants; JobShortlisting."No of Applicants")
            {
            }
            column(JobShortlisting_Pass_Mark; JobShortlisting."Pass Mark")
            {
            }
            column(JobShortlisting_Preferred_Gender; JobShortlisting."Preferred Gender")
            {
            }
            column(JobShortlisting_Work_Experience; JobShortlisting."Work Experience")
            {
            }
            column(JobShortlisting_Status; JobShortlisting.Status)
            {
            }
            dataitem(JobShortlistingCriteria; "Job Shortlisting Criteria")
            {
                DataItemLink = "No."=field("No.");

                column(JobShortlistingCriteria_Qualification_Type; JobShortlistingCriteria."Qualification Type")
                {
                }
                column(JobShortlistingCriteria_Qualification_Code; JobShortlistingCriteria."Qualification Code")
                {
                }
                column(JobShortlistingCriteria_Score; JobShortlistingCriteria.Score)
                {
                }
                column(JobShortlistingCriteria_CriteriaSN; CriteriaSN)
                {
                }
                dataitem(Qualification; Qualification)
                {
                    DataItemLink = Code=field("Qualification Code");

                    column(Qualification_Description; Qualification.Description)
                    {
                    }
                }
                trigger OnAfterGetRecord()
                begin
                    CriteriaSN:=CriteriaSN + 1;
                end;
            }
            dataitem(JobShortlistedApplicants; "Job Shortlisted Applicants")
            {
                DataItemLink = "No."=field("No.");

                column(JobShortlistedApplicants_Applicant_No_; JobShortlistedApplicants."Applicant No.")
                {
                }
                column(JobShortlistedApplicants_Fullname; StrSubstNo('%1 %2 %3', JobShortlistedApplicants."First Name", JobShortlistedApplicants."Middle Name", JobShortlistedApplicants."Last Name"))
                {
                }
                column(JobShortlistedApplicants_Initials; JobShortlistedApplicants.Initials)
                {
                }
                column(JobShortlistedApplicants_Score; JobShortlistedApplicants.Score)
                {
                }
                column(JobShortlistedApplicants_ApplicantSN; ApplicantSN)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    ApplicantSN:=ApplicantSN + 1;
                end;
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.GET;
                CompanyInformation.CALCFIELDS(Picture);
                ReportFilters:=JobShortlisting.GetFilters;
                CriteriaSN:=0;
                ApplicantSN:=0;
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    ReportFilters: Text;
    ApplicantSN: Integer;
    CriteriaSN: Integer;
}

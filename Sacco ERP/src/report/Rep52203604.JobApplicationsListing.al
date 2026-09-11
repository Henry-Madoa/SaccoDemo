report 52203604 "Job Applications Listing"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Job Applications Listing.rdl';

    dataset
    {
        dataitem(JobApplication; "Job Application")
        {
            RequestFilterFields = "Requisition No.", "Job ID", Status;
            DataItemTableView = sorting("No.")order(ascending);

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
            column(JobApplication_No_; JobApplication."No.")
            {
            }
            column(JobApplication_Applicant_No_; JobApplication."Applicant No.")
            {
            }
            column(JobApplication_ApplicantName; StrSubstNo('%1 %2 %3', JobApplication."First Name", JobApplication."Middle Name", JobApplication."Last Name"))
            {
            }
            column(JobApplication_Requisition_No_; JobApplication."Requisition No.")
            {
            }
            column(JobApplication_Job_ID; JobApplication."Job ID")
            {
            }
            column(JobApplication_Job_Title; JobApplication."Job Title")
            {
            }
            column(JobApplication_Score; JobApplication.Score)
            {
            }
            column(JobApplication_Remark; JobApplication.Remark)
            {
            }
            column(JobApplication_Status; JobApplication.Status)
            {
            }
            dataitem(Applicant; Applicant)
            {
                DataItemLink = "No."=field("Applicant No.");

                column(Applicant_Years_Of_Experience; Applicant."Years Of Experience")
                {
                }
                column(Applicant_Years_Of_Relevant_Experience; Applicant."Years Of Relevant Experience")
                {
                }
                column(Applicant_Current_Expected_Salary; Applicant."Current/Expected Salary")
                {
                }
                column(Applicant_Mobile_Phone_No_; Applicant."Mobile Phone No.")
                {
                }
                column(Applicant_Gender; Applicant.Gender)
                {
                }
                dataitem(ApplicantsQualification; "Applicants Qualification")
                {
                    DataItemLink = "Applicant No."=field("No.");

                    column(ApplicantsQualification_Qualification_Type; ApplicantsQualification."Qualification Type")
                    {
                    }
                    column(ApplicantsQualification_Qualification_Code; ApplicantsQualification."Qualification Code")
                    {
                    }
                    column(ApplicantsQualification_From_Date; ApplicantsQualification."From Date")
                    {
                    }
                    column(ApplicantsQualification_To_Date; ApplicantsQualification."To Date")
                    {
                    }
                    column(ApplicantsQualification_Institution_Company; ApplicantsQualification."Institution/Company")
                    {
                    }
                    dataitem(Qualification; Qualification)
                    {
                        DataItemLink = "Qualification Type"=field("Qualification Type"), Code=field("Qualification Code");

                        column(Qualification_Description; Qualification.Description)
                        {
                        }
                    }
                }
                dataitem(ApplicantWorkExperience; "Applicant Work Experience")
                {
                    DataItemLink = "Applicant No."=field("No.");

                    column(ApplicantWorkExperience_From; ApplicantWorkExperience."From Date")
                    {
                    }
                    column(ApplicantWorkExperience_To; ApplicantWorkExperience."To Date")
                    {
                    }
                    column(ApplicantWorkExperience_Company_Name; ApplicantWorkExperience."Company Name")
                    {
                    }
                    column(ApplicantWorkExperience_Key_Experience; ApplicantWorkExperience."Key Experience")
                    {
                    }
                }
                dataitem(ApplicantProfessionalBodies; "Applicant Professional Bodies")
                {
                    DataItemLink = "Applicant No."=field("No.");

                    column(ApplicantProfessionalBodies_Code; ApplicantProfessionalBodies.Code)
                    {
                    }
                    column(ApplicantProfessionalBodies_Name; ApplicantProfessionalBodies.Name)
                    {
                    }
                    column(ApplicantProfessionalBodies_Description; ApplicantProfessionalBodies.Description)
                    {
                    }
                }
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.GET;
                CompanyInformation.CALCFIELDS(Picture);
                ReportFilters:=JobApplication.GetFilters;
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    ReportFilters: Text;
}

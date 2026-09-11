report 52203601 "Job Applications"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Job Applications.rdl';

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

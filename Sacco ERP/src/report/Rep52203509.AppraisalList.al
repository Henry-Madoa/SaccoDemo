report 52203509 "Appraisal List"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Appraisal List.rdl';

    dataset
    {
        dataitem("Appraisal Header"; "Appraisal Header")
        {
            RequestFilterFields = Status, "Employee No", "Level/Grade", "Global Dimension 1 Code";

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
            column(CompanyLocation; CompanyInformation.Location)
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
            column(JobTitle; JobTitle)
            {
            }
            column(JobGroup; JobGroup)
            {
            }
            column(AppraisalCode_AppraisalHeader; "Appraisal Header"."No.")
            {
            }
            column(EmployeeNo_AppraisalHeader; "Appraisal Header"."Employee No")
            {
            }
            column(EmployeeName_AppraisalHeader; "Appraisal Header"."Employee Name")
            {
            }
            column(Department_AppraisalHeader; "Appraisal Header"."Global Dimension 1 Code")
            {
            }
            column(AppraisalStartDate_AppraisalHeader; "Appraisal Header"."Appraisal Start Date")
            {
            }
            column(AppraisalEndDate_AppraisalHeader; "Appraisal Header"."Appraisal End Date")
            {
            }
            column(AppraisalPeriodName_AppraisalHeader; AppraisalPeriodName)
            {
            }
            column(ReviewPeriodName_AppraisalHeader; ReviewPeriodName)
            {
            }
            column(OverallScore_AppraisalHeader; "Appraisal Header"."Overall Rating")
            {
            }
            column(DeparrtmentName_AppraisalHeader; "Appraisal Header"."Appraisal Start Date")
            {
            }
            column(CreatedBy_AppraisalHeader; "Appraisal Header"."Created By")
            {
            }
            column(LastUpdatedBy_AppraisalHeader; "Appraisal Header".SystemModifiedBy)
            {
            }
            column(LastUpdatedOn_AppraisalHeader; "Appraisal Header".SystemModifiedAt)
            {
            }
            column(SubmittedKPIs_AppraisalHeader; "Appraisal Header"."Overall Rating")
            {
            }
            column(SubmissionProgress_AppraisalHeader; "Appraisal Header"."Supervisor User Id")
            {
            }
            column(AppraisalStatus_AppraisalHeader; "Appraisal Header".Status)
            {
            }
            column(ActionID_AppraisalHeader; "Appraisal Header"."Action Taken")
            {
            }
            column(TotalScoreKRA_AppraisalHeader; "Appraisal Header"."Overall Rating")
            {
            }
            column(AppraisalCalendar_AppraisalHeader; "Appraisal Header"."Global Dimension 1 Code")
            {
            }
            column(SupervisorUserID_AppraisalHeader; "Appraisal Header"."Supervisor User Id")
            {
            }
            column(EmployeeSelected_AppraisalHeader; "Appraisal Header"."Peer 1 Employee Name")
            {
            }
            column(SelectedEmployeeName_AppraisalHeader; "Appraisal Header"."Peer 2 Employee No")
            {
            }
            trigger OnAfterGetRecord()
            begin
                JobGroup:='';
                JobTitle:='';
                if Employee.Get("Appraisal Header"."Employee No")then begin
                    JobTitle:=Employee."Job Title";
                    JobGroup:=Employee."Job Scale";
                end;
                If AppraisalCalender.Get("Appraisal Header"."Calendar Code")then AppraisalPeriodName:=AppraisalCalender.Description;
                if ReviewPeriod.Get("Appraisal Header"."Calendar Code", "Review Period")then ReviewPeriodName:=ReviewPeriod.Description;
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    Employee: Record Employee;
    JobTitle: Text;
    JobGroup: Text;
    AppraisalPeriodName: Text;
    AppraisalCalender: Record "Appraisal Calender";
    ReviewPeriodName: Text;
    ReviewPeriod: Record "Appraisal Review Periods";
}

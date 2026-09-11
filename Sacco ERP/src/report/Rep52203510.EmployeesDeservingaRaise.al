report 52203510 "Employees Deserving a Raise"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Employees Deserving a Raise.rdlc';

    dataset
    {
        dataitem("Appraisal Header"; "Appraisal Header")
        {
            //DataItemTableView = WHERE("Peer 2 Employee Name"=CONST(true));
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
            column(AppraisalCode_AppraisalHeader; "Appraisal Header"."No.")
            {
            }
            column(EmployeeNo_AppraisalHeader; "Appraisal Header"."Employee No")
            {
            }
            column(EmployeeName_AppraisalHeader; "Appraisal Header"."Employee Name")
            {
            }
            column(Department_AppraisalHeader; "Appraisal Header"."Level/Grade")
            {
            }
            column(AppraisalStartDate_AppraisalHeader; "Appraisal Header"."Job Title")
            {
            }
            column(AppraisalEndDate_AppraisalHeader; "Appraisal Header"."Function/Team")
            {
            }
            column(TotalKRAs_AppraisalHeader; "Appraisal Header"."Calendar Code")
            {
            }
            column(DeparrtmentName_AppraisalHeader; "Appraisal Header"."Appraisal Start Date")
            {
            }
            column(CreatedBy_AppraisalHeader; "Appraisal Header"."Appraisal End Date")
            {
            }
            column(LastUpdatedBy_AppraisalHeader; "Appraisal Header"."No. Series")
            {
            }
            column(LastUpdatedOn_AppraisalHeader; "Appraisal Header"."Created On")
            {
            }
            column(SubmittedKPIs_AppraisalHeader; "Appraisal Header"."Created By")
            {
            }
            column(SubmissionProgress_AppraisalHeader; "Appraisal Header"."Supervisor User Id")
            {
            }
            column(Status_AppraisalHeader; "Appraisal Header"."Employee User Id")
            {
            }
            column(ActionID_AppraisalHeader; "Appraisal Header"."Supervisor No")
            {
            }
            column(TotalScoreKRA_AppraisalHeader; "Appraisal Header"."Supervisor Function/Team")
            {
            }
            column(AppraisalCalendar_AppraisalHeader; "Appraisal Header"."Global Dimension 1 Code")
            {
            }
            column(SupervisorUserID_AppraisalHeader; "Appraisal Header"."Peer 1 Employee No")
            {
            }
            column(EmployeeSelected_AppraisalHeader; "Appraisal Header"."Peer 1 Employee Name")
            {
            }
            column(SelectedEmployeeName_AppraisalHeader; "Appraisal Header"."Peer 2 Employee No")
            {
            }
            column(DeservesaRaise_AppraisalHeader; "Appraisal Header"."Peer 2 Employee Name")
            {
            }
            column(TotalMaxKPIWeight_AppraisalHeader; "Appraisal Header"."Action Taken")
            {
            }
            column(TotalSupervisorScore_AppraisalHeader; "Appraisal Header"."Overview Manager")
            {
            }
            column(TotalAgreedScore_AppraisalHeader; "Appraisal Header"."Action To Implement")
            {
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
}

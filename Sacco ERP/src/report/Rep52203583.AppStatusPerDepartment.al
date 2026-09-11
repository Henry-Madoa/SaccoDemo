report 52203583 "App. Status Per Department"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/App. Status Per Department.rdlc';

    dataset
    {
        dataitem("Appraisal Header"; "Appraisal Header")
        {
            RequestFilterFields = "Global Dimension 2 Code";

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
            column(AppraisalNo_AppraisalHeader; "Appraisal Header"."No.")
            {
            }
            column(EmployeeNo_AppraisalHeader; "Appraisal Header"."Employee No")
            {
            }
            column(EmployeeName_AppraisalHeader; "Appraisal Header"."Employee Name")
            {
            }
            column(LevelGrade_AppraisalHeader; "Appraisal Header"."Level/Grade")
            {
            }
            column(JobTitle_AppraisalHeader; "Appraisal Header"."Job Title")
            {
            }
            column(FunctionTeam_AppraisalHeader; "Appraisal Header"."Function/Team")
            {
            }
            column(AppraisalStartDate_AppraisalHeader; "Appraisal Header"."Appraisal Start Date")
            {
            }
            column(AppraisalEndDate_AppraisalHeader; "Appraisal Header"."Appraisal End Date")
            {
            }
            column(NoSeries_AppraisalHeader; "Appraisal Header"."No. Series")
            {
            }
            column(CreatedOn_AppraisalHeader; "Appraisal Header"."Created On")
            {
            }
            column(CreatedBy_AppraisalHeader; "Appraisal Header"."Created By")
            {
            }
            column(SupervisorUserId_AppraisalHeader; "Appraisal Header"."Supervisor User Id")
            {
            }
            column(EmployeeUserId_AppraisalHeader; "Appraisal Header"."Employee User Id")
            {
            }
            column(SupervisorNo_AppraisalHeader; "Appraisal Header"."Supervisor No")
            {
            }
            column(SupervisorName_AppraisalHeader; "Appraisal Header"."Supervisor Name")
            {
            }
            column(SupervisorTitle_AppraisalHeader; "Appraisal Header"."Supervisor Title")
            {
            }
            column(SupervisorFunctionTeam_AppraisalHeader; "Appraisal Header"."Supervisor Function/Team")
            {
            }
            column(Peer1EmployeeNo_AppraisalHeader; "Appraisal Header"."Peer 1 Employee No")
            {
            }
            column(Peer1EmployeeName_AppraisalHeader; "Appraisal Header"."Peer 1 Employee Name")
            {
            }
            column(Peer2EmployeeNo_AppraisalHeader; "Appraisal Header"."Peer 2 Employee No")
            {
            }
            column(Peer2EmployeeName_AppraisalHeader; "Appraisal Header"."Peer 2 Employee Name")
            {
            }
            column(NewEmpAppStatus_AppraisalHeader; "Appraisal Header"."New Emp. App. Status")
            {
            }
            column(HrUserId_AppraisalHeader; "Appraisal Header"."Hr UserId")
            {
            }
            column(ActionTaken_AppraisalHeader; "Appraisal Header"."Action Taken")
            {
            }
            column(OverviewManager_AppraisalHeader; "Appraisal Header"."Overview Manager")
            {
            }
            column(ActionToImplement_AppraisalHeader; "Appraisal Header"."Action To Implement")
            {
            }
            column(OverviewManagerName_AppraisalHeader; "Appraisal Header"."Overview Manager Name")
            {
            }
            column(OverviewManagerUserID_AppraisalHeader; "Appraisal Header"."Overview Manager UserID")
            {
            }
            column(RecomendedAction_AppraisalHeader; "Appraisal Header"."Recomended Action")
            {
            }
            column(ProbationExtended_AppraisalHeader; "Appraisal Header"."Probation Extended")
            {
            }
            column(GlobalDimension1Code_AppraisalHeader; "Appraisal Header"."Global Dimension 1 Code")
            {
            }
            column(GlobalDimension2Code_AppraisalHeader; "Appraisal Header"."Global Dimension 2 Code")
            {
            }
            column(GlobalDimension3Code_AppraisalHeader; "Appraisal Header"."Global Dimension 3 Code")
            {
            }
            column(GlobalDimension4Code_AppraisalHeader; "Appraisal Header"."Global Dimension 4 Code")
            {
            }
            column(GlobalDimension5Code_AppraisalHeader; "Appraisal Header"."Global Dimension 5 Code")
            {
            }
            column(GlobalDimension6Code_AppraisalHeader; "Appraisal Header"."Global Dimension 6 Code")
            {
            }
            column(TechnicalObjectiveScore_AppraisalHeader; "Appraisal Header"."Technical Objective Score")
            {
            }
            column(QualitativeObjectiveScore_AppraisalHeader; "Appraisal Header"."Qualitative Objective Score")
            {
            }
            column(OverViewManagerComments_AppraisalHeader; "Appraisal Header"."OverView Manager Comments")
            {
            }
            column(OverallScore_AppraisalHeader; "Appraisal Header"."Overall Rating")
            {
            }
            trigger OnAfterGetRecord()
            begin
                JobGroup:='';
                JobTitle:='';
                IF Employee.GET("Appraisal Header"."Employee No")THEN BEGIN
                    JobTitle:=Employee."Job Title";
                    JobGroup:=Employee."Job Scale";
                end;
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.GET;
                CompanyInformation.CALCFIELDS(Picture);
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    Employee: Record Employee;
    JobTitle: Text;
    JobGroup: Text;
}

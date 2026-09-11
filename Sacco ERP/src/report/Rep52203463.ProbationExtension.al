report 52203463 "Probation Extension"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Probation Extension.rdlc';

    dataset
    {
        dataitem("Appraisal Header"; "Appraisal Header")
        {
            RequestFilterFields = "No. Series";

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
            column(NewProbationEndDate; NewProbationEndDate)
            {
            }
            column(ProbationEndDate; ProbationEndDate)
            {
            }
            column(MonthAfterExtension; MonthAfterExtension)
            {
            }
            column(Days7AfterExtension; Days7AfterExtension)
            {
            }
            column(DayBeforeExtension; DayBeforeExtension)
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
            column(ProbationRecomendedAction_AppraisalHeader; "Appraisal Header"."Probation Recomended Action")
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
            dataitem("Employee Appraisal KPIs"; "Appraisal Objectives/KRAs")
            {
                DataItemLink = "Appraisal No"=FIELD("No.");

                column(AppraisalNo_EmployeeAppraisalKPIs; "Employee Appraisal KPIs"."Appraisal No")
                {
                }
                column(EmployeeNo_EmployeeAppraisalKPIs; "Employee Appraisal KPIs"."Employee No")
                {
                }
                column(Objective_EmployeeAppraisalKPIs; "Employee Appraisal KPIs"."KRA/Objective")
                {
                }
            }
            trigger OnAfterGetRecord()
            begin
                Employee.GET("Appraisal Header"."Employee No");
                NewProbationEndDate:=Employee."New Probation Period End Date";
                ProbationEndDate:=Employee."End of Probation Period";
                MonthAfterExtension:=CALCDATE('1M', ProbationEndDate);
                Days7AfterExtension:=CALCDATE('-7D', NewProbationEndDate);
                DayBeforeExtension:=CALCDATE('-1D', NewProbationEndDate);
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
    NewProbationEndDate: Date;
    ProbationEndDate: Date;
    MonthAfterExtension: Date;
    Days7AfterExtension: Date;
    DayBeforeExtension: Date;
}

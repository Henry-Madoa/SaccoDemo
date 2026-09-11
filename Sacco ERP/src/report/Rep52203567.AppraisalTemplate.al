report 52203567 "Appraisal Template"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Appraisal Template.rdlc';

    dataset
    {
        dataitem("Appraisal Header"; "Appraisal Header")
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
            column(SupervisorUserID_AppraisalHeader; "Appraisal Header"."Peer 1 Employee No")
            {
            }
            column(AppraisalCalendar_AppraisalHeader; "Appraisal Header"."Global Dimension 1 Code")
            {
            }
            dataitem("Employee Appraisal KPIs"; "Appraisal Activities")
            {
                DataItemLink = "Line No"=FIELD("No."), "Kra Line No"=FIELD("Employee No");

                column(KPICode_EmployeeAppraisalKPIs; "Employee Appraisal KPIs"."Appraisal No")
                {
                }
                column(KPIDescription_EmployeeAppraisalKPIs; "Employee Appraisal KPIs"."Employee No")
                {
                }
                column(MaximumWeight_EmployeeAppraisalKPIs; "Employee Appraisal KPIs".Activity)
                {
                }
                column(TargetScore_EmployeeAppraisalKPIs; "Employee Appraisal KPIs"."Due Date")
                {
                }
            }
            dataitem("Appraisal Training Rec."; "Appraisal Training Rec.")
            {
                DataItemLink = "Appraisal Code"=FIELD("No."), "Employee No."=FIELD("Employee No");

                column(AppraisalCode_AppraisalTrainingRec; "Appraisal Training Rec."."Appraisal Code")
                {
                }
                column(EmployeeNo_AppraisalTrainingRec; "Appraisal Training Rec."."Employee No.")
                {
                }
                column(TrainingArea_AppraisalTrainingRec; "Appraisal Training Rec."."Training Area")
                {
                }
                column(TrainingDescription_AppraisalTrainingRec; "Appraisal Training Rec."."Training Description")
                {
                }
                column(Reason_AppraisalTrainingRec; "Appraisal Training Rec.".Reason)
                {
                }
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

report 52203495 "Appraisal Print Out"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Appraisal Print Out.rdl';

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
            column(SupervisorSignature; UserSetup.Signature)
            {
            }
            column(UserSignature; UserSetup1.Signature)
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
            column(OverallScore_AppraisalHeader; "Appraisal Header"."Overall Score")
            {
            }
            column(OverallRating_AppraisalHeader; "Appraisal Header"."Overall Rating")
            {
            }
            column(Status_AppraisalHeader; "Appraisal Header".Status)
            {
            }
            column(SupervisorUserID_AppraisalHeader; "Appraisal Header"."Supervisor User Id")
            {
            }
            column(SupervisorName_AppraisalHeader; "Appraisal Header"."Supervisor Name")
            {
            }
            column(OverviewManagerName_AppraisalHeader; "Appraisal Header"."Overview Manager Name")
            {
            }
            column(SupervisorOverallComments_AppraisalHeader; "Appraisal Header"."Supervisor Overall Comments")
            {
            }
            column(OverViewManagerComments_AppraisalHeader; "Appraisal Header"."OverView Manager Comments")
            {
            }
            dataitem("Appraisal Objectives/KRAs"; "Appraisal Objectives/KRAs")
            {
                DataItemLink = "Appraisal No"=FIELD("No.");

                column(AppraisalCode_EmployeeAppraisalKRAs; "Appraisal Objectives/KRAs"."Appraisal No")
                {
                }
                column(EmployeeNo_EmployeeAppraisalKRAs; "Appraisal Objectives/KRAs"."Employee No")
                {
                }
                column(PerspectivePillar_EmployeeAppraisalKRAs; "Appraisal Objectives/KRAs"."Perspective/Pillar")
                {
                }
                column(KRADescription_EmployeeAppraisalKRAs; "Appraisal Objectives/KRAs"."KRA/Objective")
                {
                }
                column(Status_EmployeeAppraisalKRAs; "Appraisal Objectives/KRAs"."Appraiser Rating")
                {
                }
                dataitem("Appraisal Activities"; "Appraisal Activities")
                {
                    DataItemLink = "Appraisal No"=FIELD("Appraisal No"), "KRA Line No"=FIELD("Line No");

                    column(AppraisalCode_EmployeeAppraisalKPIs; "Appraisal Activities"."Appraisal No")
                    {
                    }
                    column(EmployeeNo_EmployeeAppraisalKPIs; "Appraisal Activities"."Employee No")
                    {
                    }
                    column(KPIDescription_EmployeeAppraisalKPIs; "Appraisal Activities"."Kra/Objective")
                    {
                    }
                    column(Activity_EmployeeAppraisalKPIs; "Appraisal Activities".Activity)
                    {
                    }
                    column(MaximumWeight_EmployeeAppraisalKPIs; "Appraisal Activities".Weight)
                    {
                    }
                    column(TargetScore_EmployeeAppraisalKPIs; "Appraisal Activities"."Target/KPI")
                    {
                    }
                    column(ActualQuantity_EmployeeAppraisalKPIs; "Appraisal Activities".Weight)
                    {
                    }
                    column(SubmittedKPIs_EmployeeAppraisalKRAs; "Appraisal Activities"."Kra/Objective")
                    {
                    }
                    dataitem("Appraisal KPIs Rating"; "Appraisal KPIs Rating")
                    {
                        DataItemLink = "Appraisal No"=FIELD("Appraisal No"), "KPI Line No"=FIELD("Line No");

                        column(LineNo_AppraisalKPIsRating; "Appraisal KPIs Rating"."Line No")
                        {
                        }
                        column(TotalKPIs_EmployeeAppraisalKRAs; "Appraisal KPIs Rating".Score)
                        {
                        }
                        column(ReviewPeriodName_AppraisalKPIsRating; ReviewPeriodName)
                        {
                        }
                        column(ApprovedKPIs_EmployeeAppraisalKRAs; "Appraisal KPIs Rating"."Appraisee Self Rating")
                        {
                        }
                        column(Comments_EmployeeAppraisalKPIs; "Appraisal KPIs Rating"."Appraisee Comments")
                        {
                        }
                        column(SupervisorComments_EmployeeAppraisalKPIs; "Appraisal KPIs Rating"."Appraiser Comments")
                        {
                        }
                        column(SelfAssesment_EmployeeAppraisalKPIs; "Appraisal KPIs Rating"."Appraisee Self Rating")
                        {
                        }
                        column(JustifyScore_EmployeeAppraisalKPIs; "Appraisal KPIs Rating"."Non Achievement Reasons")
                        {
                        }
                        column(SupervisorScore_EmployeeAppraisalKPIs; "Appraisal KPIs Rating"."Appraiser Rating")
                        {
                        }
                        column(AgreedScore_EmployeeAppraisalKPIs; "Appraisal KPIs Rating".Score)
                        {
                        }
                        column(SupervisorScoreComments_EmployeeAppraisalKPIs; "Appraisal KPIs Rating"."Overview Manager Comments")
                        {
                        }
                        column(TargetKPIStatus_EmployeeAppraisalKPIs; "Appraisal KPIs Rating"."Target/KPI Status")
                        {
                        }
                        column(Agree_EmployeeAppraisalKPIs; "Appraisal KPIs Rating".Agree)
                        {
                        }
                        column(DisagreementComments_EmployeeAppraisalKPIs; "Appraisal KPIs Rating"."Disagreement Comments")
                        {
                        }
                        trigger OnAfterGetRecord()
                        begin
                            if "Appraisal KPIs Rating"."Review Period" = '' then CurrReport.Skip;
                            if ReviewPeriod.Get("Appraisal Header"."Calendar Code", "Appraisal KPIs Rating"."Review Period")then ReviewPeriodName:=ReviewPeriod.Description;
                        end;
                    }
                    trigger OnAfterGetRecord()
                    begin
                        if "Appraisal Activities"."Kra/Objective" = '' then CurrReport.Skip;
                    end;
                }
                trigger OnAfterGetRecord()
                begin
                    if "Appraisal Objectives/KRAs"."KRA/Objective" = '' then CurrReport.Skip;
                end;
            }
            dataitem("Appraisal Training Needs"; "Appraisal Training Needs")
            {
                DataItemLink = "Appraisal No."=FIELD("No.");

                column(LineNo_AppraisalTrainingNeeds; "Appraisal Training Needs"."Line No.")
                {
                }
                column(AppraisalCode_AppraisalTrainingNeeds; "Appraisal Training Needs"."Appraisal No.")
                {
                }
                column(EmployeeNo_AppraisalTrainingNeeds; "Appraisal Training Needs"."Employee No.")
                {
                }
                column(Category_AppraisalTrainingNeeds; "Appraisal Training Needs".Category)
                {
                }
                column(CategoryName_AppraisalTrainingNeeds; "Appraisal Training Needs"."Category Name")
                {
                }
                column(TrainingNeedDescription_AppraisalTrainingNeeds; "Appraisal Training Needs"."Training Need Description")
                {
                }
                column(Recommended_AppraisalTrainingNeeds; "Appraisal Training Needs".Recommended)
                {
                }
                column(RecommendationJustification_AppraisalTrainingNeeds; "Appraisal Training Needs"."Recommendation Justification")
                {
                }
                dataitem(Vendor; Vendor)
                {
                    DataItemLink = "No."=field("Proposed Trainer");

                    column(ProposedTrainer_Vendor; Vendor.Name)
                    {
                    }
                }
                trigger OnAfterGetRecord()
                begin
                    if "Appraisal Training Needs"."Category Name" = '' then CurrReport.Skip;
                end;
            }
            dataitem("Areas of Further Development"; "Areas of Further Development")
            {
                DataItemLink = "Appraisal No."=FIELD("No.");

                column(LineNo_AreasofFurtherDevelopment; "Areas of Further Development"."Line No.")
                {
                }
                column(AppraisalNo_AreasofFurtherDevelopment; "Areas of Further Development"."Appraisal No.")
                {
                }
                column(EmployeeNo_AreasofFurtherDevelopment; "Areas of Further Development"."Employee No.")
                {
                }
                column(Weakness_AreasofFurtherDevelopment; "Areas of Further Development".Weakness)
                {
                }
                column(TrainingNeeded_AreasofFurtherDevelopment; "Areas of Further Development"."Training Needed")
                {
                }
                column(SupportNeeded_AreasofFurtherDevelopment; "Areas of Further Development"."Support Needed")
                {
                }
                column(StatusComment_AreasofFurtherDevelopment; "Areas of Further Development"."Status Comment")
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if "Areas of Further Development".Weakness = '' then CurrReport.Skip;
                end;
            }
            dataitem("Appraisal Competence"; "Appraisal Competence")
            {
                DataItemLink = "Appraisal No"=FIELD("No.");

                column(LineNo_AppraisalCompetence; "Appraisal Competence"."Line No")
                {
                }
                column(AppraisalNo_AppraisalCompetence; "Appraisal Competence"."Appraisal No")
                {
                }
                column(EmployeeNo_AppraisalCompetence; "Appraisal Competence"."Employee Code")
                {
                }
                column(CompetenceCategory_AppraisalCompetence; "Appraisal Competence"."Competence Category")
                {
                }
                column(MaximumWeigth_AppraisalCompetence; "Appraisal Competence"."Maximum Weigth")
                {
                }
                column(OverallRating_AppraisalCompetence; "Appraisal Competence"."Overall Score")
                {
                }
                column(TotalWeigth_AppraisalCompetence; "Appraisal Competence"."Total Weigth")
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if "Appraisal Competence"."Competence Category" = '' then CurrReport.Skip;
                end;
            }
            trigger OnAfterGetRecord()
            begin
                UserSetup.Reset;
                UserSetup.SetRange("Employee No.", "Appraisal Header"."Employee No");
                if UserSetup.FindFirst then UserSetup.CalcFields(Signature);
                UserSetup1.Reset;
                UserSetup1.SetRange("Line Manager", "Appraisal Header"."Peer 1 Employee No");
                if UserSetup1.FindFirst then UserSetup1.CalcFields(Signature);
                If AppraisalCalender.Get("Appraisal Header"."Calendar Code")then AppraisalPeriodName:=AppraisalCalender.Description;
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    UserSetup: Record "User Setup";
    Approver: Code[70];
    UserSetup1: Record "User Setup";
    AppraisalPeriodName: Text;
    AppraisalCalender: Record "Appraisal Calender";
    ReviewPeriodName: Text;
    ReviewPeriod: Record "Appraisal Review Periods";
}

report 52203507 "Training Plan Due"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Training Plan Due.rdl';

    dataset
    {
        dataitem("Training Plan Lines"; "Training Plan Lines")
        {
            RequestFilterFields = "Global Dimension 1 Code", "Calender Code";

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
            column(PlanNo_TrainingPlanLines; "Training Plan Lines"."Plan No.")
            {
            }
            column(TrainingNeed_TrainingPlanLines; "Training Plan Lines"."Training Need")
            {
            }
            column(TrainingNeedDescription_TrainingPlanLines; "Training Plan Lines"."Training Need Description")
            {
            }
            column(TrainerCode_TrainingPlanLines; "Training Plan Lines"."Trainer Code")
            {
            }
            column(TrainerName_TrainingPlanLines; "Training Plan Lines"."Trainer Name")
            {
            }
            column(ExpectedStartDate_TrainingPlanLines; "Training Plan Lines"."Expected Start Date")
            {
            }
            column(ExpectedEndDate_TrainingPlanLines; "Training Plan Lines"."Expected End Date")
            {
            }
            column(EstimatedCost_TrainingPlanLines; "Training Plan Lines"."Estimated Cost")
            {
            }
            column(Duration_TrainingPlanLines; "Training Plan Lines".Duration)
            {
            }
            column(EmployeeSpecific_TrainingPlanLines; "Training Plan Lines"."Employee Specific")
            {
            }
            column(EmployeeNo_TrainingPlanLines; "Training Plan Lines"."Employee No")
            {
            }
            column(EmployeeName_TrainingPlanLines; "Training Plan Lines"."Employee Name")
            {
            }
            column(GlobalDimension1Code_TrainingPlanLines; "Training Plan Lines"."Global Dimension 1 Code")
            {
            }
            column(LineNo_TrainingPlanLines; "Training Plan Lines"."Line No.")
            {
            }
            column(CalenderCode_TrainingPlanLines; "Training Plan Lines"."Calender Code")
            {
            }
            column(ExpectedTrainees_TrainingPlanLines; "Training Plan Lines"."Expected Trainees")
            {
            }
            column(NoofApplications_TrainingPlanLines; "Training Plan Lines"."No. of Applications")
            {
            }
            column(TrainingVenue_TrainingPlanLines; "Training Plan Lines"."Training Venue")
            {
            }
            column(TrainingSponsor_TrainingPlanLines; "Training Plan Lines"."Training Sponsor")
            {
            }
            column(DepartmentName_TrainingPlanLines; DepartmentName)
            {
            }
            trigger OnAfterGetRecord()
            begin
                DimensionValue.Reset;
                DimensionValue.SetRange(Code, "Global Dimension 1 Code");
                if DimensionValue.FindFirst then begin
                    DepartmentName:=DimensionValue.Name;
                end;
            end;
            trigger OnPreDataItem()
            begin
                if StarttDate = 0D then Error('You must specify the cut off date');
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
                "Training Plan Lines".SetFilter("Training Plan Lines"."Expected Start Date", '>=%1', StarttDate);
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                field("Cut off Date"; StarttDate)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    var CompanyInformation: Record "Company Information";
    StarttDate: Date;
    DepartmentName: Text;
    DimensionValue: Record "Dimension Value";
}

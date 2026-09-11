report 52203506 "Training Needs Allocation"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Training Needs Allocation.rdl';

    dataset
    {
        dataitem("Training Application"; "Training Application")
        {
            DataItemTableView = WHERE(Status=CONST(Attended));
            RequestFilterFields = "Global Dimension 1 Code", Status;

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
            column(ApplicationNo_TrainingApplication; "Training Application"."No.")
            {
            }
            column(DateofApplication_TrainingApplication; "Training Application"."Date of Application")
            {
            }
            column(CreatedBy_TrainingApplication; "Training Application"."Created By")
            {
            }
            column(CreatedOn_TrainingApplication; "Training Application"."Created On")
            {
            }
            column(NoSeries_TrainingApplication; "Training Application"."No. Series")
            {
            }
            column(TrainingCalender_TrainingApplication; "Training Application"."Training Calender")
            {
            }
            column(TrainingNeed_TrainingApplication; "Training Application"."Training Need")
            {
            }
            column(TrainingNeedDescription_TrainingApplication; "Training Application"."Training Need Description")
            {
            }
            column(GlobalDimension1Code_TrainingApplication; "Training Application"."Global Dimension 1 Code")
            {
            }
            column(EmployeeNo_TrainingApplication; "Training Application"."Employee No")
            {
            }
            column(EmployeeName_TrainingApplication; "Training Application"."Employee Name")
            {
            }
            column(Status_TrainingApplication; "Training Application".Status)
            {
            }
            column(StartDate_TrainingApplication; "Training Application"."Start Date")
            {
            }
            column(EndDate_TrainingApplication; "Training Application"."End Date")
            {
            }
            column(Period_TrainingApplication; "Training Application".Period)
            {
            }
            column(ExpectedCost_TrainingApplication; "Training Application"."Expected Cost")
            {
            }
            column(Trainer_TrainingApplication; "Training Application".Trainer)
            {
            }
            column(TrainingPlanLineNo_TrainingApplication; "Training Application"."Training Plan Line No")
            {
            }
            column(JobGroup_TrainingApplication; "Training Application"."Job Group")
            {
            }
            column(JobTitle_TrainingApplication; "Training Application"."Job Title")
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
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    DepartmentName: Text;
    DimensionValue: Record "Dimension Value";
}

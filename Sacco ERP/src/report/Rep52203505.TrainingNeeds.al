report 52203505 "Training Needs"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Training Needs.rdl';

    dataset
    {
        dataitem("Training Need"; "Training Need")
        {
            DataItemTableView = WHERE("From Appraisal"=CONST(true));

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
            column(Code_TrainingNeed; "Training Need".Code)
            {
            }
            column(Description_TrainingNeed; "Training Need".Description)
            {
            }
            column(GlobalDimension1Code_TrainingNeed; "Training Need"."Global Dimension 1 Code")
            {
            }
            column(CreatedBy_TrainingNeed; "Training Need"."Created By")
            {
            }
            column(CreatedOn_TrainingNeed; "Training Need"."Created On")
            {
            }
            column(EmployeeSpecific_TrainingNeed; "Training Need"."Employee Specific")
            {
            }
            column(EmployeeNo_TrainingNeed; "Training Need"."Employee No")
            {
            }
            column(EmployeeName_TrainingNeed; "Training Need"."Employee Name")
            {
            }
            column(FromAppraisal_TrainingNeed; "Training Need"."From Appraisal")
            {
            }
            column(AppraisalCalender_TrainingNeed; "Training Need"."Calendar Code")
            {
            }
            column(AppraisalPeriod_TrainingNeed; AppraisalPeriodName)
            {
            }
            column(Supervisor_TrainingNeed; SupervisorName)
            {
            }
            column(TrainingSource_TrainingNeed; "Training Need"."Training Source")
            {
            }
            column(TrainingObjective_TrainingNeed; "Training Need"."Training Objective")
            {
            }
            column(DepartmentName_TrainingNeed; DepartmentName)
            {
            }
            column(Trainer_TrainingApplication; TrainerName)
            {
            }
            column(JobTitle; JobTitle)
            {
            }
            column(JobGroup; JobGroup)
            {
            }
            trigger OnAfterGetRecord()
            begin
                JobTitle:='';
                DepartmentName:='';
                AppraisalPeriodName:='';
                SupervisorName:='';
                if Employee.Get("Employee No")then begin
                    JobTitle:=Employee."Job Title";
                    JobGroup:=Employee."Job Scale";
                end;
                DimensionValue.Reset;
                DimensionValue.SetRange(Code, "Global Dimension 1 Code");
                if DimensionValue.FindFirst then begin
                    DepartmentName:=DimensionValue.Name;
                end;
                if AppraisalCalender.Get("Appraisal Period")then begin
                    AppraisalPeriodName:=AppraisalCalender.Description;
                end;
                if Employee.Get(Supervisor)then SupervisorName:=Employee.FullName;
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
    DepartmentName: Text;
    JobGroup: Text;
    DimensionValue: Record "Dimension Value";
    Vendor: Record Vendor;
    TrainerName: Text;
    AppraisalCalender: Record "Appraisal Calender";
    AppraisalPeriodName: Text;
    SupervisorName: Text;
}

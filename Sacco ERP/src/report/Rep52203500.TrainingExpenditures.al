report 52203500 "Training Expenditures"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Training Expenditures.rdl';

    dataset
    {
        dataitem("Training Application"; "Training Application")
        {
            RequestFilterFields = "Training Need", "Training Calender", "Global Dimension 1 Code", "Employee No", Status;

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
            column(Division_TrainingApplication; "Training Application"."Global Dimension 1 Code")
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
            column(Trainer_TrainingApplication; TrainerName)
            {
            }
            column(JobGroup_TrainingApplication; "Training Application"."Job Group")
            {
            }
            column(JobTitle_TrainingApplication; "Training Application"."Job Title")
            {
            }
            column(ExceedsExpectedTrainees_TrainingApplication; "Training Application"."Exceeds Expected Trainees")
            {
            }
            column(TrainingStartDate_TrainingApplication; "Training Application"."Training Start Date")
            {
            }
            column(Department_TrainingApplication; "Training Application"."Global Dimension 1 Code")
            {
            }
            column(EstimateCost_TrainingApplication; "Training Application"."Expected Cost")
            {
            }
            column(TrainingAllowance_TrainingApplication; TrainingAllowance)
            {
            }
            column(TotalCost_TrainingApplication; "Training Application"."Expected Cost" + TrainingAllowance)
            {
            }
            column(ReportFilters; ReportFilters)
            {
            }
            dataitem(Employee; Employee)
            {
                DataItemLink = "No."=FIELD("Employee No");

                column(JobTitle_Employee; Employee."Job Title")
                {
                }
                column(DepartmentName_Employee; DepartmentName)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if PayrollScale.Get(Employee."Job Scale")then TrainingAllowance:=PayrollScale."Training Allowance Amount";
                end;
            }
            trigger OnAfterGetRecord()
            begin
                DimensionValue.Reset;
                DimensionValue.SetRange(Code, "Global Dimension 1 Code");
                if DimensionValue.FindFirst then begin
                    DepartmentName:=DimensionValue.Name;
                end;
                if Vendor.Get(Trainer)then TrainerName:=Vendor.Name;
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.GET;
                CompanyInformation.CALCFIELDS(Picture);
                ReportFilters:="Training Application".GetFilters;
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    DepartmentName: Text;
    DimensionValue: Record "Dimension Value";
    PayrollScale: Record "Employee Payroll Scales";
    TrainingAllowance: Decimal;
    ReportFilters: Text;
    Vendor: Record Vendor;
    TrainerName: Text;
}

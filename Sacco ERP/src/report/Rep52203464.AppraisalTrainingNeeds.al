report 52203464 "Appraisal Training Needs"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Appraisal Training Needs.rdl';

    dataset
    {
        dataitem("Appraisal Training Needs"; "Appraisal Training Needs")
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
            dataitem("Weakness Development Plan"; "Appraisal Training Needs")
            {
                column(LineNo_WeaknessDevelopmentPlan; "Weakness Development Plan"."Line No.")
                {
                }
                column(AppraisalNo_WeaknessDevelopmentPlan; "Weakness Development Plan"."Appraisal No.")
                {
                }
                column(EmployeeNo_WeaknessDevelopmentPlan; "Weakness Development Plan"."Employee No.")
                {
                }
                column(DevelopmentPlan_WeaknessDevelopmentPlan; "Weakness Development Plan"."Training Needs Line No.")
                {
                }
                column(WekanessLineNo_WeaknessDevelopmentPlan; "Weakness Development Plan"."Training Needs Line No.")
                {
                }
                column(TrainingCategory_WeaknessDevelopmentPlan; "Weakness Development Plan".Category)
                {
                }
                column(ProposedTrainer_WeaknessDevelopmentPlan; "Weakness Development Plan"."Proposed Trainer")
                {
                }
                column(TrainingNeedDescription_WeaknessDevelopmentPlan; "Weakness Development Plan"."Training Need Description")
                {
                }
                column(EmployeeName; EmployeeName)
                {
                }
                column(AppraisalPeriod; AppraisalPeriod)
                {
                }
                column(Division; Division)
                {
                }
                column(Department; Department)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    EmployeeName:='';
                    AppraisalPeriod:='';
                    Division:='';
                    Department:='';
                    IF NOT AppraisalHeader.GET("Weakness Development Plan"."Appraisal No.")THEN CurrReport.SKIP;
                    EmployeeName:=AppraisalHeader."Employee Name";
                    Division:=AppraisalHeader."Global Dimension 1 Code";
                    Department:=AppraisalHeader."Global Dimension 2 Code";
                    If AppraisalCalender.Get(AppraisalHeader."Calendar Code")then AppraisalPeriod:=AppraisalCalender.Description;
                end;
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.GET;
                CompanyInformation.CALCFIELDS(Picture);
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    PeriodYear: Integer;
    GratuityAmount: Decimal;
    PayrollPeriods: Record "Payroll Periods";
    PayrollPeriodTransaction: Record "Payroll Period Transaction";
    EmployeeName: Text;
    AppraisalPeriod: Text;
    AppraisalCalender: Record "Appraisal Calender";
    Division: Text;
    Department: Text;
    AppraisalHeader: Record "Appraisal Header";
}

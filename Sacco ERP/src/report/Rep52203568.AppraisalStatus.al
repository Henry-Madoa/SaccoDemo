report 52203568 "Appraisal Status"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Appraisal Status.rdl';

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
            column(Department_AppraisalHeader; "Appraisal Header"."Global Dimension 1 Code")
            {
            }
            column(AppraisalStartDate_AppraisalHeader; "Appraisal Header"."Appraisal Start Date")
            {
            }
            column(AppraisalEndDate_AppraisalHeader; "Appraisal Header"."Appraisal End Date")
            {
            }
            column(SupervisorUserID_AppraisalHeader; "Appraisal Header"."Supervisor User Id")
            {
            }
            column(AppraisalCalendar_AppraisalHeader; "Appraisal Header"."Calendar Code")
            {
            }
            column(AppraisalPeriodName_AppraisalHeader; AppraisalPeriodName)
            {
            }
            column(AppraisalStatus_AppraisalHeader; "Appraisal Header".Status)
            {
            }
            trigger OnAfterGetRecord()
            begin
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
    AppraisalPeriodName: Text;
    AppraisalCalender: Record "Appraisal Calender";
}

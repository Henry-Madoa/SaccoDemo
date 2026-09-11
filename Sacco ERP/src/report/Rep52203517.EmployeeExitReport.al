report 52203517 "Employee Exit Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Employee Exit Report.rdlc';

    dataset
    {
        dataitem("Employee Exit"; "Employee Exit")
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
            column(ExitNo_EmployeeExit; "Employee Exit"."No.")
            {
            }
            column(EmployeeNo_EmployeeExit; "Employee Exit"."Employee No")
            {
            }
            column(EmployeeName_EmployeeExit; "Employee Exit"."Employee Name")
            {
            }
            column(DateofExit_EmployeeExit; "Employee Exit"."Date of Exit")
            {
            }
            column(ReasonForExit_EmployeeExit; "Employee Exit"."Reason For Exit")
            {
            }
            column(Grade_EmployeeExit; "Employee Exit".Grade)
            {
            }
            column(GlobalDimension1Code_EmployeeExit; "Employee Exit"."Global Dimension 1 Code")
            {
            }
            column(Status_EmployeeExit; "Employee Exit".Status)
            {
            }
            column(NoSeries_EmployeeExit; "Employee Exit"."No. Series")
            {
            }
            column(CreatedBy_EmployeeExit; "Employee Exit"."Created By")
            {
            }
            column(CreatedOn_EmployeeExit; "Employee Exit"."Created On")
            {
            }
            column(InterviewConductedBy_EmployeeExit; "Employee Exit"."Interview Conducted By")
            {
            }
            column(NoticePeriod_EmployeeExit; "Employee Exit"."Notice Period")
            {
            }
            column(ReasonDescription_EmployeeExit; "Employee Exit"."Reason Description")
            {
            }
            column(JobTitle_EmployeeExit; "Employee Exit"."Job Code")
            {
            }
            column(JobDescription_EmployeeExit; "Employee Exit"."Job Description")
            {
            }
            column(PayrollGrade_EmployeeExit; "Employee Exit"."Payroll Grade")
            {
            }
            column(DateOfNotice_EmployeeExit; "Employee Exit"."Date Of Notice")
            {
            }
            column(ExpiryofNotice_EmployeeExit; "Employee Exit"."Expiry of Notice")
            {
            }
            column(NoticeFullyServed_EmployeeExit; "Employee Exit"."Notice Fully Served")
            {
            }
            column(ReasonsForNotServingNotice_EmployeeExit; "Employee Exit"."Reasons For Not Serving Notice")
            {
            }
            column(DateofExitInterview_EmployeeExit; "Employee Exit"."Date of Exit Interview")
            {
            }
            column(TotalLeaveBalnces_EmployeeExit; "Employee Exit"."Total Leave Balances")
            {
            }
            column(LeaveDayWorth_EmployeeExit; "Employee Exit"."Leave Day Worth")
            {
            }
            column(LeavePay_EmployeeExit; "Employee Exit"."Leave Pay")
            {
            }
            column(Gratuity_EmployeeExit; "Employee Exit".Gratuity)
            {
            }
            column(BasicPay_EmployeeExit; "Employee Exit"."Basic Pay")
            {
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

report 52203499 "Leave Application History"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Leave Application History.rdlc';

    dataset
    {
        dataitem("Leave Applications"; "Leave Applications")
        {
            RequestFilterFields = "Start Date";

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
            column(EmployeeNo_leaveApplication; "Leave Applications"."Employee No")
            {
            }
            column(ApplicationNo_leaveApplication; "Leave Applications"."No.")
            {
            }
            column(Comments_leaveApplication; "Leave Applications".Comments)
            {
            }
            column(Noseries_leaveApplication; "Leave Applications"."No. series")
            {
            }
            column(EmployeeName_leaveApplication; "Leave Applications"."Employee Name")
            {
            }
            column(GlobalDimension1Code_leaveApplication; "Leave Applications"."Global Dimension 1 Code")
            {
            }
            column(Attachment_leaveApplication; "Leave Applications".Attachment)
            {
            }
            column(SupervisorCode_leaveApplication; "Leave Applications"."Supervisor Code")
            {
            }
            column(SupervisorName_leaveApplication; "Leave Applications"."Supervisor Name")
            {
            }
            column(TotalNoofLeavesApplied_leaveApplication; "Leave Applications"."Total No. of Leaves Applied")
            {
            }
            column(DateFilter_leaveApplication; "Leave Applications"."Date Filter")
            {
            }
            column(Reliever_leaveApplication; "Leave Applications".Reliever)
            {
            }
            column(RelieverName_leaveApplication; "Leave Applications"."Reliever Name")
            {
            }
            column(Status_leaveApplication; "Leave Applications".Status)
            {
            }
            column(ApprovalLevel_leaveApplication; "Leave Applications"."Approval Level")
            {
            }
            column(ActionId_leaveApplication; "Leave Applications"."Action Id")
            {
            }
            column(CurrentLevel_leaveApplication; "Leave Applications"."Current Level")
            {
            }
            column(LeaveCode_leaveApplication; "Leave Applications"."Leave Code")
            {
            }
            column(DaysApplied_leaveApplication; "Leave Applications"."Days Applied")
            {
            }
            column(StartDate_leaveApplication; "Leave Applications"."Start Date")
            {
            }
            column(EndDate_leaveApplication; "Leave Applications"."End Date")
            {
            }
            column(ApplicationDate_leaveApplication; "Leave Applications"."Application Date")
            {
            }
            column(Leavebalance_leaveApplication; "Leave Applications"."Leave balance")
            {
            }
            column(UserID_leaveApplication; "Leave Applications"."User ID")
            {
            }
            column(HalfDayonStartDate_leaveApplication; "Leave Applications"."Half Day on Start Date")
            {
            }
            column(HalfDayonEndDate_leaveApplication; "Leave Applications"."Half Day on End Date")
            {
            }
            column(TotalNoOfDays_leaveApplication; "Leave Applications"."Total No Of Days")
            {
            }
            column(Holidays_leaveApplication; "Leave Applications".Holidays)
            {
            }
            column(WeekendDays_leaveApplication; "Leave Applications"."Weekend Days")
            {
            }
            column(Days_leaveApplication; "Leave Applications".Days)
            {
            }
            column(BalanceAfter_leaveApplication; "Leave Applications"."Balance After")
            {
            }
            column(ReturnDate_leaveApplication; "Leave Applications"."Return Date")
            {
            }
            column(ReportingDate_leaveApplication; "Leave Applications"."Reporting Date")
            {
            }
            column(CreatedBy_leaveApplication; "Leave Applications"."Created By")
            {
            }
            column(CreatedOn_leaveApplication; "Leave Applications"."Created On")
            {
            }
            column(ContactAddress_leaveApplication; "Leave Applications"."Contact Address")
            {
            }
            column(EmployeePhoneNo_leaveApplication; "Leave Applications"."Employee Phone No.")
            {
            }
            column(LeaveCalenderCode_leaveApplication; "Leave Applications"."Leave Calender Code")
            {
            }
            column(Posted_leaveApplication; "Leave Applications".Posted)
            {
            }
            column(ApprovalEntries_leaveApplication; "Leave Applications"."Approval Entries")
            {
            }
            column(GlobalDimension2Code_leaveApplication; "Leave Applications"."Global Dimension 2 Code")
            {
            }
            column(SystemEntry_leaveApplication; "Leave Applications"."System Entry")
            {
            }
            column(LeaveTypeDecription_leaveApplication; "Leave Applications"."Leave Type Decription")
            {
            }
            column(AppointmentDate_leaveApplication; "Leave Applications"."Appointment Date")
            {
            }
            column(PhoneNo_leaveApplication; "Leave Applications"."Phone No.")
            {
            }
            column(EMailAddress_leaveApplication; "Leave Applications"."E-Mail Address")
            {
            }
            column(Grade_leaveApplication; "Leave Applications".Grade)
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

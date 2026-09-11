report 52203560 "Leave Adjustment Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Leave Adjustment Report.rdlc';

    dataset
    {
        dataitem("Leave Adjustment Header"; "Leave Adjustment Header")
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
            column(LeaveAdjustmentsNo_LeaveAdjustmentHeader; "Leave Adjustment Header"."Leave Adjustments No.")
            {
            }
            column(Status_LeaveAdjustmentHeader; "Leave Adjustment Header".Status)
            {
            }
            column(Type_LeaveAdjustmentHeader; "Leave Adjustment Header".Type)
            {
            }
            column(Description_LeaveAdjustmentHeader; "Leave Adjustment Header".Description)
            {
            }
            column(LeaveType_LeaveAdjustmentHeader; "Leave Adjustment Header"."Leave Type")
            {
            }
            column(LeaveTypeName_LeaveAdjustmentHeader; "Leave Adjustment Header"."Leave Type Name")
            {
            }
            dataitem("Leave Adjustment Line"; "Leave Adjustment Line")
            {
                column(No_LeaveAdjustmentLine; "Leave Adjustment Line"."No.")
                {
                }
                column(EmployeeNo_LeaveAdjustmentLine; "Leave Adjustment Line"."Employee No.")
                {
                }
                column(ProcessedDate_LeaveAdjustmentLine; "Leave Adjustment Line"."Processed Date")
                {
                }
                column(EmployeeName_LeaveAdjustmentLine; "Leave Adjustment Line"."Employee Name")
                {
                }
                column(AdjustmentDays_LeaveAdjustmentLine; "Leave Adjustment Line"."Adjustment Days")
                {
                }
                column(Department; Department)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    Department:='';
                    IF Employee.GET("Leave Adjustment Line"."Employee No.")THEN Department:=Employee."Global Dimension 2 Code" end;
                trigger OnPreDataItem()
                begin
                    CompanyInformation.GET;
                    CompanyInformation.CALCFIELDS(Picture);
                end;
            }
        }
    }
    var CompanyInformation: Record "Company Information";
    PeriodYear: Integer;
    GratuityAmount: Decimal;
    PayrollPeriods: Record "Payroll Periods";
    PayrollPeriodTransaction: Record "Payroll Period Transaction";
    Department: Code[50];
    Employee: Record Employee;
}

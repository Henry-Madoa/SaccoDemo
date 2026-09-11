report 52203488 "Initialize Payroll Period"
{
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(content)
            {
                field("Start Date"; StartDate)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        if StartDate = 0D then Error('Start Date Must have a value');
        PayrollPeriods.Init;
        PayrollPeriods."Period Name":=Format(StartDate, 0, '<Month Text>-<Year4>');
        PayrollPeriods."Start Date":=CalcDate('-CM', StartDate);
        PayrollPeriods."End Date":=CalcDate('CM', StartDate);
        PayrollPeriods."Period Month":=Date2DMY(StartDate, 2);
        PayrollPeriods."Period Year":=Date2DMY(StartDate, 3);
        PayrollPeriods."Created By":=UserId;
        PayrollPeriods."Created On":=WorkDate;
        PayrollPeriods.Insert;
    end;
    var StartDate: Date;
    PayrollPeriods: Record "Payroll Periods";
}

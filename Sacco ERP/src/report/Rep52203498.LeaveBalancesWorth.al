report 52203498 "Leave Balances Worth"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Leave Balances Worth.rdlc';

    dataset
    {
        dataitem("Leave Types"; "Leave Types")
        {
            DataItemTableView = WHERE("Is Annual Leave"=CONST(true));

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
            column(LeaveDayWorth_LeaveTypes; LeaveDaysWorth)
            {
            }
            column(Code_LeaveTypes; "Leave Types".Code)
            {
            }
            column(Description_LeaveTypes; "Leave Types".Description)
            {
            }
            dataitem("Leave Ledger Entries"; "Leave Ledger Entries")
            {
                DataItemLink = "Leave Type"=FIELD(Code);
                DataItemTableView = WHERE(Closed=CONST(false));

                column(EmployeeNo_LeaveLedgerEntries; "Leave Ledger Entries"."Employee No.")
                {
                }
                column(EmployeeName_LeaveLedgerEntries; "Leave Ledger Entries"."Employee Name")
                {
                }
                column(Quantity_LeaveLedgerEntries; "Leave Ledger Entries".Quantity)
                {
                }
                column(LeaveYearCode_LeaveLedgerEntries; "Leave Ledger Entries"."Leave Year Code")
                {
                }
                column(LeaveEntryType_LeaveLedgerEntries; "Leave Ledger Entries"."Leave Entry Type")
                {
                }
                trigger OnAfterGetRecord()
                begin
                    LeaveDaysWorth:=0;
                    if Employee.Get("Leave Ledger Entries"."Employee No.")then begin
                        LeaveDaysToAccrueMatrix.Reset;
                        LeaveDaysToAccrueMatrix.SetRange("Leave Type", "Leave Ledger Entries"."Leave Type");
                        LeaveDaysToAccrueMatrix.SetRange("Employee Grade Code", Employee."Job Scale");
                        if LeaveDaysToAccrueMatrix.FindFirst then LeaveDaysWorth:=LeaveDaysToAccrueMatrix."Leave Day Worth";
                    end;
                end;
                trigger OnPreDataItem()
                begin
                    CompanyInformation.Get;
                    CompanyInformation.CalcFields(Picture);
                end;
            }
        }
    }
    var CompanyInformation: Record "Company Information";
    Employee: Record Employee;
    LeaveDaysToAccrueMatrix: Record "Leave Days To Accrue Matrix";
    LeaveDaysWorth: Decimal;
}

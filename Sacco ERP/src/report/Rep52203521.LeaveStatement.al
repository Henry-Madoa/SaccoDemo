report 52203521 "Leave Statement"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Leave Statement.rdlc';

    dataset
    {
        dataitem(Employee; Employee)
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
            column(GratuityAmount; GratuityAmount)
            {
            }
            column(FullName_Employee; Employee.FullName)
            {
            }
            column(No_Employee; Employee."No.")
            {
            }
            dataitem("Leave Ledger Entries"; "Leave Ledger Entries")
            {
                DataItemLink = "Employee No."=FIELD("No.");

                column(ApplicationNo_LeaveLedgerEntries; "Leave Ledger Entries"."Application No.")
                {
                }
                column(Description_LeaveLedgerEntries; "Leave Ledger Entries".Description)
                {
                }
                column(EmployeeNo_LeaveLedgerEntries; "Leave Ledger Entries"."Employee No.")
                {
                }
                column(LeaveType_LeaveLedgerEntries; "Leave Ledger Entries"."Leave Type")
                {
                }
                column(PostingDate_LeaveLedgerEntries; "Leave Ledger Entries"."Posting Date")
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
                column(DocumentNo_LeaveLedgerEntries; "Leave Ledger Entries"."Document No.")
                {
                }
                column(LeaveApplicationNo_LeaveLedgerEntries; "Leave Ledger Entries"."Leave Application No.")
                {
                }
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    PeriodYear: Integer;
    GratuityAmount: Decimal;
    PayrollPeriods: Record "Payroll Periods";
    PayrollPeriodTransaction: Record "Payroll Period Transaction";
}

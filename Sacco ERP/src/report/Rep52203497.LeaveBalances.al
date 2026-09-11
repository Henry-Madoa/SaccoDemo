report 52203497 "Leave Balances"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Leave Balances.rdl';

    dataset
    {
        dataitem("Leave Ledger Entries"; "Leave Ledger Entries")
        {
            RequestFilterFields = "Leave Year Code";

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
            column(EmployeeNo_LeaveLedgerEntries; "Leave Ledger Entries"."Employee No.")
            {
            }
            column(EmployeeName_LeaveLedgerEntries; "Leave Ledger Entries"."Employee Name")
            {
            }
            column(Quantity_LeaveLedgerEntries; "Leave Ledger Entries".Quantity)
            {
            }
            column(EnteredBy_LeaveLedgerEntries; "Leave Ledger Entries"."Entered By")
            {
            }
            column(PostingDate_LeaveLedgerEntries; "Leave Ledger Entries"."Posting Date")
            {
            }
            column(LeaveType_LeaveLedgerEntries; "Leave Ledger Entries"."Leave Type")
            {
            }
            column(LeaveEntryType_LeaveLedgerEntries; "Leave Ledger Entries"."Leave Entry Type")
            {
            }
            column(LeaveYearCode_LeaveLedgerEntries; "Leave Ledger Entries"."Leave Year Code")
            {
            }
            column(JobGroup; JobGroup)
            {
            }
            column(Depertment; Depertment)
            {
            }
            trigger OnAfterGetRecord()
            begin
                JobGroup:='';
                if Employee.Get("Leave Ledger Entries"."Employee No.")then begin
                    JobGroup:=Employee."Job Scale";
                    DimensionValue.RESET;
                    DimensionValue.SETRANGE("Dimension Code", 'DEPARTMENT');
                    DimensionValue.SETRANGE(Code, Employee."Global Dimension 1 Code");
                    IF DimensionValue.FINDFIRST THEN Depertment:=DimensionValue.Name;
                end;
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    JobGroup: Code[50];
    Employee: Record Employee;
    DimensionValue: Record "Dimension Value";
    Depertment: Text;
}

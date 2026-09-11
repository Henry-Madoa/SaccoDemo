report 52203502 "Annual Leave Balances"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Annual Leave Balances.rdl';

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
            column(EmployeeName; EmployeeName)
            {
            }
            column(JobGroup; JobGroup)
            {
            }
            column(JobTitle; JobTitle)
            {
            }
            trigger OnAfterGetRecord()
            begin
                JobGroup:='';
                JobGroup:='';
                EmployeeName:='';
                if Employee.Get("Leave Ledger Entries"."Employee No.")then begin
                    JobGroup:=Employee."Job Scale";
                    JobTitle:=Employee."Job Title";
                    EmployeeName:=Employee.FullName;
                end;
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
                LeaveTypes.Reset;
                LeaveTypes.SetRange("Is Annual Leave", true);
                if LeaveTypes.FindFirst then "Leave Ledger Entries".SetRange("Leave Ledger Entries"."Leave Type", LeaveTypes.Code)
                else
                    Error('No Leave type marked as %1', LeaveTypes."Is Annual Leave");
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    LeaveTypes: Record "Leave Types";
    EmployeeName: Text;
    JobGroup: Text;
    JobTitle: Text;
    Employee: Record Employee;
}

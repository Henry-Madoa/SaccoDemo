report 52204072 "Job Queue Execution"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    PreviewMode = Normal;
    RDLCLayout = './ssrs/Job Execution Entries.rdl';

    dataset
    {
        dataitem("Job Execution Entries"; "Job Execution Entries")
        {
            RequestFilterFields = "Run Date", "Task Type";

            column(Entry_No; "Entry No")
            {
            }
            column(Run_Date; "Run Date")
            {
            }
            column(Amount; Amount)
            {
            }
            column(Task_Type; "Task Type")
            {
            }
            column(Credit_Account; "Credit Account")
            {
            }
            column(Member_No; "Member No")
            {
            }
            column(MemberName; MemberName)
            {
            }
            column(PFNo; PFNo)
            {
            }
            column(PhoneNo; PhoneNo)
            {
            }
            column(IDNo; IDNo)
            {
            }
            column(SASA_Amount; "SASA Amount")
            {
            }
            column(Investment_Amount; "Investment Amount")
            {
            }
            column(Deposits_Amount; "Deposits Amount")
            {
            }
            trigger OnAfterGetRecord()
            begin
                MemberName := '';
                PFNo := '';
                IDNo := '';
                Employer := '';
                PhoneNo := '';
                if Amount = 0 then CurrReport.Skip();
                if Members.Get("Member No") then begin
                    PhoneNo := Members."Mobile Phone No.";
                    MemberName := Members."Full Name";
                    PFNo := Members."Payroll No.";
                    if PFNo = '' then PFNo := Members."Payroll No.";
                    IDNo := Members."Identification No.";
                    if Employers.Get(Members."Employer Code") then Employer := Employers.Name;
                end;
            end;
        }
    }
    var
        Members: Record Members;
        MemberName, PFNo, IDNo, PhoneNo, Employer : Text[200];
        Employers: Record Employers;
}

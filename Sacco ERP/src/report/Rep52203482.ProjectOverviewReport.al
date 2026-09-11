report 52203482 "Project Overview Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Project Overview Report.rdlc';

    dataset
    {
        dataitem("Project Details"; "Project Details")
        {
            RequestFilterFields = "Donor Code";

            column(ProjectNo; "Project Details"."Donor Code")
            {
            }
            column(Funder; "Project Details"."Donor Description")
            {
            }
            column(ProjectName; "Project Details"."Project Name")
            {
            }
            column(Amount; "Project Details".Amount)
            {
            }
            column(Duration; "Project Details".Duration)
            {
            }
            column(Status; "Project Details".Status)
            {
            }
            column(ApprovalDate; "Project Details"."Approval Date")
            {
            }
            column(Currency; "Project Details".Currency)
            {
            }
            column(ApprovedAmount; "Project Details"."Approved Amount")
            {
            }
            column(ApprovalWithdrawal; "Project Details"."Approval/Withdrawal")
            {
            }
            column(ContractDate; "Project Details"."Contract Date")
            {
            }
            column(ContractAmount; "Project Details"."Contract Amount")
            {
            }
            column(Expected; "Project Details"."Expected Amount (Transfers)")
            {
            }
            column(ActualAmount; "Project Details"."Actual Amount (Transfers)")
            {
            }
        }
    }
}

report 52203427 "Completion Certificate"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Completion Certificate.rdlc';

    dataset
    {
        dataitem("Contract Milestone"; "Contract Milestone")
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
            column(ContractNo_ContractMilestone; "Contract Milestone"."Contract No")
            {
            }
            column(MilestoneCode_ContractMilestone; "Contract Milestone"."Milestone Code")
            {
            }
            column(MilestoneDescription_ContractMilestone; "Contract Milestone"."Milestone Description")
            {
            }
            column(StartDate_ContractMilestone; "Contract Milestone"."Start Date")
            {
            }
            column(Period_ContractMilestone; "Contract Milestone".Period)
            {
            }
            column(EndDate_ContractMilestone; "Contract Milestone"."End Date")
            {
            }
            column(IsPercentage_ContractMilestone; "Contract Milestone"."Is Percentage")
            {
            }
            column(Percentage_ContractMilestone; "Contract Milestone".Percentage)
            {
            }
            column(FixedAmount_ContractMilestone; "Contract Milestone"."Fixed Amount")
            {
            }
            column(Amount_ContractMilestone; "Contract Milestone".Amount)
            {
            }
            column(OrderCreated_ContractMilestone; "Contract Milestone"."Order Created")
            {
            }
            column(LineNo_ContractMilestone; "Contract Milestone"."Line No")
            {
            }
            column(ItemNo_ContractMilestone; "Contract Milestone"."Item No.")
            {
            }
            column(ItemName_ContractMilestone; "Contract Milestone"."Item Name")
            {
            }
            column(TenderAmount_ContractMilestone; "Contract Milestone"."Tender Amount")
            {
            }
            trigger OnPostDataItem()
            begin
                NotifySenderToSenderOnApprovalOfContract("Contract Milestone");
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    CommunicationsMgmt: Codeunit "Communications Mgmt";
    local procedure NotifySenderToSenderOnApprovalOfContract(var ContractMilestone: Record "Contract Milestone")
    var
        Vendor: Record Vendor;
        //PaymentVoucherLines: Record "Payment Voucher Lines";
        SenderName: Text;
        SenderAddress: Text;
        Recepient: list of[Text];
        Subject: Text;
        Body: Text;
        Employee: Record Employee;
        UserSetup: Record "User Setup";
        ProcurementSetup: Record "Purchases & Payables Setup";
    begin
        with ContractMilestone do begin
            Clear(Recepient);
            ProcurementSetup.Get;
            if UserSetup.Get(ProcurementSetup."Procurement Officer User Id")then begin
                if Employee.Get(UserSetup."Employee No.")then begin
                    Recepient.Add(UserSetup."E-Mail");
                    Subject:='Milestone Completed';
                    Body:='Dear ' + Employee.FullName + ' <br>The following milestone ' + Format("Milestone Description") + 'For contract no ' + Format("Contract No") + ' has been achieved and its completion certificate has been generated' + '<br> If there is any clarification Please contact the procurement manager' + '<br> This is system generated email, please do not reply to it <br>Regards';
                    CommunicationsMgmt.SendEmailWithoutAttachement(Recepient, Subject, Body);
                end;
            end;
        end;
    end;
}

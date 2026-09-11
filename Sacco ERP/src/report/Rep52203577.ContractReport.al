report 52203577 "Contract Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Contract Report.rdlc';

    dataset
    {
        dataitem("Contract Header"; "Contract Header")
        {
            RequestFilterFields = "Contract Status", "Tender Amount", "Vendor No.", "Requisition No", "Contract Start Date", "Contract period";

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
            column(No_ContractHeader; "Contract Header"."No.")
            {
            }
            column(VendorNo_ContractHeader; "Contract Header"."Vendor No.")
            {
            }
            column(TenderNo_ContractHeader; "Contract Header"."Tender No.")
            {
            }
            column(TenderTitle_ContractHeader; "Contract Header"."Tender Title")
            {
            }
            column(AgreementDate_ContractHeader; "Contract Header"."Agreement Date")
            {
            }
            column(ContractStartDate_ContractHeader; "Contract Header"."Contract Start Date")
            {
            }
            column(Contractperiod_ContractHeader; "Contract Header"."Contract period")
            {
            }
            column(ContractEndDate_ContractHeader; "Contract Header"."Contract End Date")
            {
            }
            column(TenderAmount_ContractHeader; "Contract Header"."Tender Amount")
            {
            }
            column(ContractStatus_ContractHeader; "Contract Header"."Contract Status")
            {
            }
            column(Vendor_Name; VendorName)
            {
            }
            dataitem("Contract Milestone"; "Contract Milestone")
            {
                DataItemLink = "Contract No"=FIELD("No.");

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
                column(MilestoneExtended_ContractMilestone; "Contract Milestone"."Milestone Extended")
                {
                }
                column(NewEndDate_ContractMilestone; "Contract Milestone"."New End Date")
                {
                }
            }
            trigger OnAfterGetRecord()
            begin
                if Vendor.Get("Contract Header"."Vendor No.")then VendorName:=Vendor.Name;
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    Vendor: Record Vendor;
    VendorName: Text[50];
}

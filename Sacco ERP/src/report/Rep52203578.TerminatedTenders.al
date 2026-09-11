report 52203578 "Terminated Tenders"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Terminated Tenders.rdlc';

    dataset
    {
        dataitem("Procurement Request"; "Procurement Request")
        {
            DataItemTableView = WHERE("Procurement Method"=Filter('Open Tendering'|'Restricted Tendering'));
            RequestFilterFields = "No.", Status;

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
            column(No_ProcurementRequest; "Procurement Request"."No.")
            {
            }
            column(Status_ProcurementRequest; "Procurement Request".Status)
            {
            }
            column(Title_ProcurementRequest; "Procurement Request".Description)
            {
            }
            column(RequisitonNo_ProcurementRequest; "Procurement Request"."Requisiton No")
            {
            }
            column(CurrentBudget_ProcurementRequest; "Procurement Request"."Current Budget")
            {
            }
            column(TenderOpeningDate_ProcurementRequest; "Procurement Request"."Tender Opening Date")
            {
            }
            column(TenderDuration_ProcurementRequest; "Procurement Request"."Tender Duration")
            {
            }
            column(TenderClosingDate_ProcurementRequest; "Procurement Request"."Tender Closing Date")
            {
            }
            column(GlobalDimension1Code_ProcurementRequest; "Procurement Request"."Global Dimension 1 Code")
            {
            }
            column(GlobalDimension2Code_ProcurementRequest; "Procurement Request"."Global Dimension 2 Code")
            {
            }
            column(TenderSecurityAmount_ProcurementRequest; "Procurement Request"."Tender Security Amount")
            {
            }
            column(TechnicalPassMark_ProcurementRequest; "Procurement Request"."Technical Pass Mark")
            {
            }
            column(TenderStatus_ProcurementRequest; "Procurement Request"."Tender Status")
            {
            }
            column(ProcurementPlan_ProcurementRequest; "Procurement Request"."Procurement Plan")
            {
            }
            column(TotalAmount_ProcurementRequest; "Procurement Request"."Total Amount")
            {
            }
            column(GeneratedOrderNo_ProcurementRequest; "Procurement Request"."Generated Order No")
            {
            }
            column(DateAwarded_ProcurementRequest; "Procurement Request"."Date Awarded")
            {
            }
            column(ContractNoGenerated_ProcurementRequest; "Procurement Request"."Contract No Generated")
            {
            }
            column(ReasonForTenderTermination_ProcurementRequest; "Procurement Request"."Awarded Vendor No")
            {
            }
            column(DateTerminated_ProcurementRequest; "Procurement Request"."Minimum No. of Suppliers")
            {
            }
            column(TerminatedBy_ProcurementRequest; "Procurement Request"."Terminated By")
            {
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
}

report 52203580 "Tender Awards"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Tender Awards.rdlc';

    dataset
    {
        dataitem("Procurement Request"; "Procurement Request")
        {
            DataItemTableView = WHERE("Tender Status"=FILTER("Contract Created"|"Order Created"));

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
            column(Title_ProcurementRequest; "Procurement Request".Description)
            {
            }
            column(RequisitonNo_ProcurementRequest; "Procurement Request"."Requisiton No")
            {
            }
            column(CurrentBudget_ProcurementRequest; "Procurement Request"."Current Budget")
            {
            }
            column(CreationDate_ProcurementRequest; "Procurement Request"."Creation Date")
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
            column(TenderStatus_ProcurementRequest; "Procurement Request"."Tender Status")
            {
            }
            column(ProcurementPlan_ProcurementRequest; "Procurement Request"."Procurement Plan")
            {
            }
            column(DateofMandatoryEvaluation_ProcurementRequest; "Procurement Request"."Date of Mandatory Evaluation")
            {
            }
            column(DateofTechnicalEvaluation_ProcurementRequest; "Procurement Request"."Date of Technical Evaluation")
            {
            }
            column(DateofFinancialEvaluation_ProcurementRequest; "Procurement Request"."Date of Financial Evaluation")
            {
            }
            column(ContractNoGenerated_ProcurementRequest; "Procurement Request"."Contract No Generated")
            {
            }
            column(AwardedVendorNo_ProcurementRequest; "Procurement Request"."Awarded Vendor No")
            {
            }
            column(DateAwarded_ProcurementRequest; "Procurement Request"."Date Awarded")
            {
            }
            column(GeneratedOrderNo_ProcurementRequest; "Procurement Request"."Generated Order No")
            {
            }
            column(VendorName; VendorName)
            {
            }
            trigger OnAfterGetRecord()
            begin
                VendorName:='';
                if Vendor.Get("Procurement Request"."Awarded Vendor No")then VendorName:=Vendor.Name;
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
    VendorName: Text;
}

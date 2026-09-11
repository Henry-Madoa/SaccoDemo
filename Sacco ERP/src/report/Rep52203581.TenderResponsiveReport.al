report 52203581 "Tender Responsive Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Tender Responsive Report.rdlc';

    dataset
    {
        dataitem("Procurement Request"; "Procurement Request")
        {
            DataItemTableView = WHERE("Tender Status"=FILTER(<>New));

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
            column(MinimumNoofSuppliers_ProcurementRequest; "Procurement Request"."Minimum No. of Suppliers")
            {
            }
            dataitem("Tender Suppliers"; "Tender Suppliers")
            {
                DataItemLink = "Reference No"=FIELD("No.");

                column(ReferenceNo_TenderSuppliers; "Tender Suppliers"."Reference No")
                {
                }
                column(VendorName_TenderSuppliers; "Tender Suppliers"."Vendor Name")
                {
                }
                column(Adress_TenderSuppliers; "Tender Suppliers".Adress)
                {
                }
                column(PostCode_TenderSuppliers; "Tender Suppliers"."Post Code")
                {
                }
                column(City_TenderSuppliers; "Tender Suppliers".City)
                {
                }
                column(PhysicalLocation_TenderSuppliers; "Tender Suppliers"."Physical Location")
                {
                }
                column(EmailAddress_TenderSuppliers; "Tender Suppliers"."Email Address")
                {
                }
                column(ContactPersonName_TenderSuppliers; "Tender Suppliers"."Contact Person Name")
                {
                }
                column(ContactPersonPhoneNo_TenderSuppliers; "Tender Suppliers"."Contact Person Phone No.")
                {
                }
                column(ContactPersonEmail_TenderSuppliers; "Tender Suppliers"."Contact Person E-mail")
                {
                }
                column(BidAmount_TenderSuppliers; "Tender Suppliers"."Bid Amount")
                {
                }
                column(SecurityBidAmount_TenderSuppliers; "Tender Suppliers"."Security Bid Amount")
                {
                }
                column(SecurityBidReceiptNo_TenderSuppliers; "Tender Suppliers"."Security Bid Receipt No.")
                {
                }
                column(TechnicalScore_TenderSuppliers; "Tender Suppliers"."Technical Score")
                {
                }
                column(PassedMandatory_TenderSuppliers; "Tender Suppliers"."Passed Mandatory")
                {
                }
                column(PassedTechnical_TenderSuppliers; "Tender Suppliers"."Passed Technical")
                {
                }
                column(Awarded_TenderSuppliers; "Tender Suppliers".Awarded)
                {
                }
                column(SupplierNo_TenderSuppliers; "Tender Suppliers"."Supplier No.")
                {
                }
                column(ChoseFrom_TenderSuppliers; "Tender Suppliers"."Chose From")
                {
                }
                column(FinancialScore_TenderSuppliers; "Tender Suppliers"."Financial Score")
                {
                }
                column(TotalScore_TenderSuppliers; "Tender Suppliers"."Total Score")
                {
                }
                column(VendorNo_TenderSuppliers; "Tender Suppliers"."Vendor No.")
                {
                }
                column(SupplierApplication_TenderSuppliers; "Tender Suppliers"."Supplier Application")
                {
                }
                column(BidBondAmount_TenderSuppliers; "Tender Suppliers"."Bid Bond Amount")
                {
                }
                column(BidBondStartDate_TenderSuppliers; "Tender Suppliers"."Bid Bond Start Date")
                {
                }
                column(BidBondEndDate_TenderSuppliers; "Tender Suppliers"."Bid Bond End Date")
                {
                }
                column(BondStatus_TenderSuppliers; "Tender Suppliers"."Bond Status")
                {
                }
                column(ResponseDate_TenderSuppliers; "Tender Suppliers"."Response Date")
                {
                }
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

report 52203573 "Quotation Status Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Quotation Status Report.rdlc';

    dataset
    {
        dataitem("Procurement Request"; "Procurement Request")
        {
            DataItemTableView = WHERE("Procurement Method"=CONST(RFQ));
            RequestFilterFields = "No.", Status, "Vendor No";

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
            column(VendorNo_ProcurementRequest; "Procurement Request"."Vendor No")
            {
            }
            column(Vendor_Name; VendorName)
            {
            }
            column(Vendor_No; Vendor)
            {
            }
            trigger OnAfterGetRecord()
            begin
                PurchaseHeader.Reset;
                PurchaseHeader.SetCurrentKey("Document Type", "No.");
                PurchaseHeader.SetRange("No.", "Procurement Request"."Generated Order No");
                if PurchaseHeader.Find('-')then begin
                    Vendor:=PurchaseHeader."Buy-from Vendor No.";
                    VendorName:=PurchaseHeader."Buy-from Vendor Name";
                end;
                PurchInvHeader.Reset;
                PurchInvHeader.SetRange("Pre-Assigned No.", "Procurement Request"."Generated Order No");
                if PurchInvHeader.Find('-')then begin
                    Vendor:=PurchInvHeader."Buy-from Vendor No.";
                    VendorName:=PurchInvHeader."Buy-from Vendor Name";
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
    Vendor: Code[10];
    VendorName: Text[50];
    PurchaseHeader: Record "Purchase Header";
    PurchInvHeader: Record "Purch. Inv. Header";
}

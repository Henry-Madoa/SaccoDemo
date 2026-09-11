report 52203576 "Tender Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Tender Report.rdlc';

    dataset
    {
        dataitem("Procurement Request"; "Procurement Request")
        {
            DataItemTableView = WHERE("Procurement Method"=Filter('Open Tendering'|'Restricted Tendering'));

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
            column(SupplierCategory_ProcurementRequest; "Procurement Request"."Supplier Category")
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
            column(TenderSecurityAmount_ProcurementRequest; "Procurement Request"."Tender Security Amount")
            {
            }
            dataitem("Procurement Request Lines"; "Procurement Request Lines")
            {
                DataItemLink = "Procurement No"=FIELD("No.");

                column(No_ProcurementRequestLines; "Procurement Request Lines"."No.")
                {
                }
                column(Name_ProcurementRequestLines; "Procurement Request Lines".Name)
                {
                }
                column(Quantity_ProcurementRequestLines; "Procurement Request Lines".Quantity)
                {
                }
                column(UnitPrice_ProcurementRequestLines; "Procurement Request Lines"."Unit Price")
                {
                }
                column(TotalAmount_ProcurementRequestLines; "Procurement Request Lines"."Total Amount")
                {
                }
                column(Type_ProcurementRequestLines; "Procurement Request Lines".Type)
                {
                }
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

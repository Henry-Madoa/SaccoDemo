report 52203599 "Service Proforma Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Service Proforma Report.rdlc';

    dataset
    {
        dataitem("Service Proforma Header"; "Service Proforma Header")
        {
            column(No_ServiceProformaHeader; "Service Proforma Header"."No.")
            {
            }
            column(VehicleREGNo_ServiceProformaHeader; "Service Proforma Header"."Vehicle REG. No.")
            {
            }
            column(Model_ServiceProformaHeader; "Service Proforma Header".Model)
            {
            }
            column(ChassisNo_ServiceProformaHeader; "Service Proforma Header"."Chassis No.")
            {
            }
            column(EngineNo_ServiceProformaHeader; "Service Proforma Header"."Engine No.")
            {
            }
            column(MileageKms_ServiceProformaHeader; "Service Proforma Header"."Mileage (Kms)")
            {
            }
            column(DealerNo_ServiceProformaHeader; "Service Proforma Header"."Dealer No.")
            {
            }
            column(DealerName_ServiceProformaHeader; "Service Proforma Header"."Dealer Name")
            {
            }
            column(ProformaDate_ServiceProformaHeader; "Service Proforma Header"."Proforma Date")
            {
            }
            column(LastServiceDate_ServiceProformaHeader; "Service Proforma Header"."Last Service Date")
            {
            }
            column(CreatedDate_ServiceProformaHeader; "Service Proforma Header"."Created Date")
            {
            }
            column(CreatedBy_ServiceProformaHeader; "Service Proforma Header"."Created By")
            {
            }
            column(ContactPerson_ServiceProformaHeader; "Service Proforma Header"."Contact Person")
            {
            }
            column(ContactPersonName_ServiceProformaHeader; "Service Proforma Header"."Contact Person Name")
            {
            }
            column(TotalAmountSundries_ServiceProformaHeader; "Service Proforma Header"."Total Amount + Sundries")
            {
            }
            column(TotalAmount_ServiceProformaHeader; "Service Proforma Header"."Total Amount")
            {
            }
            column(TotalSundries_ServiceProformaHeader; "Service Proforma Header"."Total Sundries")
            {
            }
            column(CompanyInformationName; CompanyInformation.Name)
            {
            }
            column(CompanyInformationAddress; CompanyInformation.Address)
            {
            }
            column(CompanyInformationAddress2; CompanyInformation."Address 2")
            {
            }
            column(CompanyInformationCity; CompanyInformation.City)
            {
            }
            column(CompanyInformationPicture; CompanyInformation.Picture)
            {
            }
            column(CompanyInformationCountryRegionCode; CompanyInformation."Country/Region Code")
            {
            }
            column(CompanyInformationPhoneNo; CompanyInformation."Phone No.")
            {
            }
            column(CompanyInformationEMail; CompanyInformation."E-Mail")
            {
            }
            column(CompanyInformationHomePage; CompanyInformation."Home Page")
            {
            }
            dataitem("Service Proforma Line"; "Service Proforma Line")
            {
                DataItemLink = "Document No."=FIELD("No.");

                column(DocumentNo_ServiceProformaLine; "Service Proforma Line"."Document No.")
                {
                }
                column(ItemName_ServiceProformaLine; "Service Proforma Line"."Item Name")
                {
                }
                column(Description_ServiceProformaLine; "Service Proforma Line".Description)
                {
                }
                column(Quantity_ServiceProformaLine; "Service Proforma Line".Quantity)
                {
                }
                column(UnitPrice_ServiceProformaLine; "Service Proforma Line"."Unit Price")
                {
                }
                column(Sundries_ServiceProformaLine; "Service Proforma Line".Sundries)
                {
                }
                column(Discount_ServiceProformaLine; "Service Proforma Line"."Discount %")
                {
                }
                column(VAT_ServiceProformaLine; "Service Proforma Line"."VAT %")
                {
                }
                column(TotalAmount_ServiceProformaLine; "Service Proforma Line"."Total Amount")
                {
                }
                column(LineNo_ServiceProformaLine; "Service Proforma Line"."Line No.")
                {
                }
                column(TotalAmountSundries_ServiceProformaLine; "Service Proforma Line"."Total Amount + Sundries")
                {
                }
                column(ItemNo_ServiceProformaLine; "Service Proforma Line"."Item No")
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
    requestpage
    {
        layout
        {
        }
        actions
        {
        }
    }
    labels
    {
    }
    var CompanyInformation: Record "Company Information";
}

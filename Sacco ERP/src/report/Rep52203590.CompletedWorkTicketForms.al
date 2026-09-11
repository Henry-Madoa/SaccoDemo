report 52203590 "Completed WorkTicket Forms"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Completed WorkTicket Forms.rdlc';

    dataset
    {
        dataitem("WorkTicket Form Request"; "WorkTicket Form Request")
        {
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
            column(No_WorkTicketFormRequest; "WorkTicket Form Request"."No.")
            {
            }
            column(DriverNo_WorkTicketFormRequest; "WorkTicket Form Request"."Driver No.")
            {
            }
            column(DriverName_WorkTicketFormRequest; "WorkTicket Form Request"."Driver Name")
            {
            }
            column(VehicleREGNo_WorkTicketFormRequest; "WorkTicket Form Request"."Vehicle REG. No.")
            {
            }
            column(PreviousWTKTNo_WorkTicketFormRequest; "WorkTicket Form Request"."Previous WTKT No.")
            {
            }
            column(CompanyName_WorkTicketFormRequest; "WorkTicket Form Request"."Company Name")
            {
            }
            column(Station_WorkTicketFormRequest; "WorkTicket Form Request".Station)
            {
            }
            dataitem("WorkTicket Form Request Lines"; "WorkTicket Form Request Lines")
            {
                DataItemLink = "Document No."=FIELD("No.");

                column(DocumentNo_WorkTicketFormRequestLines; "WorkTicket Form Request Lines"."Document No.")
                {
                }
                column(Date_WorkTicketFormRequestLines; "WorkTicket Form Request Lines".Date)
                {
                }
                column(WorkTicketNo_WorkTicketFormRequestLines; "WorkTicket Form Request Lines"."Work Ticket No.")
                {
                }
                column(DriverNo_WorkTicketFormRequestLines; "WorkTicket Form Request Lines"."Driver No.")
                {
                }
                column(DriverName_WorkTicketFormRequestLines; "WorkTicket Form Request Lines"."Driver Name")
                {
                }
                column(PlaceOfDeparture_WorkTicketFormRequestLines; "WorkTicket Form Request Lines"."Place Of Departure")
                {
                }
                column(Destination_WorkTicketFormRequestLines; "WorkTicket Form Request Lines".Destination)
                {
                }
                column(ReasonForTravel_WorkTicketFormRequestLines; "WorkTicket Form Request Lines"."Reason For Travel")
                {
                }
                column(AuthorizingOfficer_WorkTicketFormRequestLines; "WorkTicket Form Request Lines"."Authorizing Officer")
                {
                }
                column(FuelLogNo_WorkTicketFormRequestLines; "WorkTicket Form Request Lines"."Fuel Log No.")
                {
                }
                column(OilDrawnlitres_WorkTicketFormRequestLines; "WorkTicket Form Request Lines"."Oil Drawn (litres)")
                {
                }
                column(FuelDrawnlitres_WorkTicketFormRequestLines; "WorkTicket Form Request Lines"."Fuel Drawn (litres)")
                {
                }
                column(TimeOut_WorkTicketFormRequestLines; "WorkTicket Form Request Lines"."Time Out")
                {
                }
                column(TimeIn_WorkTicketFormRequestLines; "WorkTicket Form Request Lines"."Time In")
                {
                }
                column(MileageatStartkms_WorkTicketFormRequestLines; "WorkTicket Form Request Lines"."Mileage at Start (kms)")
                {
                }
                column(MileageatEndkms_WorkTicketFormRequestLines; "WorkTicket Form Request Lines"."Mileage at End (kms)")
                {
                }
                column(DistanceTravelledkms_WorkTicketFormRequestLines; "WorkTicket Form Request Lines"."Distance Travelled (kms)")
                {
                }
                column(LineNo_WorkTicketFormRequestLines; "WorkTicket Form Request Lines"."Line No.")
                {
                }
                column(DateIn_WorkTicketFormRequestLines; "WorkTicket Form Request Lines"."Date In")
                {
                }
                column(AuthorizingOfficerName_WorkTicketFormRequestLines; "WorkTicket Form Request Lines"."Authorizing Officer Name")
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

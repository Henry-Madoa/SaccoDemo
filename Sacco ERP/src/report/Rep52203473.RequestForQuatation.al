report 52203473 "Request For Quatation"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Request For Quatation.rdl';

    dataset
    {
        dataitem(RFQHeader; "RFQ Header")
        {
            column(No; "No.")
            {
            }
            column(CreatedDate; "Created Date")
            {
            }
            column(CreatedBy; "Created By")
            {
            }
            column(CompName; CompInfor.Name)
            {
            }
            column(CompAdd; CompInfor.Address)
            {
            }
            column(CompCity; CompInfor.City)
            {
            }
            column(BuyersDe; BuyersDe)
            {
            }
            column(Authorized; Authorized)
            {
            }
            column(RFQ; RFQ)
            {
            }
            column(ROK; ROK)
            {
            }
            dataitem("RFQ Lines"; "RFQ Lines")
            {
                DataItemLink = "RFQ No"=FIELD("No.");

                column(Item_No; No)
                {
                }
                column(Line_No; "Line No")
                {
                }
                column(Description; Description)
                {
                }
                column(U_O_M; "Unit of Measure")
                {
                }
                column(Quantity; Quantity)
                {
                }
                column(MFR; MFR)
                {
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        CompInfor.get;
        CompInfor.CalcFields(Picture);
    end;
    var CompInfor: Record "Company Information";
    BuyersDe: label 'Buyers Designation and Address:';
    Authorized: label 'Authorized for Issue';
    RFQ: Label 'Request For Quatation';
    ROK: Label 'Republic of Kenya';
}

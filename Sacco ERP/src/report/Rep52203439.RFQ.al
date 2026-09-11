report 52203439 "RFQ"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/RFQ.rdlc';

    dataset
    {
        dataitem("Purchase Header"; "Purchase Header")
        {
            RequestFilterFields = "No.";

            column(Logo; CompInfo.Picture)
            {
            }
            column(Logo2; CompInfo.Picture2)
            {
            }
            column(Watermark; AdvancedFinanceSetup."Watermark Portrait")
            {
            }
            column(CompName; CompInfo.Name)
            {
            }
            column(CompAddress; CompInfo.Address)
            {
            }
            column(CompAddress2; CompInfo."Address 2")
            {
            }
            column(CompCity; CompInfo.City)
            {
            }
            column(CompPhone; CompInfo."Phone No.")
            {
            }
            column(Email; CompInfo."E-Mail")
            {
            }
            column(Website; CompInfo."Home Page")
            {
            }
            column(CompCountry; CompInfo."Country/Region Code")
            {
            }
            column(RFQNo; "Purchase Header"."No.")
            {
            }
            column(VendorName; "Purchase Header"."Buy-from Vendor Name")
            {
            }
            column(VendorAddress; "Purchase Header"."Buy-from Address")
            {
            }
            column(VendorCity; "Purchase Header"."Buy-from City")
            {
            }
            column(RFQDate; "Purchase Header"."Document Date")
            {
            }
            column(RequisitionNo; "Purchase Header"."Requisition No")
            {
            }
            column(Department; "Purchase Header"."Shortcut Dimension 1 Code")
            {
            }
            column(DeliveryAddress; "Purchase Header"."Location Code")
            {
            }
            column(PreparedBy; PreparedBy)
            {
            }
            column(Signature; UserSetup."Signature Card")
            {
            }
            column(Date; Today)
            {
            }
            column(RemarkesText; RemarkesText)
            {
            }
            column(TermAndConditionOne; TermAndCondition[1])
            {
            }
            column(TermAndConditionTwo; TermAndCondition[2])
            {
            }
            column(TermAndConditionThree; TermAndCondition[3])
            {
            }
            column(TermAndConditionFour; TermAndCondition[4])
            {
            }
            column(TermAndConditionFive; TermAndCondition[5])
            {
            }
            dataitem("Purchase Line"; "Purchase Line")
            {
                DataItemLink = "Document No."=FIELD("No.");

                column(SN; SN)
                {
                }
                column(Project; "Purchase Line"."Shortcut Dimension 1 Code")
                {
                }
                column(Description; "Purchase Line".Description)
                {
                }
                column(Cat; "Purchase Line"."Catalog No.")
                {
                }
                column(MFR; "Purchase Line".MFR)
                {
                }
                column(UoM; "Purchase Line"."Unit of Measure")
                {
                }
                column(Quantity; "Purchase Line".Quantity)
                {
                }
                column(UnitCost; "Purchase Line"."Unit Cost")
                {
                }
                column(TotalAmount; "Purchase Line"."Line Amount")
                {
                }
                trigger OnAfterGetRecord()
                begin
                    SN:=SN + 1;
                end;
            }
            trigger OnAfterGetRecord()
            begin
                SN:=0;
                if Users.Get(UserSecurityId)then begin
                    PreparedBy:=Users."Full Name";
                    if UserSetup.Get(UserId)then UserSetup.CalcFields("Signature Card");
                end;
                RFQVendors.Reset;
                RFQVendors.SetRange("Quote No", "Purchase Header"."No.");
                if RFQVendors.FindLast then begin
                    RFQ.Reset;
                    RFQ.SetRange("No.", RFQVendors."RFQ No");
                    if RFQ.FindFirst then RemarkesText:=RFQ.Remarks;
                end;
                i:=0;
                TandC.Reset;
                TandC.SetRange("Document Type", TandC."Document Type"::Quote);
                if TandC.Find('-')then begin
                    repeat i:=i + 1;
                        TermAndCondition[i]:=TandC.Description + TandC."Further Description";
                    until TandC.Next = 0;
                end;
            end;
        }
    }
    trigger OnPreReport()
    begin
        CompInfo.Get;
        CompInfo.CalcFields(Picture);
        CompInfo.CalcFields(Picture2);
        AdvancedFinanceSetup.Get;
    //AdvancedFinanceSetup.CALCFIELDS("Watermark Portrait");
    end;
    var VendorRec: Record Vendor;
    SN: Integer;
    CompInfo: Record "Company Information";
    RecommendationText: Label 'Based on Price, %1 has been Recommended on this Bid Analysis';
    Cat: Text;
    MFR: Text;
    Users: Record User;
    UserSetup: Record "User Setup";
    PreparedBy: Text;
    RFQ: Record "RFQ Header";
    RemarkesText: Text;
    RFQVendors: Record "RFQ Vendors";
    TandC: Record "Procurement Terms & Conditions";
    i: Integer;
    TermAndCondition: array[20]of Text;
    AdvancedFinanceSetup: Record "General Ledger Setup";
}

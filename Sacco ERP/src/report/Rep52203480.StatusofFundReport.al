report 52203480 "Status of Fund Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Status of Fund Report.rdlc';

    dataset
    {
        dataitem("Status of Fund"; "Status of Fund")
        {
            RequestFilterFields = "Date Filter", "Site Filter";

            column(ReportFilters; "Status of Fund".GetFilters)
            {
            }
            column(Fund; "Status of Fund".Fund)
            {
            }
            column(FundName; "Status of Fund"."Fund Name")
            {
            }
            column(Project; "Status of Fund".Project)
            {
            }
            column(ProjectName; "Status of Fund"."Project Name")
            {
            }
            column(Department; "Status of Fund".Department)
            {
            }
            column(FY; "Status of Fund".FY)
            {
            }
            column(TotalAllotment; "Status of Fund"."Total Allotment")
            {
            }
            column(TotalCommitment; "Status of Fund"."Total Commitment")
            {
            }
            column(CommitmentRate; CommitmentRate)
            {
            }
            column(TotalObligation; "Status of Fund"."Total Obligation")
            {
            }
            column(ObligationRate; ObligationRate)
            {
            }
            column(TotalDisbursement; "Status of Fund"."Total Disbursement")
            {
            }
            column(DisbursementRate; DisbursementRate)
            {
            }
            column(TotalOpenCommitment; "Status of Fund"."Total Open Commitment")
            {
            }
            column(TotalULO; "Status of Fund"."Total ULO")
            {
            }
            column(TotalAvailableAllotment; TotalAvailableAllotment)
            {
            }
            column(Logo; CompInfo.Picture)
            {
            }
            column(Logo2; CompInfo.Picture2)
            {
            }
            column(Watermark; AdvancedFinanceSetup."Watermark Portrait")
            {
            }
            column(CompName; CompName)
            {
            }
            column(CompAddress; CompAddress)
            {
            }
            column(CompAddress2; CompAddressTwo)
            {
            }
            column(CompCity; CompCity)
            {
            }
            column(CompPhone; CompPhone)
            {
            }
            column(CompCountry; CompInfo."Country/Region Code")
            {
            }
            trigger OnAfterGetRecord()
            begin
                CommitmentRate:=0;
                ObligationRate:=0;
                DisbursementRate:=0;
                TotalAvailableAllotment:=0;
                "Status of Fund".CalcFields("Total Allotment", "Total Commitment", "Total Obligation", "Total Disbursement");
                if "Status of Fund"."Total Allotment" <> 0 then begin
                    CommitmentRate:=Round("Status of Fund"."Total Commitment" / "Status of Fund"."Total Allotment" * 100, 0.01);
                    ObligationRate:=Round("Status of Fund"."Total Obligation" / "Status of Fund"."Total Allotment" * 100, 0.01);
                    DisbursementRate:=Round("Status of Fund"."Total Disbursement" / "Status of Fund"."Total Allotment" * 100, 0.01);
                end;
                TotalAvailableAllotment:="Status of Fund"."Total Allotment" - "Status of Fund"."Total Commitment";
            end;
        }
    }
    trigger OnPreReport()
    begin
        CompInfo.Get;
        CompInfo.CalcFields(Picture);
        CompInfo.CalcFields(Picture2);
        CompName:=CompInfo.Name;
        CompAddress:=CompInfo.Address;
        CompAddressTwo:=CompInfo."Address 2";
        CompCity:=CompInfo.City;
        CompPhone:=CompInfo."Phone No.";
        AdvancedFinanceSetup.Get;
        AdvancedFinanceSetup.CalcFields("Watermark Portrait");
    end;
    var CommitmentRate: Decimal;
    ObligationRate: Decimal;
    DisbursementRate: Decimal;
    TotalAvailableAllotment: Decimal;
    CompInfo: Record "Company Information";
    CompName: Text;
    CompAddress: Text;
    CompAddressTwo: Text;
    CompCity: Text;
    CompPhone: Text;
    AdvancedFinanceSetup: Record "General Ledger Setup";
}

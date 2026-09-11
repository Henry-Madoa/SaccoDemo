report 52203474 "Imprest Request Summary"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Imprest Request Summary.rdl';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Imprest Header"; "Request Header")
        {
            RequestFilterFields = "No.", "Employee No.", "Global Dimension 1 Code", "Global Dimension 2 Code", Date, Status, "Surrender Date", "Due Date", "Total Days in the Field";

            column(Logo; CompInfo.Picture)
            {
            }
            column(USER; UserId)
            {
            }
            column(DT; CurrentDateTime)
            {
            }
            column(ReportFilters; ReportFilters)
            {
            }
            column(ImprestNo; "Imprest Header"."No.")
            {
            }
            column(EmpNo; "Imprest Header"."Employee No.")
            {
            }
            column(EmpName; "Imprest Header"."Employee Name")
            {
            }
            column(JobTitle; "Imprest Header"."Job Title")
            {
            }
            column(DimOne; Department)
            {
            }
            column(DimTwo; Branch)
            {
            }
            column(Description; "Imprest Header".Description)
            {
            }
            column(CashType; "Imprest Header"."Request Type")
            {
            }
            column(Date; "Imprest Header".Date)
            {
            }
            column(TotalDaysInTheField; "Imprest Header"."Total Days in the Field")
            {
            }
            column(TotalRequestAmount; "Imprest Header"."Request Amount")
            {
            }
            column(Status; "Imprest Header".Status)
            {
            }
            column(SurrenderDate; "Imprest Header"."Surrender Date")
            {
            }
            column(DueDate; "Imprest Header"."Due Date")
            {
            }
            column(TotalSurrenderAmount; "Imprest Header"."Total Surrender Amount")
            {
            }
            column(TotalClaim; "Imprest Header"."Total Claim")
            {
            }
            column(TotalRefund; "Imprest Header"."Total Refund")
            {
            }
            column(NetRefundClaim; "Imprest Header"."Net Refund (Net Claim)")
            {
            }
            trigger OnAfterGetRecord()
            begin
                if DimensionValue.Get('DEPARTMENT', "Global Dimension 1 Code")then begin
                    Department:=DimensionValue.Name;
                end;
                if DimensionValue.Get('BRANCH', "Global Dimension 2 Code")then begin
                    Branch:=DimensionValue.Name;
                end;
            end;
        }
    }
    trigger OnPreReport()
    begin
        CompInfo.Get;
        CompInfo.CalcFields(Picture);
        ReportFilters:="Imprest Header".GetFilters;
    end;
    var CompInfo: Record "Company Information";
    ReportFilters: Text;
    Department: Text;
    Branch: Text;
    DimensionValue: Record "Dimension Value";
}

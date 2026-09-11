report 52203478 "Petty Cash Summary"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Petty Cash Summary.rdl';

    dataset
    {
        dataitem("Expense Claim Header"; "Petty Cash Header")
        {
            RequestFilterFields = "No.", "Employee No.", "Global Dimension 1 Code", "Global Dimension 2 Code", Date, Status, Paid, "Paid By", "Total Amount";

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
            column(ImprestNo; "Expense Claim Header"."No.")
            {
            }
            column(EmpNo; "Expense Claim Header"."Employee No.")
            {
            }
            column(EmpName; "Expense Claim Header"."Payment To")
            {
            }
            column(Global_Dimension_1_Code; Department)
            {
            }
            column(Global_Dimension_2_Code; Branch)
            {
            }
            column(Global_Dimension_3_Code; "Expense Claim Header"."Global Dimension 3 Code")
            {
            }
            column(Date; "Expense Claim Header".Date)
            {
            }
            column(Payment_To; "Expense Claim Header"."Payment To")
            {
            }
            column(Posted_By; "Expense Claim Header"."Posted By")
            {
            }
            column(On_Behalf_of; "Expense Claim Header"."On Behalf of")
            {
            }
            column(Payment_Narration; "Expense Claim Header"."Payment Narration")
            {
            }
            column(RequestStatus; "Expense Claim Header".Status)
            {
            }
            column(TotalRequestAmount; "Expense Claim Header"."Total Amount")
            {
            }
            column(Paid; "Expense Claim Header".Paid)
            {
            }
            column(Paid_By; "Expense Claim Header"."Paid By")
            {
            }
            column(Paid_Date; "Expense Claim Header"."Paid Date")
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
        ReportFilters:="Expense Claim Header".GetFilters;
    end;
    var CompInfo: Record "Company Information";
    ReportFilters: Text;
    Department: Text;
    Branch: Text;
    DimensionValue: Record "Dimension Value";
}

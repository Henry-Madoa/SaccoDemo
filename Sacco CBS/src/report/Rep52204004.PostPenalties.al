report 52204004 "Post Penalties"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Loans; Loans)
        {
            DataItemTableView = where("Mobile Loan" = const(true), Posted = const(true), "Freeze Penalty" = const(False), Closed = const(false), "Loan Balance" = filter(> 0), "Loan Account" = filter(<> ''));

            trigger OnAfterGetRecord()
            begin
                if PenaltyDate = 0D then
                    PenaltyDate := WorkDate;

                VendorLedger.Reset();
                VendorLedger.SetRange("Document No.", Format(PenaltyDate));
                VendorLedger.SetRange("Loan No.", Loans."No.");
                VendorLedger.SetRange(Reversed, false);
                if VendorLedger.FindFirst() then
                    CurrReport.Skip();

                Loans.CalcFields("Loan Balance", "Total Penalty Due", "Last Penalty Date");

                if "Total Penalty Due" = 0 then begin
                    if CalcDate('10D', Loans."Repayment End Date") > PenaltyDate then
                        CurrReport.Skip();
                end else begin
                    if CalcDate('1M', Loans."Last Penalty Date") > PenaltyDate then
                        CurrReport.Skip();
                end;

                LoansManagement.PostLoanPenalty(Loans."No.", PenaltyDate);
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    field("Penalty Posting Date"; PenaltyDate)
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        UserSetup.Get(UserId);
        if not UserSetup."Can Run Penalty" then
            Error('You are not permitted to perform this action, Kindly contact Admin.');
    end;

    var
        VendorLedger: Record "Vendor Ledger Entry";
        PenaltyDate: Date;
        LoansManagement: Codeunit "Loans Management";
        UserSetup: Record "User Setup";
}

report 52204083 "Update Vendor Ledger Entries"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Update Loans';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Detailed Vendor Ledg. Entry"; "Detailed Vendor Ledg. Entry")
        {
            RequestFilterFields = "Loan No.", "Member No.", "Loan Product Code";

            trigger OnAfterGetRecord()
            var
                ObjVendLedgerEntry: Record "Vendor Ledger Entry";
                ObjProductFactory: Record "Sacco Products";
                ObjLoanApp: Record Loans;
                ObjMember: Record Members;
                ObjCheckoffH: Record "Checkoff Advice";
                ObjG_Lentry: Record "G/L Entry";
            begin
                ObjLoanApp.reset;
                ObjLoanApp.SetRange("No.", "Detailed Vendor Ledg. Entry"."Loan No.");
                if ObjLoanApp.FindSet() then
                    repeat
                        if ObjLoanApp."Loan Account" = '' then ObjLoanApp."Loan Account" := ObjLoanApp."Product Code" + ObjLoanApp."Member No.";
                        ObjLoanApp.Disbursed := true;
                        ObjLoanApp.Status := ObjLoanApp.Status::Approved;
                        ObjLoanApp.Posted := true;
                        ObjLoanApp."Posted On" := CreateDateTime(ObjLoanApp."Posting Date", time);
                        ObjLoanApp."Portal Status" := ObjLoanApp."Portal Status"::Processing;
                        ObjLoanApp.Modify(true);
                    until ObjLoanApp.next = 0;
                Message('Tesa mehn');
            end;
        }
    }
    var
        ObjVend: Record Vendor;
}

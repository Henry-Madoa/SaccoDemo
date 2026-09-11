report 52204021 "Run Standing Orders"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    ProcessingOnly = true;
    UseRequestPage = true;

    dataset
    {
        dataitem("Standing Order"; "Standing Order")
        {
            RequestFilterFields = "Member No";
            DataItemTableView = where(Running = const(true), Terminated = const(false));

            trigger OnPreDataItem()
            var
                GLEntry: Record "G/L Entry";
                VendorLedger: Record "Vendor Ledger Entry";
                DetailedLedger: Record "Detailed Vendor Ledg. Entry";
            begin
            end;

            trigger OnAfterGetRecord()
            begin
                FosaMgt.UpdateSTO("No.", WorkDate);
                CalcFields("Last Run Date");

                if RunDate = 0D then
                    RunDate := CalcDate('-1D', WorkDate);

                if "Standing Order"."Salary Based" then
                    CurrReport.Skip();

                if "Last Run Date" = WorkDate then
                    CurrReport.Skip();


                if "Standing Order".Freezed then
                    CurrReport.Skip();

                if Vendor.Get("Account No") then begin
                    if Vendor.Blocked <> Vendor.Blocked::" " then
                        CurrReport.Skip();

                    Vendor.CalcFields(Balance);

                    if (("Standing Order"."Amount Type" = "Standing Order"."Amount Type"::Sweep) and (Vendor.Balance <= 0)) then
                        CurrReport.Skip();

                    if "Standing Order"."Amount Type" = "Standing Order"."Amount Type"::"Amount Based" then begin
                        If "Standing Order"."Amount Limit" < Vendor.Balance then
                            CurrReport.Skip();
                    end;
                end;

                if "Standing Order"."Amount Type" = "Standing Order"."Amount Type"::Fixed then begin
                    if "Run Type" = "Run Type"::"Specific Day" then begin
                        if "Standing Order"."Run From Day" = 0 then
                            CurrReport.Skip();

                        if (("Standing Order"."Run From Day" <> Date2DMY(RunDate, 1)) and ("Next Run Date" <> RunDate))
                         then
                            CurrReport.Skip();
                    end
                    else if "Run Type" = "Run Type"::"End Month" then begin
                        if ((Date2DMY(RunDate, 1) <> Date2DMY(CalcDate('CM', RunDate), 1)) and ("Next Run Date" <> RunDate)) then
                            CurrReport.Skip();
                    end;
                end;
                FosaMgt.RunStandingOrder("Standing Order"."No.", RunDate);
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Parameters)
                {
                    field(Name; RunDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Execution Date';
                    }
                }
            }
        }
    }
    var
        RunDate: Date;
        NextExpectedRunDate: Date;
        FosaMgt: Codeunit "FOSA Management";
        Loans: Record Loans;
        Vendor: Record Vendor;

    procedure GetRunDate(ParsedDate: Date) RDate: Integer
    begin
        if ParsedDate = 0D then
            ParsedDate := Today;
        exit(Date2DMY(ParsedDate, 1));
    end;
}

report 52204007 "Generate Loan Ageing"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Loan Application"; Loans)
        {
            DataItemTableView = where(Category = filter(<> HR & <> DEBT), "Skip Aging" = const(false));
            trigger OnAfterGetRecord()
            begin
                Window.Update(1, "Loan Application"."Member Name");
                LoansManagement.ClassifyLoan("No.", AsAtDate);
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group("Report Parameters")
                {
                    field("As At Date"; AsAtDate)
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
            }
        }
    }
    trigger OnInitReport()
    begin
        Window.Open('Calculating Arrears \#1###');
    end;

    trigger OnPostReport()
    begin
        Window.Close;
    end;

    var
        LoansManagement: Codeunit "Loans Management";
        AsAtDate: date;
        Window: Dialog;
}

report 52203479 "Fund Position Per Project"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Fund Position Per Project.rdlc';

    dataset
    {
        dataitem("Dimension Value"; "Dimension Value")
        {
            DataItemTableView = WHERE("Global Dimension No."=CONST(1));
            RequestFilterFields = "Code";

            column("Code"; "Dimension Value".Code)
            {
            }
            column(Name; "Dimension Value".Name)
            {
            }
            column(Received; OpeningBalance)
            {
            }
            column(Committed; Committed)
            {
            }
            column(Obligations; Obligations)
            {
            }
            column(Disbursements; Disbursements)
            {
            }
            column(FundsAvailable; ClosingBalance)
            {
            }
            trigger OnAfterGetRecord()
            begin
            /*OpeningBalance := 0;
                    Committed := 0;
                    Obligations := 0;
                    Disbursements := 0;
                    ClosingBalance := 0;
                    IF DimValue.GET("Dimension Value"."Dimension Code","Dimension Value".Code) THEN BEGIN
                      //DimValue.SETRANGE("Date Filter",0D,StartDate-1);
                      DimValue.CALCFIELDS("Project Funds Balance");
                      OpeningBalance := DimValue."Project Funds Balance";
                    end;
                    "Dimension Value".CALCFIELDS("Project Funds Committed","Project Funds Disbursements","Project Funds Obligations");

                    Committed := "Dimension Value"."Project Funds Committed";
                    Obligations := "Dimension Value"."Project Funds Obligations";
                    Disbursements := "Dimension Value"."Project Funds Disbursements";

                    ClosingBalance := OpeningBalance-Committed-Obligations-Disbursements;*/
            end;
        }
    }
    trigger OnPreReport()
    begin
    /*IF "Dimension Value".GETFILTER("Date Filter") = '' THEN
              ERROR('You must enter a date filter in the format of Start Date..End Date.');

            StartDate := "Dimension Value".GETRANGEMIN("Date Filter");
            EndDate := "Dimension Value".GETRANGEMAX("Date Filter");*/
    end;
    var StartDate: Date;
    EndDate: Date;
    DimValue: Record "Dimension Value";
    OpeningBalance: Decimal;
    ClosingBalance: Decimal;
    Committed: Decimal;
    Obligations: Decimal;
    Disbursements: Decimal;
}

report 52204025 "Risk Classification"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    RDLCLayout = './ssrs/RiskClassification.rdl';

    dataset
    {
        dataitem(Loans; Loans)
        {
            RequestFilterFields = "Date Filter";
            DataItemTableView = where(Posted = const(true), "Principal Balance" = filter(<> 0), "Product Code" = filter(<> 'L32' & <> 'L33' & <> 'L34' & <> 'L35' & <> 'L36' & <> 'L39'));
            column(Loan_Classification; "Loan Classification")
            {
            }
            column(Loan_Balance; "Principal Balance")
            {
            }
            column(Provision; Provision)
            {
            }
            column(ProvisionAmount; ProvisionAmount)
            {
            }
            column(Net_Change_Principal; "Principal Balance")
            {
            }
            column(Application_No; "No.")
            {
            }
            column(GroupOrder2; GroupOrder2)
            {
            }
            column(GroupText; GroupText)
            {
            }
            trigger OnAfterGetRecord()
            begin
                GroupText := '';
                if Loans."Product Code" = '1212' then
                    GroupText := 'Reschedule/Renegotiated Loans'
                else
                    GroupText := 'Classification';

                Provision := 0;
                ProvisionAmount := 0;
                case Loans."Loan Classification" of
                    Loans."Loan Classification"::Performing:
                        Provision := 0.01;
                    Loans."Loan Classification"::Watch:
                        Provision := 0.05;
                    Loans."Loan Classification"::Substandard:
                        Provision := 0.25;
                    Loans."Loan Classification"::Doubtfull:
                        Provision := 0.50;
                    Loans."Loan Classification"::Loss:
                        Provision := 1;
                end;
                //ProvisionAmount := Loans."Net Change-Principal" * Provision;
                ProvisionAmount := Loans."Principal Balance" * Provision;
                case Loans."Loan Classification" of
                    Loans."Loan Classification"::Performing:
                        GroupOrder2 := 1;
                    Loans."Loan Classification"::Watch:
                        GroupOrder2 := 2;
                    Loans."Loan Classification"::Substandard:
                        GroupOrder2 := 3;
                    Loans."Loan Classification"::Doubtfull:
                        GroupOrder2 := 4;
                    Loans."Loan Classification"::Loss:
                        GroupOrder2 := 5;
                end;
            end;
        }
    }

    var
        GroupText: Text;
        Provision, ProvisionAmount : decimal;
        GroupOrder2: Integer;
}

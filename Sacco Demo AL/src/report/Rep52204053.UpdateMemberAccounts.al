report 52204053 "Update Member Accounts"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Update Member Accounts';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Loan Application"; Loans)
        {
            DataItemTableView = where("No." = filter('N22LN00785|N22lN00897|N22LN01330'), Posted = filter(true));

            trigger OnAfterGetRecord()
            var
                ObjVend: Record Vendor;
                ObjMember: Record members;
            begin
                if "Loan Application"."No." = 'N22LN00785' then begin
                    "Loan Application"."Member No." := '13835';
                    "Loan Application".Validate("Member No.");
                    "Loan Application"."Loan Account" := 'L1113835';
                    "Loan Application".Modify(true);
                end
                else if "Loan Application"."No." = 'N22lN00897' then begin
                    "Loan Application"."Member No." := '12836';
                    "Loan Application".Validate("Member No.");
                    "Loan Application"."Loan Account" := 'L1912836';
                    "Loan Application".Modify(true);
                end
                else if "Loan Application"."No." = 'N22LN01330' then begin
                    "Loan Application"."Member No." := '11939';
                    "Loan Application"."Loan Account" := 'L1111939';
                    "Loan Application".Validate("Member No.");
                    "Loan Application".Modify(true);
                end;
            end;
        }
    }
    trigger OnPostReport()
    begin
        Message('We are done fantalizing them');
    end;
}

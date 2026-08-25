tableextension 52204020 "Vendor Posting Group" extends "Vendor Posting Group"
{
    fields
    {
        field(52204002; "Interest Accrual Account"; Code[20])
        {
            TableRelation = "G/L Account" where("Direct Posting"=const(true), Blocked=const(false));
        }
    }
}

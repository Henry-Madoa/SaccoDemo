query 52204003 "Savings Ledger Entry"
{
    QueryType = API;
    APIPublisher = 'PublisherName';
    APIGroup = 'GroupName';
    APIVersion = 'v1.0';
    EntityName = 'SavingsLedgerEntry';
    EntitySetName = 'SavingsLedgerEntry';

    elements
    {
        dataitem(Vendor_Ledger_Entry;
        "Vendor Ledger Entry")
        {
            DataItemTableFilter = "Product Posting Type" = filter(<> "Loan Account");

            column(Posting_Date;
            "Posting Date")
            {
            }
            column(Transaction_Type;
            "Sacco Transaction Type")
            {
            }
            column(Amount;
            Amount)
            {
            }
            column(Reason_Code;
            "Reason Code")
            {
            }
            column(Vendor_Posting_Group;
            "Vendor Posting Group")
            {
            }
            column(Member_No_;
            "Member No.")
            {
            }
            column(Member_Posting_Type;
            "Product Posting Type")
            {
            }
        }
    }
}

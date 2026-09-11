query 52204002 "Credit Ledger Entry"
{
    QueryType = API;
    APIPublisher = 'PublisherName';
    APIGroup = 'GroupName';
    APIVersion = 'v1.0';
    EntityName = 'CreditLedgerEntry';
    EntitySetName = 'CreditLedgerEntry';

    elements
    {
        dataitem(Vendor_Ledger_Entry;
        "Vendor Ledger Entry")
        {
            DataItemTableFilter = "Sacco Transaction Type" = filter("Loan Disbursal" | "Interest Due" | "Interest Paid" | "Principal Paid" | "Interest Paid"), "Product Posting Type" = const("Loan Account");

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
        }
    }
}

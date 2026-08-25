report 52204087 "Custodial Holding"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/CustodialHolding.rdl';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Custodial Header"; "Custodial Header")
        {
            RequestFilterFields = "Document Status";

            column(Logo; CompanyInformation.Picture)
            {
            }
            column(City; CompanyInformation.City)
            {
            }
            column(Address2; CompanyInformation."Address 2")
            {
            }
            column(Address; CompanyInformation.Address)
            {
            }
            column(Name; CompanyInformation.Name)
            {
            }
            column(TransactionNo_CustodialHeader; "Custodial Header"."No.")
            {
            }
            column(ServiceType_CustodialHeader; "Custodial Header"."Service Type")
            {
            }
            column(RefrenceNo_CustodialHeader; "Custodial Header"."Refrence No.")
            {
            }
            column(OwnerType_CustodialHeader; "Custodial Header"."Owner Type")
            {
            }
            column(OwnerNo_CustodialHeader; "Custodial Header"."Owner No")
            {
            }
            column(OwnerName_CustodialHeader; "Custodial Header"."Owner Name")
            {
            }
            column(Remarks_CustodialHeader; "Custodial Header".Remarks)
            {
            }
            column(PostingDate_CustodialHeader; "Custodial Header"."Posting Date")
            {
            }
            column(CreatedBy_CustodialHeader; "Custodial Header"."Created By")
            {
            }
            column(CreatedOn_CustodialHeader; "Custodial Header"."Created On")
            {
            }
            column(ApprovalStatus_CustodialHeader; "Custodial Header".Status)
            {
            }
            column(DocumentStatus_CustodialHeader; "Custodial Header"."Document Status")
            {
            }
            column(ServiceDescription_CustodialHeader; "Custodial Header"."Service Description")
            {
            }
            column(AccountNo_CustodialHeader; "Custodial Header"."Account No.")
            {
            }
            column(StoragePeriod_CustodialHeader; "Custodial Header"."Storage Period")
            {
            }
            column(ExpectedCollectionDate_CustodialHeader; "Custodial Header"."Expected Collection Date")
            {
            }
            column(ReceivingCashbook_CustodialHeader; "Custodial Header"."Source Account No")
            {
            }
            column(AmountExpected_CustodialHeader; "Custodial Header"."Amount Expected")
            {
            }
            column(AmountPaid_CustodialHeader; "Custodial Header"."Amount Paid")
            {
            }
            column(PaymentMethod_CustodialHeader; "Custodial Header"."Payment Method")
            {
            }
            column(PaymentRefrence_CustodialHeader; "Custodial Header"."Payment Refrence")
            {
            }
            column(PaymentDate_CustodialHeader; "Custodial Header"."Payment Date")
            {
            }
            column(PaymentPosted_CustodialHeader; "Custodial Header"."Payment Posted")
            {
            }
            column(GlobalDimension1Code_CustodialHeader; "Custodial Header"."Global Dimension 1 Code")
            {
            }
            column(GlobalDimension2Code_CustodialHeader; "Custodial Header"."Global Dimension 2 Code")
            {
            }
            column(ApprovalEntries_CustodialHeader; "Custodial Header"."Approval Entries")
            {
            }
            column(StorageType_CustodialHeader; "Custodial Header"."Storage Type")
            {
            }
            column(StorageSerialNo_CustodialHeader; "Custodial Header"."Storage Serial No.")
            {
            }
            column(CollectedBy_CustodialHeader; "Custodial Header"."Collected By")
            {
            }
            column(ExpectedReturnDate_CustodialHeader; "Custodial Header"."Expected Return Date")
            {
            }
            column(CollectedByPhoneNo_CustodialHeader; "Custodial Header"."Collected By Phone No")
            {
            }
            column(CollectedByIDNo_CustodialHeader; "Custodial Header"."Collected By ID  No")
            {
            }
            column(EntryType_CustodialHeader; "Custodial Header"."Entry Type")
            {
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.GET;
                CompanyInformation.CALCFIELDS(Picture);
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
}

report 52204088 "Custodial Application Receipt"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/CustodialApplicationReceipt.rdl';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Custodial Header"; "Custodial Header")
        {
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
            column(RCreatedBy_CustodialHeader; "Custodial Header"."Created By")
            {
            }
            column(RApprovalStatus_CustodialHeader; "Custodial Header".Status)
            {
            }
            column(RCollectedBy_CustodialHeader; "Custodial Header"."Collected By")
            {
            }
            dataitem("Custodial Services Entries"; "Custodial Services Entries")
            {
                DataItemLink = "Custodial No." = FIELD("No.");
                DataItemTableView = SORTING("Custodial No.", "Document No.") ORDER(Ascending);

                column(CustodialNo_CustodialServicesEntries; "Custodial Services Entries"."Custodial No.")
                {
                }
                column(DocumentNo_CustodialServicesEntries; "Custodial Services Entries"."Document No.")
                {
                }
                column(PostingDate_CustodialServicesEntries; "Custodial Services Entries"."Posting Date")
                {
                }
                column(Description_CustodialServicesEntries; "Custodial Services Entries".Description)
                {
                }
                column(Amount_CustodialServicesEntries; "Custodial Services Entries".Amount)
                {
                }
                column(Posted_CustodialServicesEntries; "Custodial Services Entries".Posted)
                {
                }
                column(EntryType_CustodialServicesEntries; "Custodial Services Entries"."Entry Type")
                {
                }
            }
            dataitem("Custodial Movement"; "Custodial Movement")
            {
                DataItemLink = "Transaction No" = FIELD("No.");

                column(EntryNo_CustodialMovement; "Custodial Movement"."Entry No")
                {
                }
                column(TransactionNo_CustodialMovement; "Custodial Movement"."Transaction No")
                {
                }
                column(PostingDate_CustodialMovement; "Custodial Movement"."Posting Date")
                {
                }
                column(EntryType_CustodialMovement; "Custodial Movement"."Entry Type")
                {
                }
                column(Description_CustodialMovement; "Custodial Movement".Description)
                {
                }
                column(CreatedBy_CustodialMovement; "Custodial Movement"."Created By")
                {
                }
                column(CreatedOn_CustodialMovement; "Custodial Movement"."Created On")
                {
                }
                column(CollectedBy_CustodialMovement; "Custodial Movement"."Collected By")
                {
                }
                column(ExpectedReturnDate_CustodialMovement; "Custodial Movement"."Expected Return Date")
                {
                }
                column(CollectedByPhoneNo_CustodialMovement; "Custodial Movement"."Collected By Phone No")
                {
                }
                column(CollectedByIDNo_CustodialMovement; "Custodial Movement"."Collected By ID  No")
                {
                }
            }
            column(DocumentType_DocumentApprovalEntries; '')
            {
            }
            column(DocumentNo_DocumentApprovalEntries; "Custodial Header"."No.")
            {
            }
            column(Amount_DocumentApprovalEntries; 0)
            {
            }
            column(SubmittedOn_DocumentApprovalEntries; "Custodial Movement"."Posting Date")
            {
            }
            column(ActionID_DocumentApprovalEntries; '')
            {
            }
            column(ActionDate_DocumentApprovalEntries; Today)
            {
            }
            column(ApprovalLevel_DocumentApprovalEntries; '')
            {
            }
            column(Status_DocumentApprovalEntries; '')
            {
            }
            column(DueDate_DocumentApprovalEntries; Today)
            {
            }
            column(Archived_DocumentApprovalEntries; false)
            {
            }
            column(Select_DocumentApprovalEntries; true)
            {
            }
            column(Action_DocumentApprovalEntries; '')
            {
            }
            column(ReasonforRejecting_DocumentApprovalEntries; '')
            {
            }
            column(ActionTime_DocumentApprovalEntries; Today)
            {
            }
            column(SubmittedAt_DocumentApprovalEntries; Today)
            {
            }
            column(ActionBy_DocumentApprovalEntries; Userid)
            {
            }
            column(Comment_DocumentApprovalEntries; '')
            {
            }
            column(Loop_DocumentApprovalEntries; '')
            {
            }
            column(SubmittedBy_DocumentApprovalEntries; Userid)
            {
            }
            column(CommentExist_DocumentApprovalEntries; false)
            {
            }
            trigger OnAfterGetRecord()
            var
                myInt: Integer;
            begin
                //Approvers
                ApprovalEntries.RESET;
                ApprovalEntries.SETRANGE(ApprovalEntries."Table ID", Database::"Custodial Header");
                ApprovalEntries.SETRANGE(ApprovalEntries."Document No.", "Custodial Header"."No.");
                ApprovalEntries.SETRANGE(ApprovalEntries.Status, ApprovalEntries.Status::Approved);
                IF ApprovalEntries.FIND('-') THEN BEGIN
                    i := 0;
                    REPEAT
                        i := i + 1;
                        IF i = 1 THEN BEGIN
                            Users.RESET;
                            Users.SETRANGE("User Name", ApprovalEntries."Sender ID");
                            IF Users.FINDFIRST THEN BEGIN
                                "1stapprover" := Users."Full Name";
                            end;
                            Users.RESET;
                            Users.SETRANGE("User Name", ApprovalEntries."Approver ID");
                            IF Users.FINDFIRST THEN BEGIN
                                "2ndapprover" := Users."Full Name";
                                "3rdapprover" := Users."Full Name";
                                "4thapprover" := Users."Full Name";
                            end;
                            "1stapproverdate" := ApprovalEntries."Date-Time Sent for Approval";
                            "2ndapproverdate" := ApprovalEntries."Last Date-Time Modified";
                            "3rdapproverdate" := ApprovalEntries."Last Date-Time Modified";
                            "4thapproverdate" := ApprovalEntries."Last Date-Time Modified";
                            IF UserRecApp1.GET(ApprovalEntries."Sender ID") THEN UserRecApp1.CALCFIELDS(UserRecApp1.Signature);
                            IF UserRecApp2.GET(ApprovalEntries."Approver ID") THEN UserRecApp2.CALCFIELDS(UserRecApp2.Signature);
                            IF UserRecApp3.GET(ApprovalEntries."Approver ID") THEN UserRecApp3.CALCFIELDS(UserRecApp3.Signature);
                            IF UserRecApp4.GET(ApprovalEntries."Approver ID") THEN UserRecApp4.CALCFIELDS(UserRecApp4.Signature);
                        end;
                        IF i = 2 THEN BEGIN
                            Users.RESET;
                            Users.SETRANGE("User Name", ApprovalEntries."Approver ID");
                            IF Users.FINDFIRST THEN BEGIN
                                "3rdapprover" := Users."Full Name";
                                "4thapprover" := Users."Full Name";
                            end;
                            "3rdapproverdate" := ApprovalEntries."Last Date-Time Modified";
                            "4thapproverdate" := ApprovalEntries."Last Date-Time Modified";
                            IF UserRecApp3.GET(ApprovalEntries."Approver ID") THEN UserRecApp3.CALCFIELDS(UserRecApp3.Signature);
                            IF UserRecApp4.GET(ApprovalEntries."Approver ID") THEN UserRecApp4.CALCFIELDS(UserRecApp4.Signature);
                        end;
                        IF i = 3 THEN BEGIN
                            Users.RESET;
                            Users.SETRANGE("User Name", ApprovalEntries."Approver ID");
                            IF Users.FINDFIRST THEN BEGIN
                                "4thapprover" := Users."Full Name";
                            end;
                            "4thapproverdate" := ApprovalEntries."Last Date-Time Modified";
                            IF UserRecApp4.GET(ApprovalEntries."Approver ID") THEN UserRecApp4.CALCFIELDS(UserRecApp4.Signature);
                        end;
                    UNTIL ApprovalEntries.NEXT = 0;
                end;
            end;

            trigger OnPreDataItem()
            begin
                CompanyInformation.GET;
                CompanyInformation.CALCFIELDS(Picture);
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        ApprovalEntries: Record "Approval Entry";
        "1stapprover": Text[100];
        "2ndapprover": Text[100];
        "3rdapprover": Text[100];
        "4thapprover": Text[100];
        i: Integer;
        "1stapproverdate": DateTime;
        "2ndapproverdate": DateTime;
        "3rdapproverdate": DateTime;
        "4thapproverdate": DateTime;
        UserRecApp1: Record "User Setup";
        UserRecApp2: Record "User Setup";
        UserRecApp3: Record "User Setup";
        UserRecApp4: Record "User Setup";
        Users: Record User;
}

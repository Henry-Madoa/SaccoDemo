report 52203588 "Allowance Print Out"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Allowance Print Out.rdlc';

    dataset
    {
        dataitem("Request Header"; "Request Header")
        {
            CalcFields = "Total Surrender Amount";
            RequestFilterFields = "No.";

            column(CompanyName; CompanyInformation.Name)
            {
            }
            column(CompanyPicture; CompanyInformation.Picture)
            {
            }
            column(CompanyAddress; CompanyInformation.Address)
            {
            }
            column(CompanyPhone; CompanyInformation."Phone No.")
            {
            }
            column(CompanyLocation; CompanyInformation.Location)
            {
            }
            column(CompanyEmail; CompanyInformation."E-Mail")
            {
            }
            column(CompanyWebsite; CompanyInformation."Home Page")
            {
            }
            column(CompanyPostCode; CompanyInformation."Post Code")
            {
            }
            column(SenderID; SenderID)
            {
            }
            column(DateTimeSend; DateTimeSend)
            {
            }
            column(SenderSignature; UserSetup.Signature)
            {
            }
            column(FirstApproverID; FirstApproverID)
            {
            }
            column(DateTimeFirstApprove; DateTimeFirstApprove)
            {
            }
            column(FirstApproveSignature; UserSetup1.Signature)
            {
            }
            column(SecondApproverID; SecondApproverID)
            {
            }
            column(DateTimeSecondApprove; DateTimeSecondApprove)
            {
            }
            column(SecondApproveSignature; UserSetup2.Signature)
            {
            }
            column(ThirdApproverID; ThirdApproverID)
            {
            }
            column(DateTimeThirdApprove; DateTimeThirdApprove)
            {
            }
            column(ThirdApproveSignature; UserSetup3.Signature)
            {
            }
            column(FourthApproverID; FourthApproverID)
            {
            }
            column(DateTimeFourthApprove; DateTimeFourthApprove)
            {
            }
            column(FourthApproveSignature; UserSetup4.Signature)
            {
            }
            column(FifthApproverID; FifthApproverID)
            {
            }
            column(DateTimeFifthApprove; DateTimeFifthApprove)
            {
            }
            column(FifthApproveSignature; UserSetup5.Signature)
            {
            }
            column(No_RequestHeader; "Request Header"."No.")
            {
            }
            column(EmployeeNo_RequestHeader; "Request Header"."Employee No.")
            {
            }
            column(EmployeeName_RequestHeader; "Request Header"."Employee Name")
            {
            }
            column(RequestFor_RequestHeader; "Request Header"."Request For")
            {
            }
            column(RequestType_RequestHeader; "Request Header"."Request Type")
            {
            }
            column(Purpose_RequestHeader; "Request Header".Purpose)
            {
            }
            column(PayingBank_RequestHeader; "Request Header"."Claim Paying Account")
            {
            }
            column(EmployeeBalance_RequestHeader; "Request Header"."Employee Balance")
            {
            }
            column(ClaimAmount_RequestHeader; "Request Header"."Total Surrender Amount")
            {
            }
            column(Status_RequestHeader; "Request Header".Status)
            {
            }
            column(CreatedOn_RequestHeader; "Request Header"."Created On")
            {
            }
            column(CreatedBy_RequestHeader; "Request Header"."Created By")
            {
            }
            column(PostingDate_RequestHeader; "Request Header"."Surrender Date")
            {
            }
            column(Posted_RequestHeader; "Request Header".Posted)
            {
            }
            column(PostedBy_RequestHeader; "Request Header"."Posted By")
            {
            }
            column(PostedOn_RequestHeader; "Request Header".Surrendered)
            {
            }
            column(GlobalDimension1Code_RequestHeader; "Request Header"."Global Dimension 3 Code")
            {
            }
            column(GlobalDimension2Code_RequestHeader; "Request Header"."Global Dimension 2 Code")
            {
            }
            column(SurrenderAmount_RequestHeader; "Request Header"."Total Surrender Amount")
            {
            }
            column(ImprestNo_RequestHeader; "Request Header"."No.")
            {
            }
            column(Surrendered_RequestHeader; "Request Header".Surrendered)
            {
            }
            column(PayMode_RequestHeader; "Request Header"."Pay Mode")
            {
            }
            column(ChequeNo_RequestHeader; "Request Header"."Payment Tx No.(Cheque No.)")
            {
            }
            column(EFTNo_RequestHeader; "Request Header"."EFT No")
            {
            }
            column(CurrencyCode_RequestHeader; "Request Header"."Currency Code")
            {
            }
            dataitem("Request Lines"; "Request Lines")
            {
                DataItemLink = "No."=FIELD("No.");

                column(AccountNo_RequestLines; "Request Lines"."Account No")
                {
                }
                column(AccountName_RequestLines; "Request Lines"."Account Name")
                {
                }
                column(Description_RequestLines; "Request Lines".Narration)
                {
                }
                column(NetAllowanceAmount_RequestLines; "Request Lines"."Net Allowance Amount")
                {
                }
                column(TaxAmount_RequestLines; "Request Lines"."Tax Amount")
                {
                }
                column(Amount_RequestLines; "Request Lines"."Actual Spent")
                {
                }
                column(EmployeeNo_RequestLines; "Request Lines"."Employee No")
                {
                }
                column(EmployeeName_RequestLines; "Request Lines"."Employee Name")
                {
                }
            }
            trigger OnAfterGetRecord()
            begin
                ApprovalEntry.RESET;
                ApprovalEntry.SETRANGE("Table ID", 64020);
                ApprovalEntry.SETRANGE("Document No.", "Request Header"."No.");
                //ApprovalEntry.SETRANGE(Status,ApprovalEntry.Status::Approved);
                IF ApprovalEntry.FINDFIRST THEN BEGIN
                    SenderID:=ApprovalEntry."Sender ID";
                    DateTimeSend:=FORMAT(ApprovalEntry."Date-Time Sent for Approval");
                    IF UserSetup.GET(SenderID)THEN BEGIN
                        UserSetup.CALCFIELDS(Signature);
                    end;
                end;
                ApprovalEntry.RESET;
                ApprovalEntry.SETRANGE("Table ID", 64020);
                ApprovalEntry.SETRANGE("Document No.", "Request Header"."No.");
                ApprovalEntry.SETRANGE(Status, ApprovalEntry.Status::Approved);
                ApprovalEntry.SETRANGE("Sequence No.", 1);
                IF ApprovalEntry.FINDFIRST THEN BEGIN
                    FirstApproverID:=ApprovalEntry."Approver ID";
                    DateTimeFirstApprove:=FORMAT(ApprovalEntry."Last Date-Time Modified");
                    IF UserSetup1.GET(FirstApproverID)THEN BEGIN
                        UserSetup1.CALCFIELDS(Signature);
                    end;
                    ApprovalEntry.RESET;
                    ApprovalEntry.SETRANGE("Table ID", 64020);
                    ApprovalEntry.SETRANGE("Document No.", "Request Header"."No.");
                    ApprovalEntry.SETRANGE(Status, ApprovalEntry.Status::Approved);
                    ApprovalEntry.SETRANGE("Sequence No.", 2);
                    IF ApprovalEntry.FINDFIRST THEN BEGIN
                        SecondApproverID:=ApprovalEntry."Approver ID";
                        DateTimeSecondApprove:=FORMAT(ApprovalEntry."Last Date-Time Modified");
                        IF UserSetup2.GET(SecondApproverID)THEN BEGIN
                            UserSetup2.CALCFIELDS(Signature);
                        end;
                    end;
                    ApprovalEntry.RESET;
                    ApprovalEntry.SETRANGE("Table ID", 64020);
                    ApprovalEntry.SETRANGE("Document No.", "Request Header"."No.");
                    ApprovalEntry.SETRANGE(Status, ApprovalEntry.Status::Approved);
                    ApprovalEntry.SETRANGE("Sequence No.", 3);
                    IF ApprovalEntry.FINDFIRST THEN BEGIN
                        ThirdApproverID:=ApprovalEntry."Approver ID";
                        DateTimeThirdApprove:=FORMAT(ApprovalEntry."Last Date-Time Modified");
                        IF UserSetup3.GET(ThirdApproverID)THEN BEGIN
                            UserSetup3.CALCFIELDS(Signature);
                        end;
                    end;
                    ApprovalEntry.RESET;
                    ApprovalEntry.SETRANGE("Table ID", 64020);
                    ApprovalEntry.SETRANGE("Document No.", "Request Header"."No.");
                    ApprovalEntry.SETRANGE(Status, ApprovalEntry.Status::Approved);
                    ApprovalEntry.SETRANGE("Sequence No.", 4);
                    IF ApprovalEntry.FINDFIRST THEN BEGIN
                        FourthApproverID:=ApprovalEntry."Approver ID";
                        DateTimeFourthApprove:=FORMAT(ApprovalEntry."Last Date-Time Modified");
                        IF UserSetup4.GET(FourthApproverID)THEN BEGIN
                            UserSetup4.CALCFIELDS(Signature);
                        end;
                    end;
                    ApprovalEntry.RESET;
                    ApprovalEntry.SETRANGE("Table ID", 64020);
                    ApprovalEntry.SETRANGE("Document No.", "Request Header"."No.");
                    ApprovalEntry.SETRANGE(Status, ApprovalEntry.Status::Approved);
                    ApprovalEntry.SETRANGE("Sequence No.", 5);
                    IF ApprovalEntry.FINDFIRST THEN BEGIN
                        FifthApproverID:=ApprovalEntry."Approver ID";
                        DateTimeFifthApprove:=FORMAT(ApprovalEntry."Last Date-Time Modified");
                        IF UserSetup5.GET(FifthApproverID)THEN BEGIN
                            UserSetup5.CALCFIELDS(Signature);
                        end;
                    end;
                end;
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.GET;
                CompanyInformation.CALCFIELDS(Picture);
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    UserSetup: Record "User Setup";
    ApprovalEntry: Record "Approval Entry";
    SenderID: Code[80];
    DateTimeSend: Text;
    SenderSignature: Variant;
    FirstApproverID: Code[80];
    DateTimeFirstApprove: Text;
    FirstApproveSignature: Variant;
    SecondApproverID: Code[80];
    DateTimeSecondApprove: Text;
    SecondApproveSignature: Variant;
    ThirdApproverID: Code[80];
    DateTimeThirdApprove: Text;
    ThirdApproveSignature: Variant;
    FourthApproverID: Code[80];
    DateTimeFourthApprove: Text;
    FourthApproveSignature: Variant;
    FifthApproverID: Code[80];
    DateTimeFifthApprove: Text;
    FifthApproveSignature: Variant;
    UserSetup1: Record "User Setup";
    UserSetup2: Record "User Setup";
    UserSetup3: Record "User Setup";
    UserSetup4: Record "User Setup";
    UserSetup5: Record "User Setup";
    UserSetup6: Record "User Setup";
    Destination: Text;
}

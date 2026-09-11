report 52203589 "Fixed Deposit Print out"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Fixed Deposit Print out.rdlc';

    dataset
    {
        dataitem("FD Header"; "Fixed Deposit Header")
        {
            CalcFields = "Interest Accrued";
            RequestFilterFields = "FD Certificate No.", "Investment Date", "Maturity Date";

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
            column(Amount_in_Words; NumberText[1] + ' ' + NumberText[2])
            {
            }
            column(FDNo_FDHeader; "FD Header"."No.")
            {
            }
            column(FDCertificateNo_FDHeader; "FD Header"."FD Certificate No.")
            {
            }
            column(InvestmentInstitution_FDHeader; "FD Header"."Investment Institution")
            {
            }
            column(DebitAccountType_FDHeader; "FD Header"."Debit Account Type")
            {
            }
            column(DebitAccountNo_FDHeader; "FD Header"."Debit Account No.")
            {
            }
            column(CreditAccountType_FDHeader; "FD Header"."Credit Account Type")
            {
            }
            column(CreditAccountNo_FDHeader; "FD Header"."Credit Account No")
            {
            }
            column(Amount_FDHeader; "FD Header".Amount)
            {
            }
            column(InvestmentDate_FDHeader; "FD Header"."Investment Date")
            {
            }
            column(InvestmentPeriod_FDHeader; "FD Header"."Investment Period")
            {
            }
            column(MaturityDate_FDHeader; "FD Header"."Maturity Date")
            {
            }
            column(NegotiatedIntrest_FDHeader; "FD Header"."Negotiated Intrest")
            {
            }
            column(ApprovalStatus_FDHeader; "FD Header".Status)
            {
            }
            column(CreatedBy_FDHeader; "FD Header"."Created By")
            {
            }
            column(CreatedOn_FDHeader; "FD Header"."Created On")
            {
            }
            column(LastUpdatedBy_FDHeader; "FD Header"."Last Updated By")
            {
            }
            column(lastUpdatedOn_FDHeader; "FD Header"."last Updated On")
            {
            }
            column(DebitAccountName_FDHeader; "FD Header"."Debit Account Name")
            {
            }
            column(CreditAccountName_FDHeader; "FD Header"."Credit Account Name")
            {
            }
            column(InterestType_FDHeader; "FD Header"."Interest Type")
            {
            }
            column(InterestReceivableAccount_FDHeader; "FD Header"."Interest Receivable Account")
            {
            }
            column(InterestReceivedAccount_FDHeader; "FD Header"."Interest Received Account")
            {
            }
            column(WTaxAccount_FDHeader; "FD Header"."W/Tax Account")
            {
            }
            column(PrincipleReceived_FDHeader; "FD Header"."Principle Received")
            {
            }
            column(InterestReceived_FDHeader; "FD Header"."Interest Received")
            {
            }
            column(WithholdingTax_FDHeader; "FD Header"."Withholding Tax")
            {
            }
            column(ReceivingAccountType_FDHeader; "FD Header"."Receiving Account Type")
            {
            }
            column(ReceivingAccountNo_FDHeader; "FD Header"."Receiving Account No")
            {
            }
            column(ExternalDocumentNo_FDHeader; "FD Header"."External Document No")
            {
            }
            column(ReceivingDate_FDHeader; "FD Header"."Receiving Date")
            {
            }
            column(Posted_FDHeader; "FD Header".Posted)
            {
            }
            column(PostedBy_FDHeader; "FD Header"."Posted By")
            {
            }
            column(PostedOn_FDHeader; "FD Header"."Posted On")
            {
            }
            column(Postedat_FDHeader; "FD Header"."Posted at")
            {
            }
            column(GlobalDimension1Code_FDHeader; "FD Header"."Global Dimension 1 Code")
            {
            }
            column(GlobalDimension2Code_FDHeader; "FD Header"."Global Dimension 2 Code")
            {
            }
            column(MarkedforLiquidation_FDHeader; "FD Header"."Marked for Liquidation")
            {
            }
            column(Liquidated_FDHeader; "FD Header".Liquidated)
            {
            }
            column(Terminated_FDHeader; "FD Header".Terminated)
            {
            }
            column(ReasonforTermination_FDHeader; "FD Header"."Reason for Termination")
            {
            }
            column(InterestAccrued_FDHeader; "FD Header"."Interest Accrued")
            {
            }
            column(EstimatedInteresttoAccrue_FDHeader; "FD Header"."Estimated Interest to Accrue")
            {
            }
            column(InvestmentType_FDHeader; "FD Header"."Investment Type")
            {
            }
            column(FaceValue_FDHeader; "FD Header"."Face Value")
            {
            }
            column(DiscountAmount_FDHeader; "FD Header"."Discount Amount")
            {
            }
            column(InvestmentPostingGroup_FDHeader; "FD Header"."Investment Posting Group")
            {
            }
            column(DimensionSetID_FDHeader; "FD Header"."Dimension Set ID")
            {
            }
            column(RolloverNo_FDHeader; "FD Header"."Rollover No.")
            {
            }
            dataitem("FD Schedule"; "Fixed Deposit Schedule")
            {
                DataItemLink = "No."=FIELD("No.");

                column(EntryNo_FDSchedule; "FD Schedule"."Entry No.")
                {
                }
                column(DocumentNo_FDSchedule; "FD Schedule"."No.")
                {
                }
                column(EntryType_FDSchedule; "FD Schedule"."Entry Type")
                {
                }
                column(Description_FDSchedule; "FD Schedule".Description)
                {
                }
                column(Amount_FDSchedule; "FD Schedule".Amount)
                {
                }
                column(PostingDate_FDSchedule; "FD Schedule"."Posting Date")
                {
                }
                column(InvestmentNo_FDSchedule; "FD Schedule"."Investment No")
                {
                }
                column(OutstandingAmount_FDSchedule; "FD Schedule"."Outstanding Amount")
                {
                }
                column(ActualAmount_FDSchedule; "FD Schedule"."Actual Amount")
                {
                }
                column(WitholdingTax_FDSchedule; "FD Schedule"."Witholding Tax")
                {
                }
                column(ActualPostingDate_FDSchedule; "FD Schedule"."Actual Posting Date")
                {
                }
                column(Posted_FDSchedule; "FD Schedule".Posted)
                {
                }
                column(PostedBy_FDSchedule; "FD Schedule"."Posted By")
                {
                }
                column(PostedOn_FDSchedule; "FD Schedule"."Posted On")
                {
                }
                column(PostedAt_FDSchedule; "FD Schedule"."Posted At")
                {
                }
            }
            trigger OnAfterGetRecord()
            begin
                ApprovalEntry.Reset;
                ApprovalEntry.SetRange("Table ID", 64020);
                ApprovalEntry.SetRange("Document No.", "FD Header"."No.");
                if ApprovalEntry.FindFirst then begin
                    SenderID:=ApprovalEntry."Sender ID";
                    DateTimeSend:=Format(ApprovalEntry."Date-Time Sent for Approval");
                    if UserSetup.Get(SenderID)then begin
                        UserSetup.CalcFields(Signature);
                    end;
                end;
                ApprovalEntry.Reset;
                ApprovalEntry.SetRange("Table ID", 64020);
                ApprovalEntry.SetRange("Document No.", "FD Header"."No.");
                ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Approved);
                ApprovalEntry.SetRange("Sequence No.", 1);
                if ApprovalEntry.FindSet then begin
                    FirstApproverID:=ApprovalEntry."Approver ID";
                    DateTimeFirstApprove:=Format(ApprovalEntry."Last Date-Time Modified");
                    if UserSetup1.Get(FirstApproverID)then begin
                        UserSetup1.CalcFields(Signature);
                    end;
                    ApprovalEntry.Reset;
                    ApprovalEntry.SetRange("Table ID", 64020);
                    ApprovalEntry.SetRange("Document No.", "FD Header"."No.");
                    ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Approved);
                    ApprovalEntry.SetRange("Sequence No.", 2);
                    if ApprovalEntry.FindFirst then begin
                        SecondApproverID:=ApprovalEntry."Approver ID";
                        DateTimeSecondApprove:=Format(ApprovalEntry."Last Date-Time Modified");
                        if UserSetup2.Get(SecondApproverID)then begin
                            UserSetup2.CalcFields(Signature);
                        end;
                    end;
                    ApprovalEntry.Reset;
                    ApprovalEntry.SetRange("Table ID", 64020);
                    ApprovalEntry.SetRange("Document No.", "FD Header"."No.");
                    ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Approved);
                    ApprovalEntry.SetRange("Sequence No.", 3);
                    if ApprovalEntry.FindFirst then begin
                        ThirdApproverID:=ApprovalEntry."Approver ID";
                        DateTimeThirdApprove:=Format(ApprovalEntry."Last Date-Time Modified");
                        if UserSetup3.Get(ThirdApproverID)then begin
                            UserSetup3.CalcFields(Signature);
                        end;
                    end;
                    ApprovalEntry.Reset;
                    ApprovalEntry.SetRange("Table ID", 64020);
                    ApprovalEntry.SetRange("Document No.", "FD Header"."No.");
                    ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Approved);
                    ApprovalEntry.SetRange("Sequence No.", 4);
                    if ApprovalEntry.FindFirst then begin
                        FourthApproverID:=ApprovalEntry."Approver ID";
                        DateTimeFourthApprove:=Format(ApprovalEntry."Last Date-Time Modified");
                        if UserSetup4.Get(FourthApproverID)then begin
                            UserSetup4.CalcFields(Signature);
                        end;
                    end;
                    ApprovalEntry.Reset;
                    ApprovalEntry.SetRange("Table ID", 64020);
                    ApprovalEntry.SetRange("Document No.", "FD Header"."No.");
                    ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Approved);
                    ApprovalEntry.SetRange("Sequence No.", 5);
                    if ApprovalEntry.FindFirst then begin
                        FifthApproverID:=ApprovalEntry."Approver ID";
                        DateTimeFifthApprove:=Format(ApprovalEntry."Last Date-Time Modified");
                        if UserSetup5.Get(FifthApproverID)then begin
                            UserSetup5.CalcFields(Signature);
                        end;
                    end;
                end;
                "FD Header".CalcFields("FD Header"."Estimated Interest to Accrue");
                AmountX:=Round("FD Header".Amount + "FD Header"."Estimated Interest to Accrue");
                AmountToWords.FormatNoText(NoText, AmountX, 'KES');
                AmountinWords:=NoText[1];
            end;
            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var CompanyInformation: Record "Company Information";
    PeriodYear: Integer;
    GratuityAmount: Decimal;
    PayrollPeriods: Record "Payroll Periods";
    PayrollPeriodTransaction: Record "Payroll Period Transaction";
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
    AmountX: Decimal;
    AmountinWords: Text;
    NoText: array[2]of Text;
    NumberText: array[2]of Text[80];
    AmountToWords: Codeunit "Amount To Words";
}

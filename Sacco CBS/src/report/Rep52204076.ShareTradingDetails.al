report 52204076 "Share Trading Details"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/ShareTradingDetails.rdlc';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Share Trading Setup"; "Share Trading Setup")
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
            column(DocumentNo_ShareTradingSetup; "Share Trading Setup"."Document No.")
            {
            }
            column(StartDate_ShareTradingSetup; "Share Trading Setup"."Start Date")
            {
            }
            column(EndDate_ShareTradingSetup; "Share Trading Setup"."End Date")
            {
            }
            column(BasePrice_ShareTradingSetup; "Share Trading Setup"."Base Price")
            {
            }
            column(Published_ShareTradingSetup; "Share Trading Setup".Published)
            {
            }
            column(Status_ShareTradingSetup; "Share Trading Setup".Status)
            {
            }
            column(Description_ShareTradingSetup; "Share Trading Setup".Description)
            {
            }
            column(Charges_ShareTradingSetup; "Share Trading Setup".Charges)
            {
            }
            column(ClearingAccount_ShareTradingSetup; "Share Trading Setup"."Clearing Account")
            {
            }
            column(HoldingAccount_ShareTradingSetup; "Share Trading Setup"."Holding Account")
            {
            }
            column(TotalValueOnMarket_ShareTradingSetup; "Share Trading Setup"."Total Value On Market")
            {
            }
            column(SharesOnMarket_ShareTradingSetup; "Share Trading Setup"."Shares On Market")
            {
            }
            column(ReservePrice_ShareTradingSetup; "Share Trading Setup"."Reserve Price")
            {
            }
            column(ShareLife_ShareTradingSetup; "Share Trading Setup"."Share Life")
            {
            }
            column(OnNoBid_ShareTradingSetup; "Share Trading Setup"."On No Bid")
            {
            }
            column(TolerancePeriod_ShareTradingSetup; "Share Trading Setup"."Tolerance Period")
            {
            }
            dataitem("Share Floating"; "Share Floating")
            {
                DataItemLink = "Share Type" = FIELD("Document No.");

                column(DocumentNo_ShareFloating; "Share Floating"."Document No")
                {
                }
                column(MemberNo_ShareFloating; "Share Floating"."Member No.")
                {
                }
                column(MemberName_ShareFloating; "Share Floating"."Member Name")
                {
                }
                column(ShareType_ShareFloating; "Share Floating"."Share Type")
                {
                }
                column(AccountNo_ShareFloating; "Share Floating"."Account No.")
                {
                }
                column(ParValue_ShareFloating; "Share Floating"."Par Value")
                {
                }
                column(TotalShares_ShareFloating; "Share Floating"."Total Shares")
                {
                }
                column(MinimumAcceptablePrice_ShareFloating; "Share Floating"."Minimum Acceptable Price")
                {
                }
                column(SharestoFloat_ShareFloating; "Share Floating"."Shares to Float")
                {
                }
                column(CurrentBalance_ShareFloating; "Share Floating"."Current Balance")
                {
                }
                column(GlobalDimension1Code_ShareFloating; "Share Floating"."Global Dimension 1 Code")
                {
                }
                column(GlobalDimension2Code_ShareFloating; "Share Floating"."Global Dimension 2 Code")
                {
                }
                column(Published_ShareFloating; "Share Floating".Published)
                {
                }
                column(MaximumBidPrice_ShareFloating; "Share Floating"."Maximum Bid Price")
                {
                }
                column(PaymentType_ShareFloating; "Share Floating"."Payment Type")
                {
                }
                column(PaymentAccountNo_ShareFloating; "Share Floating"."Payment Account No.")
                {
                }
                column(PaymentMethod_ShareFloating; "Share Floating"."Payment Method")
                {
                }
                column(ExternalRefrenceNo_ShareFloating; "Share Floating"."External Refrence No.")
                {
                }
                column(PaymentDate_ShareFloating; "Share Floating"."Payment Date")
                {
                }
                column(PaymentAmount_ShareFloating; "Share Floating"."Payment Amount")
                {
                }
                column(ProceedsAccount_ShareFloating; "Share Floating"."Proceeds Account")
                {
                }
                column(Archived_ShareFloating; "Share Floating".Archived)
                {
                }
                column(FloatedValue_ShareFloating; "Share Floating"."Floated Value")
                {
                }
                column(Awarded_ShareFloating; "Share Floating".Awarded)
                {
                }
                column(ReservePrice_ShareFloating; "Share Floating"."Reserve Price")
                {
                }
                column(CreatedBy_ShareFloating; "Share Floating"."Created By")
                {
                }
                column(CreatedOn_ShareFloating; "Share Floating"."Created On")
                {
                }
                column(FloatType_ShareFloating; "Share Floating"."Float Type")
                {
                }
                column(ShareLife_ShareFloating; "Share Floating"."Share Life")
                {
                }
                column(OnNoBid_ShareFloating; "Share Floating"."On No Bid")
                {
                }
                column(PublishedOn_ShareFloating; "Share Floating"."Published On")
                {
                }
                column(ExiryDate_ShareFloating; "Share Floating"."Exiry Date")
                {
                }
                column(ChargeAmount_ShareFloating; "Share Floating"."Charge Amount")
                {
                }
                column(PaymentDueDate_ShareFloating; "Share Floating"."Payment Due Date")
                {
                }
                column(PurchaseDate_ShareFloating; "Share Floating"."Purchase Date")
                {
                }
                column(TolerancePeriod_ShareFloating; "Share Floating"."Tolerance Period")
                {
                }
                dataitem("Share Trading Lines"; "Share Trading Lines")
                {
                    DataItemLink = "Document No." = FIELD("Document No");

                    column(DocumentNo_ShareTradingLines; "Share Trading Lines"."Document No.")
                    {
                    }
                    column(MemberNo_ShareTradingLines; "Share Trading Lines"."Member No.")
                    {
                    }
                    column(MemberName_ShareTradingLines; "Share Trading Lines"."Member Name")
                    {
                    }
                    column(BidPrice_ShareTradingLines; "Share Trading Lines"."Bid Price")
                    {
                    }
                    column(BidDate_ShareTradingLines; "Share Trading Lines"."Bid Date")
                    {
                    }
                    column(AccountNo_ShareTradingLines; "Share Trading Lines"."Account No")
                    {
                    }
                    column(AccountBalance_ShareTradingLines; "Share Trading Lines"."Account Balance")
                    {
                    }
                    column(Awarded_ShareTradingLines; "Share Trading Lines".Awarded)
                    {
                    }
                    column(Shares_ShareTradingLines; "Share Trading Lines".Shares)
                    {
                    }
                    column(TotalAmount_ShareTradingLines; "Share Trading Lines"."Total Amount")
                    {
                    }
                    column(Bought_ShareTradingLines; "Share Trading Lines".Bought)
                    {
                    }
                }
            }
            trigger OnAfterGetRecord()
            begin
                CompanyInformation.GET;
                CompanyInformation.CALCFIELDS(Picture);
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
}

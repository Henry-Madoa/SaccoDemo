report 52204022 "Disbursement Schedule"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    PreviewMode = Normal;
    RDLCLayout = './ssrs/DisbursementSchedule.rdl';

    dataset
    {
        dataitem("Loan Batch Header"; "Loan Batch Header")
        {
            column("CompanyLogo"; CompanyInformation.Picture)
            {
            }
            column("CompanyName"; CompanyInformation.Name)
            {
            }
            column("CompanyAddress1"; CompanyInformation.Address)
            {
            }
            column("CompanyAddress2"; CompanyInformation."Address 2")
            {
            }
            column("CompanyPhone"; CompanyInformation."Phone No.")
            {
            }
            column("CompanyEmail"; CompanyInformation."E-Mail")
            {
            }
            column(Document_No; "No.")
            {
            }
            column(Created_By; "Created By")
            {
            }
            column(Created_On; "Created On")
            {
            }
            column(Posting_Date; "Posting Date")
            {
            }
            dataitem("Loan Batch Lines"; "Loan Batch Lines")
            {
                DataItemLink = "No." = field("No.");
                DataItemTableView = sorting("No.", "Loan No");

                column(AmountDue; AmountDue)
                {
                }
                column(Appraisal; Appraisal)
                {
                }
                column(ApprovedAmount; ApprovedAmount)
                {
                }
                column(Bank_Account_Name; "Bank Account Name")
                {
                }
                column(Bank_Account_No_; "Bank Account No.")
                {
                }
                column(Bank_Branch_Code; "Bank Branch Code")
                {
                }
                column(Bank_Code; "Bank Code")
                {
                }
                column(BankAccount; BankAccount)
                {
                }
                column(BankCode; BankCode)
                {
                }
                column(BridgedAmount; BridgedAmount)
                {
                }
                column(BridgedCommission; BridgedCommission)
                {
                }
                column(ChequeAmount; ChequeAmount)
                {
                }
                column(CRB; CRB)
                {
                }
                column(InsurancePremium; InsurancePremium)
                {
                }
                column(Interest; Interest)
                {
                }
                column(InvestmentAmount; InvestmentAmount)
                {
                }
                column(Loan_No; "Loan No")
                {
                }
                column(MemberName; MemberName)
                {
                }
                column(MemberNo; MemberNo)
                {
                }
                column(Product; Product)
                {
                }
                column(RobinhoodTax; RobinhoodTax)
                {
                }
                column(RTGS; RTGS)
                {
                }
                column(ShareBoost; ShareBoost)
                {
                }
                column(ShareBoostComm; ShareBoostComm)
                {
                }
                column(SMS; SMS)
                {
                }
                column(BankBranchCode; BankBranchCode)
                {
                }
                dataitem(Loans; Loans)
                {
                    DataItemLink = "No." = field("Loan No");

                    column(Charges_Amount; "Charges Amount")
                    {
                    }
                    column(Approved_Amount; "Approved Amount")
                    {
                    }
                    column(Approved_NetAmount; "Approved Amount" - "Charges Amount")
                    {
                    }
                }
                trigger OnAfterGetRecord()
                begin
                    CRB := 0;
                    Appraisal := 0;
                    SMS := 0;
                    InsurancePremium := 0;
                    BridgedAmount := 0;
                    BridgedCommission := 0;
                    ShareBoost := 0;
                    ShareBoostComm := 0;
                    ApprovedAmount := 0;
                    NetAmount := 0;
                    MemberNo := '';
                    MemberName := '';
                    BankCode := '';
                    BankAccount := '';
                    Product := '';
                    ChequeAmount := 0;
                    BankBranchCode := '';
                    if Loans.Get("Loan No") then begin
                        Interest := Loans."Approved Amount" * Loans."Interest Rate" * 0.01 * (1 / 12) * (1 / 30) * Loans."Prorated Days";
                        Interest := Round(Interest, 1, '=');
                        MemberNo := Loans."Member No.";
                        MemberName := Loans."Member Name";
                        BankAccount := Loans."Pay to Account No";
                        BankCode := Loans."Pay to Bank Code";
                        BankBranchCode := Loans."Pay to Bank Code";
                        if BankCode = '' then begin
                            BankCode := 'FOSA';
                            BankAccount := Loans."Disbursement Account";
                            BankBranchCode := '';
                        end;
                        ApprovedAmount := Loans."Approved Amount";
                        LoanRecovery.Reset();
                        LoanRecovery.SetRange("Recovery Type", LoanRecovery."Recovery Type"::Loan);
                        LoanRecovery.SetRange("Loan No", Loans."No.");
                        if LoanRecovery.FindSet() then begin
                            LoanRecovery.CalcSums(Amount, "Commission Amount");
                            BridgedAmount := LoanRecovery.Amount;
                            BridgedAmount := LoanRecovery."Commission Amount";
                        end;
                        LoanRecovery.Reset();
                        LoanRecovery.SetRange("Recovery Type", LoanRecovery."Recovery Type"::Loan);
                        LoanRecovery.SetRange("Loan No", Loans."No.");
                        if LoanRecovery.FindSet() then begin
                            LoanRecovery.CalcSums(Amount, "Commission Amount");
                            BridgedAmount := LoanRecovery.Amount;
                            BridgedCommission := LoanRecovery."Commission Amount";
                        end;
                        LoanRecovery.Reset();
                        LoanRecovery.SetRange("Recovery Type", LoanRecovery."Recovery Type"::Account);
                        LoanRecovery.SetRange("Loan No", Loans."No.");
                        if LoanRecovery.FindSet() then begin
                            LoanRecovery.CalcSums(Amount, "Commission Amount");
                            ShareBoost := LoanRecovery.Amount;
                            ShareBoostComm := LoanRecovery."Commission Amount";
                        end;
                        LoanRecovery.Reset();
                        LoanRecovery.SetRange("Recovery Type", LoanRecovery."Recovery Type"::External);
                        LoanRecovery.SetRange("Loan No", Loans."No.");
                        if LoanRecovery.FindSet() then begin
                            LoanRecovery.CalcSums(Amount, "Commission Amount");
                            ChequeAmount := LoanRecovery.Amount;
                        end;
                        InsurancePremium := Loans."Insurance Amount";
                        if LoanProducts.Get(Loans."Product Code") then begin
                            Product := LoanProducts.Description;
                            CRB := LoansMgt.GetLoanProductChargesAmount(LoanProducts.Code, Loans."Approved Amount");
                            Appraisal := LoansMgt.GetLoanProductChargesAmount(LoanProducts.Code, Loans."Approved Amount");
                            SMS := LoansMgt.GetLoanProductChargesAmount(LoanProducts.Code, Loans."Approved Amount");
                            RTGS := LoansMgt.GetLoanProductChargesAmount(LoanProducts.Code, Loans."Approved Amount");
                            RobinhoodTax := LoansMgt.GetLoanProductChargesAmount(LoanProducts.Code, Loans."Approved Amount");
                        end;
                    end;
                    NetAmount := ApprovedAmount - CRB - Appraisal - SMS - InsurancePremium - BridgedAmount - BridgedCommission - ShareBoost - ShareBoostComm - RTGS - RobinhoodTax - InvestmentAmount - Interest - ChequeAmount;
                    AmountDue := NetAmount;
                end;
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
            end;
        }
    }
    var
        LoanRecovery: Record "Loan Recoveries";
        LoanProducts: Record "Sacco Products";
        LoansMgt: Codeunit "Loans Management";
        Product, BankCode, BankAccount, MemberNo, MemberName : Code[100];
        CompanyInformation: Record "Company Information";
        Member: Record Members;
        ObjExternalBankAcc: Record "External Banks";
        ObjExtBankBranch: Record "External Bank Branches";
        Interest, AmountDue, ApprovedAmount, NetAmount : decimal;
        BankBranchCode: Code[10];
        BridgedAmount, BridgedCommission, InsurancePremium, RTGS, SMS, RobinhoodTax, ShareBoostComm, CRB, Appraisal, ChequeAmount, InvestmentAmount, ShareBoost : Decimal;
}

report 52204058 "Member Withdrawal"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Member Exit ';
    UsageCategory = ReportsAndAnalysis;
    RDLCLayout = './ssrs/Member Withdrawal.rdl';

    dataset
    {
        dataitem(MemberWithdrawal; "Member Withdrawal")
        {
            column(IDNo; IDNo)
            {
            }
            column(Email; Email)
            {
            }
            column(Employer; Employer)
            {
            }
            column(PFNo; PFNo)
            {
            }
            column(PhoneNo; PhoneNo)
            {
            }
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
            column(DocumentNo; "No.")
            {
            }
            column(MemberNo; "Member No")
            {
            }
            column(MemberName; "Member Name")
            {
            }
            column(HoldingAccount; "Holding Account")
            {
            }
            column(Liabilities; Liabilities)
            {
            }
            column(Guarantees; Guarantees)
            {
            }
            column(Instant; Instant)
            {
            }
            column(NetAmount; "Net Amount")
            {
            }
            column(WithdrawalType; "Withdrawal Type")
            {
            }
            column(WithdrawalReason; "Withdrawal Reason")
            {
            }
            column(TotalAssets; "Total Assets")
            {
            }
            column(AccruedInterest; "Accrued Interest")
            {
            }
            column(ChargeAmount; ChargeAmount)
            {
            }
            column(ChargeCode; "Charge Code")
            {
            }
            column(NetRefund; NetRefund)
            {
            }
            dataitem("Member Exit Lines"; "Member Withdrawal Lines")
            {
                DataItemLink = "No." = field("No.");
                DataItemTableView = sorting("No.", "Entry No") where("Entry Type" = filter(Asset | Liability), "Share Capital" = const(false));

                column(Document_No; "No.")
                {
                }
                column(Accrued_Interest; "Accrued Interest")
                {
                }
                column(Account_No; "Account No")
                {
                }
                column(Account_Name; "Account Name")
                {
                }
                column(Amount__Base_; "Amount (Base)")
                {
                }
                column(Balance; Balance)
                {
                }
                column(Entry_Type; "Entry Type")
                {
                }
                trigger OnAfterGetRecord()
                var
                    Vendor: Record Vendor;
                    ProductFact: Record "Sacco Products";
                begin
                    if ((MemberWithdrawal."Withdrawal Type" = MemberWithdrawal."Withdrawal Type"::Desceased) and ("Member Exit Lines"."Entry Type" <> "Member Exit Lines"."Entry Type"::Asset)) then CurrReport.Skip();
                end;
            }
            trigger OnAfterGetRecord()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
                if Members.Get("Member No") then begin
                    PFNo := Members."Payroll No.";
                    PhoneNo := Members."Mobile Phone No.";
                    IDNo := Members."Identification No.";
                    Email := Members."E-Mail";
                    if Employers.Get(Members."Employer Code") then Employer := Employers.Name;
                    if "Charge Code" <> '' then ChargeAmount := JournalMgmt.GetChargesAmount("Charge Code", 1)
                end;
                if "Document Type" = "Document Type"::Withdrawal then
                    NetRefund := "Net Amount" - ChargeAmount
                else if "Document Type" = "Document Type"::Refund then NetRefund := "Requested Amount" - ChargeAmount;
            end;
        }
    }
    trigger OnInitReport()
    begin
        ChargeAmount := 0;
    end;

    var
        CompanyInformation: Record "Company Information";
        PFNo, PhoneNo, IDNo, Email, Employer : Text[200];
        Members: Record Members;
        Employers: Record Employers;
        ChargeAmount: Decimal;
        JournalMgmt: Codeunit "Journal Management";
        NetRefund: Decimal;
}

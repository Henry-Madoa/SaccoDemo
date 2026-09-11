report 52204035 "Channel Loan Application"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    PreviewMode = PrintLayout;
    EnableHyperlinks = true;
    Caption = 'Channel Loan Application';
    RDLCLayout = './ssrs/LoanForm.rdl';

    dataset
    {
        dataitem("Loan Application"; "Channel Loan Application")
        {
            column(Application_No; "No.")
            {
            }
            column(Application_Date; "Application Date")
            {
            }
            column(Member_No_; "Member No.")
            {
            }
            column(Member_Name; "Member Name")
            {
            }
            column(Installments; Installments)
            {
            }
            column(Product_Code; "Product Code")
            {
            }
            column(Product_Description; "Product Description")
            {
            }
            column(Interest_Rate; "Interest Rate")
            {
            }
            column(Applied_Amount; "Applied Amount")
            {
            }
            column(Approved_Amount; "Approved Amount")
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
            column(Company_Website; CompanyInformation."Home Page")
            {
            }
            column("CompanyEmail"; CompanyInformation."E-Mail")
            {
            }
            column(SectorName; SectorName)
            {
            }
            column(SubSectorName; SubSectorName)
            {
            }
            column(SubSubSectorname; SubSubSectorname)
            {
            }
            column(AmountInWords; AmountInWords[1])
            {
            }
            column(EmployerName; EmployerName)
            {
            }
            column(New_Monthly_Installment; "New Monthly Installment")
            {
            }
            column(BankCode; BankCode)
            {
            }
            column(BankName; BankName)
            {
            }
            column(AccountName; AccountName)
            {
            }
            column(AccountNo; AccountNo)
            {
            }
            column(Pay_to_Branch_Code; "Pay to Branch Code")
            {
            }
            column(GrossSalary; GrossSalary)
            {
            }
            column(PhoneNo; PhoneNo)
            {
            }
            column(PayrollNo; PayrollNo)
            {
            }
            column(Station; Station)
            {
            }
            column(Age; Age)
            {
            }
            column(EMail; EMail)
            {
            }
            column(WitnessSignature; WitnessRec.Signature)
            {
            }
            column(WitnessName; WitnessRec."Full Name")
            {
            }
            column(MemberSignature; Member.Signature)
            {
            }
            column(WitnessIDNo; WitnessRec."Identification No.")
            {
            }
            column(WitnessDate; WitnessDate)
            {
            }
            column(Member_National_ID; Member."Identification No.")
            {
            }
            column(Submitted_On; "Submitted On")
            {
            }
            dataitem("Online Guarantor Requests"; "Channel Guarantor Requests")
            {
                DataItemLink = "Loan No" = field("No.");
                DataItemTableView = where(Status = const(Approved), "Request Type" = const("Guarantor"));

                column(Guarantor_Member_No; "Member No")
                {
                }
                column(Guarantor_Member_Name; "Member Name")
                {
                }
                column(Amount_Accepted; "Amount Accepted")
                {
                }
                column(GuarantorSignature; Guarantors.Signature)
                {
                }
                column(GuarantorEmail; Guarantors."E-Mail")
                {
                }
                column(GuarantorNationalID; Guarantors."Identification No.")
                {
                }
                column(GuarantorPhoneNo; Guarantors."Mobile Phone No.")
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if Guarantors.Get("Online Guarantor Requests"."Member No") then begin
                        Guarantors.CalcFields(Signature);
                    end;
                end;
            }
            dataitem("Loan Recoveries"; "Loan Recoveries")
            {
                DataItemLink = "Loan No" = field("No.");

                column(Recovery_Code; "Recovery Code")
                {
                }
                column(Recovery_Description; "Recovery Description")
                {
                }
                column(Current_Balance; "Current Balance")
                {
                }
            }
            trigger OnPreDataItem()
            begin
            end;

            trigger OnAfterGetRecord()
            var
                ExtBank: Record "External Banks";
                LCharge: Record "Product Charge Setup";
                AppraisalParameters: Record "Loanees Payroll Transactions";
                LoansManagement: Codeunit "Loans Management";
                LoanRecoveries: Record "Loan Recoveries";
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
                SectorName := '';
                SubSectorName := '';
                SubSubSectorname := '';
                if EconomicSectors.Get("Loan Application"."Sector Code") then SectorName := EconomicSectors."Sector Name";
                if SubSectors.Get("Sector Code", "Sub Sector Code") then SubSectorName := SubSectors."Sub Sector Name";
                if SubSubSectors.Get("Sector Code", "Sub Sector Code", "Sub-Susector Code") then SubSubSectorname := SubSubSectors."Sub-Subsector Description";
                if Member.Get("Member No.") then begin
                    Member.CalcFields(Signature);
                    if Member."Date of Birth" <> 0D then Age := Format(Date2DMY(Today, 3) - Date2DMY(Member."Date of Birth", 3)) + ' YEARS';
                    EMail := Member."E-Mail";
                    if Employers.Get(Member."Employer Code") then EmployerName := Employers.Name;
                    PhoneNo := Member."Mobile Phone No.";
                    PayrollNo := Member."Payroll No.";
                    if PayrollNo = '' then PayrollNo := Member."Payroll No.";
                end;
                if WitnessRec.Get("Loan Application".Witness) then begin
                    WitnessRec.calcfields(Signature);
                    WitnessDate := 0D;
                    WitnessRequest.Reset();
                    WitnessRequest.SetRange("Member No", WitnessRec."No.");
                    WitnessRequest.SetRange("Loan No", "No.");
                    WitnessRequest.SetRange(Status, WitnessRequest.Status::Approved);
                    if WitnessRequest.FindFirst() then WitnessDate := DT2Date(WitnessRequest."Responded On");
                end;
                Clear(AmountInWords);
                AmountToWords.FormatNoText(AmountInWords, Net, '');
                AccountNo := '';
                if "Pay to Account No" = '' then begin
                    AccountNo := MemberMgt.GetMemberAccount("Member No.", ProductPostingType::"Withdrawable Deposit");
                    AccountName := "Member Name";
                end
                else begin
                    AccountNo := "Pay to Account No";
                    AccountName := "Pay to Account Name";
                    BankCode := "Pay to Bank Code";
                    if ExtBank.Get(BankCode) then BankName := ExtBank."Bank Name";
                end;
                GrossSalary := 0;
                GrossSalary := LoansManagement.GetGrossAmount("No.");
            end;
        }
    }
    var
        ProductPostingType: Enum "Product Posting Type";
        Employers: Record Employers;
        Guarantors: Record Members;
        WitnessDate: Date;
        WitnessRequest: Record "Channel Guarantor Requests";
        GrossSalary: Decimal;
        EmployerName: Text;
        EMail, PayrollNo, BankCode, BankName, AccountNo, AccountName, PhoneNo, Station, Age : Code[100];
        CompanyInformation: Record "Company Information";
        MemberAge: Integer;
        MemberMgt: Codeunit "Member Management";
        Portal: Codeunit "Channels Integrations";
        AmountToWords: Codeunit "Amount To Words";
        AmountInWords: array[2] of Text[250];
        LoanProduct: Record "Sacco Products";
        PayslipInfo: Record "Loanees Payroll Transactions";
        AppraisalAccounts: Record "Appraisal Accounts";
        Net: Decimal;
        Member, WitnessRec : Record Members;
        Check: Codeunit "Journal Management";
        EconomicSectors: Record "Economic Sectors";
        SubSectors: Record "Economic Subsectors";
        SubSubSectors: Record "Economic Sub-subsector";
        TagLine, GuarantorWarning, ThirdRuleWarning, LoanToDepositRatioWarning, RetirementWarning, SectorName, SubSectorName, SubSubSectorname : Text[100];
}

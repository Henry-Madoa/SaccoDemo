report 52204036 "Member Statement2"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    RDLCLayout = './ssrs/Member Statement2.rdl';

    dataset
    {
        dataitem(Member; Members)
        {
            RequestFilterFields = "No.", "Date Filter";

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
            column(CompanyWebsite; CompanyInformation."Home Page")
            {
            }
            column("MemberNo"; Member."No.")
            {
            }
            column("MemberName"; Member."Full Name")
            {
            }
            column("PhoneNo"; Member."Mobile Phone No.")
            {
            }
            column("NationalIDNo"; Member."Identification No.")
            {
            }
            column("KRAPINNo"; Member."KRA PIN")
            {
            }
            column(Payroll_No; "Payroll No.")
            {
            }
            column(EmployerCode; "Employer Code")
            {
            }
            column(EmployerName; EmployerName)
            {
            }
            column(MyMemberEmail; "E-Mail")
            {
            }
            column(MyMemberPhone; MobilePhoneNo)
            {
            }
            dataitem(Vendor; Vendor)
            {
                DataItemLink = "Member No." = field("No."), "No." = field("Account Filter");
                DataItemTableView = sorting("No.") where("Product Posting Type" = filter(<> "Loan Account"), Blocked = filter(" "));

                column(No_; "No.")
                {
                }
                column(Name; Name)
                {
                }
                column(OpeningBalance; OpeningBalance)
                {
                }
                dataitem("Vendor Ledger Entry"; "Vendor Ledger Entry")
                {
                    DataItemLink = "Vendor No." = field("No."), "Posting Date" = field("Date Filter");
                    DataItemTableView = sorting("Entry No.");

                    column(Entry_No_; "Entry No.")
                    {
                    }
                    column(Posting_Date; "Posting Date")
                    {
                    }
                    column(Document_No_; "Document No.")
                    {
                    }
                    column(Description; Description)
                    {
                    }
                    column(Debit_Amount; "Debit Amount")
                    {
                    }
                    column(Credit_Amount; "Credit Amount")
                    {
                    }
                    column(RunningBalance; RunningBalance)
                    {
                    }
                    trigger OnAfterGetRecord()
                    begin
                        "Vendor Ledger Entry".CalcFields(Amount);
                        RunningBalance += (-1 * "Vendor Ledger Entry".Amount);
                    end;

                    trigger OnPreDataItem()
                    begin
                        "Vendor Ledger Entry".SetFilter("Posting Date", DateFilter);
                    end;
                }
                trigger OnPreDataItem()
                begin
                    if ((LoanFilter <> '') AND (AccountFilter = '')) then Vendor.SetFilter("Member No.", 'philipayekomukhebo');
                    if DateFilter <> '' then begin
                        OpeningBalance := 0;
                        RunningBalance := 0;
                        DateRec.Reset();
                        DateRec.SetFilter("Period Start", DateFilter);
                        if DateRec.FindSet() then begin
                            RangeMin := DateRec.GetRangeMin("Period Start");
                            RangeMin := CalcDate('-1D', RangeMin);
                        end;
                    end;
                end;

                trigger OnAfterGetRecord()
                begin
                    OpeningBalance := 0;
                    RunningBalance := 0;
                    if Member.Get(Vendor."Member No.") then;
                    if RangeMin <> 0D then begin
                        DetailedEntries.Reset();
                        DetailedEntries.SetRange("Vendor No.", Vendor."No.");
                        DetailedEntries.SetFilter("Posting Date", '..%1', RangeMin);
                        if DetailedEntries.FindSet() then begin
                            DetailedEntries.CalcSums(Amount);
                            OpeningBalance := DetailedEntries.Amount;
                        end;
                    end;
                    OpeningBalance := RunningBalance;
                end;
            }
            dataitem("Loan Application"; Loans)
            {
                DataItemLink = "Member No." = field("No."), "No." = field("Loan Filter");
                DataItemTableView = sorting("No.");

                column(Application_No; "No.")
                {
                }
                column(Member_No_; "Member No.")
                {
                }
                column(ProductNameCalculated; ProductName)
                {
                }
                column(Application_Date; "Application Date")
                {
                }
                column(Approved_Amount; "Approved Amount")
                {
                }
                column(Monthly_Inistallment; ProductName)
                {
                }
                column(LoanName; "Product Description")
                {
                }
                column(Product_Code; "Product Code")
                {
                }
                column(Product_Description; "Product Description")
                {
                }
                column(CreditOpeningBalance; OpeningBalance)
                {
                }
                dataitem(CreditLedger; "Vendor Ledger Entry")
                {
                    DataItemTableView = sorting("Entry No.");
                    DataItemLink = "Loan No." = field("No."), "Vendor No." = field("Loan Account");

                    column(CredEntry_No_; "Entry No.")
                    {
                    }
                    column(CredPosting_Date; "Posting Date")
                    {
                    }
                    column(CredDocument_No_; "Document No.")
                    {
                    }
                    column(CredDescription; Description)
                    {
                    }
                    column(CredDebit_Amount; "Debit Amount")
                    {
                    }
                    column(CredCredit_Amount; "Credit Amount")
                    {
                    }
                    column(CredRunningBalance; RunningBalance)
                    {
                    }
                    trigger OnAfterGetRecord()
                    begin
                        CalcFields(Amount);
                        RunningBalance += Amount;
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetFilter("Posting Date", DateFilter);
                    end;
                }
                trigger OnAfterGetRecord()
                begin
                    "Loan Application".CalcFields(Disbursements);
                    if "Loan Application".Disbursements = 0 then CurrReport.Skip();
                    RunningBalance := 0;
                    OpeningBalance := 0;
                    RunningBalance := OpeningBalance;
                    ProductName := '';
                    ProductName := "Loan Application"."Product Description";
                    DateFilter := '';
                    LoanFilter := '';
                    AccountFilter := '';
                    LoanFilter := Member.GetFilter("Loan Filter");
                    AccountFilter := Member.GetFilter("Account Filter");
                    DateFilter := Member.GetFilter("Date Filter");
                    if DateFilter <> '' then begin
                        OpeningBalance := 0;
                        RunningBalance := 0;
                        DateRec.Reset();
                        DateRec.SetFilter("Period Start", DateFilter);
                        if DateRec.FindSet() then begin
                            RangeMin := DateRec.GetRangeMin("Period Start");
                            RangeMin := CalcDate('-1D', RangeMin);
                        end;
                    end;
                    if RangeMin <> 0D then begin
                        DetailedEntries.Reset();
                        DetailedEntries.SetRange("Loan No.", "Loan Application"."No.");
                        DetailedEntries.SetFilter("Posting Date", '..%1', RangeMin);
                        DetailedEntries.SetRange("Vendor No.", "Loan Application"."Loan Account");
                        if DetailedEntries.FindSet() then begin
                            DetailedEntries.CalcSums(Amount);
                            OpeningBalance := DetailedEntries.Amount;
                        end;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    if ((LoanFilter = '') AND (AccountFilter <> '')) then "Loan Application".SetFilter("Member No.", 'philipayekomukhebo');
                end;
            }
            trigger OnPreDataItem()
            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
            end;

            trigger OnAfterGetRecord()
            begin
                DateFilter := Member.GetFilter("Date Filter");
                if DateFilter <> '' then begin
                    DateRec.Reset();
                    DateRec.SetFilter("Period Start", DateFilter);
                    if DateRec.FindSet() then begin
                        RangeMin := CalcDate('-1D', DateRec.GetRangeMin("Period Start"));
                    end;
                end;
                EmployerCode := '';
                EmployerName := '';
                MobilePhoneNo := '';
                EmployerCode := Member."Employer Code";
                if Employers.Get("Employer Code") then begin
                    EmployerName := Employers.Code + ' ' + Employers.Name;
                    MobilePhoneNo := Member."Mobile Phone No.";
                end;
            end;
        }
    }
    var
        ProductName, EmployerName, LoanFilter, AccountFilter : Text;
        DateFilter: Text[250];
        OpeningBalance: Decimal;
        RunningBalance: Decimal;
        DetailedEntries: Record "Detailed Vendor Ledg. Entry";
        RangeMin: date;
        DateRec: Record Date;
        CompanyInformation: Record "Company Information";
        EmployerCode, MobilePhoneNo : Code[20];
        Employers: Record Employers;
}

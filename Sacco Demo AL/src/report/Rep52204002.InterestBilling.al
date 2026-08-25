report 52204002 "Interest Billing"
{
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Filters)
                {
                    field("Bill Date"; BillDate)
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Member No"; BillingMemberNo)
                    {
                        TableRelation = Members where(Status = filter(Active | "Not Paid Up" | Dormant));
                    }
                    field("Loan No"; BillingLoanNo)
                    {
                        TableRelation = Loans where("Loan Balance" = filter(<> 0));
                    }
                    field(Employer; EmployerFilter)
                    {
                        trigger OnLookup(var Text: Text): Boolean
                        var
                            Employers: Record Employers;
                        begin
                            EmployerCode := '';
                            Employers.Reset();
                            if Page.RunModal(Page::Employers, Employers, Employers.Code) = Action::LookupOK then begin
                                EmployerCode := Employers.Code;
                                EmployerFilter := EmployerCode;
                            end;
                        end;
                    }
                    field(BillType; BillType)
                    {
                        Caption = 'Bill Type';
                    }
                }
            }
        }
    }
    var
        LoansManagement: Codeunit "Loans Management";
        EmployerFilter: Text;
        EmployerCode, BillingMemberNo, BillingLoanNo : Code[20];
        BillType: Option All,FOSA,BOSA;
        BillDate: Date;

    trigger OnPostReport()
    begin
        LoansManagement.PostLoanInterest(BillDate, EmployerCode, BillType, BillingMemberNo, BillingLoanNo);
    end;
}

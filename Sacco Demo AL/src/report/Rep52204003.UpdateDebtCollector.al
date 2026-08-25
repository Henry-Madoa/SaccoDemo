report 52204003 "Update Debt Collector"
{
    ProcessingOnly = true;
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    field("Debt Collector"; CurrDebtCollectorName)
                    {
                        Editable = false;
                    }
                    field("Debt Collector Type"; DebtCollectorType)
                    {
                    }
                    field("New Debt Collector"; DebtCollector)
                    {
                        trigger OnLookup(var Text: Text): Boolean
                        var
                            Employee: Record Employee;
                            Vendor: Record Vendor;
                        begin
                            DebtCollector := '';
                            if DebtCollectorType = DebtCollectorType::Internal_Collector then begin
                                Employee.Reset();
                                Employee.SetRange(Status, Employee.Status::Active);
                                if Page.RunModal(Page::"Employee List", Employee) = Action::LookupOK then begin
                                    DebtCollector := Employee."No.";
                                    DebtCollectorName := Employee.FullName;
                                end;
                            end else if DebtCollectorType = DebtCollectorType::External_Collector then begin
                                Vendor.Reset();
                                Vendor.SetRange(Blocked, Vendor.Blocked::" ");
                                Vendor.SetRange("Account Type", Vendor."Account Type"::Supplier);
                                if Page.RunModal(Page::"Vendor Lookup", Vendor) = Action::LookupOK then begin
                                    DebtCollector := Vendor."No.";
                                    DebtCollectorName := Vendor.Name;
                                end;
                            end;
                        end;
                    }
                    field("New Debt Collector Name"; DebtCollectorName)
                    {
                        Editable = false;
                    }
                }
            }
        }
    }

    var
        Current, NewAmount : Decimal;
        LoanNo, DebtCollector : Code[20];
        CurrDebtCollectorName: Text[80];
        DebtCollectorName: Text[80];
        Loans: Record Loans;
        DebtCollectorType: Option " ",Internal_Collector,External_Collector;
        UserSetup: Record "User Setup";


    trigger OnPostReport()
    begin
        if Loans.Get(LoanNo) then begin
            if Confirm(StrSubstNo('You are about to update Debt Collector From %1 to %2. \\Do you wish to continue?', CurrDebtCollectorName, DebtCollectorName)) then begin
                Loans."Debt Collector Type" := DebtCollectorType;
                Loans.Validate("Debt Collector", DebtCollector);
                Loans.Modify(true);
            end;
        end;
    end;

    procedure SetCurrentDetails(Loan_No: Code[20]; Curr_Debt_Collector_Name: Text[80])
    begin
        UserSetup.Get(UserId);
        if not UserSetup."Can Update Debt Collector" then
            Error('You are not permitted to perform this action, Kindly contact Admin.');
        LoanNo := Loan_No;
        CurrDebtCollectorName := Curr_Debt_Collector_Name;
    end;
}
 
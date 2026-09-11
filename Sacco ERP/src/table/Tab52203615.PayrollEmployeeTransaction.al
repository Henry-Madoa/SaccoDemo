table 52203615 "Payroll Employee Transaction"
{
    fields
    {
        field(1; "Employee Code"; Code[30])
        {
            TableRelation = Employee."No.";
        }
        field(2; "Transaction Code"; Code[30])
        {
            TableRelation = "Payroll Transaction Code".Code;

            trigger OnValidate()
            var
                PRTransactionCodes: Record "Payroll Transaction Code";
                SelectedPeriod: Date;
                objPeriod: Record "Payroll Periods";
                PeriodName: Text[30];
                PeriodTrans: Record "Payroll Period Transaction";
                PeriodMonth: Integer;
                PeriodYear: Integer;
                blnIsLoan: Boolean;
                strExtractedFrml: Text[30];
                curTransAmount: Decimal;
                empCode: Text[30];
                PREmployeeTrans: Record "Payroll Employee Transaction";
                i: Integer;
                HREmp: Record Employee;
                objOCX: Codeunit "Payroll Processing";
            begin
                blnIsLoan := false;
                PRTransactionCodes.Reset;
                PRTransactionCodes.SetRange(PRTransactionCodes.Code, "Transaction Code");
                if PRTransactionCodes.Find('-') then begin
                    "Transaction Name" := PRTransactionCodes.Name;
                    "Sacco loan" := PRTransactionCodes."Sacco Loan";
                    if PRTransactionCodes."Special Transactions" in [PRTransactionCodes."Special Transactions"::"House Allownace"] then begin
                        if Employee.Get("Employee Code") then begin
                            if Employee.Housed then Error('This employee is housed and not entitled to house allowance');
                        end;
                    end;
                    Employee.Reset;
                    Employee.SetRange("Spouse Payroll No", "Employee Code");
                    Employee.SetRange(Housed, true);
                    if Employee.FindFirst then Error('This employee is a spouse to a housed employee and not entitled to house allowance');
                end;
                objPeriod.Reset;
                objPeriod.SetRange(Closed, false);
                if objPeriod.Find('-') then begin
                    SelectedPeriod := objPeriod."Start Date";
                    "Payroll Period" := SelectedPeriod;
                    "Period Month" := objPeriod."Period Month";
                    "Period Year" := objPeriod."Period Year";
                end;
                /*IF PRTransactionCodes."Special Transactions"=8 THEN blnIsLoan:=TRUE;

                            IF PRTransactionCodes."Is Formula"=TRUE OR PRTransactionCodes."Is Pension"= FALSE THEN
                            BEGIN
                             empCode:="Employee Code";
                             CLEAR(objOCX);
                             curTransAmount:=objOCX.fnDisplayFrmlValues(empCode,PeriodMonth,PeriodYear,PRTransactionCodes.Formula);
                             Amount:=curTransAmount;
                            end;

                            curTransAmount:=0;

                            IF PRTransactionCodes."Include Employer Deduction"=TRUE THEN

                            BEGIN
                              curTransAmount:=objOCX.fnDisplayFrmlValues(empCode,PeriodMonth,PeriodYear,PRTransactionCodes."Is Formula for employer");
                              "Employer Amount":=curTransAmount;
                            end;*/
            end;
        }
        field(3; "Transaction Name"; Text[100])
        {
        }
        field(4; Amount; Decimal)
        {
        }
        field(5; Balance; Decimal)
        {
            trigger OnValidate()
            begin
                "Original Amount" := Balance;
            end;
        }
        field(6; "Original Amount"; Decimal)
        {
        }
        field(7; "Period Month"; Integer)
        {
        }
        field(8; "Period Year"; Integer)
        {
        }
        field(9; "Payroll Period"; Date)
        {
            TableRelation = "Payroll Periods"."Start Date";
        }
        field(10; "#of Repayments"; Integer)
        {
            trigger OnValidate()
            begin
                if (Balance > 0) and ("#of Repayments" > 0) then Amount := Balance / "#of Repayments"
            end;
        }
        field(11; Membership; Code[10])
        {
            Editable = false;
        }
        field(12; "Reference No"; Text[100])
        {
            Editable = false;
        }
        field(13; integera; Integer)
        {
        }
        field(14; "Employer Amount"; Decimal)
        {
        }
        field(20; "Loan Number"; Code[100])
        {
            // trigger OnLookup()
            // var
            //     Employee: Record Employee;
            //     LoanApps: Record "Loan Application";
            //     PayrollCode: Record "Payroll Transaction Code";
            // begin
            //     if PayrollCode.Get("Transaction Code") then begin
            //         If ((PayrollCode."Coop Parameter" = PayrollCode."Coop Parameter"::Loan) or (PayrollCode."Coop Parameter" = PayrollCode."Coop Parameter"::Loan)) then begin
            //             if Employee.Get("Employee Code") then begin
            //                 LoanApps.Reset;
            //                 LoanApps.SetRange("Member No.", Employee."Member No.");
            //                 LoanApps.SetRange("Recovery Mode", LoanApps."Recovery Mode"::Checkoff);
            //                 LoanApps.SetFilter("Loan Balance", '<>%1', 0);
            //                 if LoanApps.FindSet then begin
            //                     if PAGE.RunModal(PAGE::Loans, LoanApps) = ACTION::LookupOK then begin
            //                         "Loan Number" := LoanApps."No.";
            //                     end;
            //                 end;
            //             end;
            //         end;
            //     end;
            // end;
            // trigger OnValidate()
            // var
            //     ObjLoanApp: Record "Loan Application";
            //     ObjEmp: Record Employee;
            //     PayrollCode: Record "Payroll Transaction Code";
            //     DateFilter: Text;
            // begin
            //     //Loan
            //     if PayrollCode.Get("Transaction Code") then begin
            //         If (PayrollCode."Coop Parameter" = PayrollCode."Coop Parameter"::Loan) then begin
            //             PayrollPeriods.reset;
            //             PayrollPeriods.SetRange(Closed, false);
            //             if PayrollPeriods.FindFirst() then begin
            //                 DateFilter := '';
            //                 DateFilter := '..' + format(CalcDate('CM', PayrollPeriods."Start Date"));
            //                 ObjLoanApp.reset;
            //                 ObjLoanApp.SetRange("No.", "Loan Number");
            //                 ObjLoanApp.SetFilter("Date Filter", DateFilter);
            //                 if ObjLoanApp.FindSet() then begin
            //                     ObjLoanApp.CalcFields("Loan Balance");
            //                     Balance := ABS(ObjLoanApp."Loan Balance"); // - ABS(Rec.Amount);
            //                 end;
            //             end;
            //         end;
            //     end;
            //     //Interest
            //     if PayrollCode.Get("Transaction Code") then begin
            //         If (PayrollCode."Coop Parameter" = PayrollCode."Coop Parameter"::"loan Interest") then begin
            //             PayrollPeriods.reset;
            //             PayrollPeriods.SetRange(Closed, false);
            //             if PayrollPeriods.FindFirst() then begin
            //                 DateFilter := '';
            //                 DateFilter := '..' + format(CalcDate('CM', PayrollPeriods."Start Date"));
            //                 ObjLoanApp.reset;
            //                 ObjLoanApp.SetRange("No.", "Loan Number");
            //                 ObjLoanApp.SetFilter("Date Filter", DateFilter);
            //                 if ObjLoanApp.FindSet() then begin
            //                     ObjLoanApp.CalcFields("Loan Balance");
            //                     Balance := 0; // - ABS(Rec.Amount);
            //                 end;
            //             end;
            //         end;
            //     end;
            // end;
        }
        field(41; Stopped; Boolean)
        {
        }
        field(42; "Subledger Account"; Code[10])
        {
            TableRelation = IF ("Subledger Account" = CONST('VENDOR')) Vendor."No." WHERE(Blocked = FILTER(<> All), "Vendor Posting Group" = CONST('OTHERS'))
            ELSE IF ("Subledger Account" = CONST('CUSTOMER')) Customer."No." WHERE(Blocked = FILTER(<> All));
        }
        field(44; "Sacco loan"; Boolean)
        {
        }
        field(49; Grade; Code[20])
        {
            FieldClass = Normal;
            TableRelation = "Employee Payroll Scales".Scale;
        }
        field(54; "Temporary Transaction"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(55; "Imprest No"; Code[50])
        {
            Editable = false;
            DataClassification = ToBeClassified;
            TableRelation = "Request Header"."No." WHERE("Employee No." = FIELD("Employee Code"), Posted = CONST(true), Surrendered = CONST(false), "To Recover From Payroll" = CONST(true));
        }
        field(57; Pointer; Code[5])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Salary Scale Pointers".Pointer WHERE(Scale = FIELD(Grade));
        }
        field(58; "No Of Periods"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(59; "Executed periods"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Employee Code", "Transaction Code", "Payroll Period", "Period Month", "Period Year")
        {
        }
    }
    var
        PayrollTransactionCode: Record "Payroll Transaction Code";
        PayrollPeriods: Record "Payroll Periods";
        Employee: Record Employee;
}

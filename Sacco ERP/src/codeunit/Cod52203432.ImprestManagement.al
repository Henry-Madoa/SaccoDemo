codeunit 52203432 "Imprest Management"
{
    var RequestLines: Record "Request Lines";
    GLEntry: Record "G/L Entry";
    GLSetup: Record "General Ledger Setup";
    PaymentMethods: Record "Payment Method";
    HRSetup: Record "Human Resources Setup";
    Text000: Label 'Are you sure you want to post the document?';
    Text001: Label 'The Document No %1 has not been fully approved.';
    Text003: Label 'The request amount cannot be zero.';
    Text004: Label 'The document %1 has been posted.';
    Text007: Label 'This Surrender has been posted.';
    Text010: Label 'The Surrender amount cannot be zero.';
    Selection: Integer;
    Text017: Label 'This Request has been posted.';
    Text018: Label 'Ensure you have attached Surrender documents for %1 before submitting.';
    Text019: Label 'The Document must be of Type Staff Claim';
    Text020: Label 'The Document must be of Type Salary Advance';
    Text021: Label 'You are about to Surrender %1 for Imprest No %2, Do you wish to continue?';
    RefundSelectionString: Label 'Receive Now,Deduct from Payroll';
    ClaimSelectionString: Label 'Pay Now,Pay from Payroll';
    Employee: Record Employee;
    BankAccount: Record "Bank Account";
    Budgetmgmt: Codeunit "Budget Management";
    LineNo: Integer;
    GenJnLine: Record "Gen. Journal Line";
    Batch: Record "Gen. Journal Batch";
    procedure PostImprestRequest(var ImprestHeader: Record "Request Header")
    begin
        with ImprestHeader do begin
            if Posted then Error(Text004, "No.");
            if Confirm(Text000, false) = true then begin
                if(("Request Type" <> "Request Type"::Imprest) AND (Status <> Status::Approved))then Error(Text001, "No.");
                TestField("Employee No.");
                Employee.Get("Employee No.");
                TestField(Date);
                TestField("Pay Mode");
                PaymentMethods.Get("Pay Mode");
                if PaymentMethods.Type <> PaymentMethods.Type::FOSA then TestField("Paying Bank Code");
                if PaymentMethods.Type = PaymentMethods.Type::Cheque then begin
                    TestField("Payment Tx No.(Cheque No.)");
                    TestField("Cheque Date");
                end; //Check if the  Lines have been populated
                CalcFields("Request Amount");
                if "Request Amount" = 0 then Error(Text003);
                GLSetup.Get;
                // Delete Lines Present on the General Journal Line
                GenJnLine.Reset;
                GenJnLine.SetRange(GenJnLine."Journal Template Name", GLSetup."Imprest Template");
                GenJnLine.SetRange(GenJnLine."Journal Batch Name", GLSetup."Imprest Batch");
                GenJnLine.DeleteAll;
                Batch.Init;
                Batch."Journal Template Name":=GLSetup."Imprest Template";
                Batch.Name:=GLSetup."Imprest Batch";
                if not Batch.Get(Batch."Journal Template Name", Batch.Name)then Batch.Insert;
                LineNo:=LineNo + 1000;
                //Debit Customer
                GenJnLine.Init;
                GenJnLine."Journal Template Name":=GLSetup."Imprest Template";
                GenJnLine."Journal Batch Name":=GLSetup."Imprest Batch";
                GenJnLine."Line No.":=LineNo;
                GenJnLine."Account Type":=GenJnLine."Account Type"::Employee;
                GenJnLine.Validate("Account No.", Employee."No.");
                GenJnLine."Posting Date":=WorkDate;
                GenJnLine."Document No.":="No.";
                GenJnLine."External Document No.":="Payment Tx No.(Cheque No.)";
                GenJnLine.Description:=CopyStr(ImprestHeader.Description, 1, 50);
                if("Currency Code" <> '') and ("Currency Code" <> GLSetup."LCY Code")then GenJnLine.Validate("Currency Code", "Currency Code");
                GenJnLine.Amount:="Request Amount";
                GenJnLine.Validate(Amount);
                GenJnLine."Shortcut Dimension 1 Code":="Global Dimension 1 Code";
                GenJnLine.Validate("Shortcut Dimension 1 Code");
                GenJnLine."Shortcut Dimension 2 Code":="Global Dimension 2 Code";
                GenJnLine.Validate("Shortcut Dimension 2 Code");
                if GenJnLine.Amount <> 0 then GenJnLine.Insert;
                //Credit FOSA/BANK
                LineNo:=LineNo + 1000;
                GenJnLine.Init;
                GenJnLine."Journal Template Name":=GLSetup."Imprest Template";
                GenJnLine."Journal Batch Name":=GLSetup."Imprest Batch";
                GenJnLine."Line No.":=LineNo;
                TestField("Paying Bank Code");
                GenJnLine."Account Type":=GenJnLine."Account Type"::"Bank Account";
                GenJnLine."Account No.":="Paying Bank Code";
                GenJnLine."Posting Date":=WorkDate;
                GenJnLine."Document No.":="No.";
                GenJnLine."External Document No.":="Payment Tx No.(Cheque No.)";
                GenJnLine.Description:=CopyStr(ImprestHeader.Description, 1, 50);
                if("Currency Code" <> '') and ("Currency Code" <> GLSetup."LCY Code")then GenJnLine.Validate("Currency Code", "Currency Code");
                GenJnLine.Amount:=-"Request Amount";
                GenJnLine.Validate(Amount);
                GenJnLine."Shortcut Dimension 1 Code":="Global Dimension 1 Code";
                GenJnLine.Validate("Shortcut Dimension 1 Code");
                GenJnLine."Shortcut Dimension 2 Code":="Global Dimension 2 Code";
                GenJnLine.Validate("Shortcut Dimension 2 Code");
                if GenJnLine.Amount <> 0 then GenJnLine.Insert;
                if "Pay Mode" <> 'EFT' then CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post", GenJnLine)
                else
                    CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post Ext", GenJnLine);
                GLEntry.Reset;
                GLEntry.SetRange(GLEntry."Document No.", "No.");
                GLEntry.SetRange(GLEntry.Reversed, false);
                GLEntry.SetRange("Posting Date", WorkDate);
                if GLEntry.FindFirst then begin
                    Posted:=true;
                    "Posted By":=UserId;
                    Validate("Posted Date", WorkDate);
                    "Request Type":="Request Type"::Surrender;
                    Status:=Status::Open;
                    Modify;
                end;
            end;
        end;
    end;
    procedure CloseImprestSurrender(var Imprest: Record "Request Header")
    var
        Text000: Label 'You are about to close Imprest Surrender %1, By doing so you are going to recover the intial issued amount(%2) from %3';
    begin
        with Imprest do begin
            if not Confirm(StrSubstNo(Text000, "No.", Format("Request Amount"), "Employee Name"))then exit;
            TestField(Date);
            TestField("Employee No.");
            Employee.Get("Employee No.");
            //Pay Now
            Commit;
            if "Net Refund (Net Claim)" < 0 then if PAGE.RunModal(PAGE::"Pay Imprest Claim", Imprest) = ACTION::LookupOK then begin
                end;
            Commit;
            TestField("Pay Mode");
            PaymentMethods.Get("Pay Mode");
            // if PaymentMethods.Type <> PaymentMethods.Type::FOSA then
            //     Error('You can only Recover surrender from FOSA');
            //Check if the  Lines have been populated
            CalcFields("Request Amount");
            if "Request Amount" = 0 then Error(Text003);
            GLSetup.Get;
            // Delete Lines Present on the General Journal Line
            GenJnLine.Reset;
            GenJnLine.SetRange(GenJnLine."Journal Template Name", GLSetup."Imprest Template");
            GenJnLine.SetRange(GenJnLine."Journal Batch Name", GLSetup."Imprest Batch");
            GenJnLine.DeleteAll;
            Batch.Init;
            Batch."Journal Template Name":=GLSetup."Imprest Template";
            Batch.Name:=GLSetup."Imprest Batch";
            if not Batch.Get(Batch."Journal Template Name", Batch.Name)then Batch.Insert;
            LineNo:=LineNo + 1000;
            //Credit Employee
            GenJnLine.Init;
            GenJnLine."Journal Template Name":=GLSetup."Imprest Template";
            GenJnLine."Journal Batch Name":=GLSetup."Imprest Batch";
            GenJnLine."Line No.":=LineNo;
            GenJnLine."Account Type":=GenJnLine."Account Type"::Employee;
            GenJnLine.Validate("Account No.", Employee."No.");
            GenJnLine."Posting Date":=WorkDate;
            GenJnLine."Document No.":="No.";
            GenJnLine."External Document No.":="Payment Tx No.(Cheque No.)";
            GenJnLine.Description:=StrSubstNo('Imprest Recovery from %1, for Imprest No. %2', "Employee Name", "No.");
            if("Currency Code" <> '') and ("Currency Code" <> GLSetup."LCY Code")then GenJnLine.Validate("Currency Code", "Currency Code");
            GenJnLine.Amount:=-"Request Amount";
            GenJnLine.Validate(Amount);
            GenJnLine."Shortcut Dimension 1 Code":="Global Dimension 1 Code";
            GenJnLine.Validate("Shortcut Dimension 1 Code");
            GenJnLine."Shortcut Dimension 2 Code":="Global Dimension 2 Code";
            GenJnLine.Validate("Shortcut Dimension 2 Code");
            if GenJnLine.Amount <> 0 then GenJnLine.Insert;
            //Debit FOSA/BANK
            LineNo:=LineNo + 1000;
            GenJnLine.Init;
            GenJnLine."Journal Template Name":=GLSetup."Imprest Template";
            GenJnLine."Journal Batch Name":=GLSetup."Imprest Batch";
            GenJnLine."Line No.":=LineNo;
            TestField("Paying Bank Code");
            GenJnLine."Account Type":=GenJnLine."Account Type"::"Bank Account";
            GenJnLine."Account No.":="Paying Bank Code";
            GenJnLine."Posting Date":=WorkDate;
            GenJnLine."Document No.":="No.";
            GenJnLine."External Document No.":="Payment Tx No.(Cheque No.)";
            GenJnLine.Description:=StrSubstNo('Imprest Recovery from %1, for Imprest No. %2', "Employee Name", "No.");
            if("Currency Code" <> '') and ("Currency Code" <> GLSetup."LCY Code")then GenJnLine.Validate("Currency Code", "Currency Code");
            GenJnLine.Amount:="Request Amount";
            GenJnLine.Validate(Amount);
            GenJnLine."Shortcut Dimension 1 Code":="Global Dimension 1 Code";
            GenJnLine.Validate("Shortcut Dimension 1 Code");
            GenJnLine."Shortcut Dimension 2 Code":="Global Dimension 2 Code";
            GenJnLine.Validate("Shortcut Dimension 2 Code");
            if GenJnLine.Amount <> 0 then GenJnLine.Insert;
            if "Pay Mode" <> 'EFT' then CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post", GenJnLine)
            else
                CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post Ext", GenJnLine);
            GLEntry.Reset;
            GLEntry.SetRange(GLEntry."Document No.", "No.");
            GLEntry.SetRange(GLEntry.Reversed, false);
            GLEntry.SetRange("Posting Date", WorkDate);
            if GLEntry.FindFirst then begin
                "Surrender Posted Date":=WorkDate;
                Status:=Status::Closed;
                Surrendered:=true;
                "Surrender Posted By":=UserId;
                Modify;
            end;
        end;
    end;
    procedure PostImprestSurrender(var ImprestHeader: Record "Request Header")
    begin
        with ImprestHeader do begin
            if not Confirm(StrSubstNo(Text021, Format("Total Surrender Amount"), "No."), false)then exit;
            GLSetup.Get;
            if Surrendered then Error(Text007);
            TestField("Surrender Date");
            CalcFields("Total Surrender Amount");
            CalcFields("Net Refund (Net Claim)");
            CalcFields("Total Requested Amount");
            if "Total Surrender Amount" = 0 then Error(Text010);
            if Committed then Budgetmgmt.UnCommitImprest("No.");
            Employee.Get("Employee No.");
            GLSetup.TestField("Imprest Template");
            GLSetup.TestField("Imprest Surrender Batch");
            // Delete Lines Present on the General Journal Line
            GenJnLine.Reset;
            GenJnLine.SetRange(GenJnLine."Journal Template Name", GLSetup."Imprest Template");
            GenJnLine.SetRange(GenJnLine."Journal Batch Name", GLSetup."Imprest Surrender Batch");
            GenJnLine.DeleteAll;
            Batch.Init;
            Batch."Journal Template Name":=GLSetup."Imprest Template";
            Batch.Name:=GLSetup."Imprest Surrender Batch";
            if not Batch.Get(Batch."Journal Template Name", Batch.Name)then Batch.Insert;
            if "Net Refund (Net Claim)" < 0 then begin
                Selection:=StrMenu(ClaimSelectionString, 1);
                if Selection = 1 then begin
                    //Pay Now
                    Commit;
                    if PAGE.RunModal(PAGE::"Pay Imprest Claim", ImprestHeader) = ACTION::LookupOK then begin
                    end;
                    Commit;
                    // Credit FOSA/Bank
                    LineNo:=LineNo + 1000;
                    GenJnLine.Init;
                    GenJnLine."Journal Template Name":=GLSetup."Imprest Template";
                    GenJnLine."Journal Batch Name":=GLSetup."Imprest Surrender Batch";
                    GenJnLine."Line No.":=LineNo;
                    GenJnLine."Account Type":=GenJnLine."Account Type"::"Bank Account";
                    GenJnLine."Account No.":="Claim Paying Account";
                    GenJnLine."Posting Date":=WorkDate;
                    GenJnLine."Document No.":="No.";
                    GenJnLine.Description:=StrSubstNo('Staff Claim from Imprest No: %1', "No.");
                    GenJnLine.Amount:="Net Refund (Net Claim)";
                    GenJnLine.Validate(GenJnLine.Amount);
                    GenJnLine."External Document No.":="Claim Payment Tx No";
                    GenJnLine."Currency Code":="Currency Code";
                    GenJnLine.Validate(GenJnLine."Currency Code");
                    GenJnLine.Validate(GenJnLine."Shortcut Dimension 1 Code", "Global Dimension 1 Code");
                    GenJnLine.Validate(GenJnLine."Shortcut Dimension 2 Code", "Global Dimension 2 Code");
                    if GenJnLine.Amount <> 0 then GenJnLine.Insert;
                    Commit;
                    //Credit Employee
                    LineNo:=LineNo + 1000;
                    GenJnLine.Init;
                    GenJnLine."Journal Template Name":=GLSetup."Imprest Template";
                    GenJnLine."Journal Batch Name":=GLSetup."Imprest Surrender Batch";
                    GenJnLine."Line No.":=LineNo;
                    GenJnLine."Account Type":=GenJnLine."Account Type"::Employee;
                    GenJnLine.Validate("Account No.", Employee."No.");
                    GenJnLine."Posting Date":=WorkDate;
                    GenJnLine."Document No.":="No.";
                    GenJnLine.Description:=StrSubstNo('Staff Claim from Imprest No: %1', "No.");
                    ImprestHeader.CalcFields("Total Requested Amount");
                    GenJnLine.Amount:=-ImprestHeader."Total Requested Amount";
                    GenJnLine.Validate(GenJnLine.Amount);
                    GenJnLine."External Document No.":="Claim Payment Tx No";
                    GenJnLine."Currency Code":="Currency Code";
                    GenJnLine.Validate(GenJnLine."Currency Code");
                    GenJnLine.Validate(GenJnLine."Shortcut Dimension 1 Code", "Global Dimension 1 Code");
                    GenJnLine.Validate(GenJnLine."Shortcut Dimension 2 Code", "Global Dimension 2 Code");
                    if GenJnLine.Amount <> 0 then GenJnLine.Insert;
                    // Debit Expenses
                    RequestLines.Reset;
                    RequestLines.SetRange("No.", "No.");
                    if RequestLines.FindSet then repeat begin
                            LineNo:=LineNo + 1000;
                            GenJnLine.Init;
                            GenJnLine."Journal Template Name":=GLSetup."Imprest Template";
                            GenJnLine."Journal Batch Name":=GLSetup."Imprest Surrender Batch";
                            GenJnLine."Line No.":=LineNo;
                            if RequestLines.Type = RequestLines.Type::"Fixed Asset" then GenJnLine."Account Type":=GenJnLine."Account Type"::"Fixed Asset"
                            else if RequestLines.Type = RequestLines.Type::"G/L Account" then GenJnLine."Account Type":=GenJnLine."Account Type"::"G/L Account";
                            GenJnLine."Account No.":=RequestLines."Account No";
                            GenJnLine."Posting Date":=WorkDate;
                            GenJnLine."Document No.":="No.";
                            GenJnLine.Description:=RequestLines.Narration;
                            GenJnLine.Amount:=RequestLines."Actual Spent";
                            if("Currency Code" <> '') and ("Currency Code" <> GLSetup."LCY Code")then GenJnLine.Validate("Currency Code", "Currency Code");
                            GenJnLine.Validate(Amount);
                            GenJnLine."Shortcut Dimension 1 Code":="Global Dimension 1 Code";
                            GenJnLine.Validate("Shortcut Dimension 1 Code");
                            GenJnLine."Shortcut Dimension 2 Code":="Global Dimension 2 Code";
                            GenJnLine.Validate("Shortcut Dimension 2 Code");
                            if GenJnLine.Amount <> 0 then GenJnLine.Insert;
                        end;
                        until RequestLines.Next = 0;
                end
                else if Selection = 2 then begin
                        "Transfer To Payroll":=true;
                        Modify(true);
                    end;
            end
            else if "Net Refund (Net Claim)" > 0 then begin
                    Selection:=StrMenu(RefundSelectionString, 1);
                    if Selection = 1 then begin
                        Commit;
                        if PAGE.RunModal(PAGE::"Receive Imprest Refund", ImprestHeader) = ACTION::LookupOK then begin
                        end;
                        Commit;
                        LineNo:=LineNo + 1000;
                        GenJnLine.Init;
                        GenJnLine."Journal Template Name":=GLSetup."Imprest Template";
                        GenJnLine."Journal Batch Name":=GLSetup."Imprest Surrender Batch";
                        GenJnLine."Line No.":=LineNo;
                        GenJnLine."Account Type":=GenJnLine."Account Type"::"Bank Account";
                        GenJnLine."Account No.":="Receiving Account";
                        GenJnLine."Posting Date":=WorkDate;
                        GenJnLine."Document No.":="No.";
                        GenJnLine.Description:=StrSubstNo('Cash receipting from %1 for Imprest refund of Imprest No: %2', "Employee Name", "No.");
                        GenJnLine.Amount:="Net Refund (Net Claim)";
                        GenJnLine.Validate(GenJnLine.Amount);
                        GenJnLine."External Document No.":="Receipt Tx No.(Cheque No.)";
                        GenJnLine."Currency Code":="Currency Code";
                        GenJnLine.Validate(GenJnLine."Currency Code");
                        GenJnLine.Validate(GenJnLine."Shortcut Dimension 1 Code", "Global Dimension 1 Code");
                        GenJnLine.Validate(GenJnLine."Shortcut Dimension 2 Code", "Global Dimension 2 Code");
                        if GenJnLine.Amount <> 0 then GenJnLine.Insert;
                        LineNo:=LineNo + 1000;
                        GenJnLine.Init;
                        GenJnLine."Journal Template Name":=GLSetup."Imprest Template";
                        GenJnLine."Journal Batch Name":=GLSetup."Imprest Surrender Batch";
                        GenJnLine."Line No.":=LineNo;
                        GenJnLine."Account Type":=GenJnLine."Bal. Account Type"::Employee;
                        GenJnLine.Validate("Account No.", Employee."No.");
                        GenJnLine."Posting Date":=WorkDate;
                        GenJnLine."Document No.":="No.";
                        GenJnLine.Description:=StrSubstNo('Cash receipting from %1 for Imprest refund of Imprest No: %2', "Employee Name", "No.");
                        GenJnLine.Amount:=-"Net Refund (Net Claim)";
                        GenJnLine.Validate(GenJnLine.Amount);
                        GenJnLine."External Document No.":="Receipt Tx No.(Cheque No.)";
                        GenJnLine."Currency Code":="Currency Code";
                        GenJnLine.Validate(GenJnLine."Currency Code");
                        GenJnLine.Validate(GenJnLine."Shortcut Dimension 1 Code", "Global Dimension 1 Code");
                        GenJnLine.Validate(GenJnLine."Shortcut Dimension 2 Code", "Global Dimension 2 Code");
                        if GenJnLine.Amount <> 0 then GenJnLine.Insert;
                    end
                    else if Selection = 2 then begin
                            "Transfer To Payroll":=true;
                            Modify(true);
                        end;
                    // Debit Expenses & Credit Customer Account
                    RequestLines.Reset;
                    RequestLines.SetRange("No.", "No.");
                    if RequestLines.Find('-')then repeat begin
                            LineNo:=LineNo + 1000;
                            GenJnLine.Init;
                            GenJnLine."Journal Template Name":=GLSetup."Imprest Template";
                            GenJnLine."Journal Batch Name":=GLSetup."Imprest Surrender Batch";
                            GenJnLine."Line No.":=LineNo;
                            if RequestLines.Type = RequestLines.Type::"Fixed Asset" then GenJnLine."Account Type":=GenJnLine."Account Type"::"Fixed Asset"
                            else if RequestLines.Type = RequestLines.Type::"G/L Account" then GenJnLine."Account Type":=GenJnLine."Account Type"::"G/L Account";
                            GenJnLine."Account No.":=RequestLines."Account No";
                            GenJnLine."Posting Date":=WorkDate;
                            GenJnLine."Document No.":="No.";
                            GenJnLine.Description:=RequestLines.Narration;
                            GenJnLine.Amount:=RequestLines."Actual Spent";
                            if("Currency Code" <> '') and ("Currency Code" <> GLSetup."LCY Code")then GenJnLine.Validate("Currency Code", "Currency Code");
                            GenJnLine.Validate(Amount);
                            GenJnLine."Shortcut Dimension 1 Code":="Global Dimension 1 Code";
                            GenJnLine.Validate("Shortcut Dimension 1 Code");
                            GenJnLine."Shortcut Dimension 2 Code":="Global Dimension 2 Code";
                            GenJnLine.Validate("Shortcut Dimension 2 Code");
                            GenJnLine."Bal. Account Type":=GenJnLine."Bal. Account Type"::Employee;
                            GenJnLine.Validate("Bal. Account No.", Employee."No.");
                            GenJnLine.Validate("Bal. Account No.");
                            if GenJnLine.Amount <> 0 then GenJnLine.Insert;
                        end;
                        until RequestLines.Next = 0;
                end
                else if "Net Refund (Net Claim)" = 0 then begin
                        //Credit Employee
                        LineNo:=LineNo + 1000;
                        GenJnLine.Init;
                        GenJnLine."Journal Template Name":=GLSetup."Imprest Template";
                        GenJnLine."Journal Batch Name":=GLSetup."Imprest Surrender Batch";
                        GenJnLine."Line No.":=LineNo;
                        GenJnLine."Account Type":=GenJnLine."Account Type"::Employee;
                        GenJnLine.Validate("Account No.", Employee."No.");
                        GenJnLine."Posting Date":=WorkDate;
                        GenJnLine."Document No.":="No.";
                        GenJnLine.Description:=StrSubstNo('Staff Claim from Imprest No: %1', "No.");
                        ImprestHeader.CalcFields("Total Surrender Amount");
                        GenJnLine.Amount:=-ImprestHeader."Total Surrender Amount";
                        GenJnLine.Validate(GenJnLine.Amount);
                        GenJnLine."External Document No.":="Claim Payment Tx No";
                        GenJnLine."Currency Code":="Currency Code";
                        GenJnLine.Validate(GenJnLine."Currency Code");
                        GenJnLine.Validate(GenJnLine."Shortcut Dimension 1 Code", "Global Dimension 1 Code");
                        GenJnLine.Validate(GenJnLine."Shortcut Dimension 2 Code", "Global Dimension 2 Code");
                        if GenJnLine.Amount <> 0 then GenJnLine.Insert;
                        // Debit Expenses
                        RequestLines.Reset;
                        RequestLines.SetRange("No.", "No.");
                        if RequestLines.FindSet then repeat begin
                                LineNo:=LineNo + 1000;
                                GenJnLine.Init;
                                GenJnLine."Journal Template Name":=GLSetup."Imprest Template";
                                GenJnLine."Journal Batch Name":=GLSetup."Imprest Surrender Batch";
                                GenJnLine."Line No.":=LineNo;
                                if RequestLines.Type = RequestLines.Type::"Fixed Asset" then GenJnLine."Account Type":=GenJnLine."Account Type"::"Fixed Asset"
                                else if RequestLines.Type = RequestLines.Type::"G/L Account" then GenJnLine."Account Type":=GenJnLine."Account Type"::"G/L Account";
                                GenJnLine."Account No.":=RequestLines."Account No";
                                GenJnLine."Posting Date":=WorkDate;
                                GenJnLine."Document No.":="No.";
                                GenJnLine.Description:=RequestLines.Narration;
                                GenJnLine.Amount:=RequestLines."Actual Spent";
                                if("Currency Code" <> '') and ("Currency Code" <> GLSetup."LCY Code")then GenJnLine.Validate("Currency Code", "Currency Code");
                                GenJnLine.Validate(Amount);
                                GenJnLine."Shortcut Dimension 1 Code":="Global Dimension 1 Code";
                                GenJnLine.Validate("Shortcut Dimension 1 Code");
                                GenJnLine."Shortcut Dimension 2 Code":="Global Dimension 2 Code";
                                GenJnLine.Validate("Shortcut Dimension 2 Code");
                                if GenJnLine.Amount <> 0 then GenJnLine.Insert;
                            end;
                            until RequestLines.Next = 0;
                    end;
            CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post", GenJnLine);
            GLEntry.Reset;
            GLEntry.SetRange(GLEntry."Document No.", "No.");
            GLEntry.SetRange(GLEntry.Reversed, false);
            GLEntry.SetRange("Posting Date", WorkDate);
            GLEntry.SetRange("Journal Batch Name", GLSetup."Imprest Surrender Batch");
            if GLEntry.FindFirst then begin
                Surrendered:=true;
                "Surrender Posted By":=UserId;
                "Surrender Posted Date":=WorkDate;
                Status:=Status::Closed;
                Modify;
            end;
        end;
    end;
    procedure PostStaffClaim(var RequestHeader: Record "Request Header"; Hidedialog: Boolean)
    var
        Type: Option Payment, Deduction, "Saving Scheme", Loan, Informational;
        ClaimAmount: Decimal;
        BankLedger: Record "Bank Account Ledger Entry";
        VendorLedger: Record "Vendor Ledger Entry";
        CompanyFacilitation: Decimal;
        SelfFacilitation: Decimal;
    begin
        with RequestHeader do begin
            if "Claim Posted" then Error(Text017);
            if "Request Type" <> "Request Type"::"Staff Claim" then Error(Text019);
            if Committed then Budgetmgmt.UnCommitImprest("No.");
            Employee.Get("Employee No.");
            TestField("Claim Pay Mode");
            CalcFields("Total Surrender Amount");
            PaymentMethods.Get("Claim Pay Mode");
            GLSetup.Get();
            GLSetup.TestField("Claims Template");
            GLSetup.TestField("Claims Batch");
            // Delete Lines Present on the General Journal Line
            GenJnLine.Reset;
            GenJnLine.SetRange(GenJnLine."Journal Template Name", GLSetup."Claims Template");
            GenJnLine.SetRange(GenJnLine."Journal Batch Name", GLSetup."Claims Batch");
            GenJnLine.DeleteAll;
            Batch.Init;
            Batch."Journal Template Name":=GLSetup."Claims Template";
            Batch.Name:=GLSetup."Claims Batch";
            if not Batch.Get(Batch."Journal Template Name", Batch.Name)then Batch.Insert;
            LineNo:=10000;
            //Debit Advance Customer
            GenJnLine.Init;
            GenJnLine."Journal Template Name":=GLSetup."Claims Template";
            GenJnLine."Journal Batch Name":=GLSetup."Claims Batch";
            GenJnLine."Line No.":=333333;
            GenJnLine."Account Type":=GenJnLine."Account Type"::Employee;
            GenJnLine.Validate("Account No.", Employee."No.");
            GenJnLine."Posting Date":=WorkDate;
            GenJnLine."Document No.":="No.";
            GenJnLine."External Document No.":="Claim Payment Tx No";
            GenJnLine.Description:=CopyStr(Description, 1, 50);
            if("Currency Code" <> '') and ("Currency Code" <> GLSetup."LCY Code")then GenJnLine.Validate("Currency Code", "Currency Code");
            GenJnLine.Amount:="Total Surrender Amount";
            GenJnLine.Validate(Amount);
            GenJnLine."Shortcut Dimension 1 Code":="Global Dimension 1 Code";
            GenJnLine.Validate("Shortcut Dimension 1 Code");
            GenJnLine."Shortcut Dimension 2 Code":="Global Dimension 2 Code";
            GenJnLine.Validate("Shortcut Dimension 2 Code");
            if GenJnLine.Amount <> 0 then GenJnLine.Insert; //Credit FOSA Or Bank Account
            GenJnLine.Init;
            GenJnLine."Journal Template Name":=GLSetup."Claims Template";
            GenJnLine."Journal Batch Name":=GLSetup."Claims Batch";
            GenJnLine."Line No.":=303030;
            TestField("Claim Paying Account");
            GenJnLine."Account Type":=GenJnLine."Account Type"::"Bank Account";
            GenJnLine."Account No.":="Claim Paying Account";
            GenJnLine."Posting Date":=WorkDate;
            GenJnLine."Document No.":="No.";
            GenJnLine."External Document No.":="Claim Payment Tx No";
            GenJnLine.Description:=CopyStr(Description, 1, 50);
            if("Currency Code" <> '') and ("Currency Code" <> GLSetup."LCY Code")then GenJnLine.Validate("Currency Code", "Currency Code");
            GenJnLine.Amount:=-"Total Surrender Amount";
            GenJnLine.Validate(Amount);
            GenJnLine."Shortcut Dimension 1 Code":="Global Dimension 1 Code";
            GenJnLine.Validate("Shortcut Dimension 1 Code");
            GenJnLine."Shortcut Dimension 2 Code":="Global Dimension 2 Code";
            GenJnLine.Validate("Shortcut Dimension 2 Code");
            if GenJnLine.Amount <> 0 then GenJnLine.Insert;
            //Debit Claims Line Expenses
            RequestLines.Reset();
            RequestLines.SetRange("No.", "No.");
            If RequestLines.FindSet()then repeat begin
                    LineNo+=1000;
                    GenJnLine.Init;
                    GenJnLine."Journal Template Name":=GLSetup."Claims Template";
                    GenJnLine."Journal Batch Name":=GLSetup."Claims Batch";
                    GenJnLine."Line No.":=LineNo;
                    GenJnLine."Account Type":=GenJnLine."Account Type"::"G/L Account";
                    GenJnLine."Account No.":=RequestLines."Account No";
                    GenJnLine."Posting Date":=WorkDate;
                    GenJnLine."Document No.":="No.";
                    GenJnLine."External Document No.":="Claim Payment Tx No";
                    GenJnLine.Description:=CopyStr(RequestLines.Narration, 1, 50);
                    if("Currency Code" <> '') and ("Currency Code" <> GLSetup."LCY Code")then GenJnLine.Validate("Currency Code", "Currency Code");
                    GenJnLine.Amount:=RequestLines."Actual Spent";
                    GenJnLine.Validate(Amount);
                    GenJnLine."Shortcut Dimension 1 Code":="Global Dimension 1 Code";
                    GenJnLine.Validate("Shortcut Dimension 1 Code");
                    GenJnLine."Shortcut Dimension 2 Code":="Global Dimension 2 Code";
                    GenJnLine.Validate("Shortcut Dimension 2 Code");
                    if GenJnLine.Amount <> 0 then GenJnLine.Insert;
                end;
                Until RequestLines.Next() = 0;
            //Credit Employee
            LineNo:=LineNo + 1000;
            GenJnLine.Init;
            GenJnLine."Journal Template Name":=GLSetup."Claims Template";
            GenJnLine."Journal Batch Name":=GLSetup."Claims Batch";
            GenJnLine."Line No.":=LineNo;
            GenJnLine."Account Type":=GenJnLine."Account Type"::Employee;
            GenJnLine.Validate("Account No.", Employee."No.");
            GenJnLine."Posting Date":=WorkDate;
            GenJnLine."Document No.":="No.";
            GenJnLine."External Document No.":="Claim Payment Tx No";
            GenJnLine.Description:=CopyStr(Description, 1, 50);
            if("Currency Code" <> '') and ("Currency Code" <> GLSetup."LCY Code")then GenJnLine.Validate("Currency Code", "Currency Code");
            GenJnLine.Amount:=-"Total Surrender Amount";
            GenJnLine."Shortcut Dimension 1 Code":="Global Dimension 1 Code";
            GenJnLine.Validate("Shortcut Dimension 1 Code");
            GenJnLine."Shortcut Dimension 2 Code":="Global Dimension 2 Code";
            GenJnLine.Validate("Shortcut Dimension 2 Code");
            if GenJnLine.Amount <> 0 then GenJnLine.Insert;
            if HideDialog then CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post Ext", GenJnLine)
            else
                CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post", GenJnLine);
            VendorLedger.Reset;
            VendorLedger.SetCurrentKey(VendorLedger."Document No.", VendorLedger."Posting Date");
            VendorLedger.SetRange(VendorLedger."Document No.", "No.");
            if VendorLedger.Find('-')then begin
                Posted:=true;
                "Posted By":=UserId;
                "Posted Date":=WorkDate;
                "Claim Posted":=true;
                "Claim Posted By":=UserId;
                "Claim Posted Date":=WorkDate;
                Modify;
            end
            else
            begin
                BankLedger.Reset;
                BankLedger.SetCurrentKey(BankLedger."Document No.", BankLedger."Posting Date");
                BankLedger.SetRange(BankLedger."Document No.", "No.");
                if BankLedger.Find('-')then begin
                    Posted:=true;
                    "Posted By":=UserId;
                    "Posted Date":=WorkDate;
                    "Claim Posted":=true;
                    "Claim Posted By":=UserId;
                    "Claim Posted Date":=WorkDate;
                    Modify;
                end;
            end;
        end;
    end;
    procedure PostStaffSalaryAdvance(RequestHeader: Record "Request Header")
    var
        VendorLedger: Record "Vendor Ledger Entry";
        BankLedger: Record "Bank Account Ledger Entry";
    begin
        with RequestHeader do begin
            if Posted then Error(Text017);
            if "Request Type" <> "Request Type"::"Salary Advance" then Error(Text020);
            if Committed then Budgetmgmt.UnCommitImprest("No.");
            Employee.Get("Employee No.");
            PaymentMethods.Get("Claim Pay Mode");
            TestField("Claim Pay Mode");
            CalcFields("Total Surrender Amount");
            GLSetup.Get();
            GLSetup.TestField("Claims Template");
            GLSetup.TestField("Claims Batch");
            // Delete Lines Present on the General Journal Line
            GenJnLine.Reset;
            GenJnLine.SetRange(GenJnLine."Journal Template Name", GLSetup."Claims Template");
            GenJnLine.SetRange(GenJnLine."Journal Batch Name", GLSetup."Claims Batch");
            GenJnLine.DeleteAll;
            Batch.Init;
            Batch."Journal Template Name":=GLSetup."Claims Template";
            Batch.Name:=GLSetup."Claims Batch";
            if not Batch.Get(Batch."Journal Template Name", Batch.Name)then Batch.Insert;
            //Debit Advance Customer
            GenJnLine.Init;
            GenJnLine."Journal Template Name":=GLSetup."Claims Template";
            GenJnLine."Journal Batch Name":=GLSetup."Claims Batch";
            GenJnLine."Line No.":=333333;
            GenJnLine."Account Type":=GenJnLine."Account Type"::Employee;
            GenJnLine.Validate("Account No.", Employee."No.");
            GenJnLine."Posting Date":=WorkDate;
            GenJnLine."Document No.":="No.";
            GenJnLine."External Document No.":="Claim Payment Tx No";
            GenJnLine.Description:=CopyStr(Description, 1, 50);
            if("Currency Code" <> '') and ("Currency Code" <> GLSetup."LCY Code")then GenJnLine.Validate("Currency Code", "Currency Code");
            GenJnLine.Amount:="Amount Requested";
            GenJnLine.Validate(Amount);
            GenJnLine."Shortcut Dimension 1 Code":="Global Dimension 1 Code";
            GenJnLine.Validate("Shortcut Dimension 1 Code");
            GenJnLine."Shortcut Dimension 2 Code":="Global Dimension 2 Code";
            GenJnLine.Validate("Shortcut Dimension 2 Code");
            if GenJnLine.Amount <> 0 then GenJnLine.Insert;
            //Credit Bank Or FOSA Account
            GenJnLine.Init;
            GenJnLine."Journal Template Name":=GLSetup."Claims Template";
            GenJnLine."Journal Batch Name":=GLSetup."Claims Batch";
            GenJnLine."Line No.":=444444;
            TestField("Claim Paying Account");
            GenJnLine."Account Type":=GenJnLine."Account Type"::"Bank Account";
            GenJnLine."Account No.":="Claim Paying Account";
            GenJnLine."Posting Date":=WorkDate;
            GenJnLine."Document No.":="No.";
            GenJnLine."External Document No.":="Claim Payment Tx No";
            GenJnLine.Description:=CopyStr(Description, 1, 50);
            if("Currency Code" <> '') and ("Currency Code" <> GLSetup."LCY Code")then GenJnLine.Validate("Currency Code", "Currency Code");
            GenJnLine.Amount:=-"Amount Requested";
            GenJnLine.Validate(Amount);
            GenJnLine."Shortcut Dimension 1 Code":="Global Dimension 1 Code";
            GenJnLine.Validate("Shortcut Dimension 1 Code");
            GenJnLine."Shortcut Dimension 2 Code":="Global Dimension 2 Code";
            GenJnLine.Validate("Shortcut Dimension 2 Code");
            if GenJnLine.Amount <> 0 then GenJnLine.Insert;
            CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post", GenJnLine);
            VendorLedger.Reset;
            VendorLedger.SetCurrentKey(VendorLedger."Document No.", VendorLedger."Posting Date");
            VendorLedger.SetRange(VendorLedger."Document No.", "No.");
            if VendorLedger.Find('-')then begin
                Posted:=true;
                "Posted By":=UserId;
                "Posted Date":=WorkDate;
                "Claim Posted":=true;
                "Claim Posted By":=UserId;
                "Claim Posted Date":=WorkDate;
                "To Recover From Payroll":=true;
                Modify;
            end
            else
            begin
                BankLedger.Reset;
                BankLedger.SetCurrentKey(BankLedger."Document No.", BankLedger."Posting Date");
                BankLedger.SetRange(BankLedger."Document No.", "No.");
                if BankLedger.Find('-')then begin
                    Posted:=true;
                    "Posted By":=UserId;
                    "Posted Date":=WorkDate;
                    "Claim Posted":=true;
                    "Claim Posted By":=UserId;
                    "Claim Posted Date":=WorkDate;
                    "To Recover From Payroll":=true;
                    Modify;
                end;
            end;
        end;
    end;
    procedure CheckForCashAvailability(var Header: Record "Request Header")
    begin
        if((Header."Request Type" = Header."Request Type"::Imprest) and (Header."Request Type" <> Header."Request Type"::"Staff Claim"))then begin
            if Header."Paying Bank Code" = '' then Error('The Paying Bank Code has not been specified!');
            if BankAccount.Get(Header."Paying Bank Code")then begin
                BankAccount.CalcFields(Balance);
                Header.CalcFields("Request Amount");
                if(BankAccount.Balance - Header."Request Amount") < BankAccount."Minimum Float" then Error('There is no sufficient cash for your request of %1 KSH, you can only request for the %2 KSH available.', Header."Request Amount", BankAccount.Balance - BankAccount."Minimum Float");
            end;
        end
        else if((Header."Request Type" = Header."Request Type"::Surrender) and (Header."Request Type" = Header."Request Type"::"Staff Claim"))then begin
                if Header."Paying Bank Code" = '' then Error('The Paying Bank Code has not been specified!');
                if BankAccount.Get(Header."Paying Bank Code")then begin
                    BankAccount.CalcFields(Balance);
                    Header.CalcFields("Total Surrender Amount");
                    if(BankAccount.Balance - Header."Request Amount") < BankAccount."Minimum Float" then Error('There is no sufficient cash for your request of %1 KSH, you can only request for the %2 KSH available.', Header."Total Surrender Amount", BankAccount.Balance - BankAccount."Minimum Float");
                end;
            end;
    end;
    procedure SubmitCashSurrender(var Surrender: Record "Request Header")
    begin
        Surrender.CalcFields("Total Surrender Amount");
        Surrender.TestField("Total Surrender Amount");
        if Confirm(StrSubstNo(Text018, Surrender."No."), true) = true then begin
            Surrender.Validate(Status, Surrender.Status::Approved);
            Surrender."Surrender Date":=WorkDate;
            Surrender.Modify(true);
        end
        else
        begin
            exit;
        end;
    end;
    procedure RejectCashSurrender(var Surrender: Record "Request Header")
    begin
        Surrender.Validate(Status, Surrender.Status::Open);
        Surrender.Modify(true);
    end;
    procedure LoopThroughImprestToTransferToPayroll()
    var
        RequestHeader: Record "Request Header";
        PayrollSetup: Record "Payroll Vital Setup";
        PostingDay: Integer;
        CutOffDay: Integer;
    begin
        PayrollSetup.Get;
        RequestHeader.Reset;
        RequestHeader.SetFilter("Request Type", '=%1|=%2|=%3', RequestHeader."Request Type"::Imprest, RequestHeader."Request Type"::"Salary Advance", RequestHeader."Request Type"::"Staff Claim");
        RequestHeader.SetRange(Status, RequestHeader.Status::Approved);
        RequestHeader.SetFilter("Posted Date", '<>%1', 0D);
        //RequestHeader.SetRange("Transfer To Payroll", true);
        RequestHeader.SetRange("Transfered To Payroll", false);
        if RequestHeader.FindSet then repeat PostingDay:=Date2DMY(RequestHeader."Posted Date", 1);
                CutOffDay:=Date2DMY(PayrollSetup."Payroll Cut off Date", 1);
                TransferUnsurrenderedImprestToPayroll(RequestHeader);
            until RequestHeader.Next = 0;
    end;
    procedure TransferUnsurrenderedImprestToPayroll(RequestHeader: Record "Request Header")
    var
        PayrollPeriods: Record "Payroll Periods";
        PayrollEmployeeTransaction: Record "Payroll Employee Transaction";
        SelectedPeriod: Date;
        PayrollTransactionCode: Record "Payroll Transaction Code";
    begin
        with RequestHeader do begin
            PayrollPeriods.Reset;
            PayrollPeriods.SetRange(Closed, false);
            if PayrollPeriods.FindFirst then SelectedPeriod:=PayrollPeriods."Start Date";
            CalcFields("Request Amount");
            PayrollTransactionCode.Reset;
            if RequestHeader."Request Type" in[RequestHeader."Request Type"::"Salary Advance"]then PayrollTransactionCode.SetRange("Special Transactions", PayrollTransactionCode."Special Transactions"::"Salary Adv Recovery");
            if RequestHeader."Request Type" in[RequestHeader."Request Type"::Imprest]then PayrollTransactionCode.SetRange("Special Transactions", PayrollTransactionCode."Special Transactions"::"Imprest Recovery");
            if((RequestHeader."Request Type" = RequestHeader."Request Type"::"Staff Claim"))then PayrollTransactionCode.SetRange(Type, PayrollTransactionCode."Special Transactions"::Laptop);
            if PayrollTransactionCode.FindFirst then begin
                PayrollEmployeeTransaction.Init;
                PayrollEmployeeTransaction.Validate("Employee Code", "Employee No.");
                PayrollEmployeeTransaction.Validate("Payroll Period", SelectedPeriod);
                PayrollEmployeeTransaction."Period Month":=PayrollPeriods."Period Month";
                PayrollEmployeeTransaction."Period Year":=PayrollPeriods."Period Year";
                PayrollEmployeeTransaction.Validate("Transaction Code", PayrollTransactionCode.Code);
                if RequestHeader."Request Type" in[RequestHeader."Request Type"::Imprest]then begin
                    PayrollEmployeeTransaction.Amount:=RequestHeader."Request Amount";
                    PayrollEmployeeTransaction.Validate(Balance, RequestHeader."Request Amount");
                end;
                if((RequestHeader."Request Type" in[RequestHeader."Request Type"::"Salary Advance"]) OR ((RequestHeader."Request Type" in[RequestHeader."Request Type"::"Staff Claim"])))then begin
                    PayrollEmployeeTransaction.Amount:="Amount Requested" / "Repayment Period";
                    PayrollEmployeeTransaction.Balance:="Amount Requested";
                    PayrollEmployeeTransaction.Validate(Balance);
                    PayrollEmployeeTransaction."No Of Periods":=RequestHeader."Repayment Period";
                end;
                PayrollEmployeeTransaction."Imprest No":="No.";
                if not PayrollEmployeeTransaction.Get(RequestHeader."Employee No.", PayrollTransactionCode.Code, PayrollPeriods."Start Date", PayrollPeriods."Period Month", PayrollPeriods."Period Year")then if PayrollEmployeeTransaction.Insert then begin
                        "Transfered To Payroll":=true;
                        Modify(true);
                    end
                    else
                    begin
                        if PayrollEmployeeTransaction.Get(RequestHeader."Employee No.", PayrollTransactionCode.Code, PayrollPeriods."Start Date", PayrollPeriods."Period Month", PayrollPeriods."Period Year")then payrollemployeetransaction.amount+="Amount requested" / "Repayment Period";
                        payrollemployeetransaction.modify;
                        "Transfered To Payroll":=true;
                        Modify(true);
                    end;
            end;
        end;
    end;
}

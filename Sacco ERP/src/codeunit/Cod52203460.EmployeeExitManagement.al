codeunit 52203460 "Employee Exit Management"
{
    var PayrollPeriod: Record "Payroll Periods";
    PayrollEmployeeTransaction: Record "Payroll Employee Transaction";
    PayrollEmployeeTransaction_Check: Record "Payroll Employee Transaction";
    PayrollTransactionCode: Record "Payroll Transaction Code";
    FinalDuesCalculation: Record "Final Dues Calculation";
    FinalDuesCalculation_UnclearedItems: Record "Final Dues Calculation";
    ExitClearanceForm: Record "Exit Clearance Form";
    TotalUncleared: Decimal;
    CommunicationsMgmt: Codeunit "Communications Mgmt";
    procedure GenerateClearanceForm(var EmployeeExit: Record "Employee Exit"): Code[20]var
        ExitClearanceForm: Record "Exit Clearance Form";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        HumanResourcesSetup: Record "Human Resources Setup";
        ExitClearanceFormLines: Record "Exit Clearance Form Lines";
        FormNo: Code[20];
        StaffClearanceSetup: Record "Exit Clearance Setup";
        MiscArticleInformation: Record "Misc. Article Information";
    begin
        HumanResourcesSetup.Get;
        HumanResourcesSetup.TestField("Exit Form Nos.");
        //ERROR('Here');  
        ExitClearanceForm.Reset;
        ExitClearanceForm.SetRange("Exit No", EmployeeExit."No.");
        if ExitClearanceForm.FindFirst then Error('Employee clearance form no. %1 has already been generated', ExitClearanceForm."Form No");
        ExitClearanceForm.Init;
        FormNo:=NoSeriesManagement.GetNextNo(HumanResourcesSetup."Exit Form Nos.", 0D, true);
        ExitClearanceForm."Form No":=FormNo;
        ExitClearanceForm."Exit No":=EmployeeExit."No.";
        ExitClearanceForm."Employee No":=EmployeeExit."Employee No";
        ExitClearanceForm."Employee Name":=EmployeeExit."Employee Name";
        ExitClearanceForm."Global Dimension 1 Code":=EmployeeExit."Global Dimension 1 Code";
        ExitClearanceForm."Global Dimension 2 Code":=EmployeeExit."Global Dimension 2 Code";
        ExitClearanceForm."Global Dimension 3 Code":=EmployeeExit."Global Dimension 3 Code";
        ExitClearanceForm."Global Dimension 4 Code":=EmployeeExit."Global Dimension 4 Code";
        ExitClearanceForm.Insert;
        exit(FormNo);
    end;
    [Scope('Cloud')]
    procedure SendExitClearanceFormToSections(ExitNo: Code[20]; FormNo: Code[20]; SendEmail: Boolean; ApprovalURL: Text): Boolean var
        ExitForm: Record "Exit Clearance Form";
        SenderName: Text;
        SenderAddress: Text;
        Recipients: List of[Text];
        Body: Text;
        Subject: Text;
        UserSetup: Record "User Setup";
        StaffClearanceSetup: Record "Exit Clearance Setup";
        Employee: Record Employee;
        HumanResourceMgmt: Codeunit "Human Resource Management";
        ClearanceSection: Record "Clearance Sections";
    begin
        if ExitForm.Get(FormNo)then begin
            StaffClearanceSetup.Reset();
            StaffClearanceSetup.SetCurrentKey("Employee No", Sequence);
            if StaffClearanceSetup.FindSet()then begin
                repeat if ExitForm.Modify(true)then begin
                        if SendEmail then begin
                            if Employee.Get(StaffClearanceSetup."Employee No")then begin
                                Clear(Recipients);
                                Recipients.Add(Employee."Company E-Mail");
                                if ClearanceSection.Get(StaffClearanceSetup.Section)then;
                                Subject:=StrSubstNo('%1 (%2) Clearance Form', Employee.FullName, Employee."No.");
                                Body:='';
                                Body+='Dear ' + Employee.FullName;
                                Body+=' <br><br>';
                                Body+=Format(ExitForm."Employee Name") + ' has sent their clearance form to ' + ClearanceSection.Name + ' for clearance. <br>Kindly follow the Link below to clear:';
                                Body+='<br><br>';
                                Body+=Format(ApprovalURL);
                                Body+=' <br><br>';
                                Body+='This is a system generated E-mail, do not reply to it';
                                Body+='<br><br>';
                                Body+='Kind Regards';
                                CommunicationsMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                            end;
                        end;
                    end;
                until StaffClearanceSetup.Next = 0;
            end;
        end;
    end;
    [Scope('Cloud')]
    procedure ClearSection(ExitNo: Code[20]; FormNo: Code[20]; SendEmail: Boolean; ApprovalURL: Text)
    var
        ExitForm: Record "Exit Clearance Form";
        ClearanceLines: Record "Exit Clearance Form Lines";
        ClearanceSection: Record "Clearance Sections";
        FinalDueCalculation: Record "Final Dues Calculation";
        SenderName: Text;
        SenderAddress: Text;
        Recipients: List of[Text];
        Body: Text;
        Subject: Text;
        UserSetup: Record "User Setup";
        Employee: Record Employee;
        HumanResourceMgmt: Codeunit "Human Resource Management";
        EmployeeCopy: Record Employee;
        LineNo: Integer;
        ClearanceStatus: Text[20];
        UnclearedItems: Boolean;
    begin
        UnclearedItems:=false;
        if ExitForm.Get(FormNo)then begin
            if SendEmail then begin
                if Employee.Get(ExitForm."Employee No")then begin
                    Clear(Recipients);
                    Recipients.Add(Employee."E-Mail");
                    Subject:='Clearance Form';
                    Body:='';
                    Body+='Dear ' + Employee.FullName;
                    Body+=' <br><br>';
                    Body+='HR has closed your clearance form for all Section Items as listed  below:';
                    ClearanceLines.Reset;
                    ClearanceLines.SetCurrentKey("Clearance Section");
                    ClearanceLines.Ascending;
                    ClearanceLines.SetRange("Exit No", ExitForm."Exit No");
                    ClearanceLines.SetRange("Employee No", ExitForm."Employee No");
                    if ClearanceLines.FindSet then begin
                        repeat if ClearanceSection.Get(ClearanceLines."Clearance Section")then;
                            if ClearanceLines.Status = ClearanceLines.Status::Uncleared then begin
                                UnclearedItems:=true;
                                ClearanceStatus:='Unleared';
                                FinalDueCalculation.Init;
                                FinalDueCalculation."Employee No.":=ExitForm."Employee No";
                                FinalDueCalculation."Exit No":=ExitForm."Exit No";
                                FinalDueCalculation."Line No":=LastFinalDueCalculation_LineNo;
                                FinalDueCalculation.Description:=StrSubstNo('%1 (%2)', ClearanceLines."Clearance Item", ClearanceSection.Name);
                                FinalDueCalculation.Type:=FinalDueCalculation.Type::"Uncleared Items";
                                FinalDueCalculation."Amount To Pay":=ClearanceLines.Amount;
                                FinalDueCalculation.Amount:=ClearanceLines.Amount;
                                FinalDueCalculation.Insert(true);
                            end
                            else
                                ClearanceStatus:='Cleared';
                            LineNo:=LineNo + 1;
                            Body+='<br><br>';
                            Body+=StrSubstNo('%1: %2 (%3),  Status:<b>%4</b>', Format(LineNo), ClearanceLines."Clearance Item", ClearanceSection.Name, ClearanceStatus);
                        until ClearanceLines.Next = 0;
                    end;
                    Body+='<br><br>';
                    if UnclearedItems then begin
                        Body+='The uncleared items will be recovered from the final dues payment.';
                        Body+='<br><br>';
                    end;
                    Body+='This is a system generated E-mail, do not reply to it<br> Kind Regards';
                    CommunicationsMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                end;
            end;
            ExitForm.Validate(Cleared, true);
            ExitForm.Modify(true);
            if Employee.Get(ExitForm."Employee No")then begin
                Employee."Employee Status":=Employee."Employee Status"::"Pending Final Payment";
                Employee.Modify(true);
            end;
            Message(StrSubstNo('Clearance for %1 was successful and Employee Status updated to Pending Final Payment', ExitForm."Employee Name"));
        end;
    end;
    procedure TransferToPayrollFinalDueCalsulations(EmployeeExit: Record "Employee Exit")
    var
        TotalUnClearedAmount: Decimal;
    begin
        with EmployeeExit do begin
            PayrollPeriod.Reset;
            PayrollPeriod.SetRange(Status, PayrollPeriod.Status::Open);
            PayrollPeriod.SetRange(Closed, false);
            if PayrollPeriod.FindFirst then;
            FinalDuesCalculation_UnclearedItems.Reset;
            FinalDuesCalculation_UnclearedItems.SetRange("Employee No.", "Employee No");
            FinalDuesCalculation_UnclearedItems.SetRange("Exit No", "No.");
            FinalDuesCalculation_UnclearedItems.SetRange("Include in Payment", true);
            FinalDuesCalculation_UnclearedItems.SetRange(Type, FinalDuesCalculation.Type::"Uncleared Items");
            if FinalDuesCalculation_UnclearedItems.FindSet()then begin
                FinalDuesCalculation_UnclearedItems.CalcSums("Amount To Pay");
                TotalUnClearedAmount:=FinalDuesCalculation_UnclearedItems."Amount To Pay";
                if TotalUnClearedAmount <> 0 then begin
                    PayrollTransactionCode.Reset;
                    PayrollTransactionCode.SetRange("Special Transactions", PayrollTransactionCode."Special Transactions"::"Uncleared Items");
                    if PayrollTransactionCode.FindFirst then begin
                        PayrollEmployeeTransaction.Init;
                        PayrollEmployeeTransaction.Validate("Employee Code", "Employee No");
                        PayrollEmployeeTransaction.Validate("Transaction Code", PayrollTransactionCode.Code);
                        PayrollEmployeeTransaction."Payroll Period":=PayrollPeriod."Start Date";
                        PayrollEmployeeTransaction."Period Month":=PayrollPeriod."Period Month";
                        PayrollEmployeeTransaction."Period Year":=PayrollPeriod."Period Year";
                        PayrollEmployeeTransaction.Validate(Amount, TotalUnClearedAmount);
                        if not PayrollEmployeeTransaction_Check.Get("Employee No", PayrollTransactionCode.Code, PayrollPeriod."Start Date", PayrollPeriod."Period Month", PayrollPeriod."Period Year")then PayrollEmployeeTransaction.Insert(true)
                        else
                        begin
                            PayrollEmployeeTransaction_Check.Validate(Amount, TotalUnClearedAmount);
                            PayrollEmployeeTransaction_Check.Modify;
                        end;
                        Commit;
                    end;
                end;
            end;
            FinalDuesCalculation.Reset;
            FinalDuesCalculation.SetRange("Employee No.", "Employee No");
            FinalDuesCalculation.SetRange("Exit No", "No.");
            FinalDuesCalculation.SetRange("Include in Payment", true);
            FinalDuesCalculation.SetFilter(Type, '<>%1', FinalDuesCalculation.Type::"Uncleared Items");
            if FinalDuesCalculation.FindSet then begin
                repeat if FinalDuesCalculation.Type = FinalDuesCalculation.Type::"Leave Encashment" then begin
                        PayrollTransactionCode.Reset;
                        PayrollTransactionCode.SetRange("Special Transactions", PayrollTransactionCode."Special Transactions"::"Leave Encashment");
                        if PayrollTransactionCode.FindFirst then begin
                            PayrollEmployeeTransaction.Init;
                            PayrollEmployeeTransaction.Validate("Employee Code", "Employee No");
                            PayrollEmployeeTransaction.Validate("Transaction Code", PayrollTransactionCode.Code);
                            PayrollEmployeeTransaction."Payroll Period":=PayrollPeriod."Start Date";
                            PayrollEmployeeTransaction."Period Month":=PayrollPeriod."Period Month";
                            PayrollEmployeeTransaction."Period Year":=PayrollPeriod."Period Year";
                            PayrollEmployeeTransaction.Validate(Amount, FinalDuesCalculation."Amount To Pay");
                            if not PayrollEmployeeTransaction_Check.Get("Employee No", PayrollTransactionCode.Code, PayrollPeriod."Start Date", PayrollPeriod."Period Month", PayrollPeriod."Period Year")then PayrollEmployeeTransaction.Insert(true)
                            else
                            begin
                                PayrollEmployeeTransaction_Check.Validate(Amount, FinalDuesCalculation."Amount To Pay");
                                PayrollEmployeeTransaction_Check.Modify;
                            end;
                            Commit;
                        end;
                    end;
                    if FinalDuesCalculation.Type = FinalDuesCalculation.Type::Gratuity then begin
                        PayrollTransactionCode.Reset;
                        PayrollTransactionCode.SetRange("Special Transactions", PayrollTransactionCode."Special Transactions"::Gratuity);
                        if PayrollTransactionCode.FindFirst then begin
                            PayrollEmployeeTransaction.Init;
                            PayrollEmployeeTransaction.Validate("Employee Code", "Employee No");
                            PayrollEmployeeTransaction.Validate("Transaction Code", PayrollTransactionCode.Code);
                            PayrollEmployeeTransaction."Payroll Period":=PayrollPeriod."Start Date";
                            PayrollEmployeeTransaction."Period Month":=PayrollPeriod."Period Month";
                            PayrollEmployeeTransaction."Period Year":=PayrollPeriod."Period Year";
                            PayrollEmployeeTransaction.Validate(Amount, FinalDuesCalculation."Amount To Pay");
                            if not PayrollEmployeeTransaction_Check.Get("Employee No", PayrollTransactionCode.Code, PayrollPeriod."Start Date", PayrollPeriod."Period Month", PayrollPeriod."Period Year")then PayrollEmployeeTransaction.Insert(true)
                            else
                            begin
                                PayrollEmployeeTransaction_Check.Validate(Amount, FinalDuesCalculation."Amount To Pay");
                                PayrollEmployeeTransaction_Check.Modify;
                            end;
                            Commit;
                        end;
                    end;
                    if FinalDuesCalculation.Type = FinalDuesCalculation.Type::"Notice Income" then begin
                        PayrollTransactionCode.Reset;
                        PayrollTransactionCode.SetRange("Special Transactions", PayrollTransactionCode."Special Transactions"::"Final Payment(Income)");
                        if PayrollTransactionCode.FindFirst then begin
                            PayrollEmployeeTransaction.Init;
                            PayrollEmployeeTransaction.Validate("Employee Code", "Employee No");
                            PayrollEmployeeTransaction.Validate("Transaction Code", PayrollTransactionCode.Code);
                            PayrollEmployeeTransaction."Payroll Period":=PayrollPeriod."Start Date";
                            PayrollEmployeeTransaction."Period Month":=PayrollPeriod."Period Month";
                            PayrollEmployeeTransaction."Period Year":=PayrollPeriod."Period Year";
                            PayrollEmployeeTransaction.Validate(Amount, FinalDuesCalculation."Amount To Pay");
                            if not PayrollEmployeeTransaction_Check.Get("Employee No", PayrollTransactionCode.Code, PayrollPeriod."Start Date", PayrollPeriod."Period Month", PayrollPeriod."Period Year")then PayrollEmployeeTransaction.Insert(true)
                            else
                            begin
                                PayrollEmployeeTransaction_Check.Validate(Amount, FinalDuesCalculation."Amount To Pay");
                                PayrollEmployeeTransaction_Check.Modify;
                            end;
                            Commit;
                        end;
                    end;
                    if FinalDuesCalculation.Type = FinalDuesCalculation.Type::"Notice Penalty" then begin
                        PayrollTransactionCode.Reset;
                        PayrollTransactionCode.SetRange("Special Transactions", PayrollTransactionCode."Special Transactions"::"Final Payment");
                        if PayrollTransactionCode.FindFirst then begin
                            PayrollEmployeeTransaction.Init;
                            PayrollEmployeeTransaction.Validate("Employee Code", "Employee No");
                            PayrollEmployeeTransaction.Validate("Transaction Code", PayrollTransactionCode.Code);
                            PayrollEmployeeTransaction."Payroll Period":=PayrollPeriod."Start Date";
                            PayrollEmployeeTransaction."Period Month":=PayrollPeriod."Period Month";
                            PayrollEmployeeTransaction."Period Year":=PayrollPeriod."Period Year";
                            PayrollEmployeeTransaction.Validate(Amount, FinalDuesCalculation."Amount To Pay");
                            if not PayrollEmployeeTransaction_Check.Get("Employee No", PayrollTransactionCode.Code, PayrollPeriod."Start Date", PayrollPeriod."Period Month", PayrollPeriod."Period Year")then PayrollEmployeeTransaction.Insert(true)
                            else
                            begin
                                PayrollEmployeeTransaction_Check.Validate(Amount, FinalDuesCalculation."Amount To Pay");
                                PayrollEmployeeTransaction_Check.Modify;
                            end;
                            Commit;
                        end;
                    end;
                until FinalDuesCalculation.Next = 0;
            end;
            Message(StrSubstNo('Exit Form for %1 Final Dues have been transferred to Payroll', "Employee Name"));
        end;
    end;
    [Scope('Cloud')]
    procedure GenenerateClearanceFormPortal(ExitNo: Code[20]): Code[50]var
        EmployeeExitVar: Record "Employee Exit";
    begin
        if EmployeeExitVar.Get(ExitNo)then begin
            exit(GenerateClearanceForm(EmployeeExitVar));
        end;
    end;
    local procedure LastFinalDueCalculation_LineNo(): Integer var
        FinalDueCalculation: Record "Final Dues Calculation";
    begin
        FinalDueCalculation.Reset;
        FinalDueCalculation.SetCurrentKey("Line No");
        FinalDueCalculation.Ascending;
        if FinalDueCalculation.FindLast then exit(FinalDueCalculation."Line No" + 1);
    end;
}

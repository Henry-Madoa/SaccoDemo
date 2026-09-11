report 52203472 "Cost Distribution"
{
    UsageCategory = Tasks;
    ApplicationArea = Basic, Suite;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Purchase Header"; "Purchase Header")
        {
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            begin
                PurchLines.Reset;
                PurchLines.SetRange("Document No.", "Purchase Header"."No.");
                PurchLines.DeleteAll;
                NoOfEntities:=0;
                if DeptFilters = '' then DeptFilters:='*';
                if BranchFilters = '' then BranchFilters:='*';
                if(DistributeByDept = true) and (DistributeByBranch = true)then begin
                    //Get Total No of Employees
                    Employee.Reset;
                    Employee.SetRange(Status, Employee.Status::Active);
                    Employee.SetFilter("Global Dimension 1 Code", DeptFilters);
                    Employee.SetFilter("Global Dimension 2 Code", BranchFilters);
                    TotalEmployees:=Employee.Count;
                    //
                    if DistributionMethod = DistributionMethod::"No. of Staff" then begin
                        Departments.Reset;
                        Departments.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");
                        Departments.SetFilter(Code, DeptFilters);
                        Departments.SetRange(Blocked, false);
                        if Departments.FindSet()then begin
                            repeat Branches.Reset;
                                Branches.SetRange("Dimension Code", GLSetup."Global Dimension 2 Code");
                                Branches.SetFilter(Code, BranchFilters);
                                Branches.SetRange(Blocked, false);
                                if Branches.FindSet()then begin
                                    repeat LineNumber:=LineNumber + 1000;
                                        DistributeOnNoOfEmployees(Departments.Code, Branches.Code, LineNumber, "Purchase Header", AmountToShare, TotalEmployees);
                                    until Branches.Next = 0;
                                end;
                            until Departments.Next = 0;
                        end;
                    end
                    else if DistributionMethod = DistributionMethod::"Equally Distributed" then begin
                            Departments.Reset;
                            Departments.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");
                            Departments.SetFilter(Code, DeptFilters);
                            Departments.SetRange(Blocked, false);
                            NoOfEntities:=Departments.Count;
                            Branches.Reset;
                            Branches.SetRange("Dimension Code", GLSetup."Global Dimension 2 Code");
                            Branches.SetFilter(Code, BranchFilters);
                            Branches.SetRange(Blocked, false);
                            NoOfEntities:=NoOfEntities * Branches.Count;
                            Departments.Reset;
                            Departments.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");
                            Departments.SetFilter(Code, DeptFilters);
                            Departments.SetRange(Blocked, false);
                            if Departments.FindSet()then begin
                                repeat Branches.Reset;
                                    Branches.SetRange("Dimension Code", GLSetup."Global Dimension 2 Code");
                                    Branches.SetFilter(Code, BranchFilters);
                                    Branches.SetRange(Blocked, false);
                                    if Branches.FindFirst then begin
                                        repeat LineNumber:=LineNumber + 1000;
                                            DistributeEqually(Departments.Code, Branches.Code, LineNumber, "Purchase Header", AmountToShare, NoOfEntities, TotalEmployees);
                                        until Branches.Next = 0;
                                    end;
                                until Departments.Next = 0;
                            end;
                        end
                        else
                            Error('Distribution Method No. of Computers is not enabled!');
                end;
                if(DistributeByDept = true) and (DistributeByBranch = false)then begin
                    //Get Total No of Employees
                    Employee.Reset;
                    Employee.SetRange(Status, Employee.Status::Active);
                    Employee.SetFilter("Global Dimension 1 Code", DeptFilters);
                    TotalEmployees:=Employee.Count;
                    //
                    if DistributionMethod = DistributionMethod::"No. of Staff" then begin
                        Departments.Reset;
                        Departments.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");
                        Departments.SetFilter(Code, DeptFilters);
                        Departments.SetRange(Blocked, false);
                        if Departments.FindFirst then begin
                            repeat LineNumber:=LineNumber + 1000;
                                DistributeOnNoOfEmployees(Departments.Code, BlankText, LineNumber, "Purchase Header", AmountToShare, TotalEmployees);
                            until Departments.Next = 0;
                        end;
                    end
                    else if DistributionMethod = DistributionMethod::"Equally Distributed" then begin
                            Departments.Reset;
                            Departments.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");
                            Departments.SetFilter(Code, DeptFilters);
                            Departments.SetRange(Blocked, false);
                            NoOfEntities:=Departments.Count;
                            if Departments.FindFirst then begin
                                repeat LineNumber:=LineNumber + 1000;
                                    DistributeEqually(Departments.Code, BlankText, LineNumber, "Purchase Header", AmountToShare, NoOfEntities, TotalEmployees);
                                until Departments.Next = 0;
                            end;
                        end
                        else
                            Error('Distribution Method No. of Computers is not enabled!');
                end;
                if(DistributeByDept = false) and (DistributeByBranch = true)then begin
                    //Get Total No of Employees
                    Employee.Reset;
                    Employee.SetRange(Status, Employee.Status::Active);
                    Employee.SetFilter("Global Dimension 2 Code", BranchFilters);
                    TotalEmployees:=Employee.Count;
                    //
                    if DistributionMethod = DistributionMethod::"No. of Staff" then begin
                        Branches.Reset;
                        Branches.SetRange("Dimension Code", GLSetup."Global Dimension 2 Code");
                        Branches.SetFilter(Code, BranchFilters);
                        Branches.SetRange(Blocked, false);
                        if Branches.FindFirst then begin
                            repeat LineNumber:=LineNumber + 1000;
                                DistributeOnNoOfEmployees(BlankText, Branches.Code, LineNumber, "Purchase Header", AmountToShare, TotalEmployees);
                            until Branches.Next = 0;
                        end;
                    end
                    else if DistributionMethod = DistributionMethod::"Equally Distributed" then begin
                            Branches.Reset;
                            Branches.SetRange("Dimension Code", GLSetup."Global Dimension 2 Code");
                            Branches.SetFilter(Code, BranchFilters);
                            Branches.SetRange(Blocked, false);
                            NoOfEntities:=Branches.Count;
                            if Branches.FindFirst then begin
                                repeat LineNumber:=LineNumber + 1000;
                                    DistributeEqually(BlankText, Branches.Code, LineNumber, "Purchase Header", AmountToShare, NoOfEntities, TotalEmployees);
                                until Branches.Next = 0;
                            end;
                        end
                        else
                            Error('Distribution Method No. of Computers is not enabled!');
                end;
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                //IB
                field(ExpenseCode; ExpenseCode)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Expense Code';
                    TableRelation = "Expense Codes" where("Account No"=filter(<>''));

                    trigger OnValidate()
                    begin
                        if ExpenseCodes.Get(ExpenseCode)then begin
                            //Type := ExpenseCodes."Account Type" + 1;
                            if ExpenseCodes."Account Type" = ExpenseCodes."Account Type"::"G/L Account" then Type:=Type::"G/L Account"
                            else if ExpenseCodes."Account Type" = ExpenseCodes."Account Type"::"Fixed Asset" then Type:=Type::"Fixed Asset"
                                else if ExpenseCodes."Account Type" = ExpenseCodes."Account Type"::Item then Type:=Type::Item;
                            AccountNo:=ExpenseCodes."Account No";
                            Desc:=ExpenseCodes.Description;
                        end;
                    end;
                } //
                field(Type; Type)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Expense Type';
                }
                field(AccountNo; AccountNo)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'No';

                    trigger OnLookup(var Text: Text): Boolean begin
                        if Format(Type) = '' then Error('Specify the Type');
                        if Type = Type::"G/L Account" then begin
                            GLAcc.Reset;
                            GLAcc.SetRange(Blocked, false);
                            GLAcc.SetRange("Account Type", GLAcc."Account Type"::Posting);
                            GLAcc.SetRange("Income/Balance", GLAcc."Income/Balance"::"Income Statement");
                            if PAGE.RunModal(18, GLAcc) = ACTION::LookupOK then AccountNo:=GLAcc."No.";
                        end
                        else if Type = Type::"Fixed Asset" then begin
                                FA.Reset;
                                if PAGE.RunModal(5601, FA) = ACTION::LookupOK then AccountNo:=FA."No.";
                            end
                            else if Type = Type::Item then begin
                                    Items.Reset;
                                    if PAGE.RunModal(31, Items) = ACTION::LookupOK then AccountNo:=Items."No.";
                                end;
                    end;
                }
                field(Desc; Desc)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Description';
                }
                field(AmountToShare; AmountToShare)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Total Amount';
                }
                field(DistributeByDept; DistributeByDept)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Distribute By Department?';
                }
                field(DeptFilters; DeptFilters)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Department Filters';

                    trigger OnLookup(var Text: Text): Boolean begin
                        GLSetup.Get;
                        Departments.Reset;
                        Departments.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");
                        if PAGE.RunModal(537, Departments) = ACTION::LookupOK then begin
                            if DeptFilters = '' then DeptFilters:=Departments.Code
                            else
                                DeptFilters:=DeptFilters + '|' + Departments.Code;
                        end;
                    end;
                }
                field(DistributeByBranch; DistributeByBranch)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Distribute By Branch?';
                }
                field(BranchFilters; BranchFilters)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Branch Filters';

                    trigger OnLookup(var Text: Text): Boolean begin
                        GLSetup.Get;
                        Departments.Reset;
                        Departments.SetRange("Dimension Code", GLSetup."Global Dimension 2 Code");
                        if PAGE.RunModal(537, Departments) = ACTION::LookupOK then begin
                            if BranchFilters = '' then BranchFilters:=Departments.Code
                            else
                                BranchFilters:=BranchFilters + '|' + Departments.Code;
                        end;
                    end;
                }
                field(DistributionMethod; DistributionMethod)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Distribution Method';
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        if AmountToShare = 0 then Error('Amount to distribute cannot be zero.');
        if not DistributeByBranch and not DistributeByDept then Error('You must choose to distribute by either Branch or Department');
        if "Purchase Header".GetFilter("No.") = '' then Error('PO Number is Mandatory before distribution.');
        GLSetup.Get;
        BlankText:='';
    end;
    var ExpenseCode: Code[20];
    Type: Option " ", "G/L Account", Item, , "Fixed Asset";
    AccountNo: Code[10];
    Desc: Text;
    AmountToShare: Decimal;
    DistributeByDept: Boolean;
    DistributeByBranch: Boolean;
    DistributionMethod: Option "Equally Distributed", "No. of Staff", "No of Computers";
    GLAcc: Record "G/L Account";
    FA: Record "Fixed Asset";
    Items: Record Item;
    Lines: Record "Purchase Line";
    GLSetup: Record "General Ledger Setup";
    Departments: Record "Dimension Value";
    Branches: Record "Dimension Value";
    NoOfEmployees: Integer;
    TotalEmployees: Integer;
    Employee: Record Employee;
    PurchLines: Record "Purchase Line";
    LineNumber: Integer;
    BlankText: Code[10];
    NoOfEntities: Decimal;
    ExpenseCodes: Record "Expense Codes";
    DeptFilters: Text;
    BranchFilters: Text;
    Expenserec: Record "Expense Codes";
    procedure DistributeOnNoOfEmployees(var Dept: Code[20]; var Branch: Code[20]; var LineNo: Integer; var PO: Record "Purchase Header"; var AmountToShare: Decimal; var AllEmployees: Integer)
    begin
        with PO do begin
            Employee.Reset;
            Employee.SetRange(Status, Employee.Status::Active);
            if Dept <> '' then Employee.SetRange("Global Dimension 1 Code", Dept);
            if Branch <> '' then Employee.SetRange("Global Dimension 2 Code", Branch);
            NoOfEmployees:=Employee.Count;
            if(AllEmployees <> 0) and (NoOfEmployees <> 0)then begin
                Lines.Init;
                Lines."Document Type":="Document Type";
                Lines."Document No.":="No.";
                Lines."Line No.":=LineNo;
                Lines."Buy-from Vendor No.":="Buy-from Vendor No.";
                if NoOfEmployees / AllEmployees * AmountToShare <> 0 then begin
                    Lines.Insert;
                    Lines.Description:=Desc;
                    Lines.Quantity:=1;
                    Lines."Direct Unit Cost":=NoOfEmployees / TotalEmployees * AmountToShare;
                    Lines."Shortcut Dimension 1 Code":=Dept;
                    Lines."Shortcut Dimension 2 Code":=Branch;
                    Lines.Validate("Direct Unit Cost");
                    Lines.Modify;
                end;
            end;
        end;
    end;
    procedure DistributeEqually(var Dept: Code[20]; var Branch: Code[20]; var LineNo: Integer; var PO: Record "Purchase Header"; var AmountToShare: Decimal; var Divisor: Decimal; var AllEmployees: Integer)
    begin
        with PO do begin
            Employee.Reset;
            Employee.SetRange(Status, Employee.Status::Active);
            if Dept <> '' then Employee.SetRange("Global Dimension 1 Code", Dept);
            if Branch <> '' then Employee.SetRange("Global Dimension 2 Code", Branch);
            NoOfEmployees:=Employee.Count;
            //IF (AllEmployees <> 0) AND (NoOfEmployees <> 0) THEN BEGIN
            Lines.Init;
            Lines."Document Type":="Document Type";
            Lines."Document No.":="No.";
            Lines."Line No.":=LineNo;
            Lines."Buy-from Vendor No.":="Buy-from Vendor No.";
            if AmountToShare / Divisor <> 0 then begin
                Lines.Insert;
                Lines.Description:=Desc;
                Lines.Quantity:=1;
                Lines."Direct Unit Cost":=AmountToShare / Divisor;
                Lines."Shortcut Dimension 1 Code":=Dept;
                Lines."Shortcut Dimension 2 Code":=Branch;
                Lines.Validate("Direct Unit Cost");
                Lines.Modify;
            end;
        //END;
        end;
    end;
}

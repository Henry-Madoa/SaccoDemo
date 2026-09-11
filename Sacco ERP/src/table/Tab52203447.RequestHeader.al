table 52203447 "Request Header"
{
    DataCaptionFields = "No.", "Employee No.";

    fields
    {
        field(1; "No."; Code[20])
        {
            Editable = false;
            NotBlank = false;

            trigger OnValidate()
            begin
                AdvancedFinanceSetup.Get;
                if "No." <> xRec."No." then begin
                    if "Request Type" = "Request Type"::Imprest then begin
                        AdvancedFinanceSetup.TestField("Imprest Nos");
                        NoSeriesMgt.TestManual(AdvancedFinanceSetup."Imprest Nos");
                    end;
                    if "Request Type" = "Request Type"::"Staff Claim" then begin
                        AdvancedFinanceSetup.TestField("Staff Claim Nos");
                        NoSeriesMgt.TestManual(AdvancedFinanceSetup."Staff Claim Nos");
                    end;
                    if "Request Type" = "Request Type"::"Salary Advance" then begin
                        AdvancedFinanceSetup.TestField("Salary Advance Nos");
                        NoSeriesMgt.TestManual(AdvancedFinanceSetup."Salary Advance Nos");
                    end;
                    "No. Series":='';
                end;
            end;
        }
        field(2; "Employee No."; Code[20])
        {
            TableRelation = Employee where(Status=const(Active));

            trigger OnValidate()
            begin
                Hallowance:=0;
                if Emp.Get("Employee No.")then begin
                    "Global Dimension 1 Code":=Emp."Global Dimension 1 Code";
                    "Global Dimension 2 Code":=Emp."Global Dimension 2 Code";
                    Emp.TestField("Employment Date");
                    "Job Title":=Emp."Job Title";
                    "Employee Name":=Emp.FullName();
                    "Phone No.":=Emp."Mobile Phone No.";
                    if "Request Type" = "Request Type"::"Salary Advance" then begin
                        OpenSalaryAdvance("Employee No.");
                        AdditionalAdvance("Employee No.");
                        "Payroll Period":=Payrollperiod;
                        if "Basic Pay" > 0 then "1/3 of Basic":=1 / 3 * "Basic Pay";
                        RequestHeader.Reset();
                        RequestHeader.SetRange("Employee No.", "Employee No.");
                        RequestHeader.SetRange(Status, RequestHeader.Status::Approved);
                        RequestHeader.SetRange("Request Type", RequestHeader."Request Type"::"Salary Advance");
                        if RequestHeader.FindLast()then begin
                            NextAdvanceDate:=CalcDate('1Y', RequestHeader."Posted Date");
                            if(NextAdvanceDate > WorkDate)then Error(StrSubstNo('You can only qualify for Salary Advance from %1', Format(NextAdvanceDate)));
                        end;
                    end;
                end;
            end;
        }
        field(3; "Employee Name"; Text[100])
        {
        }
        field(4; "Global Dimension 1 Code"; Code[20])
        {
            Editable = false;
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
        }
        field(5; "Global Dimension 2 Code"; Code[20])
        {
            Editable = false;
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));
        }
        field(6; "Global Dimension 3 Code"; Code[20])
        {
            CaptionClass = '1,2,3';
            Caption = 'Global Dimension 3 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(3), Blocked=const(false));
        }
        field(7; Date; Date)
        {
            Editable = false;
        }
        field(8; "Created By"; Code[50])
        {
            Editable = false;
        }
        field(9; Status;Enum "Document Status")
        {
            Editable = false;
        }
        field(10; "Transfer To Payroll"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Transfered To Payroll"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(12; Country; Code[10])
        {
            TableRelation = "Country/Region";
        }
        field(13; City; Code[10])
        {
            TableRelation = "Post Code";
        }
        field(14; "Request Amount"; Decimal)
        {
            CalcFormula = Sum("Request Lines"."Request Amount" WHERE("No."=FIELD("No.")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(15; "Request Type"; Option)
        {
            Editable = false;
            OptionMembers = " ", Imprest, Surrender, "Staff Claim", "Salary Advance";
        }
        field(16; "No. Series"; Code[11])
        {
            TableRelation = "No. Series";
        }
        field(17; "Surrender Date"; Date)
        {
            Caption = 'Surrender Date';
            Editable = false;

            trigger OnValidate()
            begin
                if Rec."Surrender Date" <> 0D then begin
                    if "Surrender Date" < "Due Date" then "Overdue Days":="Surrender Date" - "Due Date"
                    else
                        "Overdue Days":=0;
                end;
            end;
        }
        field(18; "Total Days in the Field"; Integer)
        {
        }
        field(19; "Job Title"; Text[30])
        {
        }
        field(20; Posted; Boolean)
        {
            Editable = false;
        }
        field(21; "Posted By"; Code[50])
        {
            Editable = false;
        }
        field(22; "Posted Date"; Date)
        {
            Editable = false;

            trigger OnValidate()
            begin
                AdvancedFinanceSetup.Get;
                "Due Date":=CALCDATE('+' + Format("Total Days in the Field") + 'D', "Posted Date");
            //"Due Date" := CalcDate(AdvancedFinanceSetup."Employee Payment Terms", "Request Posted Date");
            end;
        }
        field(23; Surrendered; Boolean)
        {
            Editable = false;
        }
        field(24; "Surrender Posted By"; Code[50])
        {
            Editable = false;
        }
        field(25; "Surrender Posted Date"; Date)
        {
            Editable = false;
            Caption = 'Surrender Posted Date';
        }
        field(26; "Total Surrender Amount"; Decimal)
        {
            CalcFormula = Sum("Request Lines"."Actual Spent" WHERE("No."=FIELD("No.")));
            FieldClass = FlowField;
            Editable = false;
            Caption = 'Gross Amount';
        }
        field(27; "Total Claim"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Sum("Request Lines".Claim WHERE("No."=FIELD("No.")));
        }
        field(28; "Total Refund"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Sum("Request Lines".Refund WHERE("No."=FIELD("No.")));
        }
        field(29; "Net Refund (Net Claim)"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Sum("Request Lines".Difference WHERE("No."=FIELD("No.")));
        }
        field(30; "Paying Bank Code"; Code[10])
        {
            TableRelation = "Bank Account";
        }
        field(31; "Pay Mode"; Code[10])
        {
            TableRelation = "Payment Method";

            trigger OnValidate()
            begin
                "Cheque Date":=WorkDate;
            end;
        }
        field(32; "Payment Tx No.(Cheque No.)"; Code[10])
        {
            trigger OnValidate()
            begin
            //AdvancedFinanceSetup.CodeRegExChecker("Payment Tx No.(Cheque No.)");
            end;
        }
        field(33; "Cheque Date"; Date)
        {
            Editable = false;
        }
        field(34; "Due Date"; Date)
        {
            Editable = false;
        }
        field(35; "Currency Code"; Code[10])
        {
            TableRelation = Currency;
        }
        field(36; "Overdue Days"; Integer)
        {
        }
        field(37; "Receiving Account"; Code[10])
        {
            TableRelation = "Bank Account";
        }
        field(38; "Receipt Mode"; Code[10])
        {
            TableRelation = "Payment Method";

            trigger OnValidate()
            begin
                "Receipt Tx No.(Cheque No.)":="No.";
            end;
        }
        field(39; "Receipt Tx No.(Cheque No.)"; Code[10])
        {
            trigger OnValidate()
            begin
            // AdvancedFinanceSetup.CodeRegExChecker("Receipt Tx No.(Cheque No.)");
            end;
        }
        field(40; "Claim Paying Account"; Code[10])
        {
            TableRelation = "Bank Account";
        }
        field(41; "Claim Pay Mode"; Code[10])
        {
            TableRelation = "Payment Method";
        }
        field(42; "Claim Payment Tx No"; Code[10])
        {
            trigger OnValidate()
            begin
            //AdvancedFinanceSetup.CodeRegExChecker("Claim Payment Tx No");
            end;
        }
        field(43; "Employee Balance"; Decimal)
        {
            CalcFormula = Sum("Detailed Employee Ledger Entry"."Amount (LCY)" WHERE("Employee No."=FIELD("Employee No.")));
            FieldClass = FlowField;
        }
        field(44; Purpose; Text[150])
        {
        }
        field(45; "Departure Location"; Text[30])
        {
        }
        field(46; "Departure Date"; Date)
        {
        }
        field(47; "Return Date"; Date)
        {
        }
        field(48; Justification; Text[150])
        {
        }
        field(49; "Payment Stopped"; Boolean)
        {
        }
        field(50; "Stopped By"; Code[50])
        {
        }
        field(51; "Stopped Date"; Date)
        {
        }
        field(52; "Request For"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Self,Other';
            OptionMembers = Self, Other;
        }
        field(53; "Budget Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(54; "Phone No."; Code[20])
        {
        }
        field(55; "Total Requested Amount"; Decimal)
        {
            CalcFormula = Sum("Request Lines"."Request Amount" WHERE("No."=FIELD("No.")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(56; "Purpose Code"; Code[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Imprest Purpose"."Purpose Code";

            trigger OnValidate()
            begin
                if ImprestPurpose.Get("Purpose Code")then Purpose:=ImprestPurpose."Purpose Desscription";
            end;
        }
        field(57; Committed; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(58; Uncommitted; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(59; Description; Text[250])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                RequestLines.Reset();
                RequestLines.SetRange("No.", Rec."No.");
                if RequestLines.FindSet()then begin
                    repeat RequestLines.Narration:=Description;
                        RequestLines.Modify(true);
                    until RequestLines.Next() = 0;
                end;
            end;
        }
        field(60; "Imprest Request Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Payment Voucher Lines"."No." WHERE("Account No"=FIELD("Employee No."), Surrendered=CONST(false), Posted=CONST(true));

            trigger OnValidate()
            begin
                PVLines.Reset;
                PVLines.SetRange("No.", "Imprest Request Code");
                PVLines.SetRange("Account No", "Employee No.");
                if PVLines.FindFirst then begin
                    if PVHeader.Get(PVLines."No.")then begin
                        "Date":=PVHeader.Date;
                        Validate("Date");
                    end;
                end;
                if "Imprest Request Code" = '' then begin
                    "Date":=WorkDate;
                    Validate("Date");
                end;
            end;
        }
        field(61; "Job Group"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(62; "Created On"; Date)
        {
            Editable = false;
        }
        field(63; Designation; Text[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(64; "Payroll Period"; Date)
        {
            DataClassification = ToBeClassified;
            TableRelation = "Accounting Period";
        }
        field(65; "Pending Approvals Ext"; Integer)
        {
            CalcFormula = Count("Approval Entry" WHERE("Table ID"=CONST(Database::"Request Header"), "Document No."=FIELD("No."), Status=FILTER(Open|Created)));
            Caption = 'Pending Approvals';
            FieldClass = FlowField;
            Editable = false;
        }
        field(66; "External Application"; Option)
        {
            Description = 'Apply on behalf of external stakeholders';
            OptionMembers = No, Yes;
        }
        field(67; Balance; Decimal)
        {
            CalcFormula = Sum("Detailed Employee Ledger Entry".Amount WHERE("Employee No."=FIELD("Employee No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(68; "Claim Posted"; Boolean)
        {
            Editable = false;
        }
        field(69; "Claim Posted By"; Code[50])
        {
            Editable = false;
        }
        field(70; "Claim Posted Date"; Date)
        {
            Editable = false;
        }
        field(71; "EFT No"; Text[30])
        {
        }
        field(72; "Surrender EFT No"; Text[30])
        {
        }
        field(73; Approvers; Integer)
        {
            CalcFormula = Count("Approval Entry" WHERE("Table ID"=CONST(Database::"Request Header"), "Document No."=FIELD("No."), Status=FILTER(Approved)));
            FieldClass = FlowField;
            Caption = 'Approvers';
            Editable = false;
        }
        field(74; "Committed By"; Code[50])
        {
        }
        field(75; "Committed Date"; Date)
        {
        }
        field(76; "To Recover From Payroll"; Boolean)
        {
        }
        field(77; "Repayment Period"; Integer)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Rec."Repayment Period" <> xRec."Repayment Period" then begin
                    Validate("Amount Requested");
                    Validate("Employee No.");
                end;
            end;
        }
        field(78; Instalments; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(79; "Basic Pay"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(80; "1/3 of Basic"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(81; "Take Home"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(82; "Current Net Pay"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(83; "Amount Requested"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "No.")
        {
        }
    }
    trigger OnDelete()
    begin
        Rec.TestField(Status, Rec.Status::Open);
    end;
    trigger OnInsert()
    begin
        AdvancedFinanceSetup.Get;
        if "No." = '' then begin
            if "Request Type" = "Request Type"::Imprest then begin
                AdvancedFinanceSetup.TestField("Imprest Nos");
                NoSeriesMgt.InitSeries(AdvancedFinanceSetup."Imprest Nos", xRec."No. Series", 0D, "No.", "No. Series");
            end;
            if "Request Type" = "Request Type"::"Staff Claim" then begin
                AdvancedFinanceSetup.TestField("Staff Claim Nos");
                NoSeriesMgt.InitSeries(AdvancedFinanceSetup."Staff Claim Nos", xRec."No. Series", 0D, "No.", "No. Series");
            end;
            if "Request Type" = "Request Type"::"Salary Advance" then begin
                AdvancedFinanceSetup.TestField("Salary Advance Nos");
                NoSeriesMgt.InitSeries(AdvancedFinanceSetup."Salary Advance Nos", xRec."No. Series", 0D, "No.", "No. Series");
            end;
        end;
        "Date":=WorkDate;
        "Created By":=UserId;
        if not LoginMgmt.IsWebServiceUser then begin
            if not UserSetup.Get(UserId)then Error('Contact Admin for your account to be setup')
            else if not UserSetup."Finance Admin" then begin
                    Validate("Employee No.", UserSetup."Employee No.");
                end;
        end;
        GLSetup.Get;
        GLSetup.TestField("Current Budget");
        GLSetup.TestField("Current Budget End Date");
        GLSetup.TestField("Current Budget Start Date");
        "Budget Code":=GLSetup."Current Budget";
        "Created By":=UserId;
        "Created On":=WorkDate;
    end;
    procedure RequestedAmountValidator()
    begin
        CalcFields("Total Requested Amount");
        Rec.CalcFields("Total Surrender Amount");
        if "Request Type" <> "Request Type"::"Staff Claim" then begin
            if "Total Requested Amount" = 0 then Error(Text001);
        end
        else
        begin
            if Rec."Total Surrender Amount" = 0 then Error(Text002);
        end;
    end;
    procedure AttachmentValidator(): Boolean begin
        DocumentAttachment.Reset();
        DocumentAttachment.SetRange("Table ID", Database::"Request Header");
        DocumentAttachment.SetRange("No.", Rec."No.");
        DocumentAttachment.SetFilter("File Name", '<>%1', '');
        if((DocumentAttachment.FindSet()) and (Description <> ''))then exit(true)
        else
            exit(false);
    end;
    procedure AttachmentValidatorResponse(): Text begin
        exit(Validator_Err);
    end;
    var DocumentAttachment: Record "Document Attachment";
    Validator_Err: Label 'You have not attached any document. Please attach document/s and continue.';
    AdvancedFinanceSetup: Record "General Ledger Setup";
    NoSeriesMgt: Codeunit NoSeriesManagement;
    UserSetup: Record "User Setup";
    Emp: Record Employee;
    Text001: Label 'Requested Amount can not be equal to zero.';
    Text002: Label 'Claim Amount can not be equal to zero.';
    PVHeader: Record "Payment Voucher";
    PVLines: Record "Payment Voucher Lines";
    GLSetup: Record "General Ledger Setup";
    RequestLines: Record "Request Lines";
    ImprestPurpose: Record "Imprest Purpose";
    PayrollPeriods: Record "Accounting Period";
    Hallowance: Decimal;
    RequestHeader: Record "Request Header";
    NextAdvanceDate: Date;
    HRSetup: Record "Human Resources Setup";
    LoginMgmt: Codeunit "User Management Ext";
    procedure OnBeforeApproval()
    begin
        Rec.TestField(Status, Rec.Status::Open);
        Rec.Testfield(Purpose);
        Rec.Testfield("Global Dimension 1 Code");
        Rec.Testfield("Global Dimension 2 Code");
        GLSetup.Get;
        GLSetup.TestField("Max No Outstanding Imprests");
        if "Request Type" in["Request Type"::Imprest]then begin
            RequestHeader.Reset;
            RequestHeader.SetRange("Employee No.", "Employee No.");
            RequestHeader.SetRange("Request Type", RequestHeader."Request Type"::Imprest);
            RequestHeader.SetRange(Posted, true);
            RequestHeader.SetRange(Surrendered, false);
            //RequestHeader.SETFILTER(Status,'%1',RequestHeader.Status::Rejected);
            if RequestHeader.FindSet then begin
                if RequestHeader.Count >= GLSetup."Max No Outstanding Imprests" then Error('You have %1 unsurrendered imprest', RequestHeader.Count);
            end;
        end;
        CalcFields("Request Amount");
        HRSetup.Get;
    // if HRSetup.impre then begin
    //     if "Request Amount" > HRSetup."Maximum Imprest Amount" then
    //         Error('%1 cannot apply imprest higher than %2', "Employee Name", HRSetup."Maximum Imprest Amount");
    //end;
    end;
    procedure Navigate()
    var
        NavigatePage: Page Navigate;
    begin
        if(("Request Type" = "Request Type"::Imprest) or ("Request Type" = "Request Type"::Surrender))then begin
            if Posted and not Surrendered then NavigatePage.SetDoc("Posted Date", "No.")
            else if Posted and Surrendered then NavigatePage.SetDoc("Surrender Posted Date", "No.");
            NavigatePage.SetRec(Rec);
            NavigatePage.Run;
        end;
        case "Request Type" of "Request Type"::"Staff Claim": begin
            NavigatePage.SetDoc("Claim Posted Date", "No.");
            NavigatePage.SetRec(Rec);
            NavigatePage.Run;
        end;
        "Request Type"::"Salary Advance": begin
            NavigatePage.SetDoc("Posted Date", "No.");
            NavigatePage.SetRec(Rec);
            NavigatePage.Run;
        end;
        end;
    end;
    procedure OpenSalaryAdvance(EmpN: Code[20])
    var
        EmployeeLedgerEntry: Record "Employee Ledger Entry";
        RequestHeader: Record "Request Header";
    begin
        EmployeeLedgerEntry.Reset;
        EmployeeLedgerEntry.SetRange("Employee No.", EmpN);
        EmployeeLedgerEntry.SetRange(Open, true);
        if EmployeeLedgerEntry.FindSet then repeat EmployeeLedgerEntry.CalcFields("Remaining Amount");
                if EmployeeLedgerEntry."Remaining Amount" > 5 then begin
                    RequestHeader.Reset;
                    RequestHeader.SetRange("No.", EmployeeLedgerEntry."Document No.");
                    RequestHeader.SetRange("Request Type", RequestHeader."Request Type"::"Salary Advance");
                    if RequestHeader.FindFirst then Error('You cannot Apply a new Salary with %1 Active with %2,Contact your Finance Manager', RequestHeader."No.", EmployeeLedgerEntry."Remaining Amt. (LCY)");
                end;
            until EmployeeLedgerEntry.Next = 0;
    end;
    procedure AdditionalAdvance(EmpN: Code[20])
    var
        RequestHeader: Record "Request Header";
    begin
    //RequestHeader.Reset;
    //RequestHeader.SetRange("Employee No.", EmpN);
    //RequestHeader.SetRange("Request Type", RequestHeader."Request Type"::"Salary Advance");
    //RequestHeader.SetFilter("No.", '<>%1', RequestHeader."No.");
    //RequestHeader.SetFilter(Status, '%1', RequestHeader.Status::"Pending Approval");
    //if RequestHeader.FindFirst then
    //Error('You cannot create another salary Advance with %1 Pending Approval', RequestHeader."No.");
    // RequestHeader.Reset;
    // RequestHeader.SetRange("Employee No.", EmpN);
    // RequestHeader.SetRange("Request Type", RequestHeader."Request Type"::"Salary Advance");
    // RequestHeader.SetFilter("No.", '<>%1', RequestHeader."No.");
    // RequestHeader.SetFilter(Status, '%1', RequestHeader.Status::Approved);
    // RequestHeader.SetFilter("Global Dimension 1 Code", '<>%1', '');
    // RequestHeader.SetRange(Posted, false);
    // if RequestHeader.FindFirst then
    //     Error('You cannot create another salary Advance with %1 still unposted', RequestHeader."No.");
    end;
    local procedure Payrollperiod(): Date begin
        PayrollPeriods.Reset;
        PayrollPeriods.SetRange(Closed, false);
        if PayrollPeriods.FindFirst then exit(PayrollPeriods."Starting Date");
    end;
}

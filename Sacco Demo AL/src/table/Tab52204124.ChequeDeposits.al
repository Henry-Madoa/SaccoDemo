table 52204124 "Cheque Deposits"
{
    fields
    {
        field(1; "No."; code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Document Type"; Enum "Cheque Deposit Type")
        {
            Editable = false;
        }
        field(3; "Global Dimension 1 Code"; code[20])
        {
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1), Blocked = const(false));
        }
        field(4; "Global Dimension 2 Code"; code[20])
        {
            CaptionClass = '1,1,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2), Blocked = const(false));
        }
        field(5; "Cheque Book No."; Code[20])
        {
            TableRelation = "Cheque Books" where(Active = const(true));

            trigger OnValidate()
            var
                ChequeBook: Record "Cheque Books";
            begin
                ChequeBook.Get("Cheque Book No.");
                Validate("Member No", ChequeBook."Member No");
                Validate("Account No.", ChequeBook."Account No");
            end;
        }
        field(6; "Cheque Type"; Code[20])
        {
            TableRelation = if ("Document Type" = const(Deposit)) "Cheque Types" where(Type = const("External Cheque"))
            else if ("Document Type" = const(Clearance)) "Cheque Types" where(Type = const("Internal Cheque"));

            trigger OnValidate()
            var
                ChequeTypes: Record "Cheque Types";
            begin
                ChequeTypes.Get("Cheque Type", ChequeTypes.Type::"External Cheque");
                "Clearing Account No." := ChequeTypes."Clearing Account";
                "Clearing Charge" := ChequeTypes."Clearing Charge";
                "Bouncing Charge" := ChequeTypes."Bouncing Charge Code";
                "Express Clearing Charge" := ChequeTypes."Express Clearing Charge Code";
                "In-House" := ChequeTypes."In-House";
                "Maturity Period" := ChequeTypes."Maturity Period";

                if ChequeTypes."In-House" then
                    Validate("Maturity Date", "Deposit Date")
                else
                    Validate("Maturity Date");
            end;
        }
        field(7; "Clearing Charge"; Code[20])
        {
            TableRelation = "Transaction Charges";
            Editable = false;

            trigger OnValidate()
            begin
                Validate("Total Clearing Charges");
            end;
        }
        field(8; "Bouncing Charge"; Code[20])
        {
            Editable = false;
            TableRelation = "Transaction Charges";
        }
        field(9; "Express Clearing Charge"; Code[20])
        {
            Editable = false;
            TableRelation = "Transaction Charges";
        }
        field(10; "In-House"; Boolean)
        {
            Editable = false;
        }
        field(11; "Deposit Date"; Date)
        {
            trigger OnValidate()
            begin
                Validate("Maturity Date");
            end;
        }
        field(12; "Maturity Period"; DateFormula)
        {
            Editable = false;

            trigger OnValidate()
            begin
                Validate("Maturity Date");
            end;
        }
        field(13; "Maturity Date"; Date)
        {
            Editable = false;

            trigger OnValidate()
            var
                MaturityDays, Weekends, Holidays : Integer;
                MaturityDate, TheDayToday : Date;
                Date: Record Date;
                NonWorkingDaysDates: Record "Non Working Days & Dates";
            begin
                if "Deposit Date" <> 0D then begin
                    if "Deposit Date" < WorkDate then
                        Error('You cannot back date a Cheque');

                    if not "In-House" then begin
                        MaturityDate := CalcDate("Maturity Period", "Deposit Date");
                        MaturityDays := MaturityDate - "Deposit Date";
                        TheDayToday := "Deposit Date";

                        while (TheDayToday <= MaturityDate) do begin
                            if Date.Get(Date."Period Type"::Date, TheDayToday) then begin
                                if (((Date."Period Name" = 'Sunday') or ((Date."Period Name" = 'Saturday')))) then
                                    Weekends += 1;
                                TheDayToday := CalcDate('1D', TheDayToday);
                            end;
                        end;

                        TheDayToday := "Deposit Date";
                        while (TheDayToday <= CalcDate(Format(MaturityDays + Weekends) + 'D', "Deposit Date")) do begin
                            NonWorkingDaysDates.Reset;
                            NonWorkingDaysDates.SetRange(Date, TheDayToday);
                            if NonWorkingDaysDates.FindFirst then
                                if Date.Get(Date."Period Type"::Date, TheDayToday) then begin
                                    if ((not (Date."Period Name" = 'Sunday') or (not (Date."Period Name" = 'Saturday')))) then
                                        Holidays += 1;
                                end;
                            TheDayToday := CalcDate('1D', TheDayToday);
                        end;

                        "Maturity Date" := CalcDate(StrSubstNo('%1D', Weekends + MaturityDays + Holidays), "Deposit Date");

                        if Date.Get(Date."Period Type"::Date, "Maturity Date") then begin
                            if (Date."Period Name" = 'Sunday') then
                                "Maturity Date" := CalcDate('+1D', "Maturity Date");
                            if (Date."Period Name" = 'Saturday') then
                                "Maturity Date" := CalcDate('+2D', "Maturity Date");
                        end;
                    end;
                end;
            end;
        }
        field(14; "Member No"; code[20])
        {
            TableRelation = members;

            trigger onvalidate()
            var
                Members: Record Members;
                MemberMgmt: Codeunit "Member Management";
                ProductPostingType: Enum "Product Posting Type";
            begin
                if Members.Get("Member No") then begin
                    "Member Name" := Members."Full Name";
                    Validate("Account No.", MemberMgmt.GetMemberAccount("Member No", ProductPostingType::"Withdrawable Deposit"));
                end;
            end;
        }
        field(15; "Member Name"; Text[150])
        {
            Editable = false;
        }
        field(16; "Account No."; code[20])
        {
            Editable = false;
            TableRelation = Vendor where("Member No." = field("Member No"));

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                if vendor.Get("Account No.") then begin
                    "Account Name" := vendor.name;
                end
            end;
        }
        field(17; "Account Name"; Text[150])
        {
            Editable = false;
        }
        field(18; "Cheque No"; Code[30])
        {
        }
        field(19; "Cheque Date"; Date)
        {
        }
        field(20; "Clearing Account No."; code[20])
        {
            Editable = false;
        }
        field(21; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(22; "Express Cheque"; Boolean)
        {
            trigger OnValidate()
            begin
                if not "Express Cheque" then begin
                    Validate("Express Amount", 0);
                end;
            end;
        }
        field(23; Amount; Decimal)
        {
            trigger OnValidate()
            begin
                Validate("Total Clearing Charges");
            end;
        }
        field(24; "Instructions Amount"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Cheque Instructions".Amount where("Document No" = field("No.")));
            Editable = false;
        }
        field(25; "Express Amount"; Decimal)
        {
            trigger OnValidate()
            begin
                Validate("Total Clearing Charges");
            end;
        }
        field(26; "Total Clearing Charges"; Decimal)
        {
            Editable = false;

            trigger OnValidate()
            var
                JournalManagement: Codeunit "Journal Management";
            begin
                "Total Clearing Charges" := 0;
                "Total Clearing Charges" += JournalManagement.GetChargesAmount("Clearing Charge", Amount);
                "Total Clearing Charges" += JournalManagement.GetChargesAmount("Express Clearing Charge", "Express Amount");
                If "Express Amount" > (Rec.Amount - Rec."Total Clearing Charges") then Error('You cannot pay more than the Instruction Amount');
            end;
        }
        field(27; "Drawer Account Name"; text[150])
        {
        }
        field(28; "Drawer Bank"; code[50])
        {
            TableRelation = "External Banks";
        }
        field(29; "Drawer Account No."; code[30])
        {
        }
        field(30; "Drawer Branch"; Code[20])
        {
            TableRelation = "External Bank Branches" where("Bank Code" = field("Drawer Bank"));
        }
        field(31; "Created By"; code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(32; "Created On"; Datetime)
        {
            editable = false;
        }
        field(33; "Cleared By"; code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(34; "Clearance Date"; Date)
        {
            Editable = false;
        }
        field(35; "Payee Account Name"; text[150])
        {
        }
        field(36; "Payee Bank"; code[50])
        {
        }
        field(37; "Payee Account No."; code[30])
        {
        }
        field(38; "Payee Branch"; Code[20])
        {
        }
        field(39; Processed; Boolean)
        {
        }
        field(40; "Processed Date"; Date)
        {
        }
        field(41; Due; Boolean)
        {
        }
    }
    keys
    {
        key(Key1; "No.", "Document Type")
        {
            Clustered = true;
        }
    }
    var
        NoSeries: Codeunit NoSeriesManagement;
        SaccoSetup: Record "General Ledger Setup";
        UserSetup: Record "User Setup";
        Employee: Record Employee;

    trigger OnInsert()
    begin
        SaccoSetup.Get();
        if "Document Type" = "Document Type"::Deposit then begin
            SaccoSetup.TestField("Cheque Deposit Nos");
            "No." := NoSeries.GetNextNo(SaccoSetup."Cheque Deposit Nos", Today, true);
            "Deposit Date" := WorkDate;
        end
        else if "Document Type" = "Document Type"::Clearance then begin
            SaccoSetup.TestField("Cheque Clearance Nos");
            "No." := NoSeries.GetNextNo(SaccoSetup."Cheque Clearance Nos", Today, true);
        end;
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
        UserSetup.Get(UserId);
        Employee.Get(UserSetup."Employee No.");
        "Global Dimension 1 Code" := Employee."Global Dimension 1 Code";
        "Global Dimension 2 Code" := Employee."Global Dimension 2 Code";
    end;

    procedure Navigate()
    var
        NavigatePage: Page Navigate;
    begin
        NavigatePage.SetDoc("Processed Date", "No.");
        NavigatePage.SetRec(Rec);
        NavigatePage.Run;
    end;

    trigger OnDelete()
    begin
        TestField(Status, Status::Open);
    end;

    procedure OnBeforeSendForApproval()
    begin
        TestField("Cheque Type");
        TestField("Deposit Date");
        TestField("Maturity Date");
        TestField("Member No");
        TestField("Cheque No");
        TestField("Cheque Date");
        CalcFields("Instructions Amount");
        if (Amount - "Total Clearing Charges") < "Instructions Amount" then
            Error('The Instructions Amount is more than the amount received less processing charges');
    end;
}

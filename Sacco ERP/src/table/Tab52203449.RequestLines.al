table 52203449 "Request Lines"
{
    Caption = 'Request Details';

    fields
    {
        field(1; "No."; Code[20])
        {
            trigger OnValidate()
            begin
                If RequestHeader.Get("No.")then begin
                    "Global Dimension 1 Code":=RequestHeader."Global Dimension 1 Code";
                    "Global Dimension 2 Code":=RequestHeader."Global Dimension 2 Code";
                    "Global Dimension 3 Code":=RequestHeader."Global Dimension 3 Code";
                    "Employee No":=RequestHeader."Employee No.";
                    "Employee Name":=RequestHeader."Employee Name";
                    Narration:=RequestHeader.Description;
                end;
            end;
        }
        field(2; "Line No"; Integer)
        {
        }
        field(3; "Expense Code"; Code[20])
        {
            TableRelation = "Expense Codes" where("Account No"=filter(<>''));

            trigger OnValidate()
            begin
                Validate("No.");
                if ExpenseCodes.Get("Expense Code")then begin
                    Expense:=ExpenseCodes.Description;
                    Type:=ExpenseCodes."Account Type";
                    "Account No":=ExpenseCodes."Account No";
                    "Account Name":=ExpenseCodes."Account Name";
                end;
            end;
        }
        field(4; Expense; Text[50])
        {
        }
        field(5; Type;Enum "Purchase Line Type")
        {
        }
        field(6; "Account No"; Code[20])
        {
        }
        field(7; "Account Name"; Text[50])
        {
        }
        field(8; Narration; Text[250])
        {
        }
        field(9; "Request Amount"; Decimal)
        {
            Editable = false;

            trigger OnValidate()
            begin
                if "Request Amount" < 0 then Error('Request amount cannot be less than Zero');
                Difference:="Request Amount" - "Actual Spent";
                if Difference > 0 then begin
                    Refund:=Abs(Difference);
                    Claim:=0;
                end
                else if Difference < 0 then begin
                        Refund:=0;
                        Claim:=Abs(Difference);
                    end
                    else
                    begin
                        Refund:=0;
                        Claim:=0;
                    end;
                BudgetMgt.ValidateImprestBudget(Rec, "Request Amount");
            end;
        }
        field(10; "Actual Spent"; Decimal)
        {
            trigger OnValidate()
            begin
                if "Request Amount" < 0 then Error('Amount cannot be less than Zero');
                Difference:="Request Amount" - "Actual Spent";
                if Difference > 0 then begin
                    Refund:=Abs(Difference);
                    Claim:=0;
                end
                else if Difference < 0 then begin
                        Refund:=0;
                        Claim:=Abs(Difference);
                    end
                    else
                    begin
                        Refund:=0;
                        Claim:=0;
                    end;
                BudgetMgt.ValidateImprestBudget(Rec, "Actual Spent");
            end;
        }
        field(11; Claim; Decimal)
        {
            Editable = false;
        }
        field(12; Refund; Decimal)
        {
            Editable = false;
        }
        field(13; Difference; Decimal)
        {
            Editable = false;
        }
        field(15; "Currency Code"; Code[10])
        {
            TableRelation = Currency;
        }
        field(17; UoM; Code[10])
        {
            TableRelation = "Unit of Measure";
        }
        field(18; Quantity; Decimal)
        {
            trigger OnValidate()
            begin
                Validate("Unit Cost");
            end;
        }
        field(19; "Unit Cost"; Decimal)
        {
            trigger OnValidate()
            begin
                "Request Amount":=Quantity * "Unit Cost";
                Validate("Request Amount");
            end;
        }
        field(20; "PV No"; Code[20])
        {
        }
        field(21; "PO No."; Code[20])
        {
        }
        field(22; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            Editable = false;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
        }
        field(23; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            Editable = false;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));
        }
        field(24; "Global Dimension 3 Code"; Code[20])
        {
            CaptionClass = '1,2,3';
            Caption = 'Global Dimension 3 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(3), Blocked=const(false));
        }
        field(25; "Claim Quantity"; Decimal)
        {
            Caption = 'Quantity';

            trigger OnValidate()
            begin
                Validate("Claim Unit Cost");
            end;
        }
        field(26; Commited; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(27; "Budget Available"; Boolean)
        {
        }
        field(28; "Tax Percentage"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(29; "Net Allowance Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Claim Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';

            trigger OnValidate()
            begin
                if(("Claim Quantity" <> 0) And ("Claim Unit Cost" <> 0))then Validate("Actual Spent", ("Claim Quantity" * "Claim Unit Cost"));
            end;
        }
        field(31; Date; Date)
        {
        }
        field(33; "Tax Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(34; "Employee No"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee;

            trigger OnValidate()
            begin
                IF Employee.GET("Employee No")THEN BEGIN
                    "Employee Name":=Employee.FullName;
                //Employee.TESTFIELD(Grade);
                //"CBS Member Id":=Employee."Sub-County";
                END
                ELSE
                    "Employee Name":='';
            end;
        }
        field(35; "Employee Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(36; "Payroll Scale"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(37; "Nature Of Employment"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Contract,Permanent,Board';
            OptionMembers = " ", Contract, Permanent, Board;
        }
    }
    keys
    {
        key(Key1; "No.", "Line No")
        {
        }
    }
    trigger OnDelete()
    begin
        if RequestHeader.Get("No.")then begin
            if RequestHeader."Request Type" = RequestHeader."Request Type"::"Staff Claim" then RequestHeader.TestField(Status, RequestHeader.Status::Open)
            else
            begin
                RequestHeader.TestField("Request Type", RequestHeader."Request Type"::Imprest);
                RequestHeader.TestField(Status, RequestHeader.Status::Open);
            end;
        end;
    end;
    trigger OnModify()
    begin
        if RequestHeader.Get("No.")then begin
            if RequestHeader."Request Type" = RequestHeader."Request Type"::"Staff Claim" then RequestHeader.TestField("Claim Posted", false)
            else
                RequestHeader.TestField(Surrendered, false);
        end;
    end;
    var ExpenseCodes: Record "Expense Codes";
    RequestHeader: Record "Request Header";
    BudgetMgt: Codeunit "Budget Management";
    HRSetup: Record "Human Resources Setup";
    Employee: Record Employee;
}

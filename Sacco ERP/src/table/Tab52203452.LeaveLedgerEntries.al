table 52203452 "Leave Ledger Entries"
{
    DrillDownPageId = "HR Leave Ledger Entries";
    LookupPageId = "HR Leave Ledger Entries";

    fields
    {
        field(5; "Start Date"; Date)
        {
        }
        field(6; "End Date"; Date)
        {
        }
        field(10; "Entry No."; Integer)
        {
        }
        field(20; "Application No."; Code[20])
        {
        }
        field(25; Description; Text[250])
        {
        }
        field(30; "Employee No."; Code[20])
        {
            TableRelation = Employee;
        }
        field(40; "Leave Type"; Code[20])
        {
            TableRelation = "Leave Types".Code;
        }
        field(50; "Posting Date"; Date)
        {
        }
        field(60; "Employee Name"; Text[250])
        {
        }
        field(70; Quantity; Decimal)
        {
        }
        field(80; "Department Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
        }
        field(122; "Entered By"; Code[70])
        {
        }
        field(123; "Leave Year Code"; Code[30])
        {
            TableRelation = "Leave Calendar";
        }
        field(124; "Leave Entry Type"; Option)
        {
            Caption = 'Leave Entry Type';
            Editable = true;
            OptionCaption = 'Positive Adjustment,Leave Taken,Reimbursement,Opening Balance,Accrued';
            OptionMembers = Positive, Negative, Reimbursement, OpeinigBalance, Accrued;
        }
        field(125; "Leave Approval Date"; Date)
        {
            Caption = 'Leave Approval Date';
            Editable = false;
        }
        field(126; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(128; "Global Dimension 1 Code"; Code[70])
        {
            CalcFormula = Lookup(Employee."Global Dimension 1 Code" WHERE("No."=FIELD("Employee No.")));
            CaptionClass = '1,2,1';
            FieldClass = FlowField;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));

            trigger OnValidate()
            begin
            /*ValidateShortcutDimCode(1,"Shortcut Dimension 1 Code");
                   Rec.Modify;
                    */
            end;
        }
        field(129; "Global Dimension 2 Code"; Code[70])
        {
            CalcFormula = Lookup(Employee."Global Dimension 2 Code" WHERE("No."=FIELD("Employee No.")));
            CaptionClass = '1,2,2';
            FieldClass = FlowField;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));

            trigger OnValidate()
            begin
            /*ValidateShortcutDimCode(2,"Shortcut Dimension 2 Code");
                   Rec.Modify;*/
            end;
        }
        field(137; "Leave Application No."; Code[20])
        {
            Caption = 'Leave Application No.';
            TableRelation = "Leave Applications"."No.";

            trigger OnValidate()
            begin
            // IF "Leave Application No." = '' THEN BEGIN
            //  CreateDim(DATABASE::Insurance,"Leave Application No.");
            //  EXIT;
            // end;
            // Insurance.RESET;
            // Insurance.SETRANGE(Insurance."Application Code","Leave Application No.");
            // IF Insurance.FIND('-')THEN BEGIN
            // //Insurance.GET("Leave Application No.");
            // //Insurance.TESTFIELD(Blocked,FALSE);
            // Description := Insurance."Applicant Comments";
            // "Leave Approval Date":=Insurance."Start Date";
            // "No. of Days":=Insurance."Approved days";
            // "Leave Type":=Insurance."Leave Type";
            // end;
            // CreateDim(DATABASE::Insurance,"Leave Application No.");
            end;
        }
        field(138; "Journal Batch Name"; Code[50])
        {
        }
        field(140; Closed; Boolean)
        {
        }
    }
    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Employee No.", "Leave Type")
        {
        }
    }
}

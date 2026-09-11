table 52203672 "HR Individual Targets Header"
{
    fields
    {
        field(1; "Appraisal No"; Code[30])
        {
            trigger OnValidate()
            begin
                /*IF "Appraisal no" <> xRec."Appraisal no" THEN BEGIN
                  HRSetup.GET;
                  NoSeriesMgt.TestManual(HRSetup."Appraisal Nos");
                  "No series" := '';
                end; */
                if "Appraisal No" <> xRec."Appraisal No" then begin
                    HRSetup.Get;
                    NoSeriesMgt.TestManual(HRSetup."Appraisal Nos");
                    "No series":='';
                end;
            end;
        }
        field(2; "Appraisal Period"; Code[40])
        {
            Editable = true;
            TableRelation = "Appraisal Calender"."Calendar Code";
        }
        field(3; "Appraisal Date"; Date)
        {
        }
        field(4; "Employee No"; Code[40])
        {
            Editable = false;
            TableRelation = Employee;

            trigger OnValidate()
            begin
                HREmp.Reset;
                if HREmp.Get("Employee No")then "Employee Name":=HREmp."First Name" + ' ' + HREmp."Middle Name" + ' ' + HREmp."Last Name"
                else
                    "Employee Name":=' ';
            end;
        }
        field(5; "Financial Targeted Score"; Decimal)
        {
            CalcFormula = Sum("Individual Target Line"."Targeted Score" WHERE("Perspective Type"=FILTER("Financial Stewardship"), "Appraisal No"=FIELD("Appraisal No")));
            FieldClass = FlowField;
        }
        field(7; "Achieved Financial  Score"; Decimal)
        {
            CalcFormula = Sum("Individual Target Line"."Achieved Score" WHERE("Perspective Type"=FILTER("Financial Stewardship"), "Appraisal No"=FIELD("Appraisal No")));
            FieldClass = FlowField;
        }
        field(8; "Unachieved Targets"; Decimal)
        {
            CalcFormula = Sum("Individual Target Line"."Unachieved Targets" WHERE("Appraisal No"=FIELD("Appraisal No")));
            FieldClass = FlowField;
        }
        field(9; "Employee Name"; Text[200])
        {
            Editable = false;
        }
        field(10; "Training Targeted Score"; Decimal)
        {
            CalcFormula = Sum("Individual Target Line"."Targeted Score" WHERE("Perspective Type"=FILTER("Training and Development"), "Appraisal No"=FIELD("Appraisal No")));
            FieldClass = FlowField;
        }
        field(11; "Service Delivery Target Score"; Decimal)
        {
            CalcFormula = Sum("Individual Target Line"."Targeted Score" WHERE("Perspective Type"=FILTER("Service Delivery"), "Appraisal No"=FIELD("Appraisal No")));
            FieldClass = FlowField;
        }
        field(12; "Customer Target Score"; Decimal)
        {
            CalcFormula = Sum("Individual Target Line"."Targeted Score" WHERE("Perspective Type"=FILTER("Customer and Sales"), "Appraisal No"=FIELD("Appraisal No")));
            FieldClass = FlowField;
        }
        field(13; "Customer Achieved  Score"; Decimal)
        {
            CalcFormula = Sum("Individual Target Line"."Achieved Score" WHERE("Perspective Type"=FILTER("Customer and Sales"), "Appraisal No"=FIELD("Appraisal No")));
            FieldClass = FlowField;
        }
        field(14; "Service Delivery Achieved"; Decimal)
        {
            CalcFormula = Sum("Individual Target Line"."Achieved Score" WHERE("Perspective Type"=FILTER("Service Delivery"), "Appraisal No"=FIELD("Appraisal No")));
            FieldClass = FlowField;
        }
        field(15; "Training Achieved  Score"; Decimal)
        {
            CalcFormula = Sum("Individual Target Line"."Achieved Score" WHERE("Perspective Type"=FILTER("Training and Development"), "Appraisal No"=FIELD("Appraisal No")));
            FieldClass = FlowField;
        }
        field(16; Status; Option)
        {
            Editable = true;
            OptionCaption = 'Open,Pending Approval,Discussed,Approved,Posted,Closed';
            OptionMembers = Open, "Pending Approval", Discussed, Approved, Posted, Closed;
        }
        field(17; "Responsibility Center"; Code[30])
        {
            Editable = true;
        }
        field(18; "Global Dimension 1 Code"; Code[30])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
        }
        field(19; "Global Dimension 2 Code"; Code[30])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));
        }
        field(20; "Shortcut Dimension 3 Code"; Code[30])
        {
            CaptionClass = '1,2,3';
            Caption = 'Shortcut Dimension 3 Code';
            Description = 'Stores the reference of the Third global dimension in the database';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(3));
        }
        field(21; "Shortcut Dimension 4 Code"; Code[30])
        {
            CaptionClass = '1,2,4';
            Caption = 'Shortcut Dimension 4 Code';
            Description = 'Stores the reference of the Third global dimension in the database';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(4));
        }
        field(22; "Appraisal Type"; Option)
        {
            Editable = true;
            OptionCaption = 'Target Setting,Quarter 1,Appraisal Review,Quarter 3,End Year Appraisal';
            OptionMembers = "Target Setting", "Quarter 1", "Appraisal Review", "Quarter 3", "End Year Appraisal";
        }
        field(23; "No series"; Code[30])
        {
        }
        field(24; "Appraisal Year"; Integer)
        {
            Editable = true;
        }
        field(25; "Finance Rating"; Decimal)
        {
            CalcFormula = Sum("Individual Target Line"."Agreed Rating" WHERE("Appraisal No"=FIELD("Appraisal No"), "Perspective Code"=CONST(1)));
            FieldClass = FlowField;
            MaxValue = 25;

            trigger OnValidate()
            begin
            // test:=HRIndividualTargetLine.COUNT;
            // MESSAGE('%1',test);
            end;
        }
        field(26; "Customer Rating"; Decimal)
        {
            CalcFormula = Sum("Individual Target Line"."Agreed Rating" WHERE("Appraisal No"=FIELD("Appraisal No"), "Perspective Code"=CONST(2)));
            FieldClass = FlowField;
        }
        field(27; "Training Rating"; Decimal)
        {
            CalcFormula = Sum("Individual Target Line"."Agreed Rating" WHERE("Appraisal No"=FIELD("Appraisal No"), "Perspective Code"=CONST(3)));
            FieldClass = FlowField;
        }
        field(28; "Service Rating"; Decimal)
        {
            CalcFormula = Sum("Individual Target Line"."Agreed Rating" WHERE("Appraisal No"=FIELD("Appraisal No"), "Perspective Code"=CONST(4)));
            FieldClass = FlowField;
        }
        field(29; "Overall Rating"; Decimal)
        {
            CalcFormula = Sum("Individual Target Line"."Agreed Rating" WHERE("Appraisal No"=FIELD("Appraisal No")));
            FieldClass = FlowField;
        }
        field(30; "Finance Perc Score"; Decimal)
        {
        }
        field(31; "Customer Perc Score"; Decimal)
        {
        }
        field(32; "Training Perc Score"; Decimal)
        {
        }
        field(33; "Service Perc Score"; Decimal)
        {
        }
        field(34; "Overall Perc Score"; Decimal)
        {
        }
        field(36; Finance; Integer)
        {
            CalcFormula = Count("Individual Target Line" WHERE("Appraisal No"=FIELD("Appraisal No"), "Perspective Code"=CONST(1)));
            FieldClass = FlowField;
        }
        field(37; Customer; Integer)
        {
            CalcFormula = Count("Individual Target Line" WHERE("Appraisal No"=FIELD("Appraisal No"), "Perspective Code"=CONST(2)));
            FieldClass = FlowField;
        }
        field(38; Training; Integer)
        {
            CalcFormula = Count("Individual Target Line" WHERE("Appraisal No"=FIELD("Appraisal No"), "Perspective Code"=CONST(3)));
            FieldClass = FlowField;
        }
        field(39; Service; Integer)
        {
            CalcFormula = Count("Individual Target Line" WHERE("Appraisal No"=FIELD("Appraisal No"), "Perspective Code"=CONST(4)));
            FieldClass = FlowField;
        }
        field(40; "User ID"; Code[100])
        {
            Editable = false;
        }
        field(41; "Supervisor ID"; Code[80])
        {
            Editable = false;
            TableRelation = "User Setup"."User ID";
        }
        field(42; "Supervisor Name"; Text[100])
        {
            Editable = false;
        }
        field(43; "Lock appraisal"; Boolean)
        {
            Editable = false;
        }
        field(44; "Total score"; Decimal)
        {
        }
    }
    keys
    {
        key(Key1; "Appraisal No")
        {
        }
    }
    trigger OnInsert()
    begin
        if "Appraisal No" = '' then begin
            HRSetup.Get;
            HRSetup.TestField(HRSetup."Appraisal Nos");
            NoSeriesMgt.InitSeries(HRSetup."Appraisal Nos", xRec."No series", 0D, "Appraisal No", "No series");
        end;
        /*
         //check if period is for capturing target setting or achievement then fill the necessary fields----
         HRSetup.RESET;
         HRSetup.GET;
        "Appraisal Type":=fnAppraisalType;
        "Appraisal Period":=fnAppraisalDate;
        */
        "Appraisal Date":=WorkDate;
        "Employee No":=CurrentEmployee;
        "User ID":=UserId;
        "Employee Name":=EmployeeNames;
        "Supervisor ID":=SupervisorCode;
        "Supervisor Name":=SupervisorName;
    //Status:=Status::Open;   
    end;
    trigger OnModify()
    begin
    //"Finance Perc Score":=("Finance Rating"*25)/(Finance2*5)
    end;
    var HRSetup: Record "Human Resources Setup";
    NoSeriesMgt: Codeunit NoSeriesManagement;
    HREmp: Record Employee;
    HRIndividualTargetLine: Record "Individual Target Line";
    EmployeeNames: Text;
    i: Integer;
    HRIndividualTargetsHeader: Record "Individual Targets Header";
    HRIndividualTargetLine_2: Record "Individual Target Line";
    SupervisorCode: Code[20];
    SupervisorName: Text;
    procedure CreateLedgerEntries()
    begin
    /*IF (Status=Status::Approved) AND ("Appraisal Type" = "Appraisal Type"::"Quarter 1") THEN ERROR('Appraisal has already been posted');


            HRSetup.RESET;
            IF HRSetup.FIND('-') THEN
            BEGIN
                HRSetup.TESTFIELD(HRSetup."Appraisal Template");
                HRSetup.TESTFIELD(HRSetup."Appraisal Batch");
                HRSetup.TESTFIELD(HRSetup."Appraisal Posting Period[FROM]");
                HRSetup.TESTFIELD(HRSetup."Appraisal Posting Period[TO]");

                HRAppraisalJournalLine.RESET;
                HRAppraisalJournalLine.SETRANGE("Journal Template Name",HRSetup."Appraisal Template");
                HRAppraisalJournalLine.SETRANGE("Journal Batch Name",HRSetup."Appraisal Batch");
                HRAppraisalJournalLine.DELETEALL;

                HREmp.RESET;
                HREmp.GET("Employee No");

                "LineNo.":=10000;
                //Get the lines
                HRIndividualTargetLine.RESET;
                HRIndividualTargetLine.SETRANGE(HRIndividualTargetLine."Appraisal No","Appraisal No");
                IF HRIndividualTargetLine.FIND('-') THEN
                BEGIN
                    REPEAT
                      //Populate Journal
                      "LineNo.":="LineNo."+10000;
                      HRAppraisalJournalLine.INIT;
                      HRAppraisalJournalLine."Journal Template Name":=HRSetup."Appraisal Template";
                      HRAppraisalJournalLine."Journal Batch Name":=HRSetup."Appraisal Batch";
                      HRAppraisalJournalLine."Line No.":="LineNo.";
                      HRAppraisalJournalLine."Appraisal Period":=FORMAT(HRSetup."Appraisal Posting Period[FROM]") + ' '
                                                                + FORMAT(HRSetup."Appraisal Posting Period[TO]");
                      HRAppraisalJournalLine."Appraisal No.":="Appraisal No";
                      HRAppraisalJournalLine."Document No.":="Appraisal No";
                      HRAppraisalJournalLine."Staff No.":="Employee No";
                      HRAppraisalJournalLine.VALIDATE(HRAppraisalJournalLine."Staff No.");
                      HRAppraisalJournalLine."Posting Date":=TODAY;
                      HRAppraisalJournalLine."Appraisal Approval Date":=TODAY;
                      HRAppraisalJournalLine.Description:='BSC';
                      //HRIndividualTargetLine.CALCFIELDS(HRIndividualTargetLine."Perspective Type");
                      HRAppraisalJournalLine."Appraisal Type":=HRIndividualTargetLine."Perspective Type";
                      HRAppraisalJournalLine."Appraisal Period Start Date":=HRSetup."Appraisal Posting Period[FROM]";
                      HRAppraisalJournalLine."Appraisal Period End Date":=HRSetup."Appraisal Posting Period[TO]";
                      HRAppraisalJournalLine.Score:=HRIndividualTargetLine."Targeted Score";
                      HRAppraisalJournalLine."Self Rating":=HRIndividualTargetLine."Self Rating";
                      HRAppraisalJournalLine."Supervisor Rating":=HRIndividualTargetLine."Supervisor Rating";
                      HRAppraisalJournalLine."Agreed Rating":=HRIndividualTargetLine."Agreed Rating";
                      HRAppraisalJournalLine.INSERT(TRUE);
                  UNTIL HRIndividualTargetLine.NEXT=0;
                end;
                      //Post Journal
                      HRAppraisalJournalLine.RESET;
                      HRAppraisalJournalLine.SETRANGE("Journal Template Name",HRSetup."Appraisal Template");
                      HRAppraisalJournalLine.SETRANGE("Journal Batch Name",HRSetup."Appraisal Batch");
                      IF HRAppraisalJournalLine.FIND('-') THEN
                      BEGIN
                       CODEUNIT.RUN(CODEUNIT::Codeunit39003911,HRAppraisalJournalLine);
                      end;

                      Status:=Status::Posted;
                     Rec.Modify;

            end;
            */
    end;
    procedure CurrentEmployee()EmployeeCD: Code[50]begin
        HREmp.RESET;
        HREmp.SETRANGE(HREmp."User ID", UserId);
        IF HREmp.FIND('-')THEN BEGIN
            EmployeeCD:=HREmp."No.";
            EmployeeNames:=HREmp."First Name" + ' ' + HREmp."Middle Name" + ' ' + HREmp."Last Name";
        // SupervisorCode := HREmp."Supervisor Code";
        // SupervisorName := HREmp."Supervisor Name";
        END
        ELSE
        BEGIN
            ERROR('The user id or supervisor id has not been setup in the HR offices')end;
    end;
    procedure loadtheyearsTarget()
    begin
        i:=0;
        HRIndividualTargetLine.Reset;
        if HRIndividualTargetLine.Find('+')then i:=HRIndividualTargetLine."Line No" + 1;
        HRIndividualTargetsHeader.Reset;
        HRIndividualTargetsHeader.SetRange(HRIndividualTargetsHeader."Appraisal Year", "Appraisal Year");
        HRIndividualTargetsHeader.SetRange(HRIndividualTargetsHeader."Employee No", "Employee No");
        HRIndividualTargetsHeader.SetRange(HRIndividualTargetsHeader."Appraisal Type", HRIndividualTargetsHeader."Appraisal Type"::"Quarter 1");
        if HRIndividualTargetsHeader.Find('-')then begin
            HRIndividualTargetLine.Reset;
            HRIndividualTargetLine.SetRange(HRIndividualTargetLine."Appraisal No", HRIndividualTargetsHeader."Appraisal No");
            if HRIndividualTargetLine.Find('-')then begin
                repeat HRIndividualTargetLine_2.Init;
                    HRIndividualTargetLine_2."Line No":=i;
                    HRIndividualTargetLine_2."Appraisal No":="Appraisal No";
                    HRIndividualTargetLine_2."Perspective Code":=HRIndividualTargetLine."Perspective Code";
                    HRIndividualTargetLine_2."Targeted Score":=HRIndividualTargetLine."Targeted Score";
                    HRIndividualTargetLine_2."Unachieved Targets":=HRIndividualTargetLine."Unachieved Targets";
                    HRIndividualTargetLine_2."Appraisee Comments":=HRIndividualTargetLine."Appraisee Comments";
                    HRIndividualTargetLine_2.Objective:=HRIndividualTargetLine.Objective;
                    HRIndividualTargetLine_2."Start Date":=HRIndividualTargetLine."Start Date";
                    HRIndividualTargetLine_2."End Date":=HRIndividualTargetLine."End Date";
                    //HRIndividualTargetLine_2."Appraisal Period":="Appraisal Period";
                    HRIndividualTargetLine_2."Perspective Description":=HRIndividualTargetLine."Perspective Description";
                    HRIndividualTargetLine_2."Perspective Type":=HRIndividualTargetLine."Perspective Type";
                    HRIndividualTargetLine_2.Insert;
                    i:=i + 1;
                until HRIndividualTargetLine.Next = 0 end end end;
}

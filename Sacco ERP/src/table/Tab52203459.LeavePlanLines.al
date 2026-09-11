table 52203459 "Leave Plan Lines"
{
    fields
    {
        field(2; "Plan No."; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                If LeavePlan.Get("Plan No.")then Validate("Employee Code.", LeavePlan."Employee No.");
            end;
        }
        field(3; "Employee Code."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Leave Code"; Code[30])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                LeaveBalance: Decimal;
                PlannedDays: Decimal;
            begin
                if "Leave Code" <> '' then begin
                    if LeaveTypes.Get("Leave Code")then "Leave Type Description":=LeaveTypes.Description;
                    LeavePlan.Get("Plan No.");
                    LeaveBalance:=HumanResourceMgmt.GetLeaveBalance("Employee Code.", "Leave Code", LeavePlan."Leave Calendar Code");
                    PlannedDays:=GetPreviouslyPlannedLeaveDays(Rec."Plan No.", Rec."Employee Code.", "Leave Code");
                    "Leave Balance":=LeaveBalance - PlannedDays;
                    if "Leave Balance" <= 0 then Error('Leave Balance is %1', "Leave Balance");
                end;
            end;
        }
        field(5; "Leave Type Description"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Leave Balance"; Decimal)
        {
        }
        field(7; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if xRec."Start Date" <> Rec."Start Date" then begin
                    if "Start Date" = 0D then begin
                        "End Date":=0D;
                        Days:=0;
                        "Weekend Days":=0;
                        HoliDay:=0;
                        "Days Planned":=0;
                        exit;
                    end;
                end;
                if "Start Date" <= Today then Error('Please Use a future Date for Applications');
                if Rec."Start Date" <> xRec."Start Date" then "End Date":=0D;
                if(("Start Date" > "End Date") and ("End Date" <> 0D))then begin
                    Error('Start Date Cannot be After End Date');
                end;
                if(("Start Date" <> 0D) and ("End Date" <> 0D))then "Total No Of Days":="End Date" - "Start Date";
                HoliDay:=0;
                IF "Start Date" <> 0D THEN BEGIN
                    LeavePlanLines.RESET;
                    LeavePlanLines.SETRANGE("Employee Code.", Rec."Employee Code.");
                    LeavePlanLines.SETRANGE("Plan No.", Rec."Plan No.");
                    LeavePlanLines.SETFILTER("End Date", '>%1', Rec."Start Date");
                    LeavePlanLines.SETFILTER("Line No", '<>%1', Rec."Line No");
                    IF LeavePlanLines.FINDFIRST THEN ERROR('You have already planned for this period (%1)', LeavePlanLines.GETFILTERS);
                end;
            end;
        }
        field(8; "End Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                TempDate: Date;
            begin
                if "End Date" = 0D then exit;
                Rec.Testfield("Start Date");
                if(("Start Date" > "End Date") and ("End Date" <> 0D))then begin
                    Error('Start Date Cannot be After End Date');
                end;
                if(("Start Date" <> 0D) and ("End Date" <> 0D))then begin
                    "Total No Of Days":=("End Date" - "Start Date") + 1;
                end;
                HoliDay:=0;
                LeaveTypes.Get("Leave Code");
                Weekends:=0;
                TempDate:=Rec."Start Date";
                if Date.Get(Date."Period Type"::Date, TempDate)then begin
                    if((Date."Period Name" = 'Sunday') and (LeaveTypes."Inclusive of Sunday" = false))then TempDate:=CalcDate('+1D', TempDate)
                    else if((Date."Period Name" = 'Saturday') and (LeaveTypes."Inclusive of Saturday" = false))then begin
                            if LeaveTypes."Inclusive of Sunday" = false then TempDate:=CalcDate('+2D', TempDate)
                            else
                                TempDate:=CalcDate('+1D', TempDate);
                        end;
                end;
                if TempDate <> 0D then begin
                    repeat if Date.Get(Date."Period Type"::Date, TempDate)then begin
                            if((Date."Period Name" = 'Sunday') and (LeaveTypes."Inclusive of Sunday" = false))then Weekends+=1;
                            if((Date."Period Name" = 'Saturday') and (LeaveTypes."Inclusive of Saturday" = false))then Weekends+=1;
                        end;
                        TempDate:=CalcDate('+1D', TempDate);
                    until TempDate = "End Date";
                end;
                LeaveSetup.Get;
                LeaveSetup.TestField("Base Calender");
                NonWorkingDaysDates.Reset;
                if NonWorkingDaysDates.FindFirst then begin
                    repeat if((NonWorkingDaysDates.Date >= "Start Date") and (NonWorkingDaysDates.Date <= "End Date"))then begin
                            HoliDay+=1;
                        end;
                    until NonWorkingDaysDates.Next = 0;
                end;
                "Weekend Days":=Weekends;
                Holidays:=HoliDay;
                LeaveTypes.Get("Leave Code");
                if LeaveTypes."Inclusive of Holidays" and LeaveTypes."Inclusive of Saturday" and LeaveTypes."Inclusive of Sunday" then begin
                    Weekends:=0;
                end;
                "Days Planned":="Total No Of Days" - HoliDay - Weekends;
                if "Days Planned" > "Leave Balance" then Error('Leave Days cannot be more than %1', "Leave Balance");
            end;
        }
        field(9; "Days Planned"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                IntDays: Integer;
                NewDate: Date;
                HDays: Integer;
                TotDays: Integer;
                i: Integer;
            begin
            end;
        }
        field(10; Holidays; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Weekend Days"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Total No Of Days"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(13; Days; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Line No"; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(15; "Global Dimension 1 Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Leave Calender"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(17; Status; Option)
        {
            CalcFormula = Lookup("Leave Plan".Status WHERE("No."=FIELD("Plan No.")));
            FieldClass = FlowField;
            OptionCaption = 'Open,Pending Approval,Approved,Rejected,Taken';
            OptionMembers = Open, "Pending Approval", Approved, Rejected, Taken;
        }
        field(18; "Employee Name"; Text[100])
        {
            CalcFormula = Lookup("Leave Plan"."Employee Name" WHERE("No."=FIELD("Plan No.")));
            FieldClass = FlowField;
        }
    }
    keys
    {
        key(Key1; "Plan No.", "Employee Code.", "Line No", "Global Dimension 1 Code", "Leave Calender")
        {
        }
    }
    trigger OnInsert()
    begin
        LeaveTypes.Reset;
        LeaveTypes.SetRange("Is Annual Leave", true);
        if LeaveTypes.FindFirst then "Leave Code":=LeaveTypes.Code
        else
            Error('No Leave type marked as annual was found');
        LeavePlan.Reset();
        LeavePlan.SetRange("No.", Rec."Plan No.");
        if LeavePlan.FindSet()then begin
            Rec."Leave Calender":=LeavePlan."Leave Calendar Code";
            LeaveLedger.Reset();
            LeaveLedger.SetRange("Employee No.", Rec."Employee Code.");
            LeaveLedger.SetRange(LeaveLedger."Leave Year Code", Rec."Leave Calender");
            LeaveLedger.Setfilter(LeaveLedger."Leave Type", 'ANNUAL');
            if LeaveLedger.FindSet()then begin
                LeaveLedger.CalcSums(Quantity);
                "Leave Balance":=LeaveLedger.Quantity;
            end;
        end;
    end;
    var LeaveTypes: Record "Leave Types";
    NonWorkingDaysDates: Record "Non Working Days & Dates";
    Date: Record Date;
    LeaveSetup: Record "Leave Setup";
    Weekends: Integer;
    HoliDay: Integer;
    HumanResourceMgmt: Codeunit "Human Resource Management";
    LeavePlan: Record "Leave Plan";
    LeavePlanLines: Record "Leave Plan Lines";
    LeaveLedger: Record "Leave Ledger Entries";
    local procedure GetPreviouslyPlannedLeaveDays(PlanNo: Code[30]; EmployeeCode: Code[40]; LeaveCode: Code[50]): Decimal var
        LeavePlanLines: Record "Leave Plan Lines";
    begin
        LeavePlanLines.Reset;
        LeavePlanLines.SetRange("Plan No.", PlanNo);
        LeavePlanLines.SetRange("Leave Code", LeaveCode);
        LeavePlanLines.SetRange("Employee Code.", EmployeeCode);
        if LeavePlanLines.FindSet then begin
            LeavePlanLines.CalcSums("Days Planned");
            exit(LeavePlanLines."Days Planned");
        end;
    end;
}

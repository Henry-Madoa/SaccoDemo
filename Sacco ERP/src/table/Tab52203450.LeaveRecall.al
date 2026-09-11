table 52203450 "Leave Recall"
{
    DrillDownPageID = "Leave Recalls";
    LookupPageID = "Leave Recalls";

    fields
    {
        field(1; "No."; Code[30])
        {
            Editable = false;
            NotBlank = false;
        }
        field(2; "Employee No"; Code[20])
        {
            Editable = true;
            NotBlank = false;
            TableRelation = Employee;

            trigger OnValidate()
            begin
                if Employee.Get("Employee No")then begin
                    Employee.TestField(Status, Employee.Status::Active);
                    Employee.TestField("Suspend Leave Application", false);
                    HumanResourcesSetup.Get;
                    if CalcDate(HumanResourcesSetup."Retirement Age", Employee."Birth Date") < Today then Error('You are beyond %1', HumanResourcesSetup."Retirement Age");
                    "Employee Name":=Format(Employee.Title) + Employee.FullName;
                    "Contact Address":=Employee.Address;
                    "Employee Phone No.":=Employee."Mobile Phone No.";
                    "Global Dimension 1 Code":=Employee."Global Dimension 1 Code";
                    Validate("Global Dimension 1 Code");
                    Validate("Supervisor Code", Employee."Manager No.");
                    "Global Dimension 2 Code":=Employee."Global Dimension 2 Code";
                    "Phone No.":=Employee."Phone No.";
                    Grade:=Employee."Job Scale";
                    "E-Mail Address":=Employee."E-Mail";
                end;
            end;
        }
        field(3; "Leave Status"; Option)
        {
            Editable = true;
            OptionCaption = 'Open,Submitted,Approved,Rejected,Canceled';
            OptionMembers = Open, Submitted, Approved, Rejected, Canceled;
        }
        field(4; Comments; Text[250])
        {
        }
        field(5; "No. series"; Code[10])
        {
        }
        field(6; "Employee Name"; Text[70])
        {
            Editable = false;
            TableRelation = Employee;
        }
        field(7; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Editable = false;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));

            trigger OnValidate()
            begin
                DimensionValue.Reset;
                DimensionValue.SetRange(Code, "Global Dimension 1 Code");
                if DimensionValue.FindFirst then begin
                    Employee.Reset;
                    Employee.SetRange("Global Dimension 1 Code", Rec."Global Dimension 1 Code");
                    Employee.SetFilter("Employee Status", '=%1|%2', Employee."Employee Status"::Active, Employee."Employee Status"::OnLeave);
                end;
            end;
        }
        field(8; "Hospital Name"; Text[50])
        {
        }
        field(9; "Doctor's Name"; Text[50])
        {
        }
        field(10; Attachment; Boolean)
        {
            Editable = false;
        }
        field(11; "Supervisor Code"; Code[100])
        {
            Editable = false;

            trigger OnValidate()
            begin
                //TBL LM 1.0 VKP 26/08/2016 START
                if UserSetup.Get("Supervisor Code")then begin
                    if Employee.Get(UserSetup."Employee No.")then "Supervisor Name":=Employee."First Name" + ' ' + Employee."Middle Name" + ' ' + Employee."Last Name";
                //TBL LM 1.0 VKP 26/08/2016 END
                end;
            end;
        }
        field(12; "Supervisor Name"; Text[70])
        {
            Editable = false;
        }
        field(13; "Total No. of Leaves Applied"; Decimal)
        {
            Editable = false;
            FieldClass = Normal;
        }
        field(14; "Date Filter"; Date)
        {
            FieldClass = FlowFilter;
        }
        field(15; Reliever; Code[100])
        {
            TableRelation = Employee;

            trigger OnValidate()
            begin
                if Employee.Get(Reliever)then begin
                    if Employee."No." = Rec."Employee No" then Error('You cannot relieve yourself');
                end;
                leaveApplication.Reset;
                leaveApplication.SetRange(Status, leaveApplication.Status::Approved);
                leaveApplication.SetFilter("End Date", '>%1', Rec."Start Date");
                leaveApplication.SetRange("Employee No", Rec.Reliever);
                if leaveApplication.FindFirst then Error('%1 is on leave between %2 and %3 which is within the period you are applying for', leaveApplication."Employee Name", leaveApplication."Start Date", leaveApplication."End Date");
                LeavePlan.Reset;
                LeavePlan.SetRange("Employee No.", Reliever);
                LeavePlan.SetRange(Status, LeavePlan.Status::Approved);
                LeavePlan.SetRange("Leave Calendar Code", Rec."Leave Calender Code");
                if LeavePlan.FindFirst then begin
                    LeavePlanLines.Reset;
                    LeavePlanLines.SetRange("Plan No.", LeavePlan."No.");
                    LeavePlanLines.SetRange("Employee Code.", LeavePlan."Employee No.");
                    LeavePlanLines.SetFilter("End Date", '>%1', Rec."Start Date");
                    if LeavePlanLines.FindFirst then Error('%1 has a leave planned between %2 and %3 ', LeavePlanLines."Start Date", LeavePlanLines."End Date");
                end;
                Employee.Reset;
                Employee.SetRange("No.", Reliever);
                if Employee.FindFirst then begin
                    "Reliever Name":=Employee."First Name" + ' ' + Employee."Last Name";
                end;
            end;
        }
        field(16; "Reliever Name"; Text[100])
        {
            Editable = false;
        }
        field(17; Status;Enum "Document Status")
        {
            Editable = false;

            trigger OnValidate()
            begin
                if Rec.Status = Rec.Status::Approved then OnLeaveRecallApproval(Rec);
            end;
        }
        field(18; "Approval Level"; Integer)
        {
            Editable = false;
        }
        field(19; "Action Id"; Code[200])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(20; "Current Level"; Integer)
        {
            Editable = false;
        }
        field(21; "Leave Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            InitValue = 'ANNUAL';
            TableRelation = "Leave Types".Code;

            trigger OnValidate()
            begin
                if "Leave Code" = '' then exit;
                if LeaveTypes.Get("Leave Code")then begin
                    "Leave Type Decription":=LeaveTypes.Description;
                    if Employee.Get("Employee No")then begin
                        if(LeaveTypes.Gender in[LeaveTypes.Gender::Female]) and (Employee.Gender in[Employee.Gender::Male])then Error('This Leave type is only applicable by %1', LeaveTypes.Gender);
                        if(LeaveTypes.Gender in[LeaveTypes.Gender::Male]) and (Employee.Gender in[Employee.Gender::Female])then Error('This Leave type is only applicable by %1', LeaveTypes.Gender);
                        if LeaveTypes."Special Categorization" in[LeaveTypes."Special Categorization"::Compasionate]then begin
                            LeaveTypesCopy.Reset;
                            LeaveTypesCopy.SetRange("Is Annual Leave", true);
                            if LeaveTypesCopy.FindFirst then begin
                                LeaveCalendar.Reset;
                                LeaveCalendar.SetRange("Current Leave Calendar", true);
                                if LeaveCalendar.FindFirst then begin
                                    LeaveEntries.Reset;
                                    LeaveEntries.SetRange("Employee No.", Rec."Employee No");
                                    LeaveEntries.SetRange("Leave Year Code", LeaveCalendar."Calendar Code");
                                    if LeaveEntries.FindSet then begin
                                        LeaveEntries.CalcSums(Quantity);
                                        if LeaveEntries.Quantity >= 2 then Error('You cannot apply for this kind of leave when you have more than 2 annual leave leave balance');
                                    end;
                                end;
                            end;
                        end;
                    end;
                end
                else
                    "Leave Type Decription":='';
                //GeneralSetup.GET;
                LeaveCalendar.Reset;
                LeaveCalendar.SetRange("Current Leave Calendar", true);
                if LeaveCalendar.FindFirst then begin
                    LeaveEntries.Reset;
                    LeaveEntries.SetRange("Employee No.", "Employee No");
                    LeaveEntries.SetRange("Leave Type", "Leave Code");
                    LeaveEntries.SetRange(Closed, false);
                    if LeaveEntries.FindFirst then begin
                        repeat Balance+=LeaveEntries.Quantity;
                        until LeaveEntries.Next = 0;
                    end
                    else
                        Message(LeaveEntries.GetFilters);
                end
                else
                    Error('There is No Leave Period Set Up');
                "Leave balance":=Balance;
            end;
        }
        field(22; "Days Applied"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = true;

            trigger OnValidate()
            begin
                if "Days Applied" > "Leave balance" then Error('You Cannot Apply for more than %1 Days', "Leave balance");
                if "Days Applied" = 0 then begin
                    Holidays:=0;
                    Weekends:=0;
                    "End Date":=0D;
                    "Reporting Date":=0D;
                    "Return Date":=0D;
                    Days:=0;
                    "Balance After":=0;
                    "Total No Of Days":=0;
                    exit;
                end;
                Holidays:=0;
                LeaveTypes.Get("Leave Code");
                Weekends:=0;
                TheDayToday:="Start Date";
                DaysCounted:=1;
                //EndDate:=CALCDATE(FORMAT("Days Applied")+'D',CALCDATE('-1D',"Start Date"));
                while(DaysCounted <= "Days Applied")do begin
                    if Date.Get(Date."Period Type"::Date, TheDayToday)then begin
                        if((Date."Period Name" = 'Sunday') or ((Date."Period Name" = 'Saturday')))then Weekends+=1
                        else
                            DaysCounted+=1;
                    end;
                    TheDayToday:=CalcDate('1D', TheDayToday);
                end;
                TheDayToday:="Start Date";
                while(TheDayToday <= CalcDate(Format("Days Applied" + Weekends) + 'D', "Start Date"))do begin
                    NonWorkingDaysDates.Reset;
                    NonWorkingDaysDates.SetRange(Date, TheDayToday);
                    if NonWorkingDaysDates.FindFirst then if Date.Get(Date."Period Type"::Date, TheDayToday)then begin
                            if(not(Date."Period Name" = 'Sunday') or (not(Date."Period Name" = 'Saturday')))then Holidays+=1;
                        end;
                    TheDayToday:=CalcDate('1D', TheDayToday);
                end;
                EndDate:=CalcDate(Format((Weekends + "Days Applied" + Holidays) - 1) + 'D', "Start Date");
                "End Date":=EndDate;
                "Weekend Days":=Weekends;
                Rec.Holidays:=Holidays;
                "Total No Of Days":=("Days Applied") + "Weekend Days" + Rec.Holidays;
                Days:="Days Applied";
                //"Return Date":=CALCDATE(FORMAT("Total No Of Days"+1)+'D',"Start Date");
                // IF Date.GET(Date."Period Type"::Date,"End Date") THEN BEGIN
                //    IF (Date."Period Name" = 'Sunday')THEN
                //      "End Date":=CALCDATE('-D',"End Date");
                //    IF (Date."Period Name" = 'Saturday')THEN
                //      "End Date":=CALCDATE('+2D',"End Date");
                //    end;            "Reporting Date" := "End Date";
                if Date.Get(Date."Period Type"::Date, "Reporting Date")then begin
                    if(Date."Period Name" = 'Sunday')then "Reporting Date":=CalcDate('+1D', "Reporting Date");
                    if(Date."Period Name" = 'Saturday')then "Reporting Date":=CalcDate('+2D', "Reporting Date");
                    if(Date."Period Name" = 'Friday')then "Reporting Date":=CalcDate('+3D', "Reporting Date");
                end;
                "Return Date":="Reporting Date";
                if Days > "Leave balance" then Error('Days cannot exceed %1', "Leave balance");
                "Balance After":="Leave balance" - Days;
                if "Days Applied" < 0 then "Days Applied":=0;
                Validate("Balance After");
            end;
        }
        field(23; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                TempDate: Date;
            begin
                if "Start Date" = 0D then exit;
                if UserSetup.Get(UserId)then if not UserSetup."Apply Leave Later Dater" then if "Start Date" <= Today then Error('Please Use a future Date for Applications');
                if(("Start Date" > "End Date") and ("End Date" <> 0D))then begin
                    Error('Start Date Cannot be After End Date');
                end;
                if LeaveTypes.Get("Leave Code")then begin
                    if LeaveTypes."Special Categorization" in[LeaveTypes."Special Categorization"::Partenity]then begin
                        LeaveTypes.TestField(Days);
                        NoDaysString:=Format(Format(LeaveTypes.Days) + 'D');
                        if Evaluate(NoDays, NoDaysString)then "End Date":=CalcDate(NoDays, "Start Date");
                        "Days Applied":=LeaveTypes.Days;
                        Days:=LeaveTypes.Days;
                        "Total No Of Days":=90;
                        "Weekend Days":=0;
                        Rec.Holidays:=0;
                        "Balance After":=0;
                        exit;
                    end;
                    if LeaveTypes."Special Categorization" in[LeaveTypes."Special Categorization"::Martenity]then begin
                        LeaveTypes.TestField(Days);
                        NoDaysString:=Format(Format(LeaveTypes.Days) + 'D');
                        if Evaluate(NoDays, NoDaysString)then "End Date":=CalcDate(NoDays, "Start Date");
                        "Days Applied":=LeaveTypes.Days;
                        Days:=LeaveTypes.Days;
                        "Total No Of Days":=90;
                        "Weekend Days":=0;
                        Rec.Holidays:=0;
                        "Balance After":=0;
                        exit;
                    end;
                end;
                if(("Start Date" <> 0D) and ("End Date" <> 0D))then "Total No Of Days":="End Date" - "Start Date";
                Holidays:=0;
                LeaveTypes.Get("Leave Code");
                leaveApplication.Reset;
                leaveApplication.SetRange("Employee No", Rec."Employee No");
                leaveApplication.SetRange("Leave Calender Code", Rec."Leave Calender Code");
                leaveApplication.SetRange(Status, leaveApplication.Status::Approved);
                leaveApplication.SetFilter("End Date", '%1..%2', Rec."Start Date", Rec."End Date");
                if leaveApplication.FindFirst then begin
                    Error('You have already applied for %1 Leave between %2 and %3', leaveApplication."Leave Code", leaveApplication."Start Date", leaveApplication."End Date");
                end;
                if xRec."Start Date" <> Rec."Start Date" then Validate("Days Applied");
            /*
                        Weekends:=0;
                        TempDate:="Start Date";
                        IF "End Date"<>0D THEN BEGIN
                          REPEAT
                            IF Date.GET(Date."Period Type"::Date,TempDate) THEN BEGIN
                              IF ((Date."Period Name" = 'Sunday') AND (LeaveTypes."Inclusive of Sunday"=FALSE)) THEN
                                Weekends+=1;
                              IF ((Date."Period Name" = 'Saturday') AND (LeaveTypes."Inclusive of Saturday"=FALSE)) THEN
                                Weekends+=1;
                            end;
                            TempDate:=CALCDATE('+1D',TempDate);
                          UNTIL TempDate ="End Date";
                        end;
                        GeneralSetup.GET;
                        GeneralSetup.TESTFIELD("Leave Base Calendar");
                        BaseCalendarChange.RESET;
                        BaseCalendarChange.SETRANGE(Code,GeneralSetup."Leave Base Calendar");
                        IF BaseCalendarChange.FINDFIRST THEN BEGIN
                          REPEAT
                            IF ((BaseCalendarChange.Date_ >="Start Date") AND (BaseCalendarChange.Date_<="End Date")) THEN
                              Holidays+=1;
                          UNTIL BaseCalendarChange.NEXT = 0;
                        end;
                        "Weekend Days":=Weekends;
                        "Days Applied":="Total No Of Days"-Holidays-Weekends;
                        VALIDATE("Days Applied");
                        */
            end;
        }
        field(24; "End Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                TempDate: Date;
            begin
                if "End Date" = 0D then exit;
                leaveApplication.Reset;
                leaveApplication.SetFilter(Status, '=%1|=%2', leaveApplication.Status::"Pending Approval", leaveApplication.Status::Approved);
                leaveApplication.SetRange("Employee No", Rec."Employee No");
                leaveApplication.SetRange("Start Date", Rec."Start Date", Rec."End Date");
                if leaveApplication.FindFirst then Error('You have applied leave No. %1 of type %2 at the same date', leaveApplication."No.", leaveApplication."Leave Type Decription");
                if LeaveTypes.Get("Leave Code")then begin
                    if LeaveTypes."Special Categorization" in[LeaveTypes."Special Categorization"::Partenity, LeaveTypes."Special Categorization"::Martenity]then Error('You cannot modify end date for this type of leave');
                end;
                if "End Date" = 0D then exit;
                if(("Start Date" > "End Date") and ("End Date" <> 0D))then begin
                    Error('Start Date Cannot be After End Date');
                end;
                if(("Start Date" <> 0D) and ("End Date" <> 0D))then begin
                    "Total No Of Days":=("End Date" - "Start Date") + 1;
                end;
                Holidays:=0;
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
                BaseCalendarChange.Reset;
                BaseCalendarChange.SetRange("Base Calendar Code", LeaveSetup."Base Calender");
                if BaseCalendarChange.FindFirst then begin
                    repeat if((BaseCalendarChange.Date >= "Start Date") and (BaseCalendarChange.Date <= "End Date"))then begin
                            Holidays+=1;
                        end;
                    until BaseCalendarChange.Next = 0;
                end;
                "Weekend Days":=Weekends;
                LeaveTypes.Get("Leave Code");
                if LeaveTypes."Inclusive of Holidays" and LeaveTypes."Inclusive of Saturday" and LeaveTypes."Inclusive of Sunday" then begin
                    Weekends:=0;
                    Holidays:=0;
                end;
                "Days Applied":="Total No Of Days" - Holidays - Weekends;
                if HumanResourceMgmt.CheckIfItsSickLeave("Leave Code")then exit;
                if LeaveTypes.Get("Leave Code")then begin
                    if LeaveTypes."Max Applicable Days" > 0 then if "Days Applied" > LeaveTypes."Max Applicable Days" then Error('You cannot apply more than %1 Days', LeaveTypes."Max Applicable Days");
                end;
                Validate("Days Applied");
            end;
        }
        field(25; "Application Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(26; "Leave balance"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(27; "User ID"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(28; "Half Day on Start Date"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(29; "Half Day on End Date"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Total No Of Days"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = true;

            trigger OnValidate()
            begin
                if "Total No Of Days" = 0 then exit;
                Holidays:=0;
                LeaveTypes.Get("Leave Code");
                Weekends:=0;
                TheDayToday:="Start Date";
                EndDate:=CalcDate(Format("Total No Of Days") + 'D', "Start Date");
                while(TheDayToday <= EndDate)do begin
                    if Date.Get(Date."Period Type"::Date, TheDayToday)then begin
                        if((Date."Period Name" = 'Sunday') or ((Date."Period Name" = 'Saturday')))then if(not LeaveTypes."Inclusive of Saturday") and (not LeaveTypes."Inclusive of Sunday")then Weekends+=1 end;
                    TheDayToday:=CalcDate('1D', TheDayToday);
                end;
                TheDayToday:="Start Date";
                EndDate:=CalcDate(Format("Total No Of Days") + 'D', "Start Date");
                while(TheDayToday <= EndDate)do begin
                    NonWorkingDaysDates.Reset;
                    NonWorkingDaysDates.SetRange(Date, TheDayToday);
                    if NonWorkingDaysDates.FindFirst then Holidays+=1;
                    TheDayToday:=CalcDate('1D', TheDayToday);
                end;
                "Weekend Days":=Weekends;
                Rec.Holidays:=Holidays;
                "Days Applied":="Total No Of Days" - ("Weekend Days" + Rec.Holidays);
                Days:="Total No Of Days" - ("Weekend Days" + Rec.Holidays);
                "End Date":=CalcDate(Format("Total No Of Days") + 'D', "Start Date");
                "Return Date":=CalcDate(Format("Total No Of Days" + 1) + 'D', "Start Date");
                if Date.Get(Date."Period Type"::Date, "End Date")then begin
                    if(Date."Period Name" = 'Sunday')then "End Date":=CalcDate('-1D', "End Date");
                    if(Date."Period Name" = 'Saturday')then "End Date":=CalcDate('-2D', "End Date");
                end;
                "Reporting Date":=CalcDate(Format("Total No Of Days" + 1) + 'D', "Start Date");
                if Date.Get(Date."Period Type"::Date, "Reporting Date")then begin
                    if(Date."Period Name" = 'Sunday')then "Reporting Date":=CalcDate('-1D', "Reporting Date");
                    if(Date."Period Name" = 'Saturday')then "Reporting Date":=CalcDate('-2D', "Reporting Date");
                end;
                if Date.Get(Date."Period Type"::Date, "Return Date")then begin
                    if(Date."Period Name" = 'Sunday')then "Return Date":=CalcDate('1D', "Return Date");
                    if(Date."Period Name" = 'Saturday')then "Return Date":=CalcDate('2D', "Return Date");
                end;
                if Days > "Leave balance" then Error('Days cannot exceed %1', "Leave balance");
                "Balance After":="Leave balance" - Days;
            end;
        }
        field(31; Holidays; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(32; "Weekend Days"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(33; Days; Decimal)
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
                Rec.Testfield("Start Date");
                NewDate:=0D;
                NewDate:="Start Date";
                HDays:=0;
                Weekends:=0;
                IntDays:=0;
                IntDays:=Days;
                LeaveTypes.Get("Leave Code");
                if Date.Get(Date."Period Type"::Date, NewDate)then begin
                    if((Date."Period Name" = 'Sunday') and (LeaveTypes."Inclusive of Sunday" = false))then NewDate:=CalcDate('+1D', NewDate)
                    else if((Date."Period Name" = 'Saturday') and (LeaveTypes."Inclusive of Saturday" = false))then begin
                            if LeaveTypes."Inclusive of Sunday" = false then NewDate:=CalcDate('+2D', NewDate)
                            else
                                NewDate:=CalcDate('+1D', NewDate);
                        end;
                end;
                i:=0;
                repeat if Date.Get(Date."Period Type"::Date, NewDate)then begin
                        if((Date."Period Name" = 'Sunday') and (LeaveTypes."Inclusive of Sunday" = false))then begin
                            Weekends+=1;
                            LeaveSetup.Get;
                            LeaveSetup.TestField("Base Calender");
                            BaseCalendarChange.Reset;
                            BaseCalendarChange.SetRange("Base Calendar Code", LeaveSetup."Base Calender");
                            BaseCalendarChange.SetRange(Date, NewDate);
                            if BaseCalendarChange.FindFirst then begin
                                HDays+=1;
                            end;
                        end
                        else if((Date."Period Name" = 'Saturday') and (LeaveTypes."Inclusive of Saturday" = false))then begin
                                Weekends+=1;
                            end
                            else
                            begin
                                LeaveSetup.Get;
                                LeaveSetup.TestField("Base Calender");
                                BaseCalendarChange.Reset;
                                BaseCalendarChange.SetRange("Base Calendar Code", LeaveSetup."Base Calender");
                                BaseCalendarChange.SetRange(Date, NewDate);
                                if BaseCalendarChange.FindFirst then begin
                                    HDays+=1;
                                end
                                else
                                begin
                                    i+=1;
                                end;
                            end;
                    end;
                    NewDate:=CalcDate('+1D', NewDate);
                until i = IntDays;
                Message('Days Applied %1, Weekends %2 Holidays %3 Total Days %4', IntDays, Weekends, HDays, (IntDays + Weekends + HDays));
                "End Date":=CalcDate('+' + Format(IntDays + Weekends + HDays) + 'D', "Start Date");
                Holidays:=HDays;
                "Weekend Days":=Weekends;
                "Total No Of Days":=(IntDays + Weekends + HDays);
                "Days Applied":=Days;
                Validate("End Date");
                Validate("Balance After");
            end;
        }
        field(34; "Balance After"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnValidate()
            begin
                "Balance After":="Leave balance" - "Days Applied";
                Validate("Reporting Date");
            end;
        }
        field(35; "Return Date"; Date)
        {
            Editable = false;
        }
        field(36; "Reporting Date"; Date)
        {
            Editable = false;

            trigger OnValidate()
            begin
                if Date.Get(Date."Period Type"::Date, "End Date")then begin
                    if Date."Period Name" = 'Sunday' then "Reporting Date":=CalcDate('+1D', "End Date")
                    else if Date."Period Name" = 'Saturday' then "Reporting Date":=CalcDate('+2D', "End Date")
                        else if Date."Period Name" = 'Friday' then "Reporting Date":=CalcDate('+3D', "End Date")
                            else
                                "Reporting Date":=CalcDate('+1D', "End Date")end;
            end;
        }
        field(37; "Created By"; Code[70])
        {
            TableRelation = "User Setup";
        }
        field(38; "Created On"; Date)
        {
        }
        field(39; "Contact Address"; Text[100])
        {
        }
        field(40; "Employee Phone No."; Code[20])
        {
        }
        field(41; "Leave Calender Code"; Code[40])
        {
        }
        field(42; Posted; Boolean)
        {
        }
        field(43; "Approval Entries"; Integer)
        {
            CalcFormula = Count("Approval Entry" WHERE("Document No."=FIELD("No.")));
            FieldClass = FlowField;
        }
        field(44; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));
        }
        field(45; "System Entry"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(46; "Leave Type Decription"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(47; "Appointment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(48; "Phone No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(49; "E-Mail Address"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50; Grade; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(51; "Exceeds Complement"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52; "Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(53; "Leave No.To Recall"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Leave Applications"."No." WHERE(Status=CONST(Approved), "Employee No"=FIELD("Employee No"), "Nature of Application"=CONST("Leave Application"));

            trigger OnValidate()
            begin
                leaveRecalls.Reset;
                leaveRecalls.SetRange(Status, leaveRecalls.Status::Approved);
                leaveRecalls.SetRange("Leave No.To Recall", Rec."Leave No.To Recall");
                if leaveRecalls.FindSet then begin
                    leaveRecalls.CalcSums("Days To Recall");
                end;
                if EmployeeLeaveApplication.Get("Leave No.To Recall")then "Balance To recall":=EmployeeLeaveApplication."Days Applied" - leaveRecalls."Days To Recall";
                if EmployeeLeaveApplication.Get("Leave No.To Recall")then begin
                    Rec."Start Date":=EmployeeLeaveApplication."Start Date";
                    Rec."End Date":=EmployeeLeaveApplication."End Date";
                    Rec."Days Applied":=EmployeeLeaveApplication."Days Applied";
                    Rec."Reporting Date":=EmployeeLeaveApplication."Reporting Date";
                    Rec."Total No Of Days":=EmployeeLeaveApplication."Total No Of Days";
                    Rec.Holidays:=EmployeeLeaveApplication.Holidays;
                    Rec."Weekend Days":=EmployeeLeaveApplication."Weekend Days";
                    Rec.Reliever:=EmployeeLeaveApplication.Reliever;
                    LeaveCalendar.Reset;
                    LeaveCalendar.SetRange("Current Leave Calendar", true);
                    LeaveCalendar.FindFirst;
                    LeaveEntries.Reset;
                    LeaveEntries.SetRange("Employee No.", "Employee No"); //MESSAGE('df %1',EmployeeLeaveApplication."Employee No");
                    LeaveEntries.SetRange("Leave Type", "Leave Code");
                    LeaveEntries.SetRange("Leave Year Code", Rec."Leave Calender Code");
                    if LeaveEntries.FindSet then begin
                        LeaveEntries.CalcSums(Quantity);
                    end;
                    "Leave balance":=LeaveEntries.Quantity;
                    "Balance After":="Leave balance";
                    Rec.Status:=Rec.Status::Open;
                    Posted:=false;
                    "User ID":=UserId;
                end;
            end;
        }
        field(54; "Recall as from"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(55; "Days To Recall"; Integer)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Days To Recall" > "Days Applied" then Error('Days to recall cannot be higher than %1', "Days Applied");
                if "Days To Recall" > "Balance To recall" then Error('Days to recall cannot be higher than %1', "Balance To recall");
                "Balance After":="Leave balance" + "Days To Recall";
            end;
        }
        field(56; "Balance To recall"; Integer)
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
    //TESTFIELD(Status,Status::New);
    end;
    trigger OnInsert()
    begin
        //  leaveRecalls.RESET;
        //  leaveRecalls.SETRANGE("Created By",USERID);
        //  leaveRecalls.SETRANGE(Status,EmployeeLeaveApplication.Status::New);
        //  IF leaveRecalls.FINDFIRST THEN
        //    ERROR('You cannot create another leave recall until leave No. %1 has been approved',leaveRecalls."Recall No");
        LeaveSetup.Get;
        LeaveSetup.TestField("Leave Recall");
        if "No." = '' then begin
            gCduNoSeriesMgt.InitSeries(LeaveSetup."Leave Recall", xRec."No. series", 0D, "No.", "No. series");
        end;
        "Application Date":=WorkDate;
        if not LoginMgmt.IsWebServiceUser then begin
            UserSetup.Get(UserId);
            UserSetup.TestField("Employee No.");
            "Employee No":=UserSetup."Employee No.";
        end;
        Validate("Employee No");
        "User ID":=UserId;
        "Created By":=UserId;
        "Created On":=WorkDate;
        Validate("Leave Code");
        LeaveCalendar.Reset;
        LeaveCalendar.SetRange("Current Leave Calendar", true);
        if LeaveCalendar.FindFirst then "Leave Calender Code":=LeaveCalendar."Calendar Code"
        else
            Error('No current calender was found');
    end;
    trigger OnRename()
    begin
        Error(Text000, TableCaption);
    end;
    [IntegrationEvent(false, false)]
    local procedure OnLeaveRecallApproval(var LeaveRecall: Record "Leave Recall")
    begin
    end;
    var HumanResourcesSetup: Record "Human Resources Setup";
    UserSetup: Record "User Setup";
    Employee: Record Employee;
    LeaveTypes: Record "Leave Types";
    gCduNoSeriesMgt: Codeunit NoSeriesManagement;
    gCduCalendarMgt: Codeunit "Calendar Management";
    CompanyInformation: Record "Company Information";
    gDateNextWorkingDate: Date;
    gTxtDescription: Text;
    BaseCalendarChange: Record "Base Calendar Change";
    Date: Record Date;
    Text000: Label 'You cannot rename  %1';
    LeaveSetup: Record "Leave Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    CalendarManagement: Codeunit "Calendar Management";
    LeaveEntries: Record "Leave Ledger Entries";
    EmployeeLeaveApplication: Record "Leave Applications";
    Balance: Decimal;
    Weekends: Integer;
    Holidays: Integer;
    AccountingPeriod: Record "Accounting Period";
    EmployeeLeave: Record "Leave Applications";
    LeaveCalendar: Record "Leave Calendar";
    leaveApplication: Record "Leave Applications";
    HumanResourceMgmt: Codeunit "Human Resource Management";
    LoginMgmt: Codeunit "User Management Ext";
    LeavePlanLines: Record "Leave Plan Lines";
    LeavePlan: Record "Leave Plan";
    NoDays: DateFormula;
    NoDaysString: Text;
    DimensionValue: Record "Dimension Value";
    MinNoEmployee: Integer;
    LeaveTypesCopy: Record "Leave Types";
    TheDayToday: Date;
    TheNextDay: Date;
    EndDate: Date;
    NoWeekendDays: Integer;
    NonWorkingDaysDates: Record "Non Working Days & Dates";
    DaysCounted: Integer;
    leaveRecalls: Record "Leave Recall";
}

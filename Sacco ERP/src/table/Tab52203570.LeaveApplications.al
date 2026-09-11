table 52203570 "Leave Applications"
{
    DrillDownPageID = "Leave Applications";
    LookupPageID = "Leave Applications";

    fields
    {
        field(1; "No."; Code[20])
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
                if Employee.Get("Employee No") then begin

                    IF LoginMgmt.IsWebServiceUser THEN BEGIN
                        "Created By" := Employee."User ID";
                        "User ID" := Employee."User ID";
                    End;

                    UserSetup.Reset();
                    UserSetup.SetRange("Employee No.", "Employee No");
                    if UserSetup.FindFirst then
                        "Is HOD" := UserSetup."Is HOD";

                    LeaveApplication.Reset;
                    LeaveApplication.SetRange("Employee No", "Employee No");
                    LeaveApplication.SetRange("Nature of Application", LeaveApplication."Nature of Application"::"Leave Application");
                    LeaveApplication.SetRange(Status, LeaveApplication.Status::Open);
                    if LeaveApplication.FindFirst THEN ERROR('You cannot create another Application until No. %1 has been approved', LeaveApplication."No.");
                    if "Nature of Application" in ["Nature of Application"::"Leave Application"] then begin
                        Employee.TestField(Status, Employee.Status::Active);
                        Employee.TestField("Suspend Leave Application", false);
                        "Employee Name" := Format(Employee.Title) + ' ' + Employee.FullName;
                        "Contact Address" := Employee.Address;
                        "Employee Phone No." := Employee."Mobile Phone No.";
                        "Global Dimension 1 Code" := Employee."Global Dimension 1 Code";
                        Validate("Global Dimension 1 Code");
                        Validate("Supervisor Code", Employee."Manager No.");
                        "Global Dimension 2 Code" := Employee."Global Dimension 2 Code";
                        "Phone No." := Employee."Phone No.";
                        "Appointment Date" := Employee."Employment Date";
                        Grade := Employee."Job Scale";
                        "E-Mail Address" := Employee."E-Mail";
                        Validate("Leave Code");
                        Validate("Calender of Interest");
                    end;
                end;
            end;
        }
        field(3; "Leave Allowance Payable"; Option)
        {
            OptionMembers = No,Yes;

            trigger OnValidate()
            begin
                if xRec.Status <> Status::Open then Error('You cannot edit the document. Kindly reject for the originator to correct');
                if "Leave Allowance Payable" = "Leave Allowance Payable"::Yes then begin
                    HumanResSetup.Get;
                    HumanResSetup.TestField("Leave Allowance Min. Days");
                    Testfield("Days Applied");
                    if "Days Applied" < HumanResSetup."Leave Allowance Min. Days" then Error('You can only be paid leave allowance if you take %1 or more Days', HumanResSetup."Leave Allowance Min. Days");
                    //Check if not Annual Leave
                    if LeaveTypes.Get("Leave Code") then if not LeaveTypes."Is Annual Leave" then Error('Leave Allowance is only Payable on Annual Leave');
                    LeaveApp.Reset;
                    LeaveApp.SetRange(LeaveApp."Employee No", "Employee No");
                    LeaveApp.SetRange(LeaveApp."Maturity Date", "Maturity Date");
                    LeaveApp.SetRange(LeaveApp.Status, LeaveApp.Status::Approved);
                    LeaveApp.SetRange(LeaveApp."Leave Allowance Payable", LeaveApp."Leave Allowance Payable"::Yes);
                    if LeaveApp.Find('-') then Error('Leave allowance has already been paid in leave application %1. Please contact Finance if your account has not been credited.', LeaveApp."No.");
                    FiscalEnd := CalcDate('1Y', "Fiscal Start Date") - 1;
                    PayrollTransactionCode.Reset;
                    PayrollTransactionCode.SetRange("Special Transactions", PayrollTransactionCode."Special Transactions"::"Leave Allowance");
                    if not PayrollTransactionCode.FindFirst then
                        Error('There is no Payroll Transaction Code define as Leave Allowance in Special Transaction')
                    else begin
                        PayrollEmpTrans_Check.Reset;
                        PayrollEmpTrans_Check.SetRange("Payroll Period", FiscalStart, FiscalEnd);
                        PayrollEmpTrans_Check.SetRange("Employee Code", LeaveApp."Employee No");
                        PayrollEmpTrans_Check.SetRange("Transaction Code", PayrollTransactionCode.Code);
                        if PayrollEmpTrans_Check.Find('-') then begin
                            LeaveAllowancePaid := true;
                            Error('Leave allowance has already been paid in %1', PayrollEmpTrans_Check."Payroll Period");
                        end;
                    end;
                end;
            end;
        }
        field(4; "Maturity Date"; Date)
        {
            Editable = false;
        }
        field(5; "Fiscal Start Date"; Date)
        {
            Editable = false;
        }
        field(6; "Allowance Paid"; Boolean)
        {
            Editable = false;
        }
        field(8; Comments; Text[250])
        {
        }
        field(9; "No. series"; Code[10])
        {
        }
        field(10; "Employee Name"; Text[70])
        {
            Editable = false;
            TableRelation = Employee;
        }
        field(11; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Editable = false;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1), Blocked = const(false));

            trigger OnValidate()
            begin
                DimensionValue.Reset;
                DimensionValue.SetRange(Code, "Global Dimension 1 Code");
                if DimensionValue.FindFirst then begin
                    Employee.Reset;
                    Employee.SetRange("Global Dimension 1 Code", "Global Dimension 1 Code");
                    Employee.SetFilter("Employee Status", '=%1|%2', Employee."Employee Status"::Active, Employee."Employee Status"::OnLeave);
                end;
            end;
        }
        field(12; Attachment; Boolean)
        {
            Editable = false;
        }
        field(13; "Supervisor Code"; Code[100])
        {
            Editable = false;

            trigger OnValidate()
            begin
                if UserSetup.Get("Supervisor Code") then begin
                    if Employee.Get(UserSetup."Employee No.") then "Supervisor Name" := Employee."First Name" + ' ' + Employee."Middle Name" + ' ' + Employee."Last Name";
                end;
            end;
        }
        field(14; "Supervisor Name"; Text[70])
        {
            Editable = false;
        }
        field(15; "Total No. of Leaves Applied"; Decimal)
        {
            Editable = false;
            FieldClass = Normal;
        }
        field(16; "Date Filter"; Date)
        {
            FieldClass = FlowFilter;
        }
        field(17; Reliever; Code[100])
        {
            TableRelation = Employee;

            trigger OnValidate()
            begin
                if Employee.Get(Reliever) then begin
                    if Employee."No." = "Employee No" then Error('You cannot relieve yourself');
                end;
                leaveApplication.Reset;
                leaveApplication.SetRange(Status, leaveApplication.Status::Approved);
                leaveApplication.SetFilter("End Date", '>%1', "Start Date");
                leaveApplication.SetRange("Employee No", Reliever);
                if leaveApplication.FindFirst then Error('%1 is on leave between %2 and %3 which is within the period you are applying for', leaveApplication."Employee Name", leaveApplication."Start Date", leaveApplication."End Date");
                LeavePlan.Reset;
                LeavePlan.SetRange("Employee No.", Reliever);
                LeavePlan.SetRange(Status, LeavePlan.Status::Approved);
                LeavePlan.SetRange("Leave Calendar Code", "Leave Calender Code");
                if LeavePlan.FindFirst then begin
                    LeavePlanLines.Reset;
                    LeavePlanLines.SetRange("Plan No.", LeavePlan."No.");
                    LeavePlanLines.SetRange("Employee Code.", LeavePlan."Employee No.");
                    LeavePlanLines.SetFilter("End Date", '>%1', "Start Date");
                    if LeavePlanLines.FindFirst then Error('%1 has a leave planned between %2 and %3 ', LeavePlanLines."Start Date", LeavePlanLines."End Date");
                end;
                Employee.Reset;
                Employee.SetRange("No.", Reliever);
                if Employee.FindFirst then begin
                    "Reliever Name" := Employee."First Name" + ' ' + Employee."Last Name";
                end;
            end;
        }
        field(18; "Reliever Name"; Text[100])
        {
            Editable = false;
        }
        field(19; Status; Enum "Document Status")
        {
            Editable = false;

            trigger OnValidate()
            var
                HumanResourceMgt: Codeunit "Human Resource Management";
            begin
                if Status = Status::Approved then
                    HumanResourceMgt.PostLeaveAfterApproval(Rec);
            end;
        }
        field(20; "Approval Level"; Integer)
        {
            Editable = false;
        }
        field(21; "Action Id"; Code[200])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(22; "Current Level"; Integer)
        {
            Editable = false;
        }
        field(23; "Leave Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Leave Types".Code;

            trigger OnValidate()
            begin
                if not LoginMgmt.IsWebServiceUser then if UserSetup.Get(UserId) then if UserSetup."HR Admin" then if LeaveTypes.Get("Leave Code") then if not LeaveTypes."Is Sick Leave" then Error('You can only apply sick leave for employee as an admin');
                if (xRec."Leave Code" <> "Leave Code") and (Rec."Leave Code" <> '') then begin
                    Validate("Start Date");
                    Days := 0;
                    "End Date" := 0D;
                    "Reporting Date" := 0D;
                    "Weekend Days" := 0;
                    Holidays := 0;
                    "Total No Of Days" := 0;
                    "Days Applied" := 0;
                end;
                if LeaveTypes.Get("Leave Code") then begin
                    "Leave Type Decription" := LeaveTypes.Description;
                    "Leave Entitlement" := LeaveTypes.Days;
                    //if Employee.Get("Employee No") then begin
                    //if (LeaveTypes.Gender in [LeaveTypes.Gender::Female]) and (Employee.Gender in [Employee.Gender::Male]) then
                    //Error('This Leave type is only applicable by %1', LeaveTypes.Gender);
                    //if (LeaveTypes.Gender in [LeaveTypes.Gender::Male]) and (Employee.Gender in [Employee.Gender::Female]) then
                    //Error('This Leave type is only applicable by %1', LeaveTypes.Gender);
                    //end;
                end
                else
                    "Leave Type Decription" := '';
                if "Nature of Application" in ["Nature of Application"::"Leave Application"] then begin
                    //GeneralSetup.GET;
                    LeaveCalendar.Reset;
                    LeaveCalendar.SetRange("Current Leave Calendar", true);
                    if LeaveCalendar.FindFirst then begin
                        LeaveEntries.Reset;
                        LeaveEntries.SetRange("Employee No.", "Employee No");
                        LeaveEntries.SetRange("Leave Type", "Leave Code");
                        LeaveEntries.SetRange(Closed, false);
                        if LeaveEntries.FindFirst then begin
                            LeaveEntries.CalcSums(Quantity);
                            Balance := LeaveEntries.Quantity;
                        end; // ELSE MESSAGE(LeaveEntries.GETFILTERS);
                    end
                    else
                        Error('There is No Leave Period Set Up');
                    "Leave balance" := Balance;
                end;
                if "Nature of Application" in ["Nature of Application"::"Leave Reimbursement"] then begin
                    Validate("Calender of Interest");
                    "Days to Reinstatement" := 0;
                end;
            end;
        }
        field(24; "Days Applied"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = true;

            trigger OnValidate()
            begin
                LeaveTypes.Get("Leave Code");
                if LeaveTypes."Check Leave Balance" then begin
                    if "Days Applied" > "Leave balance" then Error('You Cannot Apply for more than %1 Days', "Leave balance");
                end;
                if "Days Applied" = 0 then begin
                    Holidays := 0;
                    Weekends := 0;
                    "End Date" := 0D;
                    "Reporting Date" := 0D;
                    "Return Date" := 0D;
                    Days := 0;
                    "Balance After" := 0;
                    "Total No Of Days" := 0;
                    exit;
                end;
                Holidays := 0;
                LeaveTypes.Get("Leave Code");
                Weekends := 0;
                TheDayToday := "Start Date";
                DaysCounted := 1;
                //EndDate:=CALCDATE(FORMAT("Days Applied")+'D',CALCDATE('-1D',"Start Date"));         
                if LeaveTypes.Get("Leave Code") then begin
                    InclusiveOfWeekends := LeaveTypes."Inclusive of Non Working Days";
                    inclusiveOfHolidays := LeaveTypes."Inclusive of Holidays";
                end;

                while (DaysCounted <= "Days Applied") do begin
                    if Date.Get(Date."Period Type"::Date, TheDayToday) then begin
                        if (((Date."Period Name" = 'Sunday') or ((Date."Period Name" = 'Saturday')))) and (not InclusiveOfWeekends) then
                            Weekends += 1
                        else
                            DaysCounted += 1;
                    end;
                    TheDayToday := CalcDate('1D', TheDayToday);
                end;

                TheDayToday := "Start Date";
                while (TheDayToday <= CalcDate(Format("Days Applied" + Weekends) + 'D', "Start Date")) do begin
                    NonWorkingDaysDates.Reset;
                    NonWorkingDaysDates.SetRange(Date, TheDayToday);
                    if NonWorkingDaysDates.FindFirst then
                        if Date.Get(Date."Period Type"::Date, TheDayToday) then begin
                            if ((not (Date."Period Name" = 'Sunday') or (not (Date."Period Name" = 'Saturday')))) and (not inclusiveOfHolidays) then Holidays += 1;
                        end;
                    TheDayToday := CalcDate('1D', TheDayToday);
                end;

                EndDate := CalcDate(Format((Weekends + "Days Applied" + Holidays) - 1) + 'D', "Start Date");
                "End Date" := EndDate;
                "Weekend Days" := Weekends;
                Holidays := Holidays;
                "Total No Of Days" := ("Days Applied") + "Weekend Days" + Holidays;
                Days := "Days Applied";
                //"Return Date":=CALCDATE(FORMAT("Total No Of Days"+1)+'D',"Start Date");
                // IF Date.GET(Date."Period Type"::Date,"End Date") THEN BEGIN
                //    IF (Date."Period Name" = 'Sunday')THEN
                //      "End Date":=CALCDATE('-D',"End Date");
                //    IF (Date."Period Name" = 'Saturday')THEN
                //      "End Date":=CALCDATE('+2D',"End Date");
                //    end;            "Reporting Date" := "End Date";
                if Date.Get(Date."Period Type"::Date, "Reporting Date") then begin
                    if (Date."Period Name" = 'Sunday') then "Reporting Date" := CalcDate('+1D', "Reporting Date");
                    if (Date."Period Name" = 'Saturday') then "Reporting Date" := CalcDate('+2D', "Reporting Date");
                    if (Date."Period Name" = 'Friday') then "Reporting Date" := CalcDate('+3D', "Reporting Date");
                end;
                "Return Date" := "Reporting Date";
                LeaveTypes.Get("Leave Code");
                if not (LeaveTypes."Special Categorization" in [LeaveTypes."Special Categorization"::Unpaid, LeaveTypes."Special Categorization"::Study, LeaveTypes."Special Categorization"::CPD, LeaveTypes."Special Categorization"::Compensatory, LeaveTypes."Special Categorization"::Partenity, LeaveTypes."Special Categorization"::Martenity]) then begin
                    if Days > "Leave balance" then Error('Days cannot exceed your leave balance of %1', "Leave balance");
                    if LeaveTypes."Check Leave Balance" then "Balance After" := "Leave balance" - Days;
                end
                else if "Days Applied" > LeaveTypes.Days then Error('Maximum applicable days are %1', LeaveTypes.Days);
                if "Days Applied" < 0 then "Days Applied" := 0;
                Validate("Balance After");
                EmployeeContractDetails.Reset;
                EmployeeContractDetails.SetRange("Employee No", "Employee No");
                EmployeeContractDetails.SetRange("Contract Status", EmployeeContractDetails."Contract Status"::Active);
                if EmployeeContractDetails.FindFirst then if EmployeeContractDetails."Contract End Date" < "End Date" then Error('Date cannot be higher than contract end date %1', "Employee No");
            end;
        }
        field(25; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                TempDate: Date;
            begin
                if "Start Date" = 0D then exit;
                leaveApplication.Reset;
                leaveApplication.SetRange(Status, leaveApplication.Status::Approved);
                leaveApplication.SetRange("Employee No", "Employee No");
                leaveApplication.SetRange("Leave Calender Code", "Leave Calender Code");
                if leaveApplication.FindSet then begin
                    repeat
                        if (Rec."Start Date" >= leaveApplication."Start Date") and (Rec."Start Date" <= leaveApplication."End Date") then Error('You have already applied for leave on the selected period');
                    until leaveApplication.Next = 0;
                end;
                if xRec."Start Date" <> "Start Date" then begin
                    if "Start Date" <> 0D then Validate("Days Applied");
                    //    Days:=0;
                    //    "Days Applied":=0;
                    //    "End Date":=0D;
                    //    "Reporting Date":=0D;
                    //   MODIFY(TRUE);
                end;
                if UserSetup.Get(UserId) then if not UserSetup."Apply Leave Later Dater" then if "Start Date" < Today then Error('Please Use a future Date for Applications');
                if (("Start Date" > "End Date") and ("End Date" <> 0D)) then begin
                    Error('Start Date Cannot be After End Date');
                end;
                if LeaveTypes.Get("Leave Code") then begin
                    if LeaveTypes."Special Categorization" in [LeaveTypes."Special Categorization"::Partenity] then begin
                        LeaveTypes.TestField(Days);
                        NoDaysString := Format(Format(LeaveTypes.Days) + 'D');
                        if Evaluate(NoDays, NoDaysString) then "End Date" := CalcDate(NoDays, "Start Date");
                        "Days Applied" := LeaveTypes.Days;
                        Days := LeaveTypes.Days;
                        "Total No Of Days" := LeaveTypes.Days;
                        //          IF Days>"Leave balance" THEN
                        //            ERROR('You have no suficient leave balance');
                        "Weekend Days" := 0;
                        Holidays := 0;
                        "Balance After" := 0;
                        exit;
                    end;
                    if LeaveTypes."Special Categorization" in [LeaveTypes."Special Categorization"::Martenity] then begin
                        LeaveTypes.TestField(Days);
                        NoDaysString := Format(Format(LeaveTypes.Days) + 'D');
                        if Evaluate(NoDays, NoDaysString) then "End Date" := CalcDate(NoDays, "Start Date");
                        "Days Applied" := LeaveTypes.Days;
                        Days := LeaveTypes.Days;
                        "Total No Of Days" := LeaveTypes.Days;
                        "Weekend Days" := 0;
                        Holidays := 0;
                        "Balance After" := 0;
                        exit;
                    end;
                end;
                if (("Start Date" <> 0D) and ("End Date" <> 0D)) then "Total No Of Days" := "End Date" - "Start Date";
                Holidays := 0;
                LeaveTypes.Get("Leave Code");
                leaveApplication.Reset;
                leaveApplication.SetRange("Employee No", "Employee No");
                leaveApplication.SetRange("Leave Calender Code", "Leave Calender Code");
                leaveApplication.SetRange(Status, leaveApplication.Status::Approved);
                leaveApplication.SetFilter("End Date", '%1..%2', "Start Date", "End Date");
                if leaveApplication.FindFirst then begin
                    Error('You have already applied for %1 Leave between %2 and %3', leaveApplication."Leave Code", leaveApplication."Start Date", leaveApplication."End Date");
                end;
                if xRec."Start Date" <> "Start Date" then Validate("Days Applied");
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
                // IF LeaveTypes.GET("Leave Code") THEN
                // IF NOT LeaveTypes."Is Annual Leave" THEN
                //    EXIT;
                //  IF CALCDATE('14D',TODAY)>"Start Date" THEN
                //    ERROR('you can only apply leave 14 days to start date');        \
            end;
        }
        field(26; "End Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                TempDate: Date;
            begin
                if "End Date" = 0D then exit;
                leaveApplication.Reset;
                leaveApplication.SetFilter(Status, '=%1|=%2', leaveApplication.Status::"Pending Approval", leaveApplication.Status::Approved);
                leaveApplication.SetRange("Employee No", "Employee No");
                leaveApplication.SetRange("Start Date", "Start Date", "End Date");
                if leaveApplication.FindFirst then Error('You have applied leave No. %1 of type %2 at the same date', leaveApplication."No.", leaveApplication."Leave Type Decription");
                if LeaveTypes.Get("Leave Code") then begin
                    if LeaveTypes."Special Categorization" in [LeaveTypes."Special Categorization"::Partenity, LeaveTypes."Special Categorization"::Martenity] then Error('You cannot modify end date for this type of leave');
                end;
                if "End Date" = 0D then
                    if (("Start Date" > "End Date") and ("End Date" <> 0D)) then begin
                        Error('Start Date Cannot be After End Date');
                    end;
                if (("Start Date" <> 0D) and ("End Date" <> 0D)) then begin
                    "Total No Of Days" := ("End Date" - "Start Date") + 1;
                end;
                Holidays := 0;
                LeaveTypes.Get("Leave Code");
                Weekends := 0;
                TempDate := "Start Date";
                if Date.Get(Date."Period Type"::Date, TempDate) then begin
                    if ((Date."Period Name" = 'Sunday') and (LeaveTypes."Inclusive of Sunday" = false)) then
                        TempDate := CalcDate('+1D', TempDate)
                    else if ((Date."Period Name" = 'Saturday') and (LeaveTypes."Inclusive of Saturday" = false)) then begin
                        if LeaveTypes."Inclusive of Sunday" = false then
                            TempDate := CalcDate('+2D', TempDate)
                        else
                            TempDate := CalcDate('+1D', TempDate);
                    end;
                end;
                if TempDate <> 0D then begin
                    repeat
                        if Date.Get(Date."Period Type"::Date, TempDate) then begin
                            if ((Date."Period Name" = 'Sunday') and (LeaveTypes."Inclusive of Sunday" = false)) then Weekends += 1;
                            if ((Date."Period Name" = 'Saturday') and (LeaveTypes."Inclusive of Saturday" = false)) then Weekends += 1;
                        end;
                        TempDate := CalcDate('+1D', TempDate);
                    until TempDate = "End Date";
                end;
                LeaveSetup.Get;
                LeaveSetup.TestField("Base Calender");
                NonWorkingDaysDates.Reset;
                if NonWorkingDaysDates.FindFirst then begin
                    repeat
                        if ((NonWorkingDaysDates.Date >= "Start Date") and (NonWorkingDaysDates.Date <= "End Date")) then begin
                            Holidays += 1;
                        end;
                    until NonWorkingDaysDates.Next = 0;
                end;
                "Weekend Days" := Weekends;
                LeaveTypes.Get("Leave Code");
                if LeaveTypes."Inclusive of Holidays" and LeaveTypes."Inclusive of Saturday" and LeaveTypes."Inclusive of Sunday" then begin
                    Weekends := 0;
                    Holidays := 0;
                end;
                "Days Applied" := "Total No Of Days" - Holidays - Weekends;
                if HumanResourceMgmt.CheckIfItsSickLeave("Leave Code") then
                    if LeaveTypes.Get("Leave Code") then begin
                        if LeaveTypes."Max Applicable Days" > 0 then if "Days Applied" > LeaveTypes."Max Applicable Days" then Error('You cannot apply more than %1 Days', LeaveTypes."Max Applicable Days");
                    end;
                Validate("Days Applied");
            end;
        }
        field(27; "Application Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(28; "Leave balance"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(29; "User ID"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Half Day on Start Date"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(31; "Half Day on End Date"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(32; "Total No Of Days"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = true;

            trigger OnValidate()
            begin
                if "Total No Of Days" = 0 then exit;
                Holidays := 0;
                LeaveTypes.Get("Leave Code");
                Weekends := 0;
                TheDayToday := "Start Date";
                EndDate := CalcDate(Format("Total No Of Days") + 'D', "Start Date");
                while (TheDayToday <= EndDate) do begin
                    if Date.Get(Date."Period Type"::Date, TheDayToday) then begin
                        if ((Date."Period Name" = 'Sunday') or ((Date."Period Name" = 'Saturday'))) then if (not LeaveTypes."Inclusive of Saturday") and (not LeaveTypes."Inclusive of Sunday") then Weekends += 1
                    end;
                    TheDayToday := CalcDate('1D', TheDayToday);
                end;
                TheDayToday := "Start Date";
                EndDate := CalcDate(Format("Total No Of Days") + 'D', "Start Date");
                while (TheDayToday <= EndDate) do begin
                    NonWorkingDaysDates.Reset;
                    NonWorkingDaysDates.SetRange(Date, TheDayToday);
                    if NonWorkingDaysDates.FindFirst then Holidays += 1;
                    TheDayToday := CalcDate('1D', TheDayToday);
                end;
                "Weekend Days" := Weekends;
                Holidays := Holidays;
                "Days Applied" := "Total No Of Days" - ("Weekend Days" + Holidays);
                Days := "Total No Of Days" - ("Weekend Days" + Holidays);
                "End Date" := CalcDate(Format("Total No Of Days") + 'D', "Start Date");
                "Return Date" := CalcDate(Format("Total No Of Days" + 1) + 'D', "Start Date");
                if Date.Get(Date."Period Type"::Date, "End Date") then begin
                    if (Date."Period Name" = 'Sunday') then "End Date" := CalcDate('-1D', "End Date");
                    if (Date."Period Name" = 'Saturday') then "End Date" := CalcDate('-2D', "End Date");
                end;
                "Reporting Date" := CalcDate(Format("Total No Of Days" + 1) + 'D', "Start Date");
                if Date.Get(Date."Period Type"::Date, "Reporting Date") then begin
                    if (Date."Period Name" = 'Sunday') then "Reporting Date" := CalcDate('-1D', "Reporting Date");
                    if (Date."Period Name" = 'Saturday') then "Reporting Date" := CalcDate('-2D', "Reporting Date");
                end;
                if Date.Get(Date."Period Type"::Date, "Return Date") then begin
                    if (Date."Period Name" = 'Sunday') then "Return Date" := CalcDate('1D', "Return Date");
                    if (Date."Period Name" = 'Saturday') then "Return Date" := CalcDate('2D', "Return Date");
                end;
                if Days > "Leave balance" then Error('Days cannot exceed %1', "Leave balance");
                "Balance After" := "Leave balance" - Days;
            end;
        }
        field(33; Holidays; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(34; "Weekend Days"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(35; Days; Decimal)
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
                Testfield("Start Date");
                NewDate := 0D;
                NewDate := "Start Date";
                HDays := 0;
                Weekends := 0;
                IntDays := 0;
                IntDays := Days;
                LeaveTypes.Get("Leave Code");
                if Date.Get(Date."Period Type"::Date, NewDate) then begin
                    if ((Date."Period Name" = 'Sunday') and (LeaveTypes."Inclusive of Sunday" = false)) then
                        NewDate := CalcDate('+1D', NewDate)
                    else if ((Date."Period Name" = 'Saturday') and (LeaveTypes."Inclusive of Saturday" = false)) then begin
                        if LeaveTypes."Inclusive of Sunday" = false then
                            NewDate := CalcDate('+2D', NewDate)
                        else
                            NewDate := CalcDate('+1D', NewDate);
                    end;
                end;
                i := 0;
                repeat
                    if Date.Get(Date."Period Type"::Date, NewDate) then begin
                        if ((Date."Period Name" = 'Sunday') and (LeaveTypes."Inclusive of Sunday" = false)) then begin
                            Weekends += 1;
                            LeaveSetup.Get;
                            LeaveSetup.TestField("Base Calender");
                            NonWorkingDaysDates.Reset;
                            NonWorkingDaysDates.SetRange(Date, NewDate);
                            if NonWorkingDaysDates.FindFirst then begin
                                HDays += 1;
                            end;
                        end
                        else if ((Date."Period Name" = 'Saturday') and (LeaveTypes."Inclusive of Saturday" = false)) then begin
                            Weekends += 1;
                        end
                        else begin
                            LeaveSetup.Get;
                            LeaveSetup.TestField("Base Calender");
                            NonWorkingDaysDates.Reset;
                            NonWorkingDaysDates.SetRange(Date, NewDate);
                            if NonWorkingDaysDates.FindFirst then begin
                                HDays += 1;
                            end
                            else begin
                                i += 1;
                            end;
                        end;
                    end;
                    NewDate := CalcDate('+1D', NewDate);
                until i = IntDays;
                Message('Days Applied %1, Weekends %2 Holidays %3 Total Days %4', IntDays, Weekends, HDays, (IntDays + Weekends + HDays));
                "End Date" := CalcDate('+' + Format(IntDays + Weekends + HDays) + 'D', "Start Date");
                Holidays := HDays;
                "Weekend Days" := Weekends;
                "Total No Of Days" := (IntDays + Weekends + HDays);
                "Days Applied" := Days;
                Validate("End Date");
                Validate("Balance After");
            end;
        }
        field(36; "Balance After"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnValidate()
            begin
                "Balance After" := "Leave balance" - "Days Applied";
                Validate("Reporting Date");
            end;
        }
        field(37; "Return Date"; Date)
        {
            Editable = false;
        }
        field(38; "Reporting Date"; Date)
        {
            Editable = false;

            trigger OnValidate()
            begin
                if Date.Get(Date."Period Type"::Date, "End Date") then begin
                    if Date."Period Name" = 'Sunday' then
                        "Reporting Date" := CalcDate('+1D', "End Date")
                    else if Date."Period Name" = 'Saturday' then
                        "Reporting Date" := CalcDate('+2D', "End Date")
                    else if Date."Period Name" = 'Friday' then
                        "Reporting Date" := CalcDate('+3D', "End Date")
                    else
                        "Reporting Date" := CalcDate('+1D', "End Date")
                end;
            end;
        }
        field(39; "Created By"; Code[70])
        {
            TableRelation = "User Setup";
        }
        field(40; "Created On"; Date)
        {
        }
        field(41; "Contact Address"; Text[100])
        {
        }
        field(42; "Employee Phone No."; Code[20])
        {
        }
        field(43; "Leave Calender Code"; Code[40])
        {
        }
        field(44; Posted; Boolean)
        {
        }
        field(45; "Approval Entries"; Integer)
        {
            CalcFormula = Count("Approval Entry" WHERE("Document No." = FIELD("No.")));
            FieldClass = FlowField;
        }
        field(46; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2), Blocked = const(false));
        }
        field(47; "System Entry"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(48; "Leave Type Decription"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(49; "Appointment Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(50; "Phone No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(51; "E-Mail Address"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(52; Grade; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(53; "Exceeds Complement"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(54; "Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(55; "Leave Entitlement"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(56; "Nature of Application"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Leave Appliction,Leave Reimbursement';
            OptionMembers = "Leave Application","Leave Reimbursement";
        }
        field(57; "Calender of Interest"; Code[30])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "Leave Calendar"."Calendar Code" WHERE(Closed = CONST(true));

            trigger OnValidate()
            begin
                LeaveEntries.Reset;
                LeaveEntries.SetRange("Employee No.", "Employee No");
                LeaveEntries.SetRange("Leave Year Code", CalenderCodeFound);
                LeaveEntries.SetRange("Leave Type", "Leave Code");
                if LeaveEntries.FindSet then begin
                    LeaveEntries.CalcSums(Quantity);
                    "Leave Balance Then" := LeaveEntries.Quantity;
                    if LeaveTypes.Get("Leave Code") then begin
                        "Days Droped" := ("Leave Balance Then" - LeaveTypes."Max Carry Forward Days");
                    end;
                end;
            end;
        }
        field(58; "Days Droped"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(59; "Leave Balance Then"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(60; "Days to Reinstatement"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Days to Reinstatement" > "Days Droped" then Error('You cannot request reinstatement of more than %1 Days', "Days Droped");
            end;
        }
        field(61; "Justify Reinstatement"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(62; "Days To Reimburse"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                If "Days To Reimburse" > "Days Droped" then Error('You cant exceed days dropped');
                "Balance After" := "Leave balance" + "Days To Reimburse";
            end;
        }
        field(63; "Rejection Comments"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(64; "Global Dimension 4 Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(65; "Is HOD"; Boolean)
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
        FindMaturityDate;
        "Maturity Date" := MaturityDate;
        "Fiscal Start Date" := FiscalStart;
        LeaveSetup.Get;
        if "Nature of Application" in ["Nature of Application"::"Leave Application"] then begin
            LeaveSetup.TestField("Leave Application Nos.");
            if "No." = '' then begin
                gCduNoSeriesMgt.InitSeries(LeaveSetup."Leave Application Nos.", xRec."No. series", 0D, "No.", "No. series");
            end;
        end;
        if "Nature of Application" in ["Nature of Application"::"Leave Reimbursement"] then begin
            LeaveSetup.TestField("Leave Reimbursement Nos.");
            if "No." = '' then begin
                gCduNoSeriesMgt.InitSeries(LeaveSetup."Leave Reimbursement Nos.", xRec."No. series", 0D, "No.", "No. series");
            end;
        end;
        "Application Date" := WorkDate;
        IF NOT LoginMgmt.IsWebServiceUser THEN BEGIN
            UserSetup.GET(UserId);
            UserSetup.TESTFIELD("Employee No.");
            Validate("Employee No", UserSetup."Employee No.");
            "User ID" := UserId;
            "Created By" := UserId;
        end;
        "Created On" := WorkDate;
        LeaveCalendar.Reset;
        LeaveCalendar.SetRange("Current Leave Calendar", true);
        if LeaveCalendar.FindFirst then
            "Leave Calender Code" := LeaveCalendar."Calendar Code"
        else
            Error('No current calender was found');
        if "Nature of Application" in ["Nature of Application"::"Leave Reimbursement"] then begin
            LeaveCalendar.Reset;
            LeaveCalendar.SetRange("Current Leave Calendar", true);
            if LeaveCalendar.FindFirst then CurrentStartDate := LeaveCalendar."Start Date";
            DateToUse := CalcDate('-6M', CurrentStartDate);
            LeaveCalendar.Reset;
            LeaveCalendar.SetRange(Closed, true);
            if LeaveCalendar.FindSet then begin
                repeat
                    if (DateToUse >= LeaveCalendar."Start Date") and (DateToUse <= LeaveCalendar."End Date") then begin
                        CalenderCodeFound := LeaveCalendar."Calendar Code";
                    end;
                until LeaveCalendar.Next = 0;
            end;
            if CalenderCodeFound <> '' then begin
                "Calender of Interest" := CalenderCodeFound;
                Validate("Calender of Interest");
                LeaveEntries.Reset;
                LeaveEntries.SetRange("Employee No.", "Employee No");
                LeaveEntries.SetRange("Leave Year Code", CalenderCodeFound);
                LeaveEntries.SetRange("Leave Type", "Leave Code");
                if LeaveEntries.FindSet then begin
                    LeaveEntries.CalcSums(Quantity);
                    "Leave Balance Then" := LeaveEntries.Quantity;
                    if LeaveTypes.Get("Leave Code") then begin
                        "Days Droped" := ("Leave Balance Then" - LeaveTypes."Max Carry Forward Days");
                    end;
                end;
            end
            else
                Error('No previous calenders were found');
        end;
    end;

    trigger OnRename()
    begin
        Error(Text000, TableCaption);
    end;

    procedure FindMaturityDate()
    var
        AccPeriod: Record "Accounting Period";
    begin
        AccPeriod.Reset;
        AccPeriod.SetRange("Starting Date", 0D, Today);
        AccPeriod.SetRange("New Fiscal Year", true);
        if AccPeriod.Find('+') then begin
            FiscalStart := AccPeriod."Starting Date";
            MaturityDate := CalcDate('1Y', FiscalStart) - 1;
        end;
    end;

    var
        LeaveApplication: Record "Leave Applications";
        HumanResSetup: Record "Human Resources Setup";
        UserSetup: Record "User Setup";
        Employee: Record Employee;
        LeaveTypes: Record "Leave Types";
        gCduNoSeriesMgt: Codeunit NoSeriesManagement;
        NonWorkingDaysDates: Record "Non Working Days & Dates";
        Date: Record Date;
        Text000: Label 'You cannot rename  %1';
        LeaveSetup: Record "Leave Setup";
        LeaveEntries: Record "Leave Ledger Entries";
        Balance: Decimal;
        Weekends: Integer;
        Holidays: Integer;
        LeaveCalendar: Record "Leave Calendar";
        LoginMgmt: Codeunit "User Management Ext";
        HumanResourceMgmt: Codeunit "Human Resource Management";
        LeavePlanLines: Record "Leave Plan Lines";
        LeavePlan: Record "Leave Plan";
        NoDays: DateFormula;
        NoDaysString: Text;
        DimensionValue: Record "Dimension Value";
        TheDayToday: Date;
        EndDate: Date;
        DaysCounted: Integer;
        InclusiveOfWeekends: Boolean;
        inclusiveOfHolidays: Boolean;
        DateToUse: Date;
        CalenderCodeFound: Code[50];
        CurrentStartDate: Date;
        EmployeeContractDetails: Record "Employee Contract Details";
        LeaveApp: Record "Leave Applications";
        FiscalStart: Date;
        FiscalEnd: Date;
        PayrollEmpTrans_Check: Record "Payroll Employee Transaction";
        LeaveAllowancePaid: Boolean;
        MaturityDate: Date;
        PayrollTransactionCode: Record "Payroll Transaction Code";
}

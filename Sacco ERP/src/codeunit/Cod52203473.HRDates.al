codeunit 52203473 "HR Dates"
{
    var dayOfWeek: Integer;
    weekNumber: Integer;
    year: Integer;
    weekends: Integer;
    NextDay: Date;
    procedure DetermineDatesDiffrence(FromDate: Date; ToDate: Date)DiffString: Text[45]var
        dayB: Integer;
        monthB: Integer;
        yearB: Integer;
        dayJ: Integer;
        monthJ: Integer;
        yearJ: Integer;
        Year: Integer;
        Month: Integer;
        Day: Integer;
        monthsToBirth: Integer;
        D: Date;
        DateCat: Integer;
    begin
        if((FromDate <> 0D) and (ToDate <> 0D))then begin
            dayB:=Date2DMY(FromDate, 1);
            monthB:=Date2DMY(FromDate, 2);
            yearB:=Date2DMY(FromDate, 3);
            dayJ:=Date2DMY(ToDate, 1);
            monthJ:=Date2DMY(ToDate, 2);
            yearJ:=Date2DMY(ToDate, 3);
            Day:=0;
            Month:=0;
            Year:=0;
            DateCat:=DateCategory(dayB, dayJ, monthB, monthJ, yearB, yearJ);
            case(DateCat)of 1: begin
                Year:=yearJ - yearB;
                if monthJ >= monthB then Month:=monthJ - monthB
                else
                begin
                    Month:=(monthJ + 12) - monthB;
                    Year:=Year - 1;
                end;
                if(dayJ >= dayB)then Day:=dayJ - dayB
                else if(dayJ < dayB)then begin
                        Day:=(DetermineDaysInMonth(monthJ, yearJ) + dayJ) - dayB;
                        Month:=Month - 1;
                    end;
                DiffString:='%1Y, %2M & %3D';
                DiffString:=StrSubstNo(DiffString, Year, Month, Day);
            end;
            2, 3, 7: begin
                if(monthJ <> monthB)then begin
                    if monthJ >= monthB then Month:=monthJ - monthB
                    else
                        Error('The wrong date category!');
                end;
                if(dayJ <> dayB)then begin
                    if(dayJ >= dayB)then Day:=dayJ - dayB
                    else if(dayJ < dayB)then begin
                            Day:=(DetermineDaysInMonth(monthJ, yearJ) + dayJ) - dayB;
                            Month:=Month - 1;
                        end;
                end;
                DiffString:='%1M & %2D';
                DiffString:=StrSubstNo(DiffString, Month, Day);
            end;
            4: begin
                Year:=yearJ - yearB;
                DiffString:='%1Y';
                DiffString:=StrSubstNo(DiffString, Year);
            end;
            5: begin
                if(dayJ >= dayB)then Day:=dayJ - dayB
                else if(dayJ < dayB)then begin
                        Day:=(DetermineDaysInMonth(monthJ, yearJ) + dayJ) - dayB;
                        monthJ:=monthJ - 1;
                        Month:=(monthJ + 12) - monthB;
                        yearJ:=yearJ - 1;
                    end;
                Year:=yearJ - yearB;
                DiffString:='%1Y, %2M & %3D';
                DiffString:=StrSubstNo(DiffString, Year, Month, Day);
            end;
            6: begin
                if monthJ >= monthB then Month:=monthJ - monthB
                else
                begin
                    Month:=(monthJ + 12) - monthB;
                    yearJ:=yearJ - 1;
                end;
                Year:=yearJ - yearB;
                DiffString:='%1Y & %2M';
                DiffString:=StrSubstNo(DiffString, Year, Month);
            end;
            else
                DiffString:='';
            end;
        end
        else
            Message('For Date Calculation Enter All Applicable Dates!');
        exit;
    end;
    procedure DifferenceStartEnd(StartDate: Date; EndDate: Date)DaysValue: Integer var
        dayStart: Integer;
        monthS: Integer;
        yearS: Integer;
        dayEnd: Integer;
        monthE: Integer;
        yearE: Integer;
        Year: Integer;
        Month: Integer;
        Day: Integer;
        monthsBetween: Integer;
        i: Integer;
        j: Integer;
        monthValue: Integer;
        monthEnd: Integer;
        p: Integer;
        q: Integer;
        l: Integer;
        DateCat: Integer;
        daysInYears: Integer;
        m: Integer;
        yearStart: Integer;
        t: Integer;
        s: Integer;
        WeekendDays: Integer;
        Holidays: Integer;
    begin
        if((StartDate <> 0D) and (EndDate <> 0D))then begin
            Day:=0;
            monthValue:=0;
            p:=0;
            q:=0;
            l:=0;
            Year:=0;
            daysInYears:=0;
            DaysValue:=0;
            dayStart:=Date2DMY(StartDate, 1);
            monthS:=Date2DMY(StartDate, 2);
            yearS:=Date2DMY(StartDate, 3);
            dayEnd:=Date2DMY(EndDate, 1);
            monthE:=Date2DMY(EndDate, 2);
            yearE:=Date2DMY(EndDate, 3);
            WeekendDays:=0;
            /*
            AbsencePreferences.FIND('-');
             IF (AbsencePreferences."Include Weekends" = TRUE) THEN
               WeekendDays:= DetermineWeekends(StartDate,EndDate);        Holidays:= 0;
            AbsencePreferences.FIND('-');
             IF (AbsencePreferences."Include Holidays" = TRUE) THEN
                Holidays:= DetermineHolidays(StartDate,EndDate);
            */
            DateCat:=DateCategory(dayStart, dayEnd, monthS, monthE, yearS, yearE);
            case(DateCat)of 1: begin
                p:=0;
                q:=0;
                Year:=yearE - yearS;
                yearStart:=yearS;
                t:=1;
                s:=1;
                if(monthE <> monthS)then begin
                    for j:=1 to(monthS - 1)do begin
                        q:=q + DetermineDaysInMonth(t, yearS);
                        t:=t + 1;
                    end;
                    q:=q + dayStart;
                    for i:=1 to(monthE - 1)do begin
                        p:=p + DetermineDaysInMonth(s, yearE);
                        s:=s + 1;
                    end;
                    p:=p + dayend;
                    for m:=1 to Year do begin
                        if LeapYear(yearStart)then daysInYears:=daysInYears + 366
                        else
                            daysInYears:=daysInYears + 365;
                        yearStart:=yearStart + 1;
                    end;
                    DaysValue:=(((daysInYears - q) + p) - WeekendDays) - Holidays;
                end;
            end;
            2, 7: begin
                for l:=(monthS + 1)to(monthE - 1)do DaysValue:=DaysValue + DetermineDaysInMonth(l, yearS);
                DaysValue:=((DaysValue + (DetermineDaysInMonth(monthS, yearS) - dayStart) + dayEnd) - WeekendDays) - Holidays;
            end;
            3: begin
                if(dayEnd >= dayStart)then DaysValue:=dayEnd - dayStart - WeekendDays - Holidays
                else if(dayEnd = dayStart)then DaysValue:=0
                    else
                        DaysValue:=((dayStart - dayEnd) - WeekendDays) - Holidays;
            end;
            4: begin
                DaysValue:=0;
                Year:=yearE - yearS;
                yearStart:=yearS;
                for m:=1 to Year do begin
                    if(LeapYear(yearStart))then daysInYears:=366
                    else
                        daysInYears:=365;
                    DaysValue:=DaysValue + daysInYears;
                    yearStart:=yearStart + 1;
                end;
                DaysValue:=(DaysValue - WeekendDays) - Holidays;
            end;
            5: begin
                Year:=yearE - yearS;
                yearStart:=yearS;
                for m:=1 to Year do begin
                    if LeapYear(yearStart)then daysInYears:=daysInYears + 366
                    else
                        daysInYears:=daysInYears + 365;
                    yearStart:=yearStart + 1;
                end;
                DaysValue:=daysInYears;
                if dayEnd > dayStart then DaysValue:=(DaysValue + (dayEnd - dayStart) - WeekendDays) - Holidays
                else if dayStart > dayEnd then DaysValue:=(DaysValue - (dayStart - dayEnd) - WeekendDays) - Holidays;
            end;
            6: begin
                q:=0;
                p:=0;
                Year:=yearE - yearS;
                yearStart:=yearS;
                t:=1;
                s:=1;
                for j:=1 to monthS do begin
                    q:=q + DetermineDaysInMonth(t, yearS);
                    t:=t + 1;
                end;
                for i:=1 to monthE do begin
                    p:=p + DetermineDaysInMonth(s, yearE);
                    s:=s + 1;
                end;
                for m:=1 to Year do begin
                    if LeapYear(yearStart)then daysInYears:=daysInYears + 366
                    else
                        daysInYears:=daysInYears + 365;
                    yearStart:=yearStart + 1;
                end;
                DaysValue:=((daysInYears - q) + p) - WeekendDays - Holidays;
            end;
            else
                DaysValue:=0;
            end;
        end
        else
            Message('Enter all applicable dates for calculation!');
        DaysValue+=1;
        exit;
    end;
    procedure DetermineDaysInMonth(Month: Integer; Year: Integer)DaysInMonth: Integer begin
        case(Month)of 1: DaysInMonth:=31;
        2: begin
            if(LeapYear(Year))then DaysInMonth:=29
            else
                DaysInMonth:=28;
        end;
        3: DaysInMonth:=31;
        4: DaysInMonth:=30;
        5: DaysInMonth:=31;
        6: DaysInMonth:=30;
        7: DaysInMonth:=31;
        8: DaysInMonth:=31;
        9: DaysInMonth:=30;
        10: DaysInMonth:=31;
        11: DaysInMonth:=30;
        12: DaysInMonth:=31;
        else
            Message('Not valid date. The month must be between 1 and 12');
        end;
        exit;
    end;
    procedure DateCategory(BDay: Integer; EDay: Integer; BMonth: Integer; EMonth: Integer; BYear: Integer; EYear: Integer)Category: Integer begin
        if((EYear > BYear) and (EMonth <> BMonth) and (EDay <> BDay))then Category:=1
        else if((EYear = BYear) and (EMonth <> BMonth) and (EDay = BDay))then Category:=2
            else if((EYear = BYear) and (EMonth = BMonth) and (EDay <> BDay))then Category:=3
                else if((EYear > BYear) and (EMonth = BMonth) and (EDay = BDay))then Category:=4
                    else if((EYear > BYear) and (EMonth = BMonth) and (EDay <> BDay))then Category:=5
                        else if((EYear > BYear) and (EMonth <> BMonth) and (EDay = BDay))then Category:=6
                            else if((EYear = BYear) and (EMonth <> BMonth) and (EDay <> BDay))then Category:=7
                                else if((EYear = BYear) and (EMonth = BMonth) and (EDay = BDay))then Category:=3
                                    else
                                    begin
                                        Category:=0;
                                    //ERROR('The start date cannot be after the end date.');
                                    end;
        exit;
    end;
    procedure LeapYear(Year: Integer)LY: Boolean var
        CenturyYear: Boolean;
        DivByFour: Boolean;
    begin
        CenturyYear:=Year mod 100 = 0;
        DivByFour:=Year mod 4 = 0;
        if((not CenturyYear and DivByFour) or (Year mod 400 = 0))then LY:=true
        else
            LY:=false;
    end;
    procedure CalculateNextDay(Date: Date)NextDate: Date var
        today: Integer;
        month: Integer;
        year: Integer;
        nextDay: Integer;
        daysInMonth: Integer;
    begin
        today:=Date2DMY(Date, 1);
        month:=Date2DMY(Date, 2);
        year:=Date2DMY(Date, 3);
        daysInMonth:=DetermineDaysInMonth(month, year);
        nextDay:=today + 1;
        if(nextDay > daysInMonth)then begin
            nextDay:=1;
            month:=month + 1;
            if(month > 12)then begin
                month:=1;
                year:=year + 1;
            end;
        end;
        NextDate:=DMY2Date(nextDay, month, year);
    end;
}

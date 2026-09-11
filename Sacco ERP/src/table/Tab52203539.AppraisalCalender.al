table 52203539 "Appraisal Calender"
{
    fields
    {
        field(1; "Calendar Code"; Code[40])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[70])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Calendar Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Predifined,Custom';
            OptionMembers = " ", Predifined, Custom;
        }
        field(4; "Appraisal Period"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Monthly,Quarterly,Yearly';
            OptionMembers = " ", Monthly, Quarterly, Yearly;

            trigger OnValidate()
            begin
                if not("Appraisal Period" in["Appraisal Period"::" "])then begin
                    Rec.Testfield("Period Start Date");
                    Rec.Testfield("Period End Date");
                end;
            end;
        }
        field(5; "Period Start Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Period Start Date" <> 0D then begin
                    "Period End Date":=CalcDate('1Y', "Period Start Date");
                end;
            end;
        }
        field(6; "Period End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Period Length"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Current Calender"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(9; Closed; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Closed By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Closed On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Opened On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Opened By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Long Term Objective End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Calendar Code")
        {
        }
    }
    var local procedure DeleteAppraisalCalenderLines(CalendarCode: Code[40])
    var
        AppraisalCalendarLines: Record "Appraisal Calender Lines";
    begin
        AppraisalCalendarLines.Reset;
        AppraisalCalendarLines.SetRange("Calender Code", CalendarCode);
        if AppraisalCalendarLines.FindSet then AppraisalCalendarLines.DeleteAll;
    end;
    local procedure FindAppraisalCalenderLines(CalendarCode: Code[40]): Boolean var
        AppraisalCalendarLines: Record "Appraisal Calender Lines";
    begin
        AppraisalCalendarLines.Reset;
        AppraisalCalendarLines.SetRange("Calender Code", CalendarCode);
        if AppraisalCalendarLines.FindSet then exit(AppraisalCalendarLines.FindFirst);
    end;
    local procedure GenerateAppraisalCalenderLines(CalendarCode: Code[40]; PeriodEndDate: Date; PeriodLength: DateFormula; PeriodStartDate: Date)
    var
        AppraisalCalendarLines: Record "Appraisal Calender Lines";
        CurrentLineEndDate: Date;
        CurrentLineStartDate: Date;
    begin
        CurrentLineStartDate:=PeriodStartDate;
        CurrentLineEndDate:=CalcDate(PeriodLength, CurrentLineStartDate);
        //ERROR('CurrentLineStartDate %1, CurrentLineEndDate %2',CALCDATE('-1D',CurrentLineEndDate),CurrentLineEndDate);
        while CurrentLineEndDate <= CalcDate('-1D', PeriodEndDate)do begin
            AppraisalCalendarLines.Init;
            AppraisalCalendarLines."Calender Code":="Calendar Code";
            AppraisalCalendarLines."Start Date":=CurrentLineStartDate;
            AppraisalCalendarLines."End Date":=CalcDate('-1D', CurrentLineEndDate);
            AppraisalCalendarLines.Validate("End Date");
            if AppraisalCalendarLines.Insert then begin
                CurrentLineEndDate:=CalcDate(PeriodLength, CurrentLineEndDate);
                CurrentLineStartDate:=CalcDate(PeriodLength, CurrentLineStartDate);
            end;
        end;
    end;
}

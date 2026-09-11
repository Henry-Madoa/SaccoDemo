table 52203604 "Test Time"
{
    fields
    {
        field(1; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Start Time"; Time)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Format("Start Time") <> '' then Evaluate(StartTime, Format("Start Time", 0, '<Hours24>.<Minutes,2>.<Seconds,2>'));
                Message(Format(StrLen(Format(StartTime)) - 1));
                NewText:=CopyStr(Format(StartTime), StrLen(Format(StartTime)) - 2, 2);
            end;
        }
        field(3; "End Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Start Date" <> "End Date" then begin
                    Message(Format("End Date" - "Start Date"));
                end;
            end;
        }
        field(4; "End Time"; Time)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                DurationDec:="End Time" - 0T;
                Message(Format(DurationDec / 3600000));
            end;
        }
        field(5; "Start Date Time"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "End Date Time"; DateTime)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                DurationInHours:=("End Date Time" - "Start Date Time") / 3600000;
                Message(Format(DurationInHours));
                if Evaluate(DurationInDecimal, Format(DurationInHours))then Message(Format(DurationInDecimal));
            end;
        }
        field(7; "Date 1"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Date Formula"; DateFormula)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                "Date 2":=CalcDate("Date Formula", "Date 1");
            end;
        }
        field(9; "Date 2"; Date)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Start Date")
        {
        }
    }
    var StartTime: Time;
    NewText: Text;
    TimeTaken: Duration;
    DurationDec: Decimal;
    DurationInHours: BigInteger;
    DurationInDecimal: Decimal;
}

table 52203542 "Appraisal Review Periods"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Appraisal Review Periods";
    DrillDownPageId = "Appraisal Review Periods";

    fields
    {
        field(1; "Calendar Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Appraisal Calender";
        }
        field(2; Code; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; Description; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Review Type";Enum "Appraisal Review Periods")
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Review Type" = "Review Type"::"Objective Planning" then begin
                    Evaluate("Period Length", '1M');
                    Sequence:=0;
                end
                else if "Review Type" = "Review Type"::Monthly then Evaluate("Period Length", '1M')
                    else if "Review Type" = "Review Type"::Quarterly then Evaluate("Period Length", '3M')
                        else if "Review Type" = "Review Type"::Yearly then Evaluate("Period Length", '1Y');
            end;
        }
        field(5; Sequence; Integer)
        {
            DataClassification = ToBeClassified;
            MinValue = 0;
            MaxValue = 5;
        }
        field(6; "Period Length"; DateFormula)
        {
            Editable = false;
        }
        field(7; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Start Date" <> 0D then begin
                    AppraisalCalender.Get("Calendar Code");
                    if "Start Date" < AppraisalCalender."Period Start Date" then Error('The review Period cannot start the Current Calendar Start Date.');
                    "End Date":=CalcDate(StrSubstNo('%1-1D', "Period Length"), "Start Date");
                    if "End Date" > AppraisalCalender."Period End Date" then Error('The review Period cannot exceed the Current Calendar End Date.');
                end;
            end;
        }
        field(8; "End Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(9; Status; Option)
        {
            OptionMembers = Created, Open, Closed;
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Calendar Code", Code)
        {
            Clustered = true;
        }
        key(Key2; Code, "Calendar Code")
        {
        }
    }
    trigger OnDelete()
    begin
        Rec.Testfield(Status, Status::Created);
    end;
    trigger OnRename()
    begin
        Rec.Testfield(Status, Status::Created);
    end;
    var AppraisalCalender: Record "Appraisal Calender";
}

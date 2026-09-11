table 52203599 "Training Plan"
{
    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Calender Code"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "Training Calender"."Calender Code";

            trigger OnValidate()
            begin
                if TrainingCalender.Get("Calender Code")then begin
                    "Calender End Date":=TrainingCalender."End Date";
                    "Calender Start Date":=TrainingCalender."Start Date";
                end;
            end;
        }
        field(3; "Calender Start Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; "Calender End Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=FILTER(1));
        }
        field(5; "Training Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(6; Status; Option)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            OptionCaption = 'Open,Closed';
            OptionMembers = Open, Closed;
        }
        field(7; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Created By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Created On"; Date)
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
    trigger OnInsert()
    begin
        if "No." = '' then begin
            HumanResourcesSetup.Get;
            HumanResourcesSetup.TestField("Training Plan Nos");
            NoSeriesManagement.InitSeries(HumanResourcesSetup."Training Plan Nos", "No. Series", 0D, "No.", "No. Series");
        end;
        TrainingCalender.Reset;
        TrainingCalender.SetRange(Closed, false);
        TrainingCalender.SetRange("Current Period", true);
        if TrainingCalender.FindFirst then Validate("Calender Code", TrainingCalender."Calender Code")
        else
            Error('No training calender of description [%1] was found', TrainingCalender.GetFilters);
        "Created By":=UserId;
        "Created On":=WorkDate;
    end;
    var HumanResourcesSetup: Record "Human Resources Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    TrainingNeed: Record "Training Need";
    Vendor: Record Vendor;
    TrainingCalender: Record "Training Calender";
}

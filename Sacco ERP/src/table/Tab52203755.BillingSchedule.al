table 52203755 "Billing Schedule"
{
    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Schedule Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                ScheduleDate:=CalcDate('-CM', Rec."Schedule Date");
                BillingSchedule.Reset();
                BillingSchedule.SetRange("Schedule Date", ScheduleDate);
                if BillingSchedule.FindFirst()then begin
                    Error('Billing schedule for the period %1 has already been generated', ScheduleDate);
                end;
                Rec."Schedule Date":=ScheduleDate;
            end;
        }
        field(3; Status; Option)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            OptionCaption = 'Open,Generated,Closed';
            OptionMembers = Open, Generated, Closed;
        }
        field(4; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
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
            AssetManagementSetup.Get;
            AssetManagementSetup.TestField("Bill Schedule Nos");
            NoSeriesManagement.InitSeries(AssetManagementSetup."Bill Schedule Nos", xRec."No.", 0D, "No.", "No. Series");
        end;
    end;
    var AssetManagementSetup: Record "Asset Management Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    BillingSchedule: record "Billing Schedule";
    ScheduleDate: Date;
}

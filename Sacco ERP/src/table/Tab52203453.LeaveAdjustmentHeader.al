table 52203453 "Leave Adjustment Header"
{
    DataCaptionFields = "Leave Adjustments No.";

    fields
    {
        field(1; "Leave Adjustments No."; Code[20])
        {
            Editable = false;
        }
        field(2; "No. Series"; Code[10])
        {
            Editable = false;
        }
        field(3; Status;Enum "Document Status")
        {
            Editable = false;
        }
        field(4; "Created By"; Code[50])
        {
            Caption = 'Created By';
            Editable = false;
            TableRelation = "User Setup";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(5; "Date Created"; Date)
        {
            Caption = 'Date Created';
            Editable = false;
        }
        field(6; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(7; "Last Modified By"; Code[50])
        {
            Editable = false;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(8; "No. Of Days"; Integer)
        {
        }
        field(9; Type; Option)
        {
            OptionCaption = 'Positive,Negative';
            OptionMembers = Positive, Negative;
        }
        field(10; Description; Text[50])
        {
        }
        field(11; "Job Group"; Code[20])
        {
        }
        field(12; "Leave Type"; Code[20])
        {
            TableRelation = "Leave Types";

            trigger OnValidate()
            begin
                if LeaveTypes.Get("Leave Type")then begin
                    "Leave Type Name":=LeaveTypes.Description;
                end;
            end;
        }
        field(13; "Leave Type Name"; Text[50])
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Leave Adjustments No.")
        {
        }
    }
    trigger OnDelete()
    begin
    //TESTFIELD(Status,Status::New);
    end;
    trigger OnInsert()
    begin
        if "Leave Adjustments No." = '' then begin
            LeaveSetup.Get;
            LeaveSetup.TestField("Adjustment Nos");
            "Leave Adjustments No.":=NoSeriesManagement.GetNextNo(LeaveSetup."Adjustment Nos", Today, true);
        end;
        "Created By":=UserId;
        "Date Created":=WorkDate;
        "Last Date Modified":=WorkDate;
        "Last Modified By":=UserId;
    end;
    trigger OnModify()
    begin
        "Last Date Modified":=WorkDate;
        "Last Modified By":=UserId;
    end;
    var Employee: Record Employee;
    HumanResourcesSetup: Record "Human Resources Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    LeaveTypes: Record "Leave Types";
    LeaveSetup: Record "Leave Setup";
}

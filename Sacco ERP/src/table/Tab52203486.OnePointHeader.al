table 52203486 "One Point Header"
{
    DataCaptionFields = "One Point";

    fields
    {
        field(1; "One Point"; Code[20])
        {
            Editable = false;
        }
        field(2; "No. Series"; Code[10])
        {
            Editable = false;
        }
        field(3; Status; Option)
        {
            Editable = false;
            OptionCaption = 'New,Closed,Pending Approval,Approved,Rejected';
            OptionMembers = New, Closed, "Pending Approval", Approved, Rejected;
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
        field(10; Description; Text[50])
        {
        }
        field(11; "Appraisal Calender"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Appraisal Calender"."Calendar Code";
        }
    }
    keys
    {
        key(Key1; "One Point")
        {
        }
    }
    trigger OnDelete()
    begin
    //TESTFIELD(Status,Status::New);
    end;
    trigger OnInsert()
    begin
        if "One Point" = '' then begin
            HumanResourcesSetup.Get;
            HumanResourcesSetup.TestField("One Point Nos.");
            "One Point":=NoSeriesManagement.GetNextNo(HumanResourcesSetup."One Point Nos.", Today, true);
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

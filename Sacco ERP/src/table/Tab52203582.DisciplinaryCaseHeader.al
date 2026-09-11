table 52203582 "Disciplinary Case Header"
{
    DrillDownPageID = "Disciplinary Case List";
    LookupPageID = "Disciplinary Case List";

    fields
    {
        field(1; No; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Created By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Created On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Employee No"; Code[50])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Employee.Get("Employee No")then begin
                    "Employee Name":=Employee.FullName;
                    "Global Dimension 1 Code":=Employee."Global Dimension 1 Code";
                    "Global Dimension 2 Code":=Employee."Global Dimension 2 Code";
                end;
            end;
        }
        field(5; "Employee Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            DataClassification = ToBeClassified;
        }
        field(7; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            DataClassification = ToBeClassified;
        }
        field(8; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(9; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'New,Reported,Archived';
            OptionMembers = New, Reported, Archived;
        }
        field(10; Type; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Disciplinary,Grievance';
            OptionMembers = Disciplinary, Grievance;
        }
    }
    keys
    {
        key(Key1; No)
        {
        }
    }
    trigger OnInsert()
    begin
        if hrSetup.Get then begin
            if Rec.Type in[Rec.Type::Disciplinary]then begin
                hrSetup.TestField("Disciplinary Cases Nos");
                NoSeriesManagement.InitSeries(hrSetup."Disciplinary Cases Nos", "No. Series", 0D, No, "No. Series");
            end;
            if Rec.Type in[Rec.Type::Grievance]then begin
                hrSetup.TestField("Grievances Nos");
                NoSeriesManagement.InitSeries(hrSetup."Grievances Nos", "No. Series", 0D, No, "No. Series");
            end;
        end;
        if UserSetup.Get(UserId)then begin
            UserSetup.TestField("Employee No.");
            if Employee.Get(UserSetup."Employee No.")then begin
                "Employee No":=Employee."No.";
                Validate("Employee No");
            end;
        end;
        "Created By":=UserId;
        "Created On":=WorkDate;
    end;
    var NoSeries: Record "No. Series";
    hrSetup: Record "Human Resources Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    UserSetup: Record "User Setup";
    Employee: Record Employee;
}

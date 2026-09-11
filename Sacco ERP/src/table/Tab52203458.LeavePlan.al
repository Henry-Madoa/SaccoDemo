table 52203458 "Leave Plan"
{
    DrillDownPageID = "Leave Plan Pending Approval";
    LookupPageID = "Leave Plan Pending Approval";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Employee No."; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Employee.Get("Employee No.")then begin
                    HumanResourcesSetup.Get;
                    if CalcDate(HumanResourcesSetup."Retirement Age", Employee."Birth Date") < Today then Error('You are beyond %1', HumanResourcesSetup."Retirement Age");
                    "Employee Name":=Employee.FullName;
                    "Global Dimension 1 Code":=Employee."Global Dimension 1 Code";
                    "Global Dimension 2 Code":=Employee."Global Dimension 2 Code";
                    "Global Dimension 1 Name":=Employee."Global Dimension 1 Name";
                    "Line Manager":=Employee."Manager No.";
                    "Overview Manager":=Employee."Overview Manager";
                    "Grant Approver":=Employee."Grant Approver";
                end;
            end;
        }
        field(3; "Employee Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            DataClassification = ToBeClassified;
        }
        field(5; "Global Dimension 1 Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            DataClassification = ToBeClassified;
        }
        field(7; "Global Dimension 2 Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Leave Calendar Code"; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if LeaveCalendar.Get("Leave Calendar Code")then begin
                    "Leave Calendar Description":=LeaveCalendar.Description;
                    "Leave Calendar Start Date":=LeaveCalendar."Start Date";
                    "Leave Calendar End Date":=LeaveCalendar."End Date";
                end;
            end;
        }
        field(9; "Leave Calendar Description"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Leave Calendar Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Leave Calendar End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Created By"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Created On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(14; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Open,Pending Approval,Approved,Rejected,Taken';
            OptionMembers = Open, "Pending Approval", Approved, Rejected, Taken;
        }
        field(15; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Line Manager"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Overview Manager"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Grant Approver"; Code[20])
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
        if LeaveSetup.Get then begin
            LeaveSetup.TestField("Leave Plan Nos.");
            NoSeriesManagement.InitSeries(LeaveSetup."Leave Plan Nos.", "No. Series", 0D, "No.", "No. Series");
        end;
        if not LoginMgmt.IsWebServiceUser then begin
            if UserSetup.Get(UserId)then begin
                if Employee.Get(UserSetup."Employee No.")then begin
                    "Employee No.":=UserSetup."Employee No.";
                    Validate("Employee No.");
                    Employee.TestField("Global Dimension 1 Code");
                    "Global Dimension 1 Code":=Employee."Global Dimension 1 Code";
                    Validate("Global Dimension 1 Code");
                    "Global Dimension 2 Code":=Employee."Global Dimension 2 Code";
                    Validate("Global Dimension 2 Code");
                end;
            end;
        end
        else
            Validate("Employee No.");
        LeaveCalendar.Reset;
        LeaveCalendar.SetRange("Current Leave Calendar", true);
        if LeaveCalendar.FindFirst then begin
            "Leave Calendar Code":=LeaveCalendar."Calendar Code";
            Validate("Leave Calendar Code");
        end;
    end;
    var LeaveSetup: Record "Leave Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    UserSetup: Record "User Setup";
    Employee: Record Employee;
    LeaveCalendar: Record "Leave Calendar";
    HumanResourcesSetup: Record "Human Resources Setup";
    LoginMgmt: Codeunit "User Management Ext";
}

table 52203764 "Procurement Plan Initiation"
{
    LookupPageId = "Procurement Plan Initiation";

    fields
    {
        field(2; "Plan Name"; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Financial Year"; Code[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; "Created By"; Code[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5; "Employee No"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnValidate()
            begin
                if Employee.Get("Employee No")then "Employee Name":=Employee.FullName()
                else
                    "Employee Name":='';
            end;
        }
        field(6; "Employee Name"; Text[250])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(7; Initiated; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(8; "Current Budget"; Code[70])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "G/L Budget Name".Name;
        }
        field(9; "Date Created"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Initiated By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Initiated On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Plan Period"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Monthly,Quartely,Yearly';
            OptionMembers = " ", Monthly, Quartely, Yearly;
        }
        field(13; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(15; Description; Code[100])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Plan Name")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
    }
    trigger OnInsert()
    begin
        if UserSetup.Get(UserId)then begin
            UserSetup.TestField("Employee No.");
            if Employee.Get(UserSetup."Employee No.")then begin
                "Employee No":=UserSetup."Employee No.";
                "Employee Name":=Employee.FullName;
            end;
        end;
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.TestField("Current Budget");
        GeneralLedgerSetup.TestField("Current Budget Start Date");
        GeneralLedgerSetup.TestField("Current Budget End Date");
        "Current Budget":=GeneralLedgerSetup."Current Budget";
        "Financial Year":=Format(Date2DMY(GeneralLedgerSetup."Current Budget Start Date", 3));
        "Start Date":=GeneralLedgerSetup."Current Budget Start Date";
        "End Date":=GeneralLedgerSetup."Current Budget End Date";
        "Created By":=UserId;
        "Date Created":=Today;
    end;
    var Employee: Record Employee;
    UserSetup: Record "User Setup";
    GeneralLedgerSetup: Record "General Ledger Setup";
}

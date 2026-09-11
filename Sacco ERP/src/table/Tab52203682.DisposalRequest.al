table 52203682 "Disposal Request"
{
    fields
    {
        field(1; "Disposal No"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Employee No"; Code[50])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Employee.Get("Employee No")then "Emploayee Name":=Employee.FullName();
            end;
        }
        field(3; "Emploayee Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Created By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Created On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "No. Series"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(7; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'New,Pending Approval,Approved,Rejected';
            OptionMembers = New, "Pending Approval", Approved, Rejected;
        }
        field(8; "Order Created By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Order Created"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Date Order Created"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Suggested Customer"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Customer."No.";

            trigger OnValidate()
            begin
                if Customer.Get("Suggested Customer")then "Customer Name":=Customer.Name;
            end;
        }
        field(12; "Customer Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Global Dimension 1 Code"; Code[50])
        {
            CaptionClass = '1,1,1';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1));
        }
        field(14; "Global Dimension 2 Code"; Code[50])
        {
            CaptionClass = '1,1,2';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1));
        }
    }
    keys
    {
        key(Key1; "Disposal No")
        {
        }
    }
    trigger OnInsert()
    begin
        if "Disposal No" = '' then begin
            ProcurementSetup.Get;
            ProcurementSetup.TestField("Disposal Request Nos");
            NoSeriesManagement.InitSeries(ProcurementSetup."Disposal Request Nos", "No. Series", 0D, "Disposal No", "No. Series");
        end;
        if UserSetup.Get(UserId)then begin
            UserSetup.TestField("Employee No.");
            "Employee No":=UserSetup."Employee No.";
            Validate("Employee No");
        end;
        "Created By":=UserId;
        "Created On":=Today;
    end;
    var ProcurementSetup: Record "Purchases & Payables Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    UserSetup: Record "User Setup";
    Employee: Record Employee;
    Customer: Record Customer;
}

table 52203740 "WorkTicket Form Request"
{
    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Driver No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No.";

            trigger OnValidate()
            begin
                if Employee.Get("Driver No.")then begin
                    "Driver Name":=Employee."First Name" + ' ' + Employee."Middle Name" + ' ' + Employee."Last Name";
                end;
            end;
        }
        field(3; "Driver Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Vehicle REG. No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Motor Vehicle Asset"."No.";
        }
        field(5; "Previous WTKT No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Company Name"; Text[150])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
            // IF CompanyInformation.GET THEN BEGIN
            //  "Company Name" := CompanyInformation.Name;
            //  END;
            end;
        }
        field(7; Station; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(9; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'New,Pending Approval,Approved,Rejected';
            OptionMembers = New, "Pending Approval", Approved, Rejected;
        }
        field(10; Submitted; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(11; Completed; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Employee No."; Code[50])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Employee.Get("Employee No.")then begin
                    "Employee Name":=Employee."First Name" + ' ' + Employee."Middle Name" + ' ' + Employee."Last Name";
                end;
            end;
        }
        field(13; "Employee Name"; Text[150])
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
            FleetManagementSetup.Get;
            FleetManagementSetup.TestField("WorkTicket Request Nos");
            NoSeriesManagement.InitSeries(FleetManagementSetup."WorkTicket Request Nos", xRec."No.", 0D, "No.", "No. Series");
        end;
        // IF CURRENTCLIENTTYPE=CLIENTTYPE::SOAP THEN
        //  EXIT;
        // IF IansoftFactory.FnIsWebServiceUser(USERID) THEN
        //  EXIT;
        if UserSetup.Get(UserId)then begin
            UserSetup.TestField("Employee No.");
            "Driver No.":=UserSetup."Employee No.";
            Validate("Driver No.");
            "Employee No.":=UserSetup."Employee No.";
            Validate("Employee No.");
        end;
    end;
    var FleetManagementSetup: Record "Fleet Management Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    Employee: Record Employee;
    CompanyInformation: Record "Company Information";
    //IansoftFactory: Codeunit IansoftFactory;
    UserSetup: Record "User Setup";
}

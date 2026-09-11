table 52203701 "Evaluation Committee"
{
    fields
    {
        field(1; "Reference No"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "User Name"; Code[70])
        {
            DataClassification = ToBeClassified;
            TableRelation = "User Setup"."User ID";

            trigger OnValidate()
            begin
                if UserSetup.Get("User Name")then begin
                    UserSetup.TestField("Employee No.");
                    "Employee No.":=UserSetup."Employee No.";
                    Validate("Employee No.");
                end;
            end;
        }
        field(3; "Employee No."; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnValidate()
            begin
                if Employee.Get("Employee No.")then "Employee Name":=Employee."First Name" + ' ' + Employee."Middle Name" + ' ' + Employee."Last Name"
                else
                    "Employee Name":='';
            end;
        }
        field(4; "Employee Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5; "Submitted Mandatory Evaluation"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Submitted Technical Evaluation"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(7; Substitute; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Substitute Employee No."; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnLookup()
            begin
                if UserSetup.Get(Substitute)then begin
                    UserSetup.TestField("Employee No.");
                    "Substitute Employee No.":=UserSetup."Employee No.";
                    Validate("Substitute Employee No.");
                end;
            end;
            trigger OnValidate()
            begin
                if Employee.Get("Substitute Employee No.")then "Substitute Employee Name":=Employee."First Name" + ' ' + Employee."Middle Name" + ' ' + Employee."Last Name"
                else
                    "Substitute Employee Name":='';
            end;
        }
        field(9; "Substitute Employee Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(10; Stage; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Mandatory,Technical,Financial';
            OptionMembers = " ", Mandatory, Technical, Financial;
        }
        field(11; "Submitted Financial Evaluation"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Reference No", "User Name", Stage)
        {
        }
    }
    trigger OnInsert()
    begin
        if ProcurementRequest.Get("Reference No")then begin
            ProcurementRequest.TestField("Tender Status", ProcurementRequest."Tender Status"::Advertised);
        end;
    end;
    var UserSetup: Record "User Setup";
    Employee: Record Employee;
    ProcurementRequest: Record "Procurement Request";
}

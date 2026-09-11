table 52203777 "Job Shortlisting"
{
    Caption = 'Shortlisting';
    DataClassification = ToBeClassified;
    LookupPageId = "Job Shortlists";
    DrillDownPageId = "Job Shortlists";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; Date; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(3; "Requisition No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Job Requisition" where(Status=const(Approved), "Advertisement Status"=const(Closed), Shortlisted=const(false));

            trigger OnValidate()
            begin
                if JobRequisition.Get("Requisition No.")then begin
                    Rec."Job ID":=JobRequisition."Job ID";
                    Rec."Job Title":=JobRequisition.Description;
                    Rec."No of Positions":=JobRequisition.Positions;
                end;
            end;
        }
        field(4; "Job ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5; "Job Title"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(6; "No of Positions"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(7; "Pass Mark"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Created By"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(9; "No. Series"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(10; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Open, Closed;
            Editable = false;
        }
        field(11; "Preferred Gender";Enum "Employee Gender")
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Work Experience"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "No of Applicants"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count("Job Shortlisted Applicants" WHERE("No."=FIELD("No.")));
        }
        field(14; "Age Limit"; Text[5])
        {
        }
        field(15; "Type"; Option)
        {
            OptionMembers = "Long List", "Short List";
        }
        field(16; "Interview Conducted"; Boolean)
        {
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "No.", "Job ID", "Job Title", "Requisition No.")
        {
        }
        fieldgroup(Brick; "No.", "Job ID", "Job Title", "Requisition No.")
        {
        }
    }
    var HumanResSetup: Record "Human Resources Setup";
    NoSeriesMgt: Codeunit NoSeriesManagement;
    JobRequisition: Record "Job Requisition";
    trigger OnInsert()
    begin
        if "No." = '' then begin
            HumanResSetup.Get;
            HumanResSetup.TestField(HumanResSetup."Job Application Nos");
            NoSeriesMgt.InitSeries(HumanResSetup."Job Application Nos", xRec."No. Series", 0D, "No.", "No. Series");
        end;
        Date:=Today;
        "Created By":=UserId;
    end;
}

table 52203779 "Job Interview"
{
    Caption = 'Interview';
    DataClassification = ToBeClassified;

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
        field(3; "Shortlisting No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Job Shortlisting" where(Status=const(Closed), "Interview Conducted"=const(false));

            trigger OnValidate()
            begin
                if JobShortlisting.Get("Shortlisting No.")then Rec.Validate("Requisition No.", JobShortlisting."Requisition No.");
            end;
        }
        field(4; "Requisition No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Job Requisition" where(Status=const(Approved), "Advertisement Status"=const(Closed));
            Editable = false;

            trigger OnValidate()
            begin
                if JobRequisition.Get("Requisition No.")then begin
                    Rec."Job ID":=JobRequisition."Job ID";
                    Rec."Job Title":=JobRequisition.Description;
                    Rec."No of Positions":=JobRequisition.Positions;
                end;
            end;
        }
        field(5; "Job ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(6; "Job Title"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(7; "No of Positions"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(8; "Pass Mark"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Created By"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(10; "No. Series"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(11; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Created, Open, Closed;
            Editable = false;
        }
        field(12; "Subsequent Interview Mail"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(13; "No of Applicants"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count("Job Interview Applicants" WHERE("No."=FIELD("No.")));
        }
        field(14; Committee; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Committees.Code where(Interview=const(true));

            trigger OnValidate()
            begin
                if Committees.Get(Committee)then begin
                    Committees.TestField(Interview, true);
                    "Commitee Name":=Committees.Description;
                end;
            end;
        }
        field(15; "Commitee Name"; Text[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(16; "Discussion Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Discussion Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Closed Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(19; "Closed By"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(20; "Previous Interview"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(21; Subsequent; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
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
    JobShortlisting: Record "Job Shortlisting";
    Committees: Record Committees;
    trigger OnInsert()
    begin
        if "No." = '' then begin
            HumanResSetup.Get;
            HumanResSetup.TestField(HumanResSetup."Interview Nos");
            NoSeriesMgt.InitSeries(HumanResSetup."Interview Nos", xRec."No. Series", 0D, "No.", "No. Series");
        end;
        Date:=Today;
        "Created By":=UserId;
    end;
}

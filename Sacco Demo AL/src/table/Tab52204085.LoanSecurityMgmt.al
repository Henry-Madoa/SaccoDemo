table 52204085 "Loan Security Mgmt"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Loan Security Mgts.";
    DrillDownPageId = "Loan Security Mgts.";

    fields
    {
        field(1; "No."; Code[20])
        {
            Editable = false;
        }
        field(2; "Member No"; Code[20])
        {
            TableRelation = Members;

            trigger OnValidate()
            var
                Members: Record Members;
            begin
                Members.Get("Member No");
                "Member Name" := Members."Full Name";
            end;
        }
        field(3; "Member Name"; Text[100])
        {
            Editable = false;
        }
        field(4; "Created By"; Code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(5; "Created On"; DateTime)
        {
            Editable = false;
        }
        field(6; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(7; Processed; Boolean)
        {
            Editable = false;
        }
        field(8; "Loan No"; Code[20])
        {
            TableRelation = Loans where("Member No." = field("Member No"), Status = const(Approved), Posted = const(true), "Loan Balance" = filter(<> 0));
        }
        field(9; "Posting Date"; Date)
        {
            Editable = false;
        }
        field(10; "Portal Status"; Option)
        {
            OptionMembers = New,Submitted;
            Editable = false;
        }
        field(11; Source; Option)
        {
            OptionMembers = Channels,"Core Banking";
            Editable = false;
        }
        field(12; "Submitted On"; DateTime)
        {
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
    var
        SaccoSetup: Record "General Ledger Setup";
        NoSeries: Codeunit NoSeriesManagement;

    trigger OnInsert()
    begin
        SaccoSetup.Get();
        SaccoSetup.TestField("Guarantor Nos");
        "No." := NoSeries.GetNextNo(SaccoSetup."Guarantor Nos", Today, true);
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
    end;

    trigger OnDelete()
    var
        GuarantorsLines: Record "Loan Security Mgmt Lines";
        GuarantorMgtDetLines: Record "Loan Security Mgmt Det. Lines";
    begin
        TestField(Status, Status::Open);
        GuarantorsLines.Reset();
        GuarantorsLines.SetRange("No.", "No.");
        GuarantorsLines.DeleteAll(true);
        GuarantorMgtDetLines.Reset();
        GuarantorMgtDetLines.SetRange("No.", "No.");
        GuarantorMgtDetLines.DeleteAll(true);
    end;

    procedure Navigate()
    var
        NavigatePage: Page Navigate;
    begin
        NavigatePage.SetDoc("Posting Date", "No.");
        NavigatePage.SetRec(Rec);
        NavigatePage.Run;
    end;
}

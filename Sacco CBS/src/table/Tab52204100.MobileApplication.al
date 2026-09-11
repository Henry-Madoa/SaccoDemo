table 52204100 "Mobile Application"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Mobile Applications";
    DrillDownPageId = "Mobile Applications";

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
                Member: Record Members;
                MobileMembers: Record "Mobile Members";
            begin
                if MobileMembers.Get("Member No") then begin
                    if MobileMembers."Member Status" = MobileMembers."Member Status"::Active then
                        Error('The Member is already registered and is active. Please Block the member on the Mobile Member list')
                    else
                        Reactivation := true;
                end;
                Member.Get("Member No");
                "Full Name" := Member."Full Name";
                "Phone No" := Member."Mobile Phone No.";
                "ID No" := Member."Identification No.";
                "Mobile Transacting No" := Member."Mobile Transacting No";
                if MemberMgt.GetMemberAccount(Member."No.", ProductPostingType::"Withdrawable Deposit") <> '' then Validate("FOSA Account", MemberMgt.GetMemberAccount(Member."No.", ProductPostingType::"Withdrawable Deposit"));
            end;
        }
        field(3; "Full Name"; Text[150])
        {
            Editable = false;
        }
        field(4; "Phone No"; Code[20])
        {
            Editable = false;
        }
        field(5; "FOSA Account"; Code[20])
        {
            TableRelation = Vendor where("Member No." = field("Member No"), "Product Posting Type" = const("Withdrawable Deposit"));
        }
        field(6; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(8; Processed; Boolean)
        {
            Editable = false;
        }
        field(9; "Created By"; Code[50])
        {
            Editable = false;
            tablerelation = "User Setup";
        }
        field(10; "Created On"; DateTime)
        {
            Editable = false;
        }
        field(11; "Processed On"; DateTime)
        {
            Editable = false;
        }
        field(12; "Processed By"; Code[100])
        {
            Editable = false;
        }
        field(13; "ID No"; Code[20])
        {
            Editable = false;
        }
        field(14; Reactivation; Boolean)
        {
            Editable = false;
        }
        field(15; "Mobile Transacting No"; Code[20])
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
    var
        NoSeries: Codeunit NoSeriesManagement;
        SaccoSetup: Record "General Ledger Setup";
        MemberMgt: Codeunit "Member Management";
        ProductPostingType: Enum "Product Posting Type";

    trigger OnInsert()
    begin
        SaccoSetup.Get();
        SaccoSetup.TestField("Channel Application Nos.");
        if "No." = '' then "No." := NoSeries.GetNextNo(SaccoSetup."Channel Application Nos.", Today, true);
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
    end;

    trigger OnDelete()
    begin
        TestField(Processed, false);
        TestField(Status, Status::Open);
    end;

    trigger OnRename()
    begin
        TestField(Processed, false);
        TestField(Status, Status::Open);
    end;
}

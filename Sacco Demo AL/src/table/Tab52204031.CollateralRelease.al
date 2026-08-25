table 52204031 "Collateral Release"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Collateral Releases";

    fields
    {
        field(1; "No."; code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Member No."; code[20])
        {
            TableRelation = Members;

            trigger OnValidate()
            begin
                Member.Get("Member No.");
                "Member Name" := Member.FullName;
            end;
        }
        field(3; "Member Name"; Text[100])
        {
            Editable = false;
        }
        field(4; "Collateral Code"; Code[20])
        {
            TableRelation = "Collateral Register" where("Member No." = field("Member No."), Status = filter(<> Collected));

            trigger OnValidate()
            var
                CollRegister: Record "Collateral Register";
            begin
                If CollRegister.Get("Collateral Code") then CollRegister.UpdateCollateralRegister;
            end;
        }
        field(5; "Collateral Description"; Text[150])
        {
            Editable = false;
        }
        field(6; "Linked Loan Balance"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Collateral Linked Loans"."Current Balance" where("No." = field("Collateral Code")));
        }
        field(7; "Created By"; code[50])
        {
            TableRelation = "User Setup";
            Editable = false;
        }
        field(8; "Created On"; Date)
        {
            Editable = false;
        }
        field(9; Posted; Boolean)
        {
            Editable = false;
        }
        field(10; "Processed On"; Date)
        {
            Editable = false;
        }
        field(11; Remarks; Text[250])
        {
        }
        field(12; Comments; Text[250])
        {
        }
        field(13; "Collected By"; Text[100])
        {
        }
        field(14; "Collected By ID No"; code[50])
        {
        }
        field(15; Nationality; Enum "Nationality Types")
        {
            trigger OnValidate()
            var
                GeneralSetup: Record "General Ledger Setup";
            begin
                Domicile := '';
                "Country Name" := '';
                if Nationality = Nationality::Kenyan then begin
                    GeneralSetup.Get;
                    GeneralSetup.TestField("Country Code");
                    Validate(Domicile, GeneralSetup."Country Code");
                end;
            end;
        }
        field(16; Domicile; Code[20])
        {
            TableRelation = "Country/Region";

            trigger OnValidate()
            var
                CountryRegion: Record "Country/Region";
            begin
                if CountryRegion.Get(Domicile) then "Country Name" := CountryRegion.Name;
            end;
        }
        field(17; "Country Name"; Text[100])
        {
            Editable = false;
        }
        field(18; "Phone No"; code[50])
        {
            trigger OnValidate()
            var
                MemberMgmt: Codeunit "Member Management";
            begin
                MemberMgmt.PhoneNumberValidation("Phone No", Domicile);
            end;
        }
        field(19; "Collection Date"; Date)
        {
            trigger OnValidate()
            begin
                If "Collection Date" > WorkDate then Error('Collection Date cannot be a future date!');
            end;
        }
        field(20; Status; Enum "Document Status")
        {
            Editable = false;
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }
    var
        Noseries: Codeunit NoSeriesManagement;
        SaccoSetup: Record "General Ledger Setup";
        Loans: Record Loans;
        LoanSecurity: Record "Loan Securities";
        Member: Record Members;

    trigger OnInsert()
    begin
        SaccoSetup.Get();
        SaccoSetup.TestField("Collateral Release Nos.");
        "No." := Noseries.GetNextNo(SaccoSetup."Collateral Release Nos.", Today, true);
        "Created By" := UserId;
        "Created On" := WorkDate;
    end;
}

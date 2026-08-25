table 52204126 "Employers"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = Employers;
    LookupPageId = Employers;

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Name; Text[50])
        {
        }
        field(3; Address; Text[50])
        {
        }
        field(4; Nationality; Enum "Nationality Types")
        {
            DataClassification = ToBeClassified;

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
        field(5; Domicile; Code[20])
        {
            TableRelation = "Country/Region";

            trigger OnValidate()
            var
                CountryRegion: Record "Country/Region";
            begin
                if CountryRegion.Get(Domicile) then "Country Name" := CountryRegion.Name;
            end;
        }
        field(6; "Country Name"; Text[100])
        {
            Editable = false;
        }
        field(7; "Phone No"; Code[50])
        {
            trigger OnValidate()
            var
                MemberMgmt: Codeunit "Member Management";
            begin
                MemberMgmt.PhoneNumberValidation("Phone No", Domicile);
            end;
        }
        field(8; "Email Address"; Code[20])
        {
        }
        field(9; "Checkoff Account"; Code[20])
        {
            TableRelation = Customer;
        }
        field(10; "Salary Account"; Code[20])
        {
            TableRelation = Customer;
        }
        field(11; "Suspense Account"; Code[20])
        {
            TableRelation = Customer;
        }
        field(12; "Not Paid Up Members"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count(Members where("Employer Code" = field(Code), Status = filter("Not Paid Up")));
            Editable = false;
        }
        field(13; "Active Members"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count(Members where("Employer Code" = field(Code), Status = filter(Active)));
            Editable = false;
        }
        field(14; "Inactive Members"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count(Members where("Employer Code" = field(Code), Status = filter(Inactive)));
            Editable = false;
        }
        field(15; "Dormant Members"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count(Members where("Employer Code" = field(Code), Status = filter(Dormant)));
            Editable = false;
        }
        field(16; "Withdrawn Members"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count(Members where("Employer Code" = field(Code), Status = filter(Withdrawn)));
            Editable = false;
        }
        field(17; "Deceased Members"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count(Members where("Employer Code" = field(Code), Status = filter(Deceased)));
            Editable = false;
        }
        field(18; "Closed Members"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count(Members where("Employer Code" = field(Code), Status = filter(Closed)));
            Editable = false;
        }
        field(19; Blocked; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            Description = 'If an employer ceases to provide services for the sacco.';
        }
        field(20; "Payroll No. Mandatory"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
        key(Key2; Name, "Email Address", "Phone No")
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Code, Name, "Phone No", "Email Address")
        {
        }
    }
}

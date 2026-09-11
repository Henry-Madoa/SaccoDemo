table 52204092 "Signatories & Directors"
{
    DataClassification = ToBeClassified;
    DataCaptionFields = Type, Name;
    DrillDownPageId = "Signatories & Directors";
    LookupPageId = "Signatories & Directors";

    fields
    {
        field(1; "Source Code"; Code[20])
        {
            trigger OnValidate()
            begin
                If MemberApplication.Get(Rec."Source Code") then begin
                    MemberCategories.Get(MemberApplication.Category);
                    Validate("Category Type", MemberCategories."Category Type");
                end
                else If MemberEditting.Get(Rec."Source Code") then begin
                    if Member.Get(MemberEditting."Member No.") then if MemberCategories.Get(Member.Category) then Validate("Category Type", MemberCategories."Category Type");
                end;
            end;
        }
        field(2; "Identification No."; Code[20])
        {
            trigger OnValidate()
            var
                MemberMgmt: Codeunit "Member Management";
            begin
                if "Identification Type" = "Identification Type"::"National ID" then begin
                    MemberMgmt.NationalIDValidation("Identification No.");
                    if (("Identification No." = '') and "IPRS Uneditability") then "IPRS Uneditability" := false;
                end;
                Members.Reset();
                Members.SetRange("Identification No.", "Identification No.");
                If Members.FindFirst() then begin
                    Members.CalcFields(Signature, "Passport Size Photo");
                    Name := Members.FullName;
                    "Identification No." := Members."Identification No.";
                    Designation := Members.Designation;
                    "Phone No" := Members."Mobile Phone No.";
                    "Date of Birth" := Members."Date of Birth";
                    "Signature Card" := Members.Signature;
                    "Passport Image" := Members."Passport Size Photo";
                end;
            end;
        }
        field(3; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(4; "Type"; Enum "Company Members Type")
        {
        }
        field(5; "Designation"; Code[20])
        {
            TableRelation = if ("Category Type" = const(Individual)) "Member Designation" where(Type = const(Individual))
            else
            "Member Designation" where(Type = const(Group));
        }
        field(6; Name; Text[250])
        {
        }
        field(7; Nationality; Enum "Nationality Types")
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
        field(8; Domicile; Code[20])
        {
            TableRelation = "Country/Region";

            trigger OnValidate()
            var
                CountryRegion: Record "Country/Region";
            begin
                if CountryRegion.Get(Domicile) then "Country Name" := CountryRegion.Name;
            end;
        }
        field(9; "Country Name"; Text[100])
        {
            Editable = false;
        }
        field(10; "Phone No"; Code[20])
        {
            trigger OnValidate()
            var
                MemberMgmt: Codeunit "Member Management";
            begin
                MemberMgmt.PhoneNumberValidation("Phone No", Domicile);
            end;
        }
        field(11; "Passport Image"; Blob)
        {
            Subtype = Bitmap;
        }
        field(12; "Signature Card"; Blob)
        {
            Subtype = Bitmap;
        }
        field(13; "Member No"; Code[20])
        {
            TableRelation = Members;

            trigger OnValidate()
            begin
                Members.Get("Member No");
                Members.CalcFields(Signature, "Passport Size Photo");
                Name := Members.FullName;
                "Identification No." := Members."Identification No.";
                Designation := Members.Designation;
                "Phone No" := Members."Mobile Phone No.";
                "Date of Birth" := Members."Date of Birth";
                "Signature Card" := Members.Signature;
                "Passport Image" := Members."Passport Size Photo";
            end;
        }
        field(14; "Date of Birth"; Date)
        {
        }
        field(15; "IPRS Uneditability"; Boolean)
        {
        }
        field(16; "Identification Type"; Enum "Identity Type")
        {
        }
        field(17; "Category Type"; Enum "Member Category Types")
        {
            trigger OnValidate()
            begin
                if "Category Type" In ["Category Type"::Individual, "Category Type"::"Group Member"] then begin
                    If MemberApplication.Get(Rec."Source Code") then begin
                        MemberApplication.CalcFields(Signature, "Passport Size Photo");
                        Name := MemberApplication.FullName;
                        "Identification Type" := MemberApplication."Identification Type";
                        "Identification No." := MemberApplication."Identification No.";
                        "Phone No" := MemberApplication."Mobile Phone No.";
                        "Date of Birth" := MemberApplication."Date of Birth";
                        "Signature Card" := MemberApplication.Signature;
                        "Passport Image" := MemberApplication."Passport Size Photo";
                        Modify(true);
                    end
                    else If MemberEditting.Get(Rec."Source Code") then begin
                        if Member.Get(MemberEditting."Member No.") then begin
                            Members.CalcFields(Signature, "Passport Size Photo");
                            "Identification Type" := Member."Identification Type";
                            Name := Members.FullName;
                            "Identification No." := Members."Identification No.";
                            Designation := Members.Designation;
                            "Phone No" := Members."Mobile Phone No.";
                            "Date of Birth" := Members."Date of Birth";
                            "Signature Card" := Members.Signature;
                            "Passport Image" := Members."Passport Size Photo";
                            Modify(true);
                        end;
                    end;
                end;
            end;
        }
    }
    keys
    {
        key(Key1; "Source Code", "Entry No.", Type)
        {
            Clustered = true;
        }
        key(Key2; "Member No")
        {
        }
    }
    var
        Members: Record Members;
        MemberApplication: Record "Member Application";
        Member: Record Members;
        MemberEditting: Record "Member Editing";
        MemberCategories: Record "Member Categories";
}

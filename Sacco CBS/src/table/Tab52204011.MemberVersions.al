table 52204011 "Member Versions"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Document No."; code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Member No."; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
            end;
        }
        field(3; "First Name"; Text[50])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                "First Name" := UpperCase("First Name");
                Validate("Full Name");
            end;
        }
        field(4; "Middle Name"; Text[50])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                "Middle Name" := UpperCase("Middle Name");
                Validate("Full Name");
            end;
        }
        field(5; "Last Name"; Text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Surname';
            trigger OnValidate()
            begin
                "Last Name" := UpperCase("Last Name");
                Validate("Full Name");
            end;
        }
        field(6; "Full Name"; Text[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnValidate()
            begin
                "Full Name" := "First Name" + ' ' + "Middle Name" + ' ' + "Last Name";
                "Full Name" := UpperCase("Full Name");
            end;
        }
        field(7; "Mobile Phone No."; Code[50])
        {
            DataClassification = ToBeClassified;
            ExtendedDatatype = PhoneNo;

            trigger OnValidate()
            var
                MemberMgmt: Codeunit "Member Management";
            begin
                if "Mobile Phone No." <> '' then MemberMgmt.PhoneNumberValidation("Mobile Phone No.", Domicile);
            end;
        }
        field(8; "Alt. Phone No"; Code[50])
        {
            DataClassification = ToBeClassified;
            ExtendedDatatype = PhoneNo;

            trigger OnValidate()
            var
                MemberMgmt: Codeunit "Member Management";
            begin
                if "Alt. Phone No" <> '' then MemberMgmt.PhoneNumberValidation("Alt. Phone No", Domicile);
            end;
        }
        field(9; Gender; Enum "Employee Gender")
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Identification No."; Code[50])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                MemberMgmt: Codeunit "Member Management";
            begin
                if "Identification Type" = "Identification Type"::"National ID" then MemberMgmt.NationalIDValidation("Identification No.");
            end;
        }
        field(11; "Date of Birth"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Payroll No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Created On"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14; "Created By"; Code[50])
        {
            TableRelation = "User Setup";
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(15; Status; Enum "Document Status")
        {
            Editable = false;
        }
        field(16; Address; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(17; City; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(18; County; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Counties;
        }
        field(19; "Sub County"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Sub Counties"."Sub County Code" where("County Code" = field(County));
        }
        field(20; "E-Mail"; Text[100])
        {
            ExtendedDatatype = EMail;

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                if "E-Mail" <> '' then MailManagement.CheckValidEmailAddresses("E-Mail");
            end;
        }
        field(21; "Employer Code"; code[20])
        {
            TableRelation = Employers;
        }
        field(22; "Member Image"; blob)
        {
            Subtype = Bitmap;
        }
        field(23; "Front ID Image"; blob)
        {
            Subtype = Bitmap;
        }
        field(24; "Back ID Image"; blob)
        {
            Subtype = Bitmap;
        }
        field(25; "Marital Status"; Option)
        {
            OptionMembers = Single,Married,Widowed,Divorced,Withheld;
        }
        field(26; "KRA PIN"; Code[20])
        {
            trigger OnValidate()
            var
                MemberMgmt: Codeunit "Member Management";
            begin
                MemberMgmt.KRAPinValidation("KRA PIN");
            end;
        }
        field(27; Occupation; Code[20])
        {
            TableRelation = "Sacco Lookup Values".Code where(Type = const(Occupations));

            trigger OnValidate()
            var
                SaccoLookupValues: Record "Sacco Lookup Values";
            begin
                if SaccoLookupValues.Get(SaccoLookupValues.Type::Occupations, Occupation) then "Occupation Description" := SaccoLookupValues.Description;
            end;
        }
        field(28; "Occupation Description"; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(29; "Type of Residence"; Option)
        {
            OptionMembers = Rented,Owned;
        }
        field(30; "Town of Residence"; code[50])
        {
        }
        field(31; "Estate of Residence"; code[50])
        {
        }
        field(32; "Empployer Code"; Code[20])
        {
        }
        field(33; "Payroll No"; code[20])
        {
        }
        field(34; "Station Code"; Code[20])
        {
        }
        field(35; "Designation"; Code[20])
        {
            TableRelation = "Member Designation" where(Type = const(Individual));
        }
        field(36; Nationality; Enum "Nationality Types")
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
        field(37; "Mobile Transacting No"; Code[20])
        {
            trigger OnValidate()
            var
                MemberMgmt: Codeunit "Member Management";
            begin
                if "Mobile Transacting No" <> '' then MemberMgmt.PhoneNumberValidation("Mobile Transacting No", Domicile);
            end;
        }
        field(38; "Signature Card"; blob)
        {
            Subtype = Bitmap;
        }
        field(39; "Emplyoment Type"; Enum "Employee Type")
        {
            Caption = 'Type';
        }
        field(40; Class; Code[20])
        {
            TableRelation = "Sacco Lookup Values".Code where(Type = const("Member Classes"));
            Editable = false;
        }
        field(41; "Address 2"; Code[20])
        {
        }
        field(42; "Department Code"; Code[20])
        {
            TableRelation = "Employer Departments".Code where("Employer Code" = field("Employer Code"));
        }
        field(43; "Relationship Officer"; Code[20])
        {
            TableRelation = Employee where(Status = filter(Active | Inactive));

            trigger OnValidate()
            begin
                if Employee.Get("Relationship Officer") then "Relationship Officer Name" := Employee.FullName;
            end;
        }
        field(44; "Relationship Officer Name"; Text[100])
        {
            Editable = false;
        }
        field(45; "Identification Type"; Enum "Identity Type")
        {
        }
        field(46; Domicile; Code[20])
        {
            TableRelation = "Country/Region";

            trigger OnValidate()
            begin
                if CountryRegion.Get(Domicile) then "Country Name" := CountryRegion.Name;
            end;
        }
        field(47; "Country Name"; Text[100])
        {
            Editable = false;
        }
        field(48; "Date of Issue"; Date)
        {
        }
        field(49; "Date of Expiry"; Date)
        {
        }
        field(50; Channels; Boolean)
        {
        }
        field(51; "Marketing Texts"; Boolean)
        {
        }
        field(52; "E-Statement"; Boolean)
        {
        }
        field(53; "E-Statement Period"; DateFormula)
        {
        }
        field(54; "ATM Limit"; Decimal)
        {
            Editable = false;
        }
        field(55; "Mobi Loan Limit"; Decimal)
        {
            Editable = false;
        }
        field(56; "Prior Year Dividend"; Decimal)
        {
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Document No.")
        {
            Clustered = true;
        }
    }
    var
        NoSeries: Codeunit NoSeriesManagement;
        SaccoSetup: Record "General Ledger Setup";
        Member: Record Members;
        Employee: Record Employee;
        CountryRegion: Record "Country/Region";
}

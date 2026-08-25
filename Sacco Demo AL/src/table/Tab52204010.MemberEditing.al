table 52204010 "Member Editing"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Member Editings";
    LookupPageId = "Member Editings";

    fields
    {
        field(1; "No."; code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; Description; Text[250])
        {
            Caption = 'Reason';
            DataClassification = ToBeClassified;
        }
        field(3; "Member No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Members;

            trigger OnValidate()
            var
                MemberKins: array[3] of Record "Member Nominee/Kin";
                Signatories: array[3] of Record "Signatories & Directors";
                AccountInstructions: array[3] of Record "Member Account Instructions";
                MemberSubscriptions: array[3] of Record "Member Subscriptions";
            begin
                MemberKins[3].Reset();
                MemberKins[3].SetRange("Source Code", "No.");
                MemberKins[3].DeleteAll();
                Signatories[3].Reset();
                Signatories[3].SetRange("Source Code", "No.");
                Signatories[3].DeleteAll();
                AccountInstructions[3].Reset();
                AccountInstructions[3].SetRange("Source Code", "No.");
                AccountInstructions[3].DeleteAll();
                MemberSubscriptions[3].Reset();
                MemberSubscriptions[3].SetRange("Source Code", "No.");
                MemberSubscriptions[3].DeleteAll();
                Member.Get("Member No.");
                Member.CalcFields("Passport Size Photo", "Front ID Photo", "Back ID Photo", Signature);
                "First Name" := Member."First Name";
                "Middle Name" := Member."Middle Name";
                "Last Name" := Member."Last Name";
                "Mobile Phone No." := Member."Mobile Phone No.";
                "Alt. Phone No" := Member."Alt. Phone No";
                Gender := Member.Gender;
                "Member Status" := Member.Status;
                "Registration Date" := Member."Date of Registration";
                Validate("Relationship Officer", Member."Relationship Officer");
                Nationality := Member.Nationality;
                Validate(Domicile, Member.Domicile);
                "Identification Type" := Member."Identification Type";
                "Identification No." := Member."Identification No.";
                "Passport No." := Member."Passport No.";
                "Address 2" := Member."Address 2";
                "Department Code" := Member."Department Code";
                "Date of Birth" := Member."Date of Birth";
                Address := Member.Address;
                City := Member.City;
                County := Member.County;
                "Sub County" := Member."Sub County";
                "Marital Status" := Member."Marital Status";
                "Type of Residence" := Member."Type of Residence";
                "Passport Size Photo" := Member."Passport Size Photo";
                "Front ID Photo" := Member."Front ID Photo";
                "Back ID Photo" := Member."Back ID Photo";
                Signature := Member.Signature;
                "Marital Status" := Member."Marital Status";
                "Town of Residence" := Member."Town of Residence";
                "Estate of Residence" := Member."Estate of Residence";
                "Emplyoment Type" := Member."Emplyoment Type";
                Salaried := Member.Salaried;
                "Station Code" := Member."Station Code";
                Designation := Member.Designation;
                Occupation := Member.Occupation;
                "Occupation Description" := Member."Occupation Description";
                "Payroll No." := Member."Payroll No.";
                "Employer Code" := Member."Employer Code";
                "E-Mail" := Member."E-Mail";
                "KRA PIN" := Member."KRA PIN";
                "Group Name" := Member."Group/Corporate Name";
                "Group No" := Member."Group/Corporate No";
                "Date of Registration" := Member."Date of Registration";
                "Certificate of Incoop" := Member."Certificate of Incoop";
                "Is Group/Corporate" := Member."Is Group/Corporate";
                "Category Type" := Member."Category Type";
                "Protected Account" := Member."Protected Account";
                "Account Owner" := Member."Account Owner";
                "Mobile Transacting No" := Member."Mobile Transacting No";
                "ATM Limit" := Member."ATM Limit";
                "Mobi Loan Limit" := Member."Mobi Loan Limit";
                "Prior Year Dividend" := Member."Prior Year Dividend";
                "Marketing Texts" := Member."Marketing Texts";
                "E-Statement" := Member."E-Statement";
                "E-Statement Period" := Member."E-Statement Period";
                Goals := Member.Goals;
                "Mobi Loan Limit" := Member."Mobi Loan Limit";
                "Prior Year Dividend" := Member."Prior Year Dividend";
                Validate("Full Name");
                Signatories[1].Reset();
                Signatories[1].SetRange("Source Code", "Member No.");
                if Signatories[1].FindSet() then begin
                    repeat
                        Signatories[2].Init();
                        Signatories[2].TransferFields(Signatories[1]);
                        Signatories[2]."Source Code" := "No.";
                        Signatories[2].Insert();
                    until Signatories[1].Next() = 0;
                end;
                MemberKins[1].Reset();
                MemberKins[1].SetRange("Source Code", "Member No.");
                if MemberKins[1].FindSet() then begin
                    repeat
                        MemberKins[2].Init();
                        MemberKins[2].TransferFields(MemberKins[1], false);
                        MemberKins[2]."Source Code" := Rec."No.";
                        MemberKins[2]."Relative Code" := MemberKins[1]."Relative Code";
                        MemberKins[2]."Identification No." := MemberKins[1]."Identification No.";
                        MemberKins[2]."Document Type" := MemberKins[1]."Document Type";
                        MemberKins[2].Insert(true);
                    until MemberKins[1].Next() = 0;
                end;
                AccountInstructions[1].Reset();
                AccountInstructions[1].SetRange("Source Code", "Member No.");
                if AccountInstructions[1].FindSet() then begin
                    repeat
                        AccountInstructions[2].Init();
                        AccountInstructions[2].TransferFields(AccountInstructions[1], false);
                        AccountInstructions[2]."Source Code" := "No.";
                        AccountInstructions[2]."Line No" := AccountInstructions[1]."Line No";
                        AccountInstructions[2].Insert(true);
                    until AccountInstructions[1].Next() = 0;
                end;
                MemberSubscriptions[1].Reset();
                MemberSubscriptions[1].SetRange("Source Code", "Member No.");
                if MemberSubscriptions[1].FindSet() then begin
                    repeat
                        MemberSubscriptions[2].Init();
                        MemberSubscriptions[2].TransferFields(MemberSubscriptions[1], false);
                        MemberSubscriptions[2]."Source Code" := "No.";
                        MemberSubscriptions[2]."Account Type" := MemberSubscriptions[1]."Account Type";
                        MemberSubscriptions[2].Insert(true);
                    until MemberSubscriptions[1].Next() = 0;
                end;
            end;
        }
        field(4; "Category Type"; Enum "Member Category Types")
        {
        }
        field(5; "First Name"; Text[50])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                Validate("Full Name");
            end;
        }
        field(6; "Middle Name"; Text[50])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                Validate("Full Name");
            end;
        }
        field(7; "Last Name"; Text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Surname';
            trigger OnValidate()
            begin
                Validate("Full Name");
            end;
        }
        field(8; "Full Name"; Text[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnValidate()
            begin
                "Full Name" := "First Name" + ' ' + "Middle Name" + ' ' + "Last Name";
            end;
        }
        field(9; "Mobile Phone No."; Code[50])
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
        field(10; "Alt. Phone No"; Code[50])
        {
            DataClassification = ToBeClassified;
            ExtendedDatatype = PhoneNo;

            trigger OnValidate()
            begin
                if "Alt. Phone No" <> '' then MemberMgmt.PhoneNumberValidation("Alt. Phone No", Domicile);
            end;
        }
        field(11; Gender; Enum "Employee Gender")
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Identification No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Passport No."; Code[20])
        {
            trigger OnValidate()
            begin
                MemberMgmt.ValidateIdentificationNo(IdentityType::Passport, "Passport No.");
            end;
        }
        field(14; "Date of Issue"; Date)
        {
        }
        field(15; "Date of Expiry"; Date)
        {
        }
        field(16; "Date of Birth"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Payroll No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(18; Status; Enum "Document Status")
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(19; Address; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(20; City; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(21; County; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Counties;
        }
        field(22; "Sub County"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Sub Counties"."Sub County Code" where("County Code" = field(County));
        }
        field(23; "E-Mail"; Text[100])
        {
            ExtendedDatatype = EMail;

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                if "E-Mail" <> '' then MailManagement.CheckValidEmailAddresses("E-Mail");
            end;
        }
        field(24; "Employer Code"; code[20])
        {
            TableRelation = Employers;
        }
        field(25; "Passport Size Photo"; blob)
        {
            Subtype = Bitmap;

            trigger OnValidate()
            var
                SaccoSetup: Record "General Ledger Setup";
            begin
                SaccoSetup.Get;
                SaccoSetup.TestField("Passport Size");
                if "Passport Size Photo".Length > SaccoSetup."Passport Size" then Error(StrSubstNo('Maximun size Image should be %1Kbs', SaccoSetup."Passport Size" / 1000));
            end;
        }
        field(26; "Front ID Photo"; blob)
        {
            Subtype = Bitmap;

            trigger OnValidate()
            var
                SaccoSetup: Record "General Ledger Setup";
            begin
                SaccoSetup.Get;
                SaccoSetup.TestField("Identification Card Size");
                if "Front ID Photo".Length > SaccoSetup."Identification Card Size" then Error(StrSubstNo('Maximun size Image should be %1Kbs', SaccoSetup."Identification Card Size" / 1000));
            end;
        }
        field(27; "Back ID Photo"; blob)
        {
            Subtype = Bitmap;

            trigger OnValidate()
            var
                SaccoSetup: Record "General Ledger Setup";
            begin
                SaccoSetup.Get;
                SaccoSetup.TestField("Identification Card Size");
                if "Back ID Photo".Length > SaccoSetup."Identification Card Size" then Error(StrSubstNo('Maximun size Image should be %1Kbs', SaccoSetup."Identification Card Size" / 1000));
            end;
        }
        field(28; "Marital Status"; Option)
        {
            OptionMembers = Single,Married,Widowed,Divorced,Withheld;
        }
        field(29; "KRA PIN"; Code[20])
        {
            trigger OnValidate()
            var
                MemberMgmt: Codeunit "Member Management";
            begin
                MemberMgmt.KRAPinValidation("KRA PIN");
            end;
        }
        field(30; Occupation; Code[20])
        {
            TableRelation = "Sacco Lookup Values".Code where(Type = const(Occupations));

            trigger OnValidate()
            var
                SaccoLookupValues: Record "Sacco Lookup Values";
            begin
                if SaccoLookupValues.Get(SaccoLookupValues.Type::Occupations, Occupation) then "Occupation Description" := SaccoLookupValues.Description;
            end;
        }
        field(31; "Occupation Description"; Text[100])
        {
            Caption = 'Description';
        }
        field(32; "Type of Residence"; Option)
        {
            OptionMembers = Rented,Owned;
        }
        field(33; Processed; Boolean)
        {
            Editable = false;
        }
        field(34; "Town of Residence"; code[50])
        {
        }
        field(35; "Estate of Residence"; code[50])
        {
        }
        field(36; "Station Code"; code[20])
        {
            TableRelation = "Employer Stations".Code where("Employer Code" = field("Employer Code"));
        }
        field(37; Nationality; Enum "Nationality Types")
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
        field(38; Designation; Code[20])
        {
            TableRelation = "Member Designation" where(Type = const(Individual));
        }
        field(39; "Certificate Expiry"; Date)
        {
        }
        field(40; "Group No"; Code[80])
        {
        }
        field(41; "Group Name"; Text[100])
        {
        }
        field(42; "Certificate of Incoop"; Code[30])
        {
        }
        field(43; "Date of Registration"; Date)
        {
        }
        field(44; "Is Group/Corporate"; Boolean)
        {
        }

        field(45; Signature; blob)
        {
            Subtype = Bitmap;

            trigger OnValidate()
            var
                SaccoSetup: Record "General Ledger Setup";
            begin
                SaccoSetup.Get;
                SaccoSetup.TestField("Signature Size");
                if Signature.Length > SaccoSetup."Signature Size" then Error(StrSubstNo('Maximun size Image should be %1Kbs', SaccoSetup."Signature Size" / 1000));
            end;
        }
        field(46; "Marketing Texts"; Boolean)
        {
        }
        field(47; "E-Statement"; Boolean)
        {
        }
        field(48; "E-Statement Period"; DateFormula)
        {
        }
        field(49; "Protected Account"; Boolean)
        {
            trigger OnValidate()
            begin
                if not "Protected Account" then Clear("Account Owner");
            end;
        }
        field(50; "Account Owner"; Code[50])
        {
            TableRelation = "User Setup";
        }
        field(51; "Mobile Transacting No"; Code[20])
        {
            trigger OnValidate()
            var
                MemberMgmt: Codeunit "Member Management";
            begin
                if "Mobile Transacting No" <> '' then
                    MemberMgmt.PhoneNumberValidation("Mobile Transacting No", Domicile);
            end;
        }
        field(52; "Portal Status"; Option)
        {
            OptionMembers = New,Submitted;
        }
        field(53; "Emplyoment Type"; Enum "Employee Type")
        {
            Caption = 'Type';

            trigger OnValidate()
            begin
                if Rec."Emplyoment Type" <> xRec."Emplyoment Type" then begin
                    Rec."Employer Code" := '';
                    Rec.Designation := '';
                    Rec."Station Code" := '';
                    Rec."Payroll No." := '';
                    Rec.Occupation := '';
                    Rec."Occupation Description" := '';
                end;
            end;
        }
        field(54; Salaried; Boolean)
        {
            Editable = false;
        }
        field(55; "Member Status"; Enum "Member Status")
        {
            DataClassification = ToBeClassified;
        }
        field(56; "Registration Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(57; Class; Code[20])
        {
            TableRelation = "Sacco Lookup Values".Code where(Type = const("Member Classes"));
        }
        field(58; "Address 2"; Code[20])
        {
        }
        field(59; "Department Code"; Code[20])
        {
            TableRelation = "Employer Departments".Code where("Employer Code" = field("Employer Code"));
        }
        field(60; "Relationship Officer"; Code[20])
        {
            TableRelation = Employee where(Status = filter(Active | Inactive));

            trigger OnValidate()
            begin
                if Employee.Get("Relationship Officer") then "Relationship Officer Name" := Employee.FullName;
            end;
        }
        field(61; "Relationship Officer Name"; Text[100])
        {
            Editable = false;
        }
        field(62; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1), Blocked = CONST(false));
        }
        field(63; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2), Blocked = CONST(false));
        }
        field(64; "Identification Type"; Enum "Identity Type")
        {
        }
        field(65; Domicile; Code[20])
        {
            TableRelation = "Country/Region";

            trigger OnValidate()
            begin
                if CountryRegion.Get(Domicile) then "Country Name" := CountryRegion.Name;
            end;
        }
        field(66; "Country Name"; Text[100])
        {
            Editable = false;
        }
        field(67; "ATM Limit"; Decimal)
        {
        }
        field(68; "Mobi Loan Limit"; Decimal)
        {
        }
        field(69; "Prior Year Dividend"; Decimal)
        {
        }
        field(70; Goals; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(71; "Created On"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(72; "Created By"; Code[50])
        {
            TableRelation = "User Setup";
            DataClassification = ToBeClassified;
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
        NoSeries: Codeunit NoSeriesManagement;
        SaccoSetup: Record "General Ledger Setup";
        Member: Record Members;
        CountryRegion: Record "Country/Region";
        Employee: Record Employee;
        MemberMgmt: Codeunit "Member Management";
        IdentityType: Enum "Identity Type";

    trigger OnInsert()
    begin
        SaccoSetup.Get();
        SaccoSetup.TestField("Member Editing Nos");
        "No." := NoSeries.GetNextNo(SaccoSetup."Member Editing Nos", Today, true);
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
    end;

    procedure FullName(): Text[100]
    begin
        if "Is Group/Corporate" then
            exit(UpperCase("Group Name"))
        else begin
            if "Middle Name" = '' then
                exit(UpperCase("First Name" + ' ' + "Last Name"))
            else
                exit(UpperCase("First Name" + ' ' + "Middle Name" + ' ' + "Last Name"));
        end;
    end;
}

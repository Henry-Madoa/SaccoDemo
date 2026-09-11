table 52204004 "Members"
{
    LookupPageId = Members;
    DrillDownPageId = Members;

    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Old No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "First Name"; Text[30])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                Validate("Full Name");
            end;
        }
        field(4; "Middle Name"; Text[30])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                Validate("Full Name");
            end;
        }
        field(5; "Last Name"; Text[30])
        {
            DataClassification = ToBeClassified;
            Caption = 'Surname';
            trigger OnValidate()
            begin
                Validate("Full Name");
            end;
        }
        field(6; "Full Name"; Text[80])
        {
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnValidate()
            begin
                "Full Name" := FullName;
            end;
        }
        field(7; "Mobile Phone No."; Code[50])
        {
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
            begin
                MemberMgmt.ValidateIdentificationNo("Identification Type", "Identification No.");
            end;
        }
        field(11; "Passport No."; Code[20])
        {
            trigger OnValidate()
            begin
                MemberMgmt.ValidateIdentificationNo(IdentityType::Passport, "Passport No.");
            end;
        }
        field(12; "Date of Issue"; Date)
        {
        }
        field(13; "Date of Expiry"; Date)
        {
        }
        field(14; "Date of Birth"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(15; Address; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(16; City; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(17; County; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Counties;
        }
        field(18; "Sub County"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Sub Counties"."Sub County Code" where("County Code" = field(County));
        }
        field(19; Category; code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Member Categories";

            trigger onvalidate()
            var
                MemberCategory: Record "Member Categories";
            begin
                if MemberCategory.Get(Category) then begin
                    MemberCategory.TestField("Registration Fee");
                    MemberCategory.TestField("Registration Fee Account");
                    MemberCategory.TestField(Class);
                    Class := MemberCategory.Class;
                    "Category Type" := MemberCategory."Category Type";
                    "Is Group/Corporate" := MemberCategory."Category Type" in [MemberCategory."Category Type"::Group, MemberCategory."Category Type"::Institution, MemberCategory."Category Type"::"Micro Finance", MemberCategory."Category Type"::"Joint Account"];
                end;
            end;
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
        field(22; "Date Filter"; Date)
        {
            FieldClass = FlowFilter;
        }
        field(23; "Paid Registration"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Member No." = field("No."), "Posting Date" = field("Date Filter"), "Sacco Transaction Type" = const("Registration Fee")));
        }
        field(24; "Total Withdrawable Deposits"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = - sum("Detailed Vendor Ledg. Entry".Amount where("Member No." = field("No."), "Posting Date" = field("Date Filter"), "Product Posting Type" = const("Withdrawable Deposit")));
        }
        field(25; "Total Deposits"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = - sum("Detailed Vendor Ledg. Entry".Amount where("Member No." = field("No."), "Posting Date" = field("Date Filter"), "Product Posting Type" = const("Non Withdrawable Deposit")));
        }
        field(26; "Total Shares"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = - sum("Detailed Vendor Ledg. Entry".Amount where("Member No." = field("No."), "Posting Date" = field("Date Filter"), "Product Posting Type" = const("Share Capital Account")));
        }
        field(27; "Outstanding Loans"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Detailed Vendor Ledg. Entry".Amount where("Member No." = field("No."), "Posting Date" = field("Date Filter"), "Product Posting Type" = const("Loan Account")));
        }
        field(28; "Running Loans"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count(Loans where(Posted = const(true), "Member No." = field("No."), "Loan Balance" = filter(<> 0)));
            Editable = false;
        }
        field(29; "Held Collateral"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Collateral Register".Guarantee where("Member No." = field("No."), Status = filter(<> Collected)));
            Editable = false;
        }
        field(30; Image; Media)
        {
            Caption = 'Image';
            ExtendedDatatype = Person;
        }
        field(31; "Passport Size Photo"; blob)
        {
            Subtype = Bitmap;
        }
        field(32; "Front ID Photo"; blob)
        {
            Subtype = Bitmap;
        }
        field(33; "Back ID Photo"; blob)
        {
            Subtype = Bitmap;
        }
        field(34; "Marital Status"; Option)
        {
            OptionMembers = Single,Married,Widowed,Divorced,Others,Separated;
        }
        field(35; "KRA PIN"; Code[20])
        {
            trigger OnValidate()
            var
                MemberMgmt: Codeunit "Member Management";
            begin
                MemberMgmt.KRAPinValidation("KRA PIN");
            end;
        }
        field(36; Occupation; Code[20])
        {
            TableRelation = "Sacco Lookup Values".Code where(Type = const(Occupations));
        }
        field(37; "Occupation Description"; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(38; "Type of Residence"; Option)
        {
            OptionMembers = Rented,Owned;
        }
        field(39; "Estate of Residence"; code[50])
        {
        }
        field(40; "Town of Residence"; Code[50])
        {
        }
        field(41; "Station Code"; Code[20])
        {
        }
        field(42; Designation; Code[20])
        {
            TableRelation = "Member Designation" where(Type = const(Individual));
        }
        field(43; "Payroll No."; code[20])
        {
        }
        field(44; Nationality; Enum "Nationality Types")
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
        field(46; "Recruited By"; Option)
        {
            OptionMembers = " ","Sales Representative",Member;
        }
        field(45; "Recruiter Code"; Code[20])
        {
            Caption = 'Recruiter No.';
            TableRelation = if ("Recruited By" = const("Sales Representative")) Employee
            else if ("Recruited By" = const(Member)) Members;
        }
        field(47; ATM; Boolean)
        {
        }
        field(48; Mobile; Boolean)
        {
        }
        field(49; "Marketing Texts"; Boolean)
        {
        }
        field(50; "E-Statement"; Boolean)
        {
        }
        field(51; "E-Statement Period"; DateFormula)
        {
        }
        field(52; "E-Statement Next Date"; Date)
        {
        }
        field(53; "Certificate of Incoop"; code[20])
        {
        }
        field(54; "Group/Corporate No"; Code[80])
        {
            Caption = 'No.';
        }
        field(55; "Group/Corporate Name"; Text[150])
        {
            Caption = 'Name';

            trigger OnValidate()
            begin
                Validate("Full Name");
            end;
        }
        field(56; "Permit Expiry"; Date)
        {
            Caption = 'Permit Expiry';

            trigger OnValidate()
            begin
                If "Permit Expiry" <= WorkDate then Error('You can only register a member with a valid permit');
            end;
        }
        field(57; "Date of Registration"; Date)
        {
        }
        field(58; "Mobile Transacting No"; Code[30])
        {
            trigger OnValidate()
            var
                MemberMgmt: Codeunit "Member Management";
            begin
                if "Mobile Transacting No" <> '' then MemberMgmt.PhoneNumberValidation("Mobile Transacting No", Domicile);
            end;
        }
        field(59; "Is Group/Corporate"; Boolean)
        {
        }
        field(60; "Self Guarantee"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Loan Guarantees"."Guaranteed Amount" where("Member No." = field("No."), Self = const(true)));
            Editable = false;
        }
        field(61; "Non-Self Guarantee"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Loan Guarantees"."Guaranteed Amount" where("Member No." = field("No."), Self = const(false)));
            Editable = false;
        }
        field(62; "Uncleared Funds"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Uncleared Funds".Amount where("Member No" = field("No."), Cleared = const(false)));
            Editable = false;
        }
        field(63; Status; Enum "Member Status")
        {
            Editable = false;
        }
        field(64; Classification; Enum "Contribution Classification")
        {
            Editable = false;
        }
        field(65; "Account Filter"; Code[20])
        {
            TableRelation = Vendor where("Member No." = field("No."));
            FieldClass = FlowFilter;
        }
        field(66; "Loan Filter"; code[20])
        {
            FieldClass = FlowFilter;
            TableRelation = Loans where("Member No." = field("No."));
        }
        field(67; "Account Type Filter"; Code[20])
        {
            TableRelation = "Sacco Products" where(Indentation = const(1));
            FieldClass = FlowFilter;
        }
        field(68; "Emplyoment Type"; Enum "Employee Type")
        {
            Caption = 'Type';
        }
        field(69; Salaried; Boolean)
        {
            Editable = false;
        }
        field(70; Signature; blob)
        {
            Subtype = Bitmap;
        }
        field(71; "Protected Account"; Boolean)
        {
        }
        field(72; "Account Owner"; Code[50])
        {
            TableRelation = "User Setup";
        }
        field(73; "Category Type"; Enum "Member Category Types")
        {
        }
        field(74; "Micro Finance Account"; Code[20])
        {
            TableRelation = Members where("Category Type" = const("Micro Finance"));
        }
        field(75; "Guarantee Blocked"; Boolean)
        {
        }
        field(76; "Reg. Fee Paid"; Boolean)
        {
        }
        field(77; "Part of Group"; Boolean)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Signatories & Directors" where("Member No" = field("No.")));
        }
        field(78; "Has Business Account"; Boolean)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist(Vendor where("Member No." = field("No."), "Business Account" = const(true)));
        }
        field(79; "Prior Year Dividend"; Decimal)
        {
            Editable = false;
        }
        field(80; Class; Code[20])
        {
            TableRelation = "Sacco Lookup Values".Code where(Type = const("Member Classes"));
            Editable = false;
        }
        field(81; "Address 2"; Code[20])
        {
        }
        field(82; "Department Code"; Code[20])
        {
            TableRelation = "Employer Departments".Code where("Employer Code" = field("Employer Code"));
        }
        field(83; "Relationship Officer"; Code[20])
        {
            TableRelation = Employee where(Status = filter(Active | Inactive));

            trigger OnValidate()
            begin
                if Employee.Get("Relationship Officer") then "Relationship Officer Name" := Employee.FullName;
            end;
        }
        field(84; "Relationship Officer Name"; Text[100])
        {
            Editable = false;
        }
        field(85; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1), Blocked = CONST(false));
        }
        field(86; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2), Blocked = CONST(false));
        }
        field(87; "Identification Type"; Enum "Identity Type")
        {
        }
        field(88; Domicile; Code[20])
        {
            TableRelation = "Country/Region";

            trigger OnValidate()
            begin
                if CountryRegion.Get(Domicile) then
                    "Country Name" := CountryRegion.Name;
            end;
        }
        field(89; "Country Name"; Text[100])
        {
            Editable = false;
        }
        field(90; "Last Transaction Date"; Date)
        {
            CalcFormula = Max("Vendor Ledger Entry"."Posting Date" WHERE("Member No." = FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(91; SMS; Integer)
        {
            CalcFormula = count("SMS Ledger" WHERE("SMS Source" = FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(92; "Prefrential Boost"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(93; "Preferential Boost %"; Decimal)
        {
            DataClassification = ToBeClassified;
            MinValue = 1;
            MaxValue = 100;
        }
        field(94; "Dividend Exempt"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(95; "Product Code Filter"; Code[20])
        {
            TableRelation = "Sacco Products" where("Product Posting Type" = filter("Share Capital Account" | "Non Withdrawable Deposit"));
            FieldClass = FlowFilter;
        }
        field(96; "Dividend Code Filter"; Code[20])
        {
            TableRelation = "Dividend Header";
            FieldClass = FlowFilter;
        }
        field(97; "ATM Limit"; Decimal)
        {
            Editable = false;
        }
        field(98; Goals; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(99; "Created On"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(100; "Created By"; Code[50])
        {
            TableRelation = "User Setup";
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(101; "Mobi Loan Limit"; Decimal)
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
    fieldgroups
    {
        fieldgroup(DropDown; "No.", "Identification No.", "Full Name", "Mobile Phone No.")
        {
        }
    }
    var
        MemberMgmt: Codeunit "Member Management";
        IdentityType: Enum "Identity Type";
        Employee: Record Employee;
        CountryRegion: Record "Country/Region";

    trigger OnDelete()
    begin
        Error('You cannot delete a Member');
    end;

    procedure FullName(): Text[100]
    begin
        if "Is Group/Corporate" then
            exit(UpperCase("Group/Corporate Name"))
        else begin
            if "Middle Name" = '' then
                exit(UpperCase("First Name" + ' ' + "Last Name"))
            else
                exit(UpperCase("First Name" + ' ' + "Middle Name" + ' ' + "Last Name"));
        end;
    end;
}

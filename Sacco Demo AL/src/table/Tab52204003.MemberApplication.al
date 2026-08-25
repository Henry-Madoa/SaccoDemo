table 52204003 "Member Application"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Member Applications";
    DrillDownPageId = "Member Applications";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Title; Code[20])
        {
            TableRelation = Title;

            trigger OnValidate()
            var
                Titles: Record Title;
            begin
                If Titles.Get(Title) then Gender := Titles.Gender;
            end;
        }
        field(3; "First Name"; Text[50])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                Validate("Full Name");
            end;
        }
        field(4; "Middle Name"; Text[50])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                Validate("Full Name");
            end;
        }
        field(5; "Last Name"; Text[50])
        {
            Caption = 'Surname';
            trigger OnValidate()
            begin
                Validate("Full Name");
            end;
        }
        field(6; "Full Name"; Text[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;

            trigger OnValidate()
            begin
                if "Is Group/Corporate" then
                    "Full Name" := "Group/Corporate Name"
                else
                    "Full Name" := "First Name" + ' ' + "Middle Name" + ' ' + "Last Name";
            end;
        }
        field(7; "Mobile Phone No."; Code[50])
        {
            DataClassification = ToBeClassified;
            ExtendedDatatype = PhoneNo;

            trigger OnValidate()
            var
                MemberMgmt: Codeunit "Member Management";
                Member: Record Members;
            begin
                if "Mobile Phone No." <> '' then MemberMgmt.PhoneNumberValidation("Mobile Phone No.", Domicile);
                Member.Reset();
                Member.SetRange("Mobile Phone No.", "Mobile Phone No.");
                if Member.FindFirst() then Error(StrSubstNo('The Mobile Phone No is already linked to %1 Member No. %2', Member."Full Name", Member."No."));
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

            trigger OnValidate()
            var
                Titles: Record Title;
            begin
                If Titles.Get(Rec.Title) then begin
                    if Titles.Gender <> Titles.Gender::" " then Rec.TestField(Gender, Titles.Gender);
                end;
            end;
        }
        field(10; "Identification No."; Code[50])
        {
            DataClassification = ToBeClassified;

            //Numeric = false;
            trigger OnValidate()
            begin
                TestField(Category);
                if Nationality = Nationality::Kenyan then MemberMgmt.ValidateIdentificationNo("Identification Type", "Identification No.");
                If "Identification Type" = "Identification Type"::Passport then "Passport No." := "Identification No.";
                // Check for duplicate Identification Number
                Member.Reset();
                Member.SetRange("Identification No.", "Identification No.");
                Member.SetRange(Category, Category);
                if Member.FindFirst() then Error(StrSubstNo('The Identification No. is already linked to %1 Member No. %2', Member."Full Name", Member."No."));
                // Additional check with Members table
                Members.Reset;
                Members.SetCurrentKey("Identification No.");
                Members.SetRange("Identification No.", "Identification No.");
                Members.SetRange(Category, Category);
                if Members.FindSet then Error(Txt001, Rec."Identification No.");
                // If Identification No. is empty and "IPRS Uneditability" is true, set "IPRS Uneditability" to false
                if (("Identification No." = '') and "IPRS Uneditability") then "IPRS Uneditability" := false;
            end;
        }
        field(11; "Passport No."; Code[20])
        {
            trigger OnValidate()
            begin
                if Nationality = Nationality::Kenyan then
                    MemberMgmt.ValidateIdentificationNo(IdentityType::Passport, "Passport No.");
            end;
        }
        field(12; "Date of Issue"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Date of Issue';

            trigger OnValidate()
            var
                MemberMgmt: Codeunit "Member Management";
            begin
                MemberMgmt.ValidateDateOfIssue("Date of Issue");
            end;
        }
        field(13; "Date of Expiry"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Date of Expiry';

            trigger OnValidate()
            var
                MemberMgmt: Codeunit "Member Management";
            begin
                MemberMgmt.ValidateDateOfExpiry("Date of Expiry");
            end;
        }
        field(14; "Date of Birth"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                Age := 0;
                GeneralSetup.GET;
                GeneralSetup.TestField("Minimum Member Age (Yrs)");
                Age := (DATE2DMY(TODAY, 3) - DATE2DMY("Date of Birth", 3));
                IF Age < GeneralSetup."Minimum Member Age (Yrs)" THEN ERROR('You are too young to Be a Member. Minimum age is %1 Years', GeneralSetup."Minimum Member Age (Yrs)");
            end;
        }
        field(15; "Payroll No."; Code[20])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                Member.Reset();
                Member.SetRange("Employer Code", "Employer Code");
                Member.SetRange("Payroll No.", "Payroll No.");
                if Member.FindFirst then
                    Error(StrSubstNo('The Payroll No. is already linked to %1 Member No. %2', Member."Full Name", Member."No."));
            end;
        }
        field(16; Status; Enum "Document Status")
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(17; Address; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(18; City; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(19; County; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Counties;
        }
        field(20; "Sub County"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Sub Counties"."Sub County Code" where("County Code" = field(County));
        }
        field(21; Category; code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Member Categories";

            trigger onvalidate()
            Var
                MemberCategory: Record "Member Categories";
            begin
                if Rec.Category <> xRec.Category then ClearFieldsByCategory;
                if MemberCategory.Get(Category) then begin
                    MemberCategory.TestField("Registration Fee");
                    MemberCategory.TestField("Registration Fee Account");
                    MemberCategory.TestField(Class);
                    Class := MemberCategory.Class;
                    "Category Type" := MemberCategory."Category Type";
                    "Is Group/Corporate" := MemberCategory."Category Type" in [MemberCategory."Category Type"::Group, MemberCategory."Category Type"::Institution, MemberCategory."Category Type"::"Micro Finance", MemberCategory."Category Type"::"Joint Account"];
                    if "No." <> '' then begin
                        ApplicationDocs[1].Reset;
                        ApplicationDocs[1].SetRange("Source Code", Category);
                        if ApplicationDocs[1].FindSet() then begin
                            repeat
                                ApplicationDocs[2].Init();
                                ApplicationDocs[2]."Source Code" := "No.";
                                ApplicationDocs[2]."Application Area" := ApplicationDocs[1]."Application Area";
                                ApplicationDocs[2].Validate("Document No.", ApplicationDocs[1]."Document No.");
                                ApplicationDocs[2].Mandatory := ApplicationDocs[1].Mandatory;
                                if ApplicationDocs[2]."Document No." <> '' then ApplicationDocs[2].Insert(true);
                            until ApplicationDocs[1].Next = 0;
                        end;
                    end;
                end;
            end;
        }
        field(22; "E-Mail"; Text[100])
        {
            ExtendedDatatype = EMail;

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                if "E-Mail" <> '' then MailManagement.CheckValidEmailAddresses("E-Mail");
            end;
        }
        field(23; "Employer Code"; code[20])
        {
            TableRelation = Employers;
        }
        field(24; Processed; Boolean)
        {
        }
        field(25; "Passport Size Photo"; blob)
        {
            Subtype = Bitmap;

            trigger OnValidate()
            var
                GeneralLedgerSetup: Record "General Ledger Setup";
            begin
                GeneralLedgerSetup.Get;
                GeneralLedgerSetup.TestField("Passport Size");
                if "Passport Size Photo".Length > GeneralLedgerSetup."Passport Size" then Error(StrSubstNo('Maximun size Image should be %1 Kbs', GeneralLedgerSetup."Passport Size" / 1000));
            end;
        }
        field(26; "Front ID Photo"; blob)
        {
            Subtype = Bitmap;

            trigger OnValidate()
            var
                GeneralLedgerSetup: Record "General Ledger Setup";
            begin
                GeneralLedgerSetup.Get;
                GeneralLedgerSetup.TestField("Identification Card Size");
                if "Front ID Photo".Length > GeneralLedgerSetup."Identification Card Size" then Error(StrSubstNo('Maximun size Image should be %1 Kbs', GeneralLedgerSetup."Identification Card Size" / 1000));
            end;
        }
        field(27; "Back ID Photo"; blob)
        {
            Subtype = Bitmap;

            trigger OnValidate()
            var
                GeneralLedgerSetup: Record "General Ledger Setup";
            begin
                GeneralLedgerSetup.Get;
                GeneralLedgerSetup.TestField("Identification Card Size");
                if "Back ID Photo".Length > GeneralLedgerSetup."Identification Card Size" then Error(StrSubstNo('Maximun size Image should be %1 Kbs', GeneralLedgerSetup."Identification Card Size" / 1000));
            end;
        }
        field(28; "Marital Status"; Option)
        {
            OptionMembers = Single,Married,Widowed,Divorced,Others,Separated;
        }
        field(29; "KRA PIN"; Code[20])
        {
            trigger OnValidate()
            var
                MemberMgmt: Codeunit "Member Management";
                Member: Record Members;
            begin
                // Reuse the validation function from Member Management codeunit
                MemberMgmt.KRAPinValidation("KRA PIN");
                // Check for duplicate KRA PIN
                Member.Reset();
                Member.SetRange("KRA PIN", "KRA PIN");
                if Member.FindFirst() then Error('The KRA PIN %1 is already linked to %2 (Member No. %3).', Member."KRA PIN", Member."Full Name", Member."No.");
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
        field(31; "Occupation Description"; Text[250])
        {
        }
        field(32; "Type of Residence"; Option)
        {
            OptionMembers = Rented,Owned;
        }
        field(33; "Member No."; code[20])
        {
        }
        field(34; "Town of Residence"; code[50])
        {
        }
        field(35; "Estate of Residence"; code[50])
        {
        }
        field(36; "Station Code"; Code[20])
        {
            TableRelation = "Employer Stations".Code where("Employer Code" = field("Employer Code"));
        }
        field(37; Designation; Code[30])
        {
            //TableRelation = "Member Designation" where(Type = const(Individual));
        }
        field(38; Nationality; Enum "Nationality Types")
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
        field(39; "Recruited By"; Option)
        {
            OptionMembers = " ","Sales Representative",Member,Other;
        }
        field(40; "Recruiter Code"; Code[20])
        {
            TableRelation = if ("Recruited By" = const("Sales Representative")) Employee
            else if ("Recruited By" = const(Member)) Members;

            trigger OnValidate()
            var
                Member: Record Members;
                Emp: Record Employee;
            begin
                if Member.Get("Recruiter Code") then
                    "Recruiter Name" := Member.FullName
                else if Emp.Get("Recruiter Code") then "Recruiter Name" := Emp.FullName;
            end;
        }
        field(41; "Recruiter Name"; Text[100])
        {
            Editable = false;
        }
        field(42; "Other Recruitment Details"; Text[100])
        {
        }
        field(43; ATM; Boolean)
        {
            trigger OnValidate()
            begin
                SaccoProducts.Reset;
                SaccoProducts.SetRange("Product Posting Type", SaccoProducts."Product Posting Type"::"Withdrawable Deposit");
                if not SaccoProducts.FindFirst then Error('There is no Transacting Account product set in Sacco products. Kindly Setup the Transacting Product first.');
            end;
        }
        field(44; Mobile; Boolean)
        {
        }
        field(45; "Marketing Texts"; Boolean)
        {
        }
        field(46; "E-Statement"; Boolean)
        {
        }
        field(47; "E-Statement Period"; DateFormula)
        {
        }
        field(48; "Certificate of Incoop"; code[20])
        {
        }
        field(49; "Group/Corporate No."; Code[20])
        {
        }
        field(50; "Group/Corporate Name"; Text[150])
        {
            Caption = 'Name';

            trigger OnValidate()
            begin
                Validate("Full Name");
            end;
        }
        field(51; "Is Group/Corporate"; Boolean)
        {
        }
        field(52; "Date of Registration"; Date)
        {
        }
        field(53; "Permit Expiry"; Date)
        {
            Caption = 'Permit Expiry';
        }
        field(54; "PIN No"; Code[20])
        {
        }
        field(55; "Mobile Transacting No"; Code[30])
        {
            ExtendedDatatype = PhoneNo;

            trigger OnValidate()
            var
                MemberMgmt: Codeunit "Member Management";
                Member: Record Members;
            begin
                if "Mobile Transacting No" <> '' then begin
                    MemberMgmt.PhoneNumberValidation("Mobile Transacting No", Domicile);

                    Member.Reset();
                    Member.SetRange("Mobile Transacting No", "Mobile Transacting No");
                    if Member.FindFirst() then
                        Error(StrSubstNo('The Mobile Transacting No is already linked to %1 Member No. %2', Member."Full Name", Member."No."));
                end;
            end;
        }
        field(56; Signature; Blob)
        {
            Subtype = Bitmap;

            trigger OnValidate()
            var
                GeneralLedgerSetup: Record "General Ledger Setup";
            begin
                GeneralLedgerSetup.Get;
                GeneralLedgerSetup.TestField("Signature Size");
                if Signature.Length > GeneralLedgerSetup."Signature Size" then Error(StrSubstNo('Maximun size Image should be %1 Kbs', GeneralLedgerSetup."Signature Size" / 1000));
            end;
        }
        field(57; "Portal Status"; Option)
        {
            OptionMembers = New,Submitted,Processing;
        }
        field(58; "Rejection Comments"; text[150])
        {
        }
        field(59; "Emplyoment Type"; Enum "Employee Type")
        {
            Caption = 'Type';

            trigger OnValidate()
            begin
                if Rec."Emplyoment Type" <> xRec."Emplyoment Type" then begin
                    Rec."Employer Code" := '';
                    Rec.Designation := '';
                    Rec."Station Code" := '';
                    Rec."Department Code" := '';
                    Rec."Payroll No." := '';
                    Rec.Occupation := '';
                    Rec."Occupation Description" := '';
                end;
            end;
        }
        field(60; "Protected Account"; Boolean)
        {
        }
        field(61; "Account Owner"; Code[50])
        {
            TableRelation = "User Setup";
        }
        field(62; "Source Type"; Option)
        {
            OptionMembers = Member,Staff,"Social Media";
        }
        field(63; "Source No"; Text[100])
        {
        }
        field(64; Source; Option)
        {
            OptionMembers = "Core Banking","Alt. Channel";
            Editable = false;
        }
        field(65; "Payment Ref Code"; Code[20])
        {
            // trigger OnValidate()
            // var
            //     MpesaTrans: Record "Channel Transactions";
            //     MemberCategories: Record "Member Categories";
            // begin
            //     TestField(Category);
            //     if MemberCategories.Get(Category) then begin
            //         MemberCategories.TestField("Registration Fee");
            //         If MpesaTrans.Get("Payment Ref Code") then begin
            //             If MpesaTrans."Paid In" < MemberCategories."Registration Fee" then Error(StrSubstNo('The amount paid is less than the regition fee, Registration fee is %1', MemberCategories."Registration Fee"));
            //         end
            //         else
            //             Error('The Payment Reference you have Provided is not valid');
            //     end;
            // end;
        }
        field(66; "Account Created"; Boolean)
        {
            Editable = false;
        }
        field(67; "IPRS Uneditability"; Boolean)
        {
        }
        field(68; Class; Code[20])
        {
            TableRelation = "Sacco Lookup Values".Code where(Type = const("Member Classes"));
        }
        field(69; "Address 2"; Code[20])
        {
        }
        field(70; "Department Code"; Code[20])
        {
            TableRelation = "Employer Departments".Code where("Employer Code" = field("Employer Code"));
        }
        field(71; "Relationship Officer"; Code[20])
        {
            TableRelation = Employee where(Status = filter(Active | Inactive));

            trigger OnValidate()
            begin
                if Employee.Get("Relationship Officer") then "Relationship Officer Name" := Employee.FullName;
            end;
        }
        field(72; "Relationship Officer Name"; Text[100])
        {
            Editable = false;
        }
        field(73; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1), Blocked = CONST(false));
        }
        field(74; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2), Blocked = CONST(false));
        }
        field(75; "Identification Type"; Enum "Identity Type")
        {
            trigger OnValidate()
            begin
                // Clear the Identification No. if the Identification Type changes
                if xRec."Identification Type" <> "Identification Type" then "Identification No." := '';
            end;
        }
        field(76; Domicile; Code[20])
        {
            TableRelation = "Country/Region";

            trigger OnValidate()
            begin
                if CountryRegion.Get(Domicile) then "Country Name" := CountryRegion.Name;
            end;
        }
        field(77; "Country Name"; Text[100])
        {
            Editable = false;
        }
        field(78; "Category Type"; Enum "Member Category Types")
        {
        }
        field(79; "Micro Finance Account"; Code[20])
        {
            TableRelation = Members where("Category Type" = const("Micro Finance"));
        }
        field(80; Goals; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(81; "Created On"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(82; "Created By"; Code[50])
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
        key(Key2; Source)
        {
        }
    }
    // trigger OnModify()
    // var
    //     UserMgt: Codeunit "User Management";
    // begin
    //     // Check if document is pending approval
    //     if Status = Status::"Pending Approval" then begin
    //         // Optionally block all users
    //         Error('You cannot modify this document because it is pending approval.');
    //         // OR block only users with the "Approver" role or permission set
    //         //if UserMgt.IsUserInRole(USERID, 'APPROVER') then
    //         //     Error('Approvers cannot modify a document that is pending approval.');
    //       end;
    // end;
    trigger OnDelete()
    begin
        TestField(Status, Status::Open);
        Error('Deleting documents is not allowed.');
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

    var
        NoSeries: Codeunit NoSeriesManagement;
        SaccoSetup: Record "General Ledger Setup";
        SaccoProducts: Record "Sacco Products";
        Members: Record Members;
        MemberApplication: Record "Member Application";
        ApplicationDocs: array[2] of Record "Doc. Attachments Checklist";
        Txt001: TextConst ENU = 'A member with the same ID No. %1 already exists.';
        Employee: Record Employee;
        CountryRegion: Record "Country/Region";
        UserMgmtExt: Codeunit "User Management Ext";
        GeneralSetup: Record "General Ledger Setup";
        Age: Integer;
        MemberMgmt: Codeunit "Member Management";
        Member: Record Members;
        IdentityType: Enum "Identity Type";

    trigger OnInsert()
    begin
        if CurrentClientType = ClientType::Windows then begin
            MemberApplication.Reset();
            MemberApplication.SetRange("Created By", UserId);
            MemberApplication.SetRange(Processed, false);
            if MemberApplication.FindSet() then begin
                if MemberApplication.Count > 2 then Error('You are only allowed for 2 open records');
            end;
        end;
        SaccoSetup.get;
        SaccoSetup.TestField("Member Application Nos.");
        if "No." = '' then "No." := NoSeries.GetNextNo(SaccoSetup."Member Application Nos.", Today, true);
        "Created By" := UserId;
        "Created On" := CurrentDateTime;
        if GuiAllowed = false then Source := Source::"Alt. Channel";
        if Category <> '' then begin
            Validate(Category);
        end;
        UserMgmtExt.GetUserDimensions(UserId, "Global Dimension 1 Code", "Global Dimension 2 Code");
    end;

    procedure GetStatusStyleText() StatusStyleText: Text
    begin
        if Status = Status::Open then
            StatusStyleText := 'Strong'
        else if Status = Status::"Pending Approval" then
            StatusStyleText := 'StrongAccent'
        else if Status = Status::Approved then StatusStyleText := 'Favorable';
    end;

    local procedure ClearFieldsByCategory()
    var
        AccountInstructions: Record "Member Account Instructions";
        Signitories: Record "Signatories & Directors";
        MemberNomineeKin: Record "Member Nominee/Kin";
        MemberSubscriptions: Record "Member Subscriptions";
    begin
        Clear("First Name");
        Clear("Middle Name");
        Clear("Last Name");
        Clear("First Name");
        Clear("Full Name");
        Clear("Date of Birth");
        Clear("Passport No.");
        Clear("KRA PIN");
        Clear("Type of Residence");
        Clear(Gender);
        Clear("Emplyoment Type");
        Clear("Department Code");
        Clear("Employer Code");
        Clear("Station Code");
        Clear(Designation);
        Clear("Payroll No.");
        Clear(Occupation);
        Clear("Occupation Description");
        Clear("Date of Expiry");
        Clear("Date of Issue");
        Clear("Date of Registration");
        Clear("Group/Corporate No.");
        Clear("Group/Corporate Name");
        Clear("Certificate of Incoop");
        Clear("Permit Expiry");
        Clear("Date of Registration");
        Clear(Address);
        Clear("Address 2");
        Clear(County);
        Clear("Sub County");
        Clear("E-Mail");
        Clear(Nationality);
        Clear("Identification No.");
        Clear(Domicile);
        Clear("Passport Size Photo");
        Clear(Signature);
        Clear("Front ID Photo");
        Clear("Back ID Photo");
        AccountInstructions.Reset();
        AccountInstructions.SetRange("Source Code", "No.");
        AccountInstructions.DeleteAll(true);
        Signitories.Reset();
        Signitories.SetRange("Source Code", "No.");
        Signitories.DeleteAll(true);
        MemberNomineeKin.Reset();
        MemberNomineeKin.SetRange("Source Code", "No.");
        MemberNomineeKin.DeleteAll(true);
        MemberSubscriptions.Reset();
        MemberSubscriptions.SetRange("Source Code", "No.");
        MemberSubscriptions.DeleteAll(true);
        if Rec.Category <> xRec.Category then begin
            ApplicationDocs[1].Reset();
            ApplicationDocs[1].SetRange("Source Code", "No.");
            if ApplicationDocs[1].FindSet() then ApplicationDocs[1].DeleteAll;
        end;
    end;
}

table 52203773 Applicant
{
    // version THL- HRM 1.0
    DataCaptionFields = "No.", "First Name", "Middle Name", "Last Name";
    DrillDownPageID = Applicants;
    LookupPageID = Applicants;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    HumanResSetup.Get;
                    NoSeriesMgt.TestManual(HumanResSetup."Applicant Nos.");
                    "No. Series":='';
                //
                end;
                Modify;
            end;
        }
        field(2; "First Name"; Text[30])
        {
            Caption = 'First Name';
        }
        field(3; "Middle Name"; Text[30])
        {
            Caption = 'Middle Name';
        }
        field(4; "Last Name"; Text[30])
        {
            Caption = 'Last Name';
        }
        field(5; Initials; Text[30])
        {
            Caption = 'Initials';

            trigger OnValidate()
            begin
                if("Search Name" = UpperCase(xRec.Initials)) or ("Search Name" = '')then "Search Name":=Initials;
            end;
        }
        field(6; "Position Applied For"; Text[30])
        {
            Editable = false;
        }
        field(7; "Search Name"; Code[30])
        {
            Caption = 'Search Name';
        }
        field(8; "Postal Address"; Text[50])
        {
            Caption = 'Address';
        }
        field(9; "Physical Address"; Text[50])
        {
            Caption = 'Address 2';
        }
        field(10; City; Text[30])
        {
            Caption = 'City';
            TableRelation = IF("Country/Region Code"=CONST(''))"Post Code".City
            ELSE IF("Country/Region Code"=FILTER(<>''))"Post Code".City WHERE("Country/Region Code"=FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                PostCode.ValidateCity(City, "Post Code", "Home County", "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(11; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            TableRelation = IF("Country/Region Code"=CONST(''))"Post Code"
            ELSE IF("Country/Region Code"=FILTER(<>''))"Post Code" WHERE("Country/Region Code"=FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                PostCode.ValidatePostCode(City, "Post Code", "Home County", "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(12; "Home County"; Text[30])
        {
            TableRelation = Counties;
        }
        field(13; "Alternative Phone No."; Text[30])
        {
            ExtendedDatatype = PhoneNo;
        }
        field(14; "Mobile Phone No."; Text[30])
        {
            ExtendedDatatype = PhoneNo;
        }
        field(15; "E-Mail"; Text[80])
        {
            Caption = 'Email';
            ExtendedDatatype = EMail;
        }
        field(16; "Alt. Address Code"; Code[10])
        {
            Caption = 'Alt. Address Code';
            TableRelation = "Alternative Address".Code WHERE("Employee No."=FIELD("No."));
        }
        field(17; "Alt. Address Start Date"; Date)
        {
            Caption = 'Alt. Address Start Date';
        }
        field(18; "Alt. Address End Date"; Date)
        {
            Caption = 'Alt. Address End Date';
        }
        field(19; Picture; BLOB)
        {
            Caption = 'Picture';
            SubType = Bitmap;
        }
        field(20; "Birth Date"; Date)
        {
            Caption = 'Birth Date';

            trigger OnValidate()
            begin
                AgeValidation;
            end;
        }
        field(21; "Social Security No."; Text[30])
        {
            Caption = 'Social Security No.';
        }
        field(22; "Union Code"; Code[10])
        {
            Caption = 'Union Code';
            TableRelation = Union;
        }
        field(23; "Union Membership No."; Text[30])
        {
            Caption = 'Union Membership No.';
        }
        field(24; Gender;Enum "Employee Gender")
        {
            Caption = 'Gender';
        }
        field(25; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(26; "Manager No."; Code[20])
        {
            Caption = 'Manager No.';
            TableRelation = Employee where(Status=const(Active));
        }
        field(27; "Emplymt. Contract Code"; Code[10])
        {
            Caption = 'Emplymt. Contract Code';
            TableRelation = "Employment Contract";
        }
        field(28; "Statistics Group Code"; Code[10])
        {
            Caption = 'Statistics Group Code';
            TableRelation = "Employee Statistics Group";
        }
        field(29; "Employment Date"; Date)
        {
            Caption = 'Employment Date';
        }
        field(30; "Portal ID"; Integer)
        {
        }
        field(31; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Active,Inactive,Terminated';
            OptionMembers = Active, Inactive, Terminated;
            Editable = false;

            trigger OnValidate()
            begin
                EmployeeQualification.SetRange("Employee No.", "No.");
                EmployeeQualification.ModifyAll("Employee Status", Status);
                Modify;
            end;
        }
        field(32; "Inactive Date"; Date)
        {
            Caption = 'Inactive Date';
        }
        field(33; "Cause of Inactivity Code"; Code[10])
        {
            Caption = 'Cause of Inactivity Code';
            TableRelation = "Cause of Inactivity";
        }
        field(34; "Termination Date"; Date)
        {
            Caption = 'Termination Date';
        }
        field(35; "Grounds for Term. Code"; Code[10])
        {
            Caption = 'Grounds for Term. Code';
            TableRelation = "Grounds for Termination";
        }
        field(36; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
            end;
        }
        field(37; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Global Dimension 2 Code");
            end;
        }
        field(38; "Resource No."; Code[20])
        {
            Caption = 'Resource No.';
            TableRelation = Resource WHERE(Type=CONST(Person));
        }
        field(39; Comment; Boolean)
        {
            CalcFormula = Exist("Human Resource Comment Line" WHERE("Table Name"=CONST(Employee), "No."=FIELD("No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(40; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(41; "Global Dimension 1 Filter"; Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
        }
        field(42; "Global Dimension 2 Filter"; Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));
        }
        field(43; "Cause of Absence Filter"; Code[10])
        {
            Caption = 'Cause of Absence Filter';
            FieldClass = FlowFilter;
            TableRelation = "Cause of Absence";
        }
        field(44; "Total Absence (Base)"; Decimal)
        {
            CalcFormula = Sum("Employee Absence"."Quantity (Base)" WHERE("Employee No."=FIELD("No."), "Cause of Absence Code"=FIELD("Cause of Absence Filter"), "From Date"=FIELD("Date Filter")));
            Caption = 'Total Absence (Base)';
            DecimalPlaces = 0: 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(45; Extension; Text[30])
        {
            Caption = 'Extension';
        }
        field(46; "Employee No. Filter"; Code[20])
        {
            Caption = 'Employee No. Filter';
            FieldClass = FlowFilter;
            TableRelation = Employee where(Status=const(Active));
        }
        field(47; Pager; Text[30])
        {
            Caption = 'Pager';
        }
        field(48; "Fax No."; Text[30])
        {
            Caption = 'Fax No.';
        }
        field(49; "Company E-Mail"; Text[80])
        {
            Caption = 'Company Email';
        }
        field(50; Title; Text[30])
        {
            Caption = 'Title';
        }
        field(51; "Salespers./Purch. Code"; Code[10])
        {
            Caption = 'Salespers./Purch. Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(52; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(53; "Years Of Experience"; Decimal)
        {
        }
        field(54; "Years Of Relevant Experience"; Decimal)
        {
        }
        field(55; "Current/Expected Salary"; Decimal)
        {
        }
        field(56; "Job Requisition"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Job Requisition" where(Status=const(Approved), "Advertisement Status"=const(Open));

            trigger OnValidate()
            var
                JobRequisition: Record "Job Requisition";
            begin
                If JobRequisition.Get("Job Requisition")then Validate("Job ID", JobRequisition."Job ID");
            end;
        }
        field(57; "Job ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "Company Jobs" where(Status=const(Approved));

            trigger OnValidate()
            var
                CompanyJobs: Record "Company Jobs";
            begin
                If CompanyJobs.Get("Job ID")then "Position Applied For":=CompanyJobs.Name;
            end;
        }
        field(58; "Applicant Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'External,Internal';
            OptionMembers = External, Internal;
        }
        field(59; Image; Media)
        {
            Caption = 'Image';
            ExtendedDatatype = Person;
        }
        field(60; "Cost Center Code"; Code[20])
        {
            Caption = 'Cost Center Code';
            TableRelation = "Cost Center";
        }
        field(61; "Cost Object Code"; Code[20])
        {
            Caption = 'Cost Object Code';
            TableRelation = "Cost Object";
        }
        field(62; "Office Location"; Text[30])
        {
        }
        field(63; "Probation Period"; Text[30])
        {
        }
        field(64; "Probation Termination Notice"; Text[30])
        {
        }
        field(65; "Annual Leave Days"; Integer)
        {
        }
        field(66; "Leave Notice Period"; Integer)
        {
        }
        field(67; "Contract Termination Notice"; Text[30])
        {
        }
        field(68; "Hours Worked Per Week"; Decimal)
        {
        }
        field(69; "Days Worked Per Week"; Decimal)
        {
        }
        field(70; "Reporting Time"; Time)
        {
        }
        field(71; "Closing Time"; Time)
        {
        }
        field(72; "Lunch Break Duration"; Text[30])
        {
        }
        field(73; "Lunch Start Time"; Time)
        {
        }
        field(74; "Lunch End Time"; Time)
        {
        }
        field(75; "Week Start Day"; Text[30])
        {
        }
        field(76; "Week End Day"; Text[30])
        {
        }
        field(77; "Offer Signed By"; Text[50])
        {
        }
        field(78; "Offer Status"; Option)
        {
            OptionCaption = 'Applicant,Offer Made,Accepted Offer,Reported to Work,Rejected Offer,Failed';
            OptionMembers = Applicant, "Offer Made", "Accepted Offer", "Reported to Work", "Rejected Offer", Failed;
            Editable = false;
        }
        field(79; Shortlisting; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Open,Passed,Failed';
            OptionMembers = Open, Passed, Failed;
            Editable = false;
        }
        field(80; "Total Interview Marks"; Decimal)
        {
            CalcFormula = Sum("Job Interview Rating".Marks WHERE("Applicant No"=FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(81; Interview; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Passed,Failed';
            OptionMembers = " ", Passed, Failed;
            Editable = false;
        }
        field(82; "National ID"; Code[10])
        {
            Caption = 'ID No. (For Kenyans)';
            DataClassification = ToBeClassified;
        }
        field(83; "KRA PIN"; Code[11])
        {
            DataClassification = ToBeClassified;
        }
        field(84; Profession; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Professions;
        }
        field(85; LinkedIn; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(86; "Highest Level Of Education"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Education Levels";
        }
        field(87; "Ethnic Group"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Ethinic Groups";
        }
        field(88; "Pays Tax"; Boolean)
        {
        }
        field(89; "ID Number"; Code[10])
        {
        }
        field(90; "Passport No."; Code[10])
        {
        }
        field(91; "Marital Status"; Option)
        {
            OptionCaption = 'Single,Married,Separated,Divorced,Widow(er),Other', ;
            OptionMembers = Single, Married, Separated, Divorced, "Widow(er)", Other;
        }
        field(92; "NSSF No"; Code[20])
        {
        }
        field(93; "SHIF No"; Code[20])
        {
        }
        field(94; "Full / Part Time"; Option)
        {
            OptionCaption = 'Full Time,Part Time';
            OptionMembers = "Full Time", "Part Time";
        }
        field(95; "Contract Type"; Code[10])
        {
        }
        field(96; "Exit Interview Date"; Date)
        {
        }
        field(97; "Exit Interview Done By"; Text[30])
        {
        }
        field(98; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(99; "Staff No."; Code[20])
        {
        }
        field(100; "Created Date"; DateTime)
        {
            Editable = false;
        }
        field(101; "Vacany No."; Code[20])
        {
        }
        field(102; Nationality; Option)
        {
            OptionMembers = Kenyan, Others;
        }
        field(103; "Passport Issue Date"; Date)
        {
        }
        field(104; "Passport Expiry Date"; Date)
        {
        }
        field(105; "Permit No."; Code[20])
        {
        }
        field(106; "Permit Issue Date"; Date)
        {
        }
        field(107; "Permit Validity Period"; Date)
        {
            Editable = true;
        }
        field(108; Disability; Boolean)
        {
        }
        field(109; "NCPWD Certificate No."; Code[20])
        {
        }
        field(110; "Criminal Declaration"; Boolean)
        {
            Caption = 'Have you ever been convicted of, or cautioned for, any criminal offence or are any other proceedings pending against you?';

            trigger OnValidate()
            begin
                if not "Criminal Declaration" then "Criminal Declaration Spec":='';
            end;
        }
        field(111; "Criminal Declaration Spec"; Text[250])
        {
            Caption = 'Please Give Details of the case and any penalty for each offence';
        }
        field(112; "Dismissal Declaration"; Boolean)
        {
            Caption = 'Have you ever been dismissed or otherwise removed from the Judicial service, Public Service or other engagement?';

            trigger OnValidate()
            begin
                if not "Dismissal Declaration" then "Dismissal Declaration Spec":='';
            end;
        }
        field(113; "Dismissal Declaration Spec"; Text[250])
        {
            Caption = 'Please Give Details';
        }
        field(114; "Application Letter"; Text[2048])
        {
            ExtendedDatatype = URL;
        }
        field(115; "Curriculum Vitae"; Text[2048])
        {
            ExtendedDatatype = URL;
        }
        field(116; "Testimonials"; MediaSet)
        {
        }
        field(117; "Passport Photo"; Blob)
        {
            Caption = 'Passport Photo (Optional)';
            Subtype = Bitmap;
        }
        field(118; "Identification Document"; Text[2048])
        {
            ExtendedDatatype = URL;
            Caption = 'National ID/Other Legal Identification Document';
        }
        field(119; "Certificate of Admission"; MediaSet)
        {
            Caption = 'Certificate of Admission to the Roll of Advocates (Where Applicable)';
        }
        field(120; "Final Declaration"; Boolean)
        {
            Caption = 'I certify that the particulars given on this form are correct and understand that any incorrect/misleading information may lead to disqualification/ legal action ';
        }
        field(121; "Declaration Date"; DateTime)
        {
            Caption = 'Date (dd-mm-yyyy)';
        }
        field(122; Signature; Blob)
        {
            SubType = Bitmap;
            Caption = 'Signature of Applicant (Upload scanned signature)';
        }
        field(123; "Gender Specification"; Text[100])
        {
        }
        field(124; "Disability Description"; Text[2000])
        {
            Caption = 'Description';
        }
        field(125; "Country Code"; Code[20])
        {
            TableRelation = "Country/Region";

            trigger OnValidate()
            var
                CountryRegion: Record "Country/Region";
            begin
                if CountryRegion.Get("Country Code")then "Country Name":=CountryRegion.Name;
            end;
        }
        field(126; "Country Name"; Text[50])
        {
            Editable = false;
        }
        field(127; "Current Salary"; Decimal)
        {
        }
        field(128; "Expected Salary"; Decimal)
        {
        }
    }
    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Search Name")
        {
        }
        key(Key3; Status, "Union Code")
        {
        }
        key(Key4; Status, "Emplymt. Contract Code")
        {
        }
        key(Key5; "Last Name", "First Name", "Middle Name")
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "No.", "First Name", "Last Name", Initials, "Position Applied For")
        {
        }
        fieldgroup(Brick; "No.", "First Name", "Last Name", "Position Applied For", Image)
        {
        }
    }
    trigger OnDelete()
    begin
        OnDeleteApplicant(Rec);
    end;
    trigger OnInsert()
    begin
        if "No." = '' then begin
            HumanResSetup.Get;
            HumanResSetup.TestField("Applicant Nos.");
            NoSeriesMgt.InitSeries(HumanResSetup."Applicant Nos.", xRec."No. Series", 0D, "No.", "No. Series");
        end;
        OnInsertApplicant(Rec);
        "Created Date":=CurrentDateTime;
    end;
    trigger OnModify()
    begin
        "Last Date Modified":=Today;
    end;
    trigger OnRename()
    begin
        "Last Date Modified":=Today;
    end;
    var HumanResSetup: Record "Human Resources Setup";
    Employee: Record Applicant;
    PostCode: Record "Post Code";
    EmployeeQualification: Record "Employee Qualification";
    NoSeriesMgt: Codeunit NoSeriesManagement;
    DimMgt: Codeunit DimensionManagement;
    Text000: Label 'Before you can use Online Map, you must fill in the Online Map Setup window.\See Setting Up Online Map in Help.';
    procedure AssistEdit(OldEmployee: Record Applicant): Boolean begin
        with Employee do begin
            Employee:=Rec;
            HumanResSetup.Get;
            HumanResSetup.TestField("Applicant Nos.");
            if NoSeriesMgt.SelectSeries(HumanResSetup."Applicant Nos.", OldEmployee."No. Series", "No. Series")then begin
                HumanResSetup.Get;
                HumanResSetup.TestField("Applicant Nos.");
                NoSeriesMgt.SetSeries("No.");
                Rec:=Employee;
                exit(true);
            end;
        end;
    end;
    procedure FullName(): Text[100]begin
        if "Middle Name" = '' then exit("First Name" + ' ' + "Last Name");
        exit("First Name" + ' ' + "Middle Name" + ' ' + "Last Name");
    end;
    local procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::Employee, "No.", FieldNumber, ShortcutDimCode);
        Modify;
    end;
    procedure DisplayMap()
    var
        MapPoint: Record "Online Map Setup";
        MapMgt: Codeunit "Online Map Management";
    begin
        if MapPoint.FindFirst then MapMgt.MakeSelection(DATABASE::Employee, GetPosition)
        else
            Message(Text000);
    end;
    [IntegrationEvent(false, false)]
    procedure OnInsertApplicant(var Applicant: Record Applicant)
    begin
    end;
    [IntegrationEvent(false, false)]
    procedure OnDeleteApplicant(var Applicant: Record Applicant)
    begin
    end;
    local procedure AgeValidation()
    begin
        if "Birth Date" <> 0D then if((Date2DMY(WorkDate, 3) - Date2DMY("Birth Date", 3)) < 18)then Error('You cannot employ an underage candidate');
    end;
}

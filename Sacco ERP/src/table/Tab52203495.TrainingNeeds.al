table 52203495 "Training Needs"
{
    DataCaptionFields = "Code", Description;
    LookupPageId = "Training Needs";
    DrillDownPageId = "Training Needs";
    LinkedObject = false;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Editable = false;
        }
        field(2; Description; Text[50])
        {
        }
        field(3; "Start Date"; Date)
        {
            trigger OnValidate()
            begin
                if "Start Date" < Today then Error('Invalid Start Date specified [%1]', "Start Date");
            end;
        }
        field(4; "End Date"; Date)
        {
            Editable = true;

            trigger OnValidate()
            begin
                Rec.Testfield("Start Date");
                if("End Date" < Today) or ("End Date" < "Start Date")then Error('Invalid End Date specified [%1]', "End Date");
                "Re-Assessment Date":=0D;
            end;
        }
        field(5; Duration1; DateFormula)
        {
        }
        field(6; "Total Costs"; Decimal)
        {
        }
        field(7; Location; Code[50])
        {
        }
        field(8; "Re-Assessment Date"; Date)
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Start Date");
                Rec.Testfield("End Date");
                if "Re-Assessment Date" <= "End Date" then Error('Re-Assesment date should be greater than the start date and the end date');
            end;
        }
        field(9; "Need Source"; Option)
        {
            OptionCaption = '  ,Appraisal,Succesion,Training,Employee,Employee Skill Plan,Competency Profiling,Others';
            OptionMembers = "  ", Appraisal, Succesion, Training, Employee, "Employee Skill Plan", "Competency Profiling", Others;
        }
        field(10; "Provider Name"; Text[100])
        {
        }
        field(11; Posted; Boolean)
        {
            Editable = false;
        }
        field(12; Closed; Boolean)
        {
            Editable = false;
        }
        field(13; "Qualification Code"; Code[20])
        {
        //TableRelation =Qualification WHERE ("Qualification Type"=FIELD("Qualification Type"));
        }
        field(14; "Qualification Type"; Code[30])
        {
            NotBlank = false;
        }
        field(15; "Qualification Description"; Text[80])
        {
        }
        field(16; "External Provider Name"; Text[50])
        {
            Editable = false;
            FieldClass = Normal;
        }
        field(17; "Responsibility Center"; Code[10])
        {
            TableRelation = "Responsibility Center".Code;
        }
        field(18; "Bondage Start Date"; Date)
        {
            Editable = false;
        }
        field(19; "Bondage Duration"; DateFormula)
        {
            trigger OnValidate()
            begin
                "Bondage Release Date":=CalcDate("Bondage Duration", "Bondage Start Date");
            end;
        }
        field(20; "Bondage Release Date"; Date)
        {
            Editable = false;
        }
        field(21; "Inclusive of Non Working Days"; Boolean)
        {
        }
        field(22; "Bondage Required?"; Boolean)
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Start Date");
                Rec.Testfield("End Date");
                Clear("Bondage Start Date");
                Clear("Bondage Duration");
                Clear("Bondage Release Date");
                if "Bondage Required?" then begin
                    "Bondage Start Date":="End Date";
                    Validate("Bondage Duration");
                end;
            end;
        }
        field(23; "No. of Training Cost Items"; Integer)
        {
        }
        field(24; Status;Enum "Document Status")
        {
            Editable = false;
        }
        field(25; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
        }
        field(26; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));
        }
        field(27; "Currency Code"; Code[20])
        {
            TableRelation = Currency.Code;
        }
        field(28; "Allow Early Exit if Bonded?"; Boolean)
        {
            trigger OnValidate()
            begin
                Rec.Testfield("Bondage Required?", true);
                Rec.Testfield("Bondage Duration");
            end;
        }
        field(29; "Employee No"; Code[20])
        {
        }
        field(30; "No. Series"; Code[20])
        {
        }
        field(31; Duration; Duration)
        {
        }
        field(32; "Training Category"; Option)
        {
            OptionMembers = " ", Staff, Interns, Attachees;
        }
        field(33; "Training Type"; Option)
        {
            OptionMembers = " ", Conference, Seminar, Workshop, "Study Tour", "Self Sponsored", Other, "Company Sponsorship";
        }
        field(34; Provider; Code[50])
        {
            trigger OnValidate()
            begin
                Vendor.Reset;
                Vendor.SetRange(Vendor."No.", Provider);
                if Vendor.Find('-')then "Provider Name":=Vendor.Name;
            end;
        }
        field(35; "Other Provider"; Text[100])
        {
        }
        field(36; "IF Others(Specify)"; Text[250])
        {
        }
        field(37; "Employee Name"; Text[100])
        {
        }
        field(38; "Job Title"; Text[100])
        {
        }
        field(39; "Length in that Position"; Text[100])
        {
            FieldClass = Normal;
        }
        field(40; Grade; Code[10])
        {
        }
        field(41; Supervisor; Text[50])
        {
        }
        field(42; Email; Text[80])
        {
        }
        field(43; "Date Of Application"; Date)
        {
        }
        field(44; "User ID"; Code[50])
        {
        }
        field(45; "Training Opportunity"; Option)
        {
            OptionMembers = , "-", "Short Learning Opportunity(External-Local)", "Short Learning Opportunity(External-International)", "Distance Learning Opportunity/Correspondence", "Part-Time Learning Opportunity", "Others(Specify)";
        }
        field(46; "IF OTHERS..."; Text[250])
        {
        }
        field(47; "Skills to be Acquired"; Text[250])
        {
        }
        field(48; "Title of Training"; Text[50])
        {
        }
        field(49; "Date(s) of Training"; Date)
        {
        }
        field(50; "Visa Processing"; Boolean)
        {
        }
        field(51; "Flight Booking"; Boolean)
        {
        }
        field(52; Accomodation; Boolean)
        {
        }
        field(53; "Information/Materials"; Boolean)
        {
        }
        field(54; "Training Institute Contact"; Boolean)
        {
        }
        field(55; "Learning Leave"; Boolean)
        {
        }
        field(56; "Other(|Specify)"; Boolean)
        {
        }
        field(57; OTHER; Text[250])
        {
        }
        field(58; Section; Option)
        {
            OptionMembers = , "-", "Line Manager", "Staff Development Committee", HR;
        }
        field(59; Recommended; Boolean)
        {
        }
        field(60; Reason; Text[250])
        {
        }
        field(61; "Amount Approved"; Decimal)
        {
        }
        field(62; "Funds Source"; Text[100])
        {
        }
        field(63; "Managers' Name"; Text[100])
        {
        }
        field(64; Date; Date)
        {
        }
        field(65; "Amount to Pay"; Decimal)
        {
        }
        field(66; "Fund Code"; Code[20])
        {
        }
        field(67; "Transaction Code"; Code[20])
        {
        }
        field(68; "Payee's Name"; Text[100])
        {
        }
        field(69; "Source Type"; Option)
        {
            Editable = false;
            OptionCaption = 'Self,Appraisal';
            OptionMembers = Self, Appraisal;
        }
        field(50003; "Action ID"; Code[100])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(50004; "Approval Level"; Integer)
        {
            Editable = false;
        }
        field(50005; "Approval Loop"; Integer)
        {
            Editable = false;
        }
        field(50006; "Created By"; Code[100])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(50007; "Created On"; Date)
        {
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Code")
        {
        }
    }
    trigger OnInsert()
    begin
        if Code = '' then begin
            HRSetup.Get;
            HRSetup.TestField(HRSetup."Traning Needs Nos.");
            NoSeriesMgt.InitSeries(HRSetup."Traning Needs Nos.", xRec."No. Series", 0D, Code, "No. Series");
        end;
        "User ID":=UserId;
        "Created By":=UserId;
        "Created On":=WorkDate;
    end;
    var HRSetup: Record "Human Resource Setup";
    NoSeriesMgt: Codeunit NoSeriesManagement;
    Vendor: Record Vendor;
    local procedure calcDuration()
    begin
    end;
}

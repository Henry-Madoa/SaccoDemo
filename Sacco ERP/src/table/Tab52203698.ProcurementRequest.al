table 52203698 "Procurement Request"
{
    fields
    {
        field(1; "No."; Code[30])
        {
            DataClassification = ToBeClassified;
            NotBlank = false;
        }
        field(2; Status;Enum "Document Status")
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(3; Description; Code[250])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Requisiton No"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Current Budget"; Code[40])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Budget Name".Name;
        }
        field(6; "Creation Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Supplier Category"; Code[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Supplier Category"."Category Code";
        }
        field(8; "Tender Opening Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Tender Duration"; DateFormula)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Format("Tender Duration") <> '' then begin
                    Rec.Testfield("Tender Opening Date");
                    "Tender Closing Date":=CalcDate("Tender Duration", "Tender Opening Date");
                end;
            end;
        }
        field(10; "Tender Closing Date"; Date)
        {
            Caption = 'Initial Closing Date';
            DataClassification = ToBeClassified;
        }
        field(11; "Global Dimension 1 Code"; Code[50])
        {
            CaptionClass = '1,1,1';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1));
        }
        field(12; "Global Dimension 2 Code"; Code[50])
        {
            CaptionClass = '1,1,2';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2));
        }
        field(13; "Requires Inspection"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Tender Security Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Technical Pass Mark"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Tender Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'New,Advertised,Tender Opening,Evaluation,Mandatory Req Evaluation,Technical Req Evaluation,Financial Evaluation,Order Created,Contract Created,Terminated';
            OptionMembers = New, Advertised, "Tender Opening", Evaluation, "Mandatory Req Evaluation", "Technical Req Evaluation", "Financial Evaluation", "Order Created", "Contract Created", Terminated;
        }
        field(17; "Quotation Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'New,Supplier Invitation,Quote Submission,Order Created';
            OptionMembers = New, "Supplier Invitation", "Quote Submission", "Order Created";
        }
        field(18; "Procurement Plan"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Created By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Procurement Method";Enum "Procurement Methods")
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Vendor No"; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = Vendor where("Account Type"=const(Supplier));

            trigger OnValidate()
            begin
                if Vendor.Get("Vendor No")then "Vendor Name":=Vendor.Name
                else
                    "Vendor Name":='';
            end;
        }
        field(22; "Total Amount"; Decimal)
        {
            CalcFormula = Sum("Procurement Request Lines"."Total Amount" WHERE("Procurement No"=FIELD("No.")));
            FieldClass = FlowField;
        }
        field(25; "Generated Order No"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(26; "Date Awarded"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(27; "Date Advertisement"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(28; "Date of Mandatory Evaluation"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(29; "Date of Technical Evaluation"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Date of Financial Evaluation"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(31; "Contract No Generated"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(32; "Tender Max Score"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(33; "Technical Total Scores"; Decimal)
        {
            CalcFormula = Sum("Technical Specifications"."Max Weigth" WHERE("Reference No."=FIELD("No.")));
            FieldClass = FlowField;
        }
        field(34; "Financial Score"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Financial Score" = 0 then exit;
                Rec.Testfield("Tender Max Score");
                if "Financial Score" > "Tender Max Score" then Error('Pass mark cannot be higher than maximum score');
                "Technical Score":="Tender Max Score" - "Financial Score";
            end;
        }
        field(35; "Return Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(36; "Return Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(37; "Extended Closing Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(38; "Extension Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(39; "Tender Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Open National,Open International,Restricted Tender';
            OptionMembers = " ", "Open National", "Open International", "Restricted Tender";
        }
        field(40; "Technical Evaluation Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(41; "Financial Evaluation Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(46; "Technical Score"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Technical Score" = 0 then exit;
                Rec.Testfield("Tender Max Score");
                if "Technical Score" > "Tender Max Score" then Error('Technical score cannot be higher than maximum score');
                "Financial Score":="Tender Max Score" - "Technical Score";
            end;
        }
        field(47; "Awarded Vendor No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(48; "Minimum No. of Suppliers"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(49; "Terminated By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(50; "Reason For Termination"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(51; "Date of termination"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(52; "Reason For Vendor Selection"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(53; "Vendor Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(54; "Original Doc. Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ',Maintenance';
            OptionMembers = , Maintenance;
        }
        field(55; "Quotation Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(56; "Quotation Period"; DateFormula)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Format("Quotation Period") = '' then exit;
                Rec.Testfield("Quotation Start Date");
                "Quotation End Date":=CalcDate("Quotation Period", "Quotation Start Date");
            end;
        }
        field(57; "Quotation End Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(58; "No. Series"; Code[20])
        {
        }
        field(59; Archived; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(60; Title; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(61; Currency; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = Currency;
        }
        field(62; "Expected Delivery Date"; date)
        {
            DataClassification = ToBeClassified;
        }
        field(63; "RFQ Deadline Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(64; MyField; Blob)
        {
            DataClassification = ToBeClassified;
        }
        field(65; "RFQ Deadline Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(66; "Delivery Period (Days)"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(67; "Order No"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(68; "RFQ Com. Analysis Initiated"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(69; "Order Created"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(70; "Administrative-Mandatory Score"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(71; "RFP Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = New, "Order Created";
        }
        field(72; "Direct Procurement Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = New, "Email Sent", "Order Created";
        }
        field(73; "Technical Scores"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(74; "Committee Meeting Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(75; "Committee Meeting Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(76; "Committee Meeting Venue"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "No.")
        {
        }
    }
    trigger OnInsert()
    begin
        if("Procurement Method" = "Procurement Method"::"Open Tendering") or ("Procurement Method" = "Procurement Method"::"Restricted Tendering")then begin
            PurchPayablesSetup.Get;
            if "No." = '' then begin
                PurchPayablesSetup.TestField("Tender Nos");
                NoSeriesMgt.InitSeries(PurchPayablesSetup."Tender Nos", xRec."No.", 0D, "No.", "No. Series");
            end;
        end;
        "Created By":=UserId;
        "Creation Date":=WorkDate;
    end;
    var Vendor: Record Vendor;
    PurchPayablesSetup: Record "Purchases & Payables Setup";
    NoSeriesMgt: Codeunit NoSeriesManagement;
}

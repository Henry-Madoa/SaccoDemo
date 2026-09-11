table 52203498 "Appraisal Journal Batch"
{
    DataCaptionFields = Name, Description;

    fields
    {
        field(1; "Journal Template Name"; Code[20])
        {
            Caption = 'Journal Template Name';
            NotBlank = true;
            TableRelation = "Appraisal Journal Template".Name;
        }
        field(2; Name; Code[20])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(3; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(4; "Reason Code"; Code[20])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";

            trigger OnValidate()
            begin
                if "Reason Code" <> xRec."Reason Code" then begin
                    InsuranceJnlLine.SetRange("Journal Template Name", "Journal Template Name");
                    InsuranceJnlLine.SetRange("Journal Batch Name", Name);
                    InsuranceJnlLine.ModifyAll("KPI Code", "Reason Code");
                    Rec.Modify;
                end;
            end;
        }
        field(5; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                if("No. Series" <> '') and ("No. Series" = "Posting No. Series")then Validate("Posting No. Series", '');
            end;
        }
        field(6; "Posting No. Series"; Code[20])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                if("Posting No. Series" = "No. Series") and ("Posting No. Series" <> '')then FieldError("Posting No. Series", StrSubstNo(Text000, "Posting No. Series"));
                InsuranceJnlLine.SetRange("Journal Template Name", "Journal Template Name");
                InsuranceJnlLine.SetRange("Journal Batch Name", Name);
                InsuranceJnlLine.ModifyAll("Self Comments", "Posting No. Series");
                Rec.Modify;
            end;
        }
        field(18; Type; Option)
        {
            OptionCaption = 'Positive,Negative';
            OptionMembers = Positive, Negative;

            trigger OnValidate()
            begin
            /*
                    //"Test Report ID" := REPORT::"General Journal - Test";
                    //"Posting Report ID" := REPORT::"G/L Register";
                    SourceCodeSetup.GET;
                    CASE Type OF
                      Type::Positive:
                        BEGIN
                          "Source Code" := SourceCodeSetup."Leave Journal";
                          "Form ID" :=  PAGE::"HR Leave Journal Lines";
                        end;
                      Type::Negative:
                        BEGIN
                          "Source Code" := SourceCodeSetup."Leave Journal";
                          "Form ID" := PAGE::"HR Leave Journal Lines";
                        end;
                    end;
                    */
            end;
        }
        field(19; "Posting Description"; Text[50])
        {
        }
    }
    keys
    {
        key(Key1; "Journal Template Name", Name)
        {
        }
    }
    trigger OnDelete()
    begin
        InsuranceJnlLine.SetRange("Journal Template Name", "Journal Template Name");
        InsuranceJnlLine.SetRange("Journal Batch Name", Name);
        InsuranceJnlLine.DeleteAll(true);
    end;
    trigger OnInsert()
    begin
        LockTable;
        InsuranceJnlTempl.Get("Journal Template Name");
    end;
    trigger OnRename()
    begin
        InsuranceJnlLine.SetRange("Journal Template Name", xRec."Journal Template Name");
        InsuranceJnlLine.SetRange("Journal Batch Name", xRec.Name);
        while InsuranceJnlLine.Find('-')do InsuranceJnlLine.Rename("Journal Template Name", Name, InsuranceJnlLine."Line No.");
    end;
    var Text000: Label 'must not be %1';
    InsuranceJnlTempl: Record "Appraisal Journal Template";
    InsuranceJnlLine: Record "Appraisal Journal Line";
    procedure SetupNewBatch()
    begin
        InsuranceJnlTempl.Get("Journal Template Name");
        "No. Series":=InsuranceJnlTempl."No. Series";
        "Posting No. Series":=InsuranceJnlTempl."Posting No. Series";
        "Reason Code":=InsuranceJnlTempl."Reason Code";
    end;
}

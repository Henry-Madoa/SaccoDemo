page 52203965 "Job Professional Certs"
{
    PageType = ListPart;
    SourceTable = "Job Qualifications";
    SourceTableView = where("Qualification Type"=const(Professional));
    Caption = 'Professional Certifications';

    layout
    {
        area(content)
        {
            repeater(Control6)
            {
                ShowCaption = false;

                field("Competency Type"; Rec."Qualification Type")
                {
                    ApplicationArea = All;
                }
                field("Competency Code"; Rec."Qualification Code")
                {
                    ApplicationArea = All;
                }
                field(Competency; Rec.Qualification)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                }
                field("Score ID"; Rec."Score ID")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean begin
        Rec."Qualification Type":=Rec."Qualification Type"::Professional;
    end;
}

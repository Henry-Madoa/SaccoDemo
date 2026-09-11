page 52203974 "Job Academic Qualifications"
{
    PageType = ListPart;
    SourceTable = "Job Qualifications";
    SourceTableView = where("Qualification Type"=const(Academic));
    Caption = 'Academic Qualifications';

    layout
    {
        area(content)
        {
            repeater(Control6)
            {
                ShowCaption = false;

                field("Qualification Type"; Rec."Qualification Type")
                {
                    ApplicationArea = All;
                }
                field("Qualification Code"; Rec."Qualification Code")
                {
                    ApplicationArea = All;
                }
                field(Qualification; Rec.Qualification)
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
        Rec."Qualification Type":=Rec."Qualification Type"::Academic;
    end;
}

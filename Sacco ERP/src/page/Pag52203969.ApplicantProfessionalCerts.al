page 52203969 "Applicant Professional Certs"
{
    PageType = ListPart;
    Caption = 'Professional Certificates';
    SourceTable = "Applicants Qualification";
    SourceTableView = where("Qualification Type"=const(Professional));

    layout
    {
        area(content)
        {
            repeater(Control9)
            {
                ShowCaption = false;

                field("Applicant No."; Rec."Applicant No.")
                {
                    ApplicationArea = All;
                    Visible = WebServiceVisibility;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Visible = WebServiceVisibility;
                }
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
                field("From Date"; Rec."From Date")
                {
                    ApplicationArea = All;
                }
                field("To Date"; Rec."To Date")
                {
                    ApplicationArea = All;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field("Institution/Company"; Rec."Institution/Company")
                {
                    ApplicationArea = All;
                }
                field("Attachment Link"; Rec."Attachment Link")
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
    var WebServiceVisibility: Boolean;
}

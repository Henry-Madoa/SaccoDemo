page 52203493 "Employee Relatives Change"
{
    Caption = 'Employee Relatives';
    DataCaptionFields = "Employee No.";
    PageType = ListPart;
    SourceTable = "Employee Relative Change";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;

                field("Relative Code"; Rec."Relative Code")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies a relative code for the employee.';
                }
                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the first name of the employee''s relative.';
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the middle name of the employee''s relative.';
                    Visible = false;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the relative''s telephone number.';
                }
                field("Relative's Employee No."; Rec."Relative's Employee No.")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies the relative''s employee number, if the relative also works at the company.';
                    Visible = false;
                }
                field("Birth Date"; Rec."Birth Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Age; Rec.Age)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("ID/Birth Certificate No."; Rec."ID/Birth Certificate No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Gender; Rec.Gender)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Action"; Rec.Action)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Change No"; Rec."Change No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean begin
        Rec.Action:=Rec.Action::"New Addition";
    end;
}

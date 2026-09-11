page 52203707 "Payroll Transaction Codes"
{
    CardPageID = "Payroll Transaction Code Card";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Payroll Transaction Code";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Taxable; Rec.Taxable)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Is Formula"; Rec."Is Formula")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Formula; Rec.Formula)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("GL Employee Account"; Rec."GL Employer Account")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("GL Account"; Rec."GL Account No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Show on Master Roll"; Rec."Show on Master Roll")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

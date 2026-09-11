page 52203723 "Allowances Setup"
{
    PageType = List;
    SourceTable = "Allowances Setup";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("GL Account No."; Rec."GL Account No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Group; Rec.Group)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Taxable; Rec.Taxable)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Tax Code"; Rec."Tax Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec.Taxable;
                }
                field("Tax Relief"; Rec."Tax Relief")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec.Taxable;
                }
                field(Rate; Rec.Rate)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Editable; Rec.Editable)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
}

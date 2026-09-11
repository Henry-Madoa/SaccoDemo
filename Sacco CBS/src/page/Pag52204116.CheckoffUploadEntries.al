page 52204116 "Checkoff Upload Entries"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Checkoff Upload";
    InsertAllowed = false;
    DeleteAllowed = true;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Check No"; Rec."Check No")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleTxt;
                }
                field("Uploaded Name"; Rec."Uploaded Name")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleTxt;
                }
                field("System Name"; Rec."System Name")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleTxt;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleTxt;
                }
                field("Product Code"; Rec."Product Code")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleTxt;
                }
            }
        }
    }
    var
        StyleTxt: Text;

    trigger OnAfterGetRecord()
    begin
        if Rec.Matched then
            StyleTxt := 'Favorable'
        else
            StyleTxt := 'Unfavorable';
    end;
}

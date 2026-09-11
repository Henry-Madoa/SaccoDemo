page 52203905 "External Bank Branches"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "External Bank Branches";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Bank Code"; Rec."Bank Code")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = IsSoap;
                }
                field("Branch Code"; Rec."Branch Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Branch Name"; Rec."Branch Name")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    var IsSoap: Boolean;
    trigger OnAfterGetRecord()
    begin
        IsSoap:=not GuiAllowed;
    end;
}

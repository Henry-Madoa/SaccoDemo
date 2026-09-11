page 52203794 "Contract Extension"
{
    ApplicationArea = All;
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            field("Extend By"; ExtendBy)
            {
            }
        }
    }
    actions
    {
    }
    var ExtendBy: DateFormula;
    procedure IanGetDate(): Code[30]begin
        exit(Format(ExtendBy));
    end;
}

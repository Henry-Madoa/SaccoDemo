page 52203831 "Tender Termination"
{
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            field("Date Of Termination"; DateofTermination)
            {
            }
            field(Reasons; ReasonsForTermination)
            {
            }
        }
    }
    actions
    {
    }
    var DateofTermination: Date;
    ReasonsForTermination: Text;
    procedure IanGetDate(): Date begin
        exit(DateofTermination);
    end;
    procedure IanGetReasons(): Text begin
        exit(Format(ReasonsForTermination));
    end;
}

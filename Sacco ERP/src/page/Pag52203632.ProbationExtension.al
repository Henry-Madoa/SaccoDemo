page 52203632 "Probation Extension"
{
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            field("Extension Period"; ExtensionPeriod)
            {
                ApplicationArea = Basic, Suite;
            }
            field("Reason For Extension"; ReasonsForExtension)
            {
                MultiLine = true;
            }
        }
    }
    var ExtensionPeriod: DateFormula;
    ReasonsForExtension: Text;
    procedure GetExtensionPeriod(): Text begin
        exit(Format(ExtensionPeriod));
    end;
    procedure GetReasons(): Text begin
        exit(ReasonsForExtension);
    end;
}

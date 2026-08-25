tableextension 52204016 "Country/Region" extends "Country/Region"
{
    fields
    {
        field(52203423; "Country Code"; Code[10])
        {
            trigger OnValidate()
            var
                RegEx: Codeunit Regex;
                Pattern: Text;
                MatchRec: Record Matches;
            begin
                if "Country Code" <> '' then begin
                    Pattern := '([+]{1})';
                    RegEx.Match("Country Code", Pattern, MatchRec);
                    if not MatchRec.Success then Error('Kindly start the Country Code with +');
                end;
            end;
        }
    }
}

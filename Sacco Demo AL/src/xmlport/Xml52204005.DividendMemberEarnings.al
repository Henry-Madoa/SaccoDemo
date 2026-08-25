xmlport 52204005 "Dividend Member Earnings"
{
    Direction = Both;
    Format = VariableText;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement(DividendEarnedEntries; "Dividend Earned Entries")
            {
                AutoReplace = true;
                XmlName = 'DividendMemberEarnings';

                fieldattribute(MemberNo; DividendEarnedEntries."Member No.")
                {
                }
                fieldattribute(AccountType; DividendEarnedEntries."Account Type")
                {
                }
                fieldattribute(Amount; DividendEarnedEntries.Amount)
                {
                }
                trigger OnBeforeInsertRecord();
                begin
                    DividendEarnedEntries."Dividend Code" := DividendCode;
                end;
            }
        }
    }
    trigger OnPostXmlPort();
    begin
        MESSAGE('Uploaded Successfully');
    end;

    var
        DividendCode: Code[20];

    procedure Intialise(DDCode: Code[50]);
    var
        DividendEntries: Record "Dividend Earned Entries";
    begin
        DividendCode := DDCode;

        DividendEntries.Reset();
        DividendEntries.SetRange("Dividend Code", DDCode);
        DividendEntries.DeleteAll;
    end;
}

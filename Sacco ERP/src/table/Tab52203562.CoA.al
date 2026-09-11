table 52203562 "CoA"
{
    fields
    {
        field(1; No; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Name; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Income/Balance"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Income Statement,Balance Sheet';
            OptionMembers = "Income Statement", "Balance Sheet";
        }
        field(4; Type; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Posting,Heading,Total,Begin-Total,End-Total';
            OptionMembers = Posting, Heading, Total, "Begin-Total", "End-Total";
        }
    }
    keys
    {
        key(Key1; No)
        {
        }
    }
}

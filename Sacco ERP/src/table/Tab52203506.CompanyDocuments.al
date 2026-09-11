table 52203506 "Company Documents"
{
    fields
    {
        field(1; "No."; Code[20])
        {
        }
        field(2; "Document Name"; Text[30])
        {
        }
        field(3; "Visible To"; Option)
        {
            OptionCaption = 'All Staff,Management';
            OptionMembers = "All Staff", Management;
        }
    }
    keys
    {
        key(Key1; "No.")
        {
        }
    }
}

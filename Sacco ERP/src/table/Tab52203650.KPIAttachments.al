table 52203650 "KPI Attachments"
{
    fields
    {
        field(1; "Appraisal Code"; Code[20])
        {
        }
        field(2; "KRA Code"; Code[20])
        {
        }
        field(3; "KPI Code"; Code[20])
        {
        }
        field(4; "Attachment Name"; Code[20])
        {
        }
        field(5; Description; Text[200])
        {
        }
        field(6; "Attachment Uploaded"; Boolean)
        {
            Editable = false;
        }
        field(7; "Employee Code"; Code[20])
        {
        }
    }
    keys
    {
        key(Key1; "Appraisal Code", "KRA Code", "KPI Code", "Employee Code", "Attachment Name")
        {
        }
    }
}

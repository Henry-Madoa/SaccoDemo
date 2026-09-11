table 52203669 "C.Donor Allocation Details"
{
    fields
    {
        field(1; "Line No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Contract Line No"; Integer)
        {
        }
        field(3; "Employee No"; Code[20])
        {
        }
        field(4; Donor; Code[50])
        {
            TableRelation = "Donor List"."Donor Code";

            trigger OnValidate()
            begin
                if DonorList.Get(Donor)then "Donor Name":=DonorList."Donor Name";
            end;
        }
        field(5; "End Date of grant"; Date)
        {
        }
        field(6; "Employee Name"; Text[70])
        {
        }
        field(7; "Donor Name"; Text[70])
        {
        }
        field(8; Percentage; Decimal)
        {
        }
        field(9; "Current Donor Details"; Boolean)
        {
        }
        field(10; "Change No"; Code[20])
        {
        }
        field(13; "C. Line No"; Integer)
        {
        }
    }
    keys
    {
        key(Key1; "Line No.", "Change No", "Employee No")
        {
        }
    }
    var DonorList: Record "Donor List";
}

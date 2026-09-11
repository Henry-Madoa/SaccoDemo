table 52203538 "Vendor Evaluation"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Vendor No."; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(4; "Vendor Name"; text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Date; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(6; Period; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Day,Month,Quarter,Bi-annual,Annual';
            OptionMembers = Day, Month, Quarter, "Bi-annual", Annual;
        }
        field(7; Competency; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(8; Capacity; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(9; Commitment; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(10; Control; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(11; "Cash Resources"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(12; Cost; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(13; Consistency; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(14; "Created By"; Code[50])
        {
            DataClassification = CustomerContent;
        }
        field(15; "Created Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(16; "Created Time"; Time)
        {
            DataClassification = CustomerContent;
        }
        field(17; "Date Filter"; Date)
        {
            //DataClassification = ToBeClassified;
            FieldClass = FlowFilter;
        }
    }
    keys
    {
        /*key(PK; "Vendor No.")
        {
            Clustered = true;
        }*/
        key(PK; "Vendor No.", "Line No.")
        {
            Clustered = true;
        }
    }
    var Vend: Record Vendor;
}

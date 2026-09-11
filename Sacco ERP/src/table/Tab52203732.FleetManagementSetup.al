table 52203732 "Fleet Management Setup"
{
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Work Ticket Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(3; "Vehicle Repair Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(4; "Vehicle Booking Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(5; "Fuel Log Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(6; "Fuel Top-Up Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(7; "Last Modified Date-Time"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Last Modified By User ID"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "WorkTicket Request Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(10; "WorkTicket Form Limit"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Fleet Officer"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No.";
        }
        field(12; "Insurance Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(13; "Service Proforma Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(14; "Servicing Mileage (Kms)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Service Part Nos"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series".Code;
        }
    }
    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }
    trigger OnModify()
    begin
        "Last Modified Date-Time":=CreateDateTime(Today, Time);
        "Last Modified By User ID":=UserId;
    end;
}

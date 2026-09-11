table 52203741 "WorkTicket Form Request Lines"
{
    fields
    {
        field(1; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Date; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Work Ticket No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Driver No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No.";

            trigger OnValidate()
            begin
                if Employee.Get("Driver No.")then begin
                    "Driver Name":=Employee."First Name" + ' ' + Employee."Middle Name" + ' ' + Employee."Last Name";
                end;
            end;
        }
        field(5; "Driver Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Place Of Departure"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(7; Destination; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Reason For Travel"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Authorizing Officer"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No.";

            trigger OnValidate()
            begin
                if Employee.Get("Authorizing Officer")then begin
                    "Authorizing Officer Name":=Employee."First Name" + ' ' + Employee."Middle Name" + ' ' + Employee."Last Name";
                end;
            end;
        }
        field(10; "Fuel Log No."; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if FuelLog.Get("Fuel Log No.")then begin
                    "Fuel Drawn (litres)":=FuelLog."Quantity Fueled (ltrs)";
                end;
            end;
        }
        field(11; "Oil Drawn (litres)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Fuel Drawn (litres)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Time Out"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Time In"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Mileage at Start (kms)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Mileage at End (kms)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Distance Travelled (kms)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Date In"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Authorizing Officer Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
        }
    }
    var Employee: Record Employee;
    FuelLog: Record "Fuel Requisition";
}

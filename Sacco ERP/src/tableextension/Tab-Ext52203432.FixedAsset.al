tableextension 52203432 "Fixed Asset" extends "Fixed Asset"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Asset Tag"; Code[20])
        {
        }
        field(50001; "Asset Type"; Option)
        {
            OptionMembers = "Fixed Asset","Motor Vehicle";
            DataClassification = ToBeClassified;
        }
        field(50002; "Vehicle Registration No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50003; "Marked For Disposal"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50004; "Vehicle Make"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50005; "Vehicle Model"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50006; Color; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(50008; "Frame No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50009; "Engine No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50010; "Log Book No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50011; "Year Of Manufacture"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Year Of Manufacture" > Today then Error('A future date cannot be used as the date of manufacture');
            end;
        }
        field(50012; "Load Limit (KGS)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50013; "Passenger Capacity"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(50014; "Fuel Capacity"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
}

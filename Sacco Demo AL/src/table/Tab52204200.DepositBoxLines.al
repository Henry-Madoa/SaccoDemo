table 52204200 "Deposit Box Lines"
{
    fields
    {
        field(1; Type; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = 'Safe,Safety Deposit Box';
            OptionMembers = Safe, "Safety Deposit Box";
        }
        field(2; "Serial No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; Length; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(4; Width; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(5; Height; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Contents Exist"; Boolean)
        {
            CalcFormula = Exist("Custodial Header" WHERE("Storage Type"=FIELD(Type), "Storage Serial No."=FIELD("Serial No."), "Document Status"=CONST(Instore)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(7; Customers; Integer)
        {
            CalcFormula = Count("Custodial Header" WHERE("Storage Type"=FIELD(Type), "Storage Serial No."=FIELD("Serial No."), "Document Status"=CONST(Instore)));
            Editable = false;
            FieldClass = FlowField;
        }
    }
    keys
    {
        key(Key1; Type, "Serial No.")
        {
            Clustered = true;
        }
    }
}

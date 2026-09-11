tableextension 52203450 "G/L Budget Name" extends "G/L Budget Name"
{
    fields
    {
        field(50000; "Department Filter"; Code[10])
        {
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1), Blocked = const(false));
        }
        field(50001; Status; Enum "Document Status")
        {
            DataClassification = ToBeClassified;
            //Editable = false;
        }
    }
    trigger OnBeforeInsert()
    begin
        if Status <> Status::Open then Rec.Status := Rec.Status::Open;
    end;
}

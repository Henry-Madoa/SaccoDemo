table 52204131 "Channel Feedbacks"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Editable = false;
            AutoIncrement = true;
        }
        field(2; Date; DateTime)
        {
            Editable = false;
        }
        field(3; "Member No"; Code[20])
        {
            trigger OnValidate()
            var
                Member: Record Members;
            begin
                If Member.Get("Member No") then begin
                    Email := Member."E-Mail";
                    "Phone No" := Member."Mobile Phone No.";
                end;
            end;
        }
        field(4; Email; Text[100])
        {
            ExtendedDatatype = EMail;
        }
        field(5; "Phone No"; Text[100])
        {
            ExtendedDatatype = PhoneNo;
        }
        field(6; Type; Code[20])
        {
            TableRelation = "Sacco Lookup Values".Code where(Type = const("Channel Feebacks"));

            trigger OnValidate()
            var
                SaccoLookupValues: Record "Sacco Lookup Values";
            begin
                if SaccoLookupValues.Get(SaccoLookupValues.Type::"Channel Feebacks", Type) then "Type Description" := SaccoLookupValues.Description;
            end;
        }
        field(7; "Type Description"; Text[100])
        {
            Editable = false;
        }
        field(8; Subject; Code[20])
        {
        }
        field(9; Message; Text[250])
        {
        }
    }
    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        Date := CurrentDateTime;
    end;
}

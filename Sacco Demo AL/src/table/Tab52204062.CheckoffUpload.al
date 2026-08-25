table 52204062 "Checkoff Upload"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Checkoff Upload Entries";
    LookupPageId = "Checkoff Upload Entries";

    fields
    {
        field(1; "Document No"; Code[20])
        {
        }
        field(2; "Check No"; Code[20])
        {
        }
        field(3; "Product Code"; Code[20])
        {
            TableRelation = "Sacco Products" where(Indentation = const(1), Blocked = const(false));
        }
        field(4; "Uploaded Name"; Text[80])
        {
        }
        field(5; "System Name"; Text[80])
        {
        }
        field(6; Amount; Decimal)
        {
        }
        field(7; Matched; Boolean)
        {
            trigger OnValidate()
            var
                CheckoffUpload: Record "Checkoff Upload";
            begin
                CheckoffUpload.Reset();
                CheckoffUpload.SetRange("Check No", Rec."Check No");
                CheckoffUpload.SetFilter("Product Code", '<>%1', Rec."Product Code");
                if CheckoffUpload.FindSet then begin
                    repeat
                        CheckoffUpload.Matched := true;
                        CheckoffUpload."System Name" := Rec."System Name";
                        CheckoffUpload.Modify(true);
                    until CheckoffUpload.Next = 0;
                end;
            end;
        }
    }
    keys
    {
        key(Key1; "Document No", "Check No", "Product Code")
        {
            Clustered = true;
        }
    }
}

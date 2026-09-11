table 52203560 "Budget Users"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "UserName"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName(UserName);
                user.Reset();
                user.SetRange("User Name", UserName);
                if user.FindFirst()then "Full Name":=user."Full Name";
            end;
        }
        field(2; "Full Name"; Text[80])
        {
            Caption = 'Name';
            Editable = false;
        }
    }
    keys
    {
        key(Key1; UserName)
        {
            Clustered = true;
        }
    }
    var user: Record User;
}

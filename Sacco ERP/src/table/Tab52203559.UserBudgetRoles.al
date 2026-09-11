table 52203559 "User Budget Roles"
{
    fields
    {
        field(1; "User ID"; Code[50])
        {
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(2; "Global Dimension 1 Code"; Text[250])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 3 Code';
        }
        field(3; "Global Dimension 2 Code"; Text[250])
        {
            CaptionClass = '1,2,2';
            Caption = 'Global Dimension 3 Code';
        }
        field(4; "Global Dimension 3 Code"; Text[30])
        {
            CaptionClass = '1,2,3';
            Caption = 'Global Dimension 3 Code';
        }
        field(5; "Budget Acounts Range"; Text[30])
        {
        }
        field(6; Role; Option)
        {
            OptionCaption = 'Maker,Approver';
            OptionMembers = Maker, Approver;
        }
    }
    keys
    {
        key(Key1; "User ID")
        {
        }
    }
}

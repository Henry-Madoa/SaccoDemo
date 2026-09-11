table 52203655 "Competence Behaviour"
{
    fields
    {
        field(1; "Line No"; Integer)
        {
            AutoIncrement = true;
        }
        field(2; Category; Text[100])
        {
            trigger OnLookup()
            begin
                CompetenceCategories.Reset;
                if PAGE.RunModal(PAGE::"Competence Categories", CompetenceCategories) = ACTION::LookupOK then Category:=CompetenceCategories.Category;
            end;
        }
        field(3; Behaviour; Text[100])
        {
        }
        field(4; "Behaviour Description"; Text[250])
        {
        }
        field(5; Weigths; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Line No")
        {
        }
    }
    var CompetenceCategories: Record "Competence Categories";
}

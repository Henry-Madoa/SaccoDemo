table 52204064 "Sacco Product Categories"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Sacco Product Categories";
    DrillDownPageId = "Sacco Product Categories";

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[100])
        {
        }
    }
    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }
    trigger OnDelete()
    begin
        SaccoProducts[1].Reset;
        SaccoProducts[1].SetFilter(Code, '<>%1', Code);
        SaccoProducts[1].SetRange(Category, Code);
        SaccoProducts[1].SetRange(Indentation, 1);
        if SaccoProducts[1].FindSet() then
            Error('You cannot delete a Category with Products set to it \\ Kindly categorize your products again and then delete the category')
        else begin
            SaccoProducts[2].Reset;
            SaccoProducts[2].SetRange(Code, Code);
            SaccoProducts[2].SetRange(Category, Code);
            SaccoProducts[1].SetRange(Indentation, 0);
            if SaccoProducts[2].FindSet() then SaccoProducts[2].DeleteAll(true);
        end;
    end;

    var
        SaccoProducts: array[2] of Record "Sacco Products";
}

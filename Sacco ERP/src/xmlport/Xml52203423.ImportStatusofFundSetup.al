xmlport 52203423 "Import Status of Fund Setup"
{
    Direction = Import;
    Format = VariableText;

    schema
    {
    textelement(Root)
    {
    tableelement("Status of Fund";
    "Status of Fund")
    {
    XmlName = 'SOF';

    fieldattribute(Fund;
    "Status of Fund".Fund)
    {
    }
    fieldattribute(FName;
    "Status of Fund"."Fund Name")
    {
    }
    fieldattribute(Proj;
    "Status of Fund".Project)
    {
    }
    fieldattribute(PName;
    "Status of Fund"."Project Name")
    {
    }
    fieldattribute(Dept;
    "Status of Fund".Department)
    {
    }
    fieldattribute(FY;
    "Status of Fund".FY)
    {
    }
    }
    }
    }
}

xmlport 52203429 "Training Needs"
{
    Direction = Both;
    Format = VariableText;

    schema
    {
    textelement(Root)
    {
    tableelement("Training Need";
    "Training Need")
    {
    XmlName = 'TrainingNeed';

    fieldattribute(Code;
    "Training Need".Code)
    {
    }
    fieldattribute(Description;
    "Training Need".Description)
    {
    }
    fieldattribute(GlobalDim1;
    "Training Need"."Global Dimension 1 Code")
    {
    }
    fieldattribute(EmployeeSpecific;
    "Training Need"."Employee Specific")
    {
    }
    fieldattribute(EmplyeeNo;
    "Training Need"."Employee No")
    {
    }
    trigger OnBeforeInsertRecord()
    begin
        if "Training Need".Code = '' then currXMLport.Skip();
        "Training Need".Validate("Employee Specific");
        "Training Need".Validate("Employee No");
    end;
    trigger OnAfterInsertRecord()
    begin
        "Training Need".Validate("Employee Specific");
        "Training Need".Validate("Employee No");
    end;
    }
    }
    }
    trigger OnPostXmlPort()
    begin
        Message('Import Completed.');
    end;
}

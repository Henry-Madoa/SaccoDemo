xmlport 52203428 "Training Plan"
{
    Direction = Import;
    Format = VariableText;

    schema
    {
    textelement(Root)
    {
    tableelement("Training Plan Lines";
    "Training Plan Lines")
    {
    XmlName = 'TrainingPlanLines';

    fieldattribute(TrainingNeed;
    "Training Plan Lines"."Training Need")
    {
    }
    }
    }
    }
}

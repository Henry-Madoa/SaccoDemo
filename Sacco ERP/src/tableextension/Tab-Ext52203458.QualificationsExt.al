tableextension 52203458 "Qualifications Ext" extends Qualification
{
    fields
    {
        // Add changes to table fields here
        field(50000; Type; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Qualification, "Job Grade";
        }
        field(50001; "Qualification Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ", Academic, Professional, Technical, Experience, "Personal Attributes";
        }
    }
}

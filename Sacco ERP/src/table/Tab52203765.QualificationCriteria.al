table 52203765 "Qualification Criteria"
{
    fields
    {
        field(1; "Requisition No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Criteria; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Qualifications,Experience,Sector,Age,Gender';
            OptionMembers = " ", Qualifications, Experience, Sector, Age, Gender;
        }
        field(3; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(5; Gender; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Male,Female';
            OptionMembers = " ", Male, Female;
        }
        field(6; "Period in years"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Prefered Sector"; Text[50])
        {
            DataClassification = ToBeClassified;
        //TableRelation = "Experience Sector";
        }
        field(8; Used; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Requisition No", Criteria)
        {
        }
    }
    fieldgroups
    {
    }
}

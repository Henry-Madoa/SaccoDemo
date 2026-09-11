query 52204000 "Members Query"
{
    QueryType = API;
    APIPublisher = 'PublisherName';
    APIGroup = 'GroupName';
    APIVersion = 'v1.0';
    EntityName = 'SACCOMembers';
    EntitySetName = 'SACCOMembers';

    elements
    {
    dataitem(Members;
    Members)
    {
    column(Member_No_;
    "No.")
    {
    }
    column(Gender;
    Gender)
    {
    }
    column(Date_of_Birth;
    "Date of Birth")
    {
    }
    column(Date_of_Registration;
    "Date of Registration")
    {
    }
    column(Sales_Person;
    "Recruiter Code")
    {
    }
    filter(FilterName;
    "Date of Registration")
    {
    }
    }
    }
}

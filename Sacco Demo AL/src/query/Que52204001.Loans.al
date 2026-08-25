query 52204001 "Loans"
{
    QueryType = API;
    APIPublisher = 'PublisherName';
    APIGroup = 'GroupName';
    APIVersion = 'v1.0';
    EntityName = 'Loans';
    EntitySetName = 'Loans';

    elements
    {
        dataitem(Loan_Application;
        Loans)
        {
            column(Application_No;
            "No.")
            {
            }
            column(Approved_Amount;
            "Approved Amount")
            {
            }
            column(Applied_Amount;
            "Loan Amount")
            {
            }
            column(Loan_Balance;
            "Loan Balance")
            {
            }
            column(Sales_Person;
            "Sales Representative")
            {
            }
            column(Sales_Person_Name;
            "Sales Representative Name")
            {
            }
            column(Posting_Date;
            "Posting Date")
            {
            }
            column(Product_Code;
            "Product Code")
            {
            }
            column(Product_Description;
            "Product Description")
            {
            }
            column(Member_No_;
            "Member No.")
            {
            }
        }
    }
    var
        Members: Record Members;
        MemberGender: Text;

    trigger OnBeforeOpen()
    begin
    end;
}

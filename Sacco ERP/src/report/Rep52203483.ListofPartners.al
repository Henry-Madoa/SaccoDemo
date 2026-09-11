report 52203483 "List of Partners"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/List of Partners.rdlc';

    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = WHERE("Customer Posting Group"=CONST('PARTNER'));

            column("Code"; Customer."No.")
            {
            }
            column(Organization; Customer.Name)
            {
            }
            column(Acrn; Customer."Search Name")
            {
            }
            column(Country; Customer."Country/Region Code")
            {
            }
        }
    }
}

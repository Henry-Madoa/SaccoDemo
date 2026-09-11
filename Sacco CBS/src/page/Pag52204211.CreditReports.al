page 52204211 "Credit Reports"
{
    PageType = CardPart;

    layout
    {
        area(content)
        {
            cuegroup("Credit Reports")
            {
                CuegroupLayout = Wide;

                actions
                {
                    action("Member Listing")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = Report "Member List";
                        Image = TileReport;
                    }
                    action("Account Listing")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = Report "Member Account List";
                        Image = TileReport;
                    }
                    action("Over Drawn Accounts")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = Report "Overdrawn Accounts";
                        Image = TileReport;
                    }
                    action("Loan Balances Summary")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = Report "Loan Balances Summary";
                        Image = TileReport;
                    }
                    action("Loan Defaulter Aging")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = Report "Loan Defaulters";
                        Image = TileReport;
                    }
                    action("Guarantor Register")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = Report "Guarantor Register";
                        Image = TileReport;
                    }
                    action("Non_Guaranteed Loans")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = Report "Non_Guaranteed Loans";
                        Image = TileReport;
                    }
                    action("Member Guarantees")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = Report "Member Guarantees";
                        Image = TileReport;
                    }
                    action("Member Guarantors")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = Report "Member Guarantors";
                        Image = TileReport;
                    }
                    action("SASRA Reports")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = Page "Account Schedule Names";
                        Image = TileReport;
                    }
                    action("Dividend Slipt")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = Report "Dividend Slipt";
                        Image = TileReport;
                    }
                    action("Loan Classification Summary")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = Report "Risk Classification";
                        Image = TileReport;
                    }
                    action("Loan Ageing Analysis")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = Report "Loan Ageing Analysis";
                        Image = TileReport;
                    }
                }
            }
        }
    }
}

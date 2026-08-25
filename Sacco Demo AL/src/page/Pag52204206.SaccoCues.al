page 52204206 "Sacco Cues"
{
    PageType = CardPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Sacco Cues";

    layout
    {
        area(Content)
        {
            cuegroup("SACCO Actions")
            {
                CuegroupLayout = Wide;

                actions
                {
                    action("New Loan")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page Loans;
                        RunPageView = where(Status = const(Open));
                        Image = TileRed;
                    }
                    action("New Member")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Member Applications";
                        RunPageView = where(Status = const(Open));
                        Image = TileGreen;
                    }
                    action("New Fixed Deposit")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Member Fixed Deposits";
                        RunPageView = where(Status = const(Open));
                        Image = TileBrickCalendar;
                    }
                    action("New Standing Order")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Standing Orders";
                        RunPageView = where(Status = const(Open));
                        Image = TileBlue;
                    }
                    action("Approval Requests")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Requests to Approve";
                        Image = TileNew;
                    }
                }
            }
            cuegroup(SACCO)
            {
                CuegroupLayout = Wide;
                Caption = 'Shortcuts';

                field("Gross Disbursals"; Rec."Gross Disbursals")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDownPageId = Loans;
                    AutoFormatType = 10;
                    AutoFormatExpression = '1,2:2';
                }
                field("Mobile Transactions"; Rec."Mobile Transactions")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = true;
                    DrillDownPageId = "Channels Transactions";
                    AutoFormatType = 10;
                    AutoFormatExpression = '1,2:2';
                }
                field("ATM Transactions"; Rec."ATM Transactions")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = true;
                    DrillDownPageId = "ATM Transactions";
                    AutoFormatType = 10;
                    AutoFormatExpression = '1,2:2';
                }
                field("Mobile Loans"; Rec."Mobile Loans")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = true;
                    DrillDownPageId = "E-Loans";
                    AutoFormatType = 10;
                    AutoFormatExpression = '1,2:2';
                }
            }
            cuegroup("FOSA Cues")
            {
                field("Treasury Till Balance"; Rec."Treasury Till Balance")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = true;
                    DrillDownPageId = "Bank Account Ledger Entries";
                    AutoFormatType = 10;
                    AutoFormatExpression = '1,2:2';
                }
                field("Teller Till Balance"; Rec."Teller Till Balance")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = true;
                    DrillDownPageId = "Bank Account Ledger Entries";
                    AutoFormatType = 10;
                    AutoFormatExpression = '1,2:2';
                }
                field("M-Banking Till Balance"; Rec."M-Banking Till Balance")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = true;
                    DrillDownPageId = "Bank Account Ledger Entries";
                    AutoFormatType = 10;
                    AutoFormatExpression = '1,2:2';
                }
                field("Matured FD"; Rec."Matured FD")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = true;
                    DrillDownPageId = "Member Fixed Deposits";
                }
                field("Due Cheques"; Rec."Due Cheques")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = true;
                    DrillDownPageId = "Cheque Deposits";
                }
                field("Due Custodial Documents"; Rec."Due Custodial Documents")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = true;
                    DrillDownPageId = "Custodial Applications";
                }
                field("Mobile Deposits"; Rec."Mobile Credits")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Mobile Deposits';
                    DrillDown = true;
                    DrillDownPageId = "Mobile Transactions Dump";
                    AutoFormatType = 10;
                    AutoFormatExpression = '1,2:2';
                }
                field("Mobile Withdrawals"; Rec."Mobile Debits")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Mobile Withdrawals';
                    DrillDown = true;
                    DrillDownPageId = "Mobile Transactions Dump";
                    AutoFormatType = 10;
                    AutoFormatExpression = '1,2:2';
                }
                field("Total ATM Transactions"; Rec."Total ATM Transactions")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Total ATM Withdrawals';
                    DrillDownPageId = "ATM Transactions";
                    DrillDown = true;
                    AutoFormatType = 10;
                    AutoFormatExpression = '1,2:2';
                }
                field("Running Standing Orders"; Rec."Running Standing Orders")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDownPageId = "Standing Orders";
                    DrillDown = true;
                }
                field("Pending Member Applications"; Rec."Pending Member Applications")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDownPageId = "Member Applications";
                    DrillDown = true;
                }
                field("ATM Applications"; Rec."ATM Applications")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = true;
                    DrillDownPageId = "ATM Applications";
                }
            }
            cuegroup("BOSA Cues")
            {
                field("Total Members"; Rec."Total Members")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDownPageId = Members;
                    DrillDown = true;
                }
                field("Collateral in Store"; Rec."Collateral in Store")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDownPageId = "Collateral Registers";
                    DrillDown = true;
                    AutoFormatType = 10;
                    AutoFormatExpression = '1,2:2';
                }

            }
        }
    }
    trigger OnOpenPage()
    begin
        if not Rec.Get(0, UserId) then begin
            Rec.Init();
            Rec.PrimaryKey := 0;
            Rec."User ID" := UserId;
            Rec.Insert();
        end;
    end;
}

page 52204044 "Loan Statistics"
{
    PageType = CardPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = Loans;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group("Loan Details")
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member No."; Rec."Member No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Deposits To Date"; DepositsToDate)
                {
                    Editable = false;
                    Style = Strong;
                    ApplicationArea = Basic, Suite;

                    trigger OnDrillDown()
                    begin
                        MemberMgt.DrillDownPage(Rec."Member No.", Rec."Application Date");
                    end;
                }
                field("Total Recoveries"; Rec."Total Recoveries")
                {
                    ApplicationArea = Basic, Suite;
                }
                group(Appraisal)
                {
                    field("Adjusted Net"; Portal.AdjustedNet(Rec."No."))
                    {
                        ApplicationArea = Basic, Suite;
                        Style = Strong;
                    }
                    field("1/3 Basic"; Portal.OneThirdBasic(Rec."No."))
                    {
                        ApplicationArea = Basic, Suite;
                        Style = Strong;
                    }
                    field("Available Recovery"; Portal.GetAvailableRecovery(Rec."No."))
                    {
                        ApplicationArea = Basic, Suite;
                        Style = Strong;
                    }
                }
            }
            group(Balances)
            {
                field("Openning Disbursed Balance"; Rec."Openning Disbursed Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loan Balance"; Rec."Loan Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Principal Balance"; Rec."Principal Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                group(Interest)
                {
                    field("Total Interest Due"; Rec."Total Interest Due")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Interest Paid"; Rec."Interest Paid")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Interest Balance"; Rec."Interest Balance")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                group(Penalties)
                {
                    field("Total Penalty Due"; Rec."Total Penalty Due")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Penalty Paid"; Rec."Penalty Paid")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Penalty Balance"; Rec."Penalty Balance")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
            }
        }
    }
    var
        Portal: Codeunit "Channels Integrations";
        MemberMgt: Codeunit "Member Management";
        DepositsToDate, RMFToDate : Decimal;
    trigger OnAfterGetRecord()
    begin
        DepositsToDate := 0;
        RMFToDate := 0;
        MemberMgt.GetDepositsCurrYear(Rec."Member No.", Rec."Application Date", DepositsToDate, RMFToDate);
    end;
}

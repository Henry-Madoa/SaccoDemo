page 52204115 "Checkoff Lines"
{
    PageType = ListPart;
    SourceTable = "Checkoff Lines";
    Caption = 'Lines';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Suspense Account"; Rec."Suspense Account")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Member No"; Rec."Member No")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Check No"; Rec."Check No")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Payroll No"; Rec."Payroll No")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }

                field("Mobile Phone No"; Rec."Mobile Phone No")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Collections Account"; Rec."Collections Account")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Amount Earned"; Rec."Amount Earned")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field(Recoveries; Rec.Recoveries)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Net Amount"; Rec."Net Amount")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Running Loans"; Rec."Running Loans")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field(Notified; Rec.Notified)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
            }
        }
    }
    var
        StyleText: Text[20];

    trigger OnAfterGetrecord()
    begin
        if Rec."Suspense Account" then
            StyleText := 'Unfavorable'
        else
            StyleText := 'StandardAccent';
    end;
}

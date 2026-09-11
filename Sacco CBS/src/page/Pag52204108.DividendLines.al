page 52204108 "Dividend Lines"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "Dividend Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Member No."; Rec."Member No.")
                {
                    Style = Favorable;
                    StyleExpr = IsPosted;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account Balance"; Rec."Account Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Amount Earned"; Rec."Automatic Amount Earned")
                {
                    Style = Favorable;
                    StyleExpr = HasNet;
                }
                field("Manual Amount Earned"; Rec."Manual Amount Earned")
                {
                    Style = Favorable;
                    StyleExpr = HasNet;
                }
                field("Charges Amount"; Rec."Charges Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Loans Recoveries"; Rec."Loans Recoveries")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Boost Amount"; Rec."Boost Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Recoveries"; Rec."Total Recoveries")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Net Amount"; Rec."Net Amount")
                {
                    Style = Favorable;
                    StyleExpr = HasNet;
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account No"; Rec."Account No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Savings Account"; Rec."Savings Account")
                {
                    Style = Unfavorable;
                    StyleExpr = IsPreferential;
                }
                field("Has Advance"; Rec."Has Advance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Notified; Rec.Notified)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Prefrential Member"; Rec."Prefrential Boost")
                {
                    Style = Unfavorable;
                    StyleExpr = IsPreferential;
                }
                field("Preferential Boost %"; Rec."Preferential Boost %")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Dividend Slip")
            {
                ApplicationArea = Basic, Suite;
                Image = Report;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    Member: Record Members;
                begin
                    Member.Reset();
                    Member.SetRange("No.", Rec."Member No.");
                    Member.SetFilter("Product Code Filter", Rec."Account Type");
                    Member.SetFilter("Dividend Code Filter", Rec."Dividend Code");
                    if Member.FindSet() then begin
                        Report.Run(Report::"Dividend Slip", true, false, Member);
                    end;
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        IsPosted := false;
        if Rec.Posted then IsPosted := true;
        HasNet := false;
        if Rec."Net Amount" > 0 then HasNet := true;
        IsPreferential := Rec."Prefrential Boost";
    end;

    var
        IsPosted: Boolean;
        HasNet: Boolean;
        IsPreferential: Boolean;
}

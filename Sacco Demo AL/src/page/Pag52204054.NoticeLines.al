page 52204054 "Notice Lines"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Defaulter Notice Lines";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Loan No"; Rec."Loan No")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Product Code"; Rec."Product Code")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Product Description"; Rec."Product Description")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Member No"; Rec."Member No")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Total Arrears"; Rec."Total Arrears")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Loan Balance"; Rec."Loan Balance")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Defaulted Days"; Rec."Defaulted Days")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Skip Reason"; Rec."Skip Reason")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Skip; Rec.Skip)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Defaulted Installments"; Rec."Defaulted Installments")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Notice Type"; Rec."Notice Type")
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
    actions
    {
        area(Processing)
        {
            action("Print Notice")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Report;

                trigger OnAction();
                begin
                    Rec.Reset();
                    Rec.SetRange("No.", Rec."No.");
                    Rec.SetRange("Loan No", Rec."Loan No");
                    if Rec.FindFirst() then begin
                        if Rec."Notice Type" = Rec."Notice Type"::"1st" then
                            REPORT.Run(Report::"Defaulter 1st Notice", true, false, Rec)
                        else if Rec."Notice Type" = Rec."Notice Type"::"2nd" then
                            REPORT.Run(Report::"Defaulter 2nd Notice", true, false, Rec)
                        else if Rec."Notice Type" = Rec."Notice Type"::"3rd" then REPORT.Run(Report::"Defaulter 3rd Notice", true, false, Rec);
                    end;
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        ControlApprearance;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        ControlApprearance;
    end;

    trigger OnOpenPage()
    begin
        ControlApprearance;
    end;

    local procedure ControlApprearance()
    var
        myInt: Integer;
    begin
        case Rec."Notice Type" of
            Rec."Notice Type"::"1st":
                StyleText := 'StrongAccent';
            Rec."Notice Type"::"2nd":
                StyleText := 'Ambiguous';
            Rec."Notice Type"::"3rd":
                StyleText := 'Attention';
        end;
    end;

    var
        StyleText: Text[100];
}

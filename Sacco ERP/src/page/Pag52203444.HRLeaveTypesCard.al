page 52203444 "HR Leave Types Card"
{
    PageType = Card;
    SourceTable = "Leave Types";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Days; Rec.Days)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Gender; Rec.Gender)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Unlimited Days"; Rec."Unlimited Days")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Inclusive of Non Working Days"; Rec."Inclusive of Non Working Days")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Max Carry Forward Days"; Rec."Max Carry Forward Days")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Is Annual Leave"; Rec."Is Annual Leave")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Carry Forward Allowed"; Rec."Carry Forward Allowed")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Acrue Days"; Rec."Acrue Days")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Leave Day Worth($$)"; Rec."Leave Day Worth($$)")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Special Categorization"; Rec."Special Categorization")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Max Applicable Days"; Rec."Max Applicable Days")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Leave Balance Notification"; Rec."Leave Balance Notification")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Requires Attachment"; Rec."Requires Attachment")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Check Leave Balance"; Rec."Check Leave Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Is Sick Leave"; Rec."Is Sick Leave")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Leave Days To Accrue Matrix")
            {
                ApplicationArea = Basic, Suite;
                Enabled = AccrualMatrixVisible;
                Image = DataEntry;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Leave Days To Accrue Matrix";
                RunPageLink = "Leave Type"=FIELD(Code);
            }
            action("Attachements Needed")
            {
                ApplicationArea = Basic, Suite;
                Image = Document;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Leave Type Attachement Names";
                RunPageLink = "Leave Code"=FIELD(Code);
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
    end;
    var[InDataSet]
    CarryForwardVisible: Boolean;
    AccrualMatrixVisible: Boolean;
    UserSetup: Record "User Setup";
    local procedure SetVisible()
    begin
        //Dann - To hide fields to prevent setup errors and hide uneccessary fields
        CarryForwardVisible:=false;
        case Rec.Balance of Rec.Balance::"Carry Forward": begin
            CarryForwardVisible:=true;
        end;
        end;
        AccrualMatrixVisible:=false;
        if Rec."Acrue Days" then AccrualMatrixVisible:=true end;
}

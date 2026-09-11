page 52203914 "Vehicle Insurance Card"
{
    ApplicationArea = All;
    PageType = Card;
    SourceTable = "Vehicle Insurance";
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Insurance No."; Rec."Insurance No.")
                {
                    ApplicationArea = All;
                }
                field("Vehicle REG. No."; Rec."Vehicle REG. No.")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Insurance Company Code"; Rec."Insurance Company Code")
                {
                    ApplicationArea = All;
                }
                field("Insurance Company Name"; Rec."Insurance Company Name")
                {
                    ApplicationArea = All;
                }
                field("Type Of Cover"; Rec."Type Of Cover")
                {
                    ApplicationArea = All;
                }
                field("Insurance Date"; Rec."Insurance Date")
                {
                    ApplicationArea = All;
                }
                field("Insurance Period"; Rec."Insurance Period")
                {
                    ApplicationArea = All;
                }
                field("Insurance Expiry Date"; Rec."Insurance Expiry Date")
                {
                    ApplicationArea = All;
                }
                field("Insurance Amount"; Rec."Insurance Amount")
                {
                    ApplicationArea = All;
                }
                field(Expired; Rec.Expired)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(Post)
            {
                ApplicationArea = All;
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not Confirm('Are you sure you want to post the insurance expense?')then exit;
                    Rec.Reset;
                    Rec.SetRange("No.", Rec."No.");
                    if Rec.FindFirst then begin
                        Rec.TestField("Posting Date");
                        Rec.TestField("Insurance Company Code");
                        Rec.TestField("Insurance Amount");
                        Rec.TestField("Vehicle REG. No.");
                        FleetManagement.PostVehicleExpenses(Rec."Posting Date", Rec."Transaction Type", Rec."No.", Rec."Insurance Company Name", Rec."Insurance Amount", Rec."Insurance Amount", Rec."Vehicle REG. No.");
                        Rec.Posted:=true;
                        Rec.Modify(true);
                    end;
                    CurrPage.Close;
                end;
            }
        }
    }
    var FleetManagement: Codeunit "Fleet Management";
}

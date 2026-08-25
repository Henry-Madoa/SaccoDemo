page 52204099 "ATM Cards"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "ATM Cards";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Card No."; MemberMgt.MaskCardNo(Rec."Card No."))
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Added By"; Rec."Added By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Added On"; Rec."Added On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Assigned To Member No."; Rec."Assigned To Member No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Assigned to Account No"; Rec."Assigned to Account No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Assigned By"; Rec."Assigned By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Assigned On"; Rec."Assigned On")
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
            action("Update ATM Cards")
            {
                ApplicationArea = Basic, Suite;
                Image = PostBatch;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                Visible = false;

                trigger OnAction()
                begin
                    MemberMgt.UpdateATMCards;
                end;
            }
            action("Update ATM Card")
            {
                ApplicationArea = Basic, Suite;
                Image = PostBatch;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                Visible = false;

                trigger OnAction()
                var
                    Vendor: array[2] of Record Vendor;
                begin
                    Vendor[1].Reset();
                    Vendor[1].SetRange("Member No.", Rec."Assigned To Member No.");
                    Vendor[1].SetRange("Product Posting Type", Vendor[1]."Product Posting Type"::"Withdrawable Deposit");
                    if Vendor[1].FindFirst() then begin
                        Vendor[1]."Card No" := Rec."Card No.";
                        Vendor[1].Modify();
                        Rec."Assigned By" := UserId;
                        Rec."Assigned On" := CurrentDateTime;
                        Rec.Status := Rec.Status::Transacting;
                        Rec.Modify(true);
                        Message('Done');
                    end;
                end;
            }
        }
    }
    var
        MemberMgt: Codeunit "Member Management";
}

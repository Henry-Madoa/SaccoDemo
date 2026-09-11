pageextension 52203439 "Purchase Quote Card" extends "Purchase Quote"
{
    layout
    {
        // Add changes to page layout here
        addafter(Status)
        {
            field("RFQ Status"; Rec."RFQ Status")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
            }
        }
        //FactboxesArea
        addfirst(factboxes)
        {
            part("Approval Entries"; "Customize Approval Entries")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Approval Entries';
                SubPageLink = "Table ID" = CONST(38), "Document Type" = filter(Quote), "Document No." = FIELD("No.");
            }
        }
    }
    actions
    {
        // Add changes to page actions here   
        addbefore("Make order")
        {
            action(Return)
            {
                ApplicationArea = Basic, Suite;
                Image = Return;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = page "Purchaser Response";
                //RunPageLink =
            }
            action(Accept)
            {
                ApplicationArea = Basic, Suite;
                Image = Action;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = page "Purchaser Response";
                //RunPageLink =
            }
            action("Reject-Quote")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Reject';
                Image = Reject;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = page "Purchaser Response";
                //RunPageLink =
            }
        }
    }
}

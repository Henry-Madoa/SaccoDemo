page 52204071 "Receive From Bank"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate';
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "FOSA Transactions";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Editable = not Rec.Posted;

                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("&Denominations"; Rec.Denominations)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group("Source")
            {
                Editable = not Rec.Posted;

                field("Source No"; Rec."Source No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Source Name"; Rec."Source Name")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group(Destination)
            {
                Editable = false;

                field("Destination No"; Rec."Destination No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Destination Name"; Rec."Destination Name")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part(Denominations; "Transaction Denominations")
            {
                Editable = not Rec.Posted;
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "Document Type" = field("Document Type"), "No." = field("No.");
            }
            group("Audit Trail")
            {
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posted By"; Rec."Posted By")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(Navigate)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Find entries...';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Category9;
                ShortCutKey = 'Shift+Ctrl+I';
                ToolTip = 'Find entries and documents that exist for the document number and posting date on the selected document. (Formerly this action was named Navigate.)';
                Visible = Rec.Posted;

                trigger OnAction()
                begin
                    Rec.Navigate;
                end;
            }
        }
        area(Processing)
        {
            action(Post)
            {
                Promoted = true;
                Image = Post;
                PromotedIsBig = true;
                PromotedCategory = Process;
                ApplicationArea = Basic, Suite;
                Visible = not Rec.Posted;

                trigger OnAction()
                var
                    FOSA: Codeunit "FOSA Management";
                begin
                    if not Confirm('Do You want to Post?') then begin
                        CurrPage.Close();
                    end;
                    FOSA.PostFOSATransaction(Rec);
                end;
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Document Type" := Rec."Document Type"::"Receive From Bank";
    end;
}

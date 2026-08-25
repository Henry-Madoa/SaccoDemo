page 52204263 "Member Charging"
{
    PromotedActionCategories = 'New,Process,Report,Approval,Manual Approval,Request Approval,Workflow,Attachments,Navigate';
    PageType = Card;
    SourceTable = "Member Charging";

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = not Rec.Posted;

                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    MultiLine = true;
                    ShowMandatory = true;
                }
                field("Member No."; Rec."Member No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Source Balance"; Rec."Source Balance")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Charge Code"; Rec."Charge Code")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
                group(NoOfPages)
                {
                    ShowCaption = false;
                    Visible = Rec."Posting Transaction Type" = Rec."Posting Transaction Type"::"Statement Charge";

                    field("No Of Pages"; Rec."No Of Pages")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                field("Amount Charged"; Rec."Amount Charged")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group(Audit)
            {
                Editable = false;

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
                field("Posted By"; Rec."Posted By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Posted On"; Rec."Posted On")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        area(FactBoxes)
        {
            part("Member Statistics"; "Member Statistics")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("Member No.");
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
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
        area(processing)
        {
            action(Post)
            {
                ApplicationArea = Basic, Suite;
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = not Rec.Posted;

                trigger OnAction()
                begin
                    FOSAManagement.PostMemberCharges(Rec."No.");
                end;
            }
        }
    }
    var
        FOSAManagement: Codeunit "FOSA Management";
}

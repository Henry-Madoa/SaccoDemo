page 52204214 "Share Floatings"
{
    CardPageID = "Share Floating";
    PageType = List;
    SourceTable = "Share Floating";
    SourceTableView = WHERE(Archived=CONST(false), Published=CONST(false));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No."; Rec."Document No")
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
                field("Share Type"; Rec."Share Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Par Value"; Rec."Par Value")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Shares"; Rec."Total Shares")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Minimum Acceptable Price"; Rec."Minimum Acceptable Price")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Shares to Float"; Rec."Shares to Float")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Published; Rec.Published)
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("Published On"; Rec."Published On")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("Exiry Date"; Rec."Exiry Date")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            part(Control13; "Vendor Statistics FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No."=FIELD("Account No.");
            }
            part(Control15; "Member Profile Picture")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No."=FIELD("Member No.");
            }
        }
    }
}

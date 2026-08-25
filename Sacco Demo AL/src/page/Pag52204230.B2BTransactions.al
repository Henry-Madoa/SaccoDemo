page 52204230 "B2B Transactions"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "B2B Transactions";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No"; Rec."Entry No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Transaction Refrence"; Rec."Transaction Refrence")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Transaction Date"; Rec."Transaction Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Currency; Rec.Currency)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Document Refrence"; Rec."Document Refrence")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Bank Code"; Rec."Bank Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Branch Code"; Rec."Branch Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Date"; Rec."Payment Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Refrence Code"; Rec."Payment Refrence Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Code"; Rec."Payment Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Mode"; Rec."Payment Mode")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Amount"; Rec."Payment Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account Number"; Rec."Account Number")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Institution Code"; Rec."Institution Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Institution Name"; Rec."Institution Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Additional Info"; Rec."Additional Info")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Processed; Rec.Processed)
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
            action(Archive)
            {
                ApplicationArea = Basic, Suite;
                Image = AdjustEntries;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Rec.TestField(Processed, false);
                    if CONFIRM('Do you want to archive?') then begin
                        Rec.Archived := true;
                        Rec.Status := Rec.Status::Incomplete;
                        Rec.Comments := 'Archived by ' + USERID + ' on ' + FORMAT(CURRENTDATETIME);
                        Rec.MODIFY;
                    end;
                end;
            }
        }
    }
}

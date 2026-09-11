page 52204254 Release
{
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Custodial Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = IsEditable;

                field("Collected By"; Rec."Collected By")
                {
                    ShowMandatory = true;
                }
                field("Collected By ID  No"; Rec."Collected By ID  No")
                {
                    ShowMandatory = true;
                }
                field("Collected By Phone No"; Rec."Collected By Phone No")
                {
                    ShowMandatory = true;
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Source Account No"; Rec."Source Account No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Amount Expected"; Rec."Amount Expected")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Amount Paid"; Rec."Amount Paid")
                {
                    trigger OnValidate()
                    begin
                        Rec.CALCFIELDS("Amount Expected");
                        Rec.TESTFIELD("Amount Expected", Rec."Amount Paid");
                    end;
                }
                field("Payment Method"; Rec."Payment Method")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Refrence"; Rec."Payment Refrence")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Payment Date"; Rec."Payment Date")
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
            }
            group("Audit Trail")
            {
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Document Status"; Rec."Document Status")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
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
            action("Post Release")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                Image = Apply;

                trigger OnAction()
                begin
                    //Rec.TESTFIELD("R: Approval Status", Rec."R: Approval Status"::Approved);
                    Rec.CALCFIELDS("Amount Expected");
                    Rec.TESTFIELD("Amount Expected", Rec."Amount Paid");
                    CustodialManagement.PostCustodialReceipt(Rec);
                    CurrPage.CLOSE;
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        if Rec."Created By" = '' then begin
            Rec."Created By" := USERID;
            Rec.MODIFY;
        end;
        IsEditable := (Rec.Status = Rec.Status::Open);
    end;

    trigger OnOpenPage()
    begin
        IsEditable := (Rec.Status = Rec.Status::Open);
    end;

    var
        CustodialManagement: Codeunit "Custodial Management";
        IsEditable: Boolean;
}

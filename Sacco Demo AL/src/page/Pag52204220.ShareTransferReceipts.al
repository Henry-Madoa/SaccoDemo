page 52204220 "Share Transfer Receipts"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Share Transfer Receipt";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Refrence No."; Rec."Refrence No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Original Amount"; Rec."Original Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Remaining Amount"; Rec."Remaining Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Allocated Amount"; Rec."Allocated Amount")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Account No."; Rec."Account No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                }
                field("Account Name"; Vendor.Name)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
            }
        }
    }
    trigger OnAfterGetRecord();
    begin
        if Vendor.GET(Rec."Account No.") then;
    end;

    var
        Vendor: Record Vendor;
}

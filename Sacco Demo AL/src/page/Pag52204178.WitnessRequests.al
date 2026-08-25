page 52204178 "Witness Requests"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Channel Guarantor Requests";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    SourceTableView = where("Request Type" = const(Witness));

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("ID No"; Rec."ID No")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isWindowsClient;
                }
                field("Member No"; Rec."Member No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isWindowsClient;
                }
                field(PhoneNo; Rec.PhoneNo)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isWindowsClient;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isWindowsClient;
                }
                field(AppliedAmount; Rec.AppliedAmount)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isWindowsClient;
                }
                field("Rejection Reason"; Rec."Rejection Reason")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isWindowsClient;
                }
                field("Amount Accepted"; Rec."Amount Accepted")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isWindowsClient;
                }
                field("Requested Amount"; Rec."Requested Amount")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isWindowsClient;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isWindowsClient;
                }
                field("Responded On"; Rec."Responded On")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = isWindowsClient;
                }
            }
        }
    }
    var
        isWindowsClient: Boolean;

    trigger OnOpenPage()
    begin
        if CurrentClientType <> ClientType::Windows then isWindowsClient := true;
    end;
}

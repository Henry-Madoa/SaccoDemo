page 52203904 "WkTkt Form Request - Completed"
{
    ApplicationArea = All;
    Caption = 'WorkTicket Form Request - Completed';
    CardPageID = "WorkTicket Form Request Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';
    SourceTable = "WorkTicket Form Request";
    SourceTableView = WHERE(Status=CONST(Approved), Completed=CONST(true));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Driver Name"; Rec."Driver Name")
                {
                    ApplicationArea = All;
                }
                field("Vehicle REG. No."; Rec."Vehicle REG. No.")
                {
                    ApplicationArea = All;
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                }
                field(Station; Rec.Station)
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
    }
}

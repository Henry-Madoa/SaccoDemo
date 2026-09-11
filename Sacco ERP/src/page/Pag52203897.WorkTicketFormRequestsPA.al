page 52203897 "WorkTicket Form Requests - PA"
{
    ApplicationArea = All;
    Caption = 'WorkTicket Form Request - Pending A';
    CardPageID = "WorkTicket Form Request Card";
    PageType = List;
    SourceTable = "WorkTicket Form Request";
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';
    SourceTableView = WHERE(Status=CONST("Pending Approval"));

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

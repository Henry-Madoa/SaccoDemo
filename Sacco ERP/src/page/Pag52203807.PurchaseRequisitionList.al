page 52203807 "Purchase Requisition List"
{
    CardPageID = "Purchase Requisition Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Requisition Header";
    SourceTableView = WHERE("Requisition Type"=CONST("Purchase Requisition"));

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
                field("Employee No"; Rec."Employee No.")
                {
                    ApplicationArea = All;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = All;
                }
                field("Title"; Rec.Title)
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
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
    trigger OnAfterGetCurrRecord()
    begin
        //        if not IanSoftFactory.IanIsWebServiceUser(UserId) then begin
        if UserSetup.Get(UserId)then begin
            if not(UserSetup."Is Store Admin")then Rec.SetRange("Created By", UserId);
        end;
    //        end;
    end;
    trigger OnOpenPage()
    begin
        //        if not IanSoftFactory.IanIsWebServiceUser(UserId) then begin
        if UserSetup.Get(UserId)then begin
            if not(UserSetup."Is Store Admin")then Rec.SetRange("Created By", UserId);
        end;
    //        end;
    end;
    var UserSetup: Record "User Setup";
//        IanSoftFactory: Codeunit IanSoftFactory;
}

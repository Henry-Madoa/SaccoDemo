page 52203802 "App. Purch. Requisition List"
{
    // zz
    CardPageID = "Purchase Requisition Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Requisition Header";
    SourceTableView = WHERE("Requisition Type"=CONST("Purchase Requisition"), Status=CONST(Approved), "Process Initiated"=CONST(false));

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
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Created On"; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
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
        //     if not IanSoftFactory.IanIsWebServiceUser(UserId) then begin
        if UserSetup.Get(UserId)then begin
            if not(UserSetup."Is Store Admin")then Rec.SetRange("Created By", UserId);
        end;
    //     end;
    // IF UserSetup.GET(USERID) THEN
    //  IF NOT UserSetup."Is System Admin" THEN BEGIN
    //  IF NOT UserSetup."Payables User" THEN
    //    BEGIN
    //    FILTERGROUP(2);
    //    SETRANGE("Created By",USERID);
    //    FILTERGROUP(0);
    //    END ELSE IF (UserSetup."Payables User") AND (UserSetup."Additional Program"='') THEN
    //    BEGIN
    //        FILTERGROUP(2);
    //        SETRANGE("Global Dimension 1 Code",UserSetup."Global Dimension 1 Code");
    //        FILTERGROUP(0)
    //      END ELSE
    //         IF (UserSetup."Payables User") AND (UserSetup."Additional Program"<>'') THEN
    //           BEGIN
    //             FILTERGROUP(2);
    //             SETFILTER("Global Dimension 1 Code",'%1|%2',UserSetup."Global Dimension 1 Code",UserSetup."Additional Program");
    //             FILTERGROUP(0);
    //             END;
    //             END;
    end;
    trigger OnOpenPage()
    begin
        //    if not IanSoftFactory.IanIsWebServiceUser(UserId) then begin
        if UserSetup.Get(UserId)then begin
            if not(UserSetup."Is Store Admin")then Rec.SetRange("Created By", UserId);
        end;
    //    end;
    // IF UserSetup.GET(USERID) THEN
    //  IF NOT UserSetup."Is System Admin" THEN BEGIN
    //  IF NOT UserSetup."Payables User" THEN
    //    BEGIN
    //    FILTERGROUP(2);
    //    SETRANGE("Created By",USERID);
    //    FILTERGROUP(0);
    //    END ELSE IF (UserSetup."Payables User") AND (UserSetup."Additional Program"='') THEN
    //    BEGIN
    //        FILTERGROUP(2);
    //        SETRANGE("Global Dimension 1 Code",UserSetup."Global Dimension 1 Code");
    //        FILTERGROUP(0)
    //      END ELSE
    //         IF (UserSetup."Payables User") AND (UserSetup."Additional Program"<>'') THEN
    //           BEGIN
    //             FILTERGROUP(2);
    //             SETFILTER("Global Dimension 1 Code",'%1|%2',UserSetup."Global Dimension 1 Code",UserSetup."Additional Program");
    //             FILTERGROUP(0);
    //             END;
    //             END;
    end;
    var UserSetup: Record "User Setup";
    ProcurementSetup: Record "Purchases & Payables Setup";
//      IanSoftFactory: Codeunit IanSoftFactory;
}

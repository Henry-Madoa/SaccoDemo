page 52203804 "Store Requisition List"
{
    CardPageID = "Store Requisition Card";
    PageType = List;
    SourceTable = "Requisition Header";
    SourceTableView = WHERE("Requisition Type"=CONST("Store Requisition"), Status=CONST(Open));

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
                field("Global Dimension 3 Code"; Rec."Global Dimension 3 Code")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = All;
                }
                field("Requisition Type"; Rec."Requisition Type")
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
        //    if not IanSoftFactory.IanIsWebServiceUser(UserId) then begin
        if UserSetup.Get(UserId)then begin
            if not(UserSetup."Is Store Admin")then Rec.SetRange("Created By", UserId);
        end;
    //    end;
    // IF UserSetup.GET(USERID) THEN
    //  IF NOT (UserSetup."Payables User") OR (UserSetup."Is System Admin") OR (Rec."Created By" <> USERID) THEN
    //    BEGIN
    //      FILTERGROUP(2);
    //      SETRANGE("Created By",USERID);
    //      FILTERGROUP(0);
    //      END ELSE
    //        IF UserSetup."Payables User" AND (UserSetup."Additional Program"='') THEN
    //          BEGIN
    //            FILTERGROUP(2);
    //            SETRANGE("Global Dimension 1 Code",UserSetup."Global Dimension 1 Code");
    //            FILTERGROUP(0);
    //            END ELSE
    //            IF (UserSetup."Payables User") AND (UserSetup."Additional Program"<>'') THEN
    //              BEGIN
    //                FILTERGROUP(2);
    //                SETFILTER("Global Dimension 1 Code",'%1|%2',UserSetup."Global Dimension 1 Code",UserSetup."Additional Program");
    //                FILTERGROUP(0);
    //                END;
    end;
    trigger OnOpenPage()
    begin
        // IF NOT IanSoftFactory.IanIsWebServiceUser(USERID) THEN
        //  BEGIN
        if UserSetup.Get(UserId)then begin
            if not(UserSetup."Is Store Admin")then Rec.SetRange("Created By", UserId);
        end;
    // END;
    // IF UserSetup.GET(USERID) THEN
    //  IF NOT (UserSetup."Payables User") OR (UserSetup."Is System Admin") OR (Rec."Created By" <> USERID) THEN
    //    BEGIN
    //      FILTERGROUP(2);
    //      SETRANGE("Created By",USERID);
    //      FILTERGROUP(0);
    //      END ELSE
    //        IF UserSetup."Payables User" AND (UserSetup."Additional Program"='') THEN
    //          BEGIN
    //            FILTERGROUP(2);
    //            SETRANGE("Global Dimension 1 Code",UserSetup."Global Dimension 1 Code");
    //            FILTERGROUP(0);
    //            END ELSE
    //            IF (UserSetup."Payables User") AND (UserSetup."Additional Program"<>'') THEN
    //              BEGIN
    //                FILTERGROUP(2);
    //                SETFILTER("Global Dimension 1 Code",'%1|%2',UserSetup."Global Dimension 1 Code",UserSetup."Additional Program");
    //                FILTERGROUP(0);
    //                END;
    end;
    var UserSetup: Record "User Setup";
//       IanSoftFactory: Codeunit IanSoftFactory;
}

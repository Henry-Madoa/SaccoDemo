page 52204017 "Member Accounts"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = Vendor;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    SourceTableView = where("Account Type" = filter(Sacco | loan), Balance = filter(<> 0));

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Member No."; Rec."Member No.")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                    Visible = isWebservice;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field(Balance; Rec.Balance)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Account Class"; Rec."Product Posting Type")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Product Code"; Rec."Product Code")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Card No"; MemberMgt.MaskCardNo(Rec."Card No"))
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Cash Transfer Allowed"; Rec."Cash Transfer Allowed")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    var
        StyleText: Text[100];
        MemberMgt: Codeunit "Member Management";

    trigger OnAfterGetRecord()
    begin
        if Rec."Product Posting Type" = Rec."Product Posting Type"::"Loan Account" then
            StyleText := 'Ambiguous'
        else if Rec."Product Posting Type" = Rec."Product Posting Type"::"Fixed Deposit Account" then
            StyleText := 'StrongAccent'
        else
            StyleText := 'Favorable';
        if Rec.Blocked = Rec.Blocked::All then StyleText := 'Unfavorable';
        isWebService := LoginMgmt.IsWebServiceUser;
    end;

    trigger OnOpenPage()
    begin
        isWebService := LoginMgmt.IsWebServiceUser;
    end;

    var
        isWebService: Boolean;
        LoginMgmt: Codeunit "User Management Ext";
}

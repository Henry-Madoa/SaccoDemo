page 52204129 "Economic Sub-Subsectors"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Economic Sub-subsector";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Sector Code"; Rec."Sector Code")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = isWebService;
                }
                field("Sub Sector Code"; Rec."Sub Sector Code")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = isWebService;
                }
                field("Sub-Subsector Code"; Rec."Sub-Subsector Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Sub-Subsector Description"; Rec."Sub-Subsector Description")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
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

page 52204128 "Economic Subsectors"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Economic Subsectors";

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
                }
                field("Sub Sector Name"; Rec."Sub Sector Name")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Sub Subsectors")
            {
                ApplicationArea = Basic, Suite;
                Image = StepInto;
                RunObject = page "Economic Sub-Subsectors";
                RunPageLink = "Sector Code" = field("Sector Code"), "Sub Sector Code" = field("Sub Sector Code");
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

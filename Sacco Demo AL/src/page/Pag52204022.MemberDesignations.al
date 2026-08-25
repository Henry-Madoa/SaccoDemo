page 52204022 "Member Designations"
{
    PageType = List;
    SourceTable = "Member Designation";
    Caption = 'Designations';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Type; Rec.Type)
                {
                    Visible = isWebService;
                    ApplicationArea = Basic, Suite;
                }
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
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

page 52203951 "Job Requirements"
{
    PageType = ListPart;
    SourceTable = "Job Requirements";
    Caption = 'Requirements';

    layout
    {
        area(content)
        {
            repeater(Control6)
            {
                field("Job Id"; Rec."Job Id")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = IsVisible;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    // trigger OnOpenPage()
    // begin
    //     if LoginMgmt.IsWebServiceUser(UserId) then
    //         IsVisible := true
    //     else
    //         IsVisible := false;
    // end;
    var IsVisible: Boolean;
}

page 52203644 "Exit Clearance Form Lines"
{
    Caption = 'Clearance Details';
    PageType = ListPart;
    SourceTable = "Exit Clearance Form Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Clearance Section"; Rec."Clearance Section")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Clearance Section Name"; Rec."Clearance Section Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Clearance Item"; Rec."Clearance Item")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Returned; Rec.Returned)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Number; Rec.Number)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Item Worth"; Rec."Item Worth")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee no"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = IsPageEditable;
                }
                field("Exit no"; Rec."Exit No")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = IsPageEditable;
                }
                field("Line No"; Rec."Line No")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = IsPageEditable;
                }
                field("Form No"; Rec."Form No")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = IsPageEditable;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        SetControlAppearance;
    end;
    var LoginMgmt: Codeunit "User Management Ext";
    IsPageEditable: Boolean;
    local procedure SetControlAppearance()
    begin
        if LoginMgmt.IsWebServiceUser then IsPageEditable:=true
        else
            IsPageEditable:=false;
    end;
}

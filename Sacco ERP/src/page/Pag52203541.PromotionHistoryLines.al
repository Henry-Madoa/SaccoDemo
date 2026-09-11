page 52203541 "Promotion History Lines"
{
    Editable = false;
    PageType = ListPart;
    SourceTable = "Promotion History";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("Salary Scale"; Rec."Salary Scale")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Salary Pointer"; Rec."Salary Pointer")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(LengthOfService; LengthOfService)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Position Length Of Service';
                    Editable = false;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        LengthOfService:='';
        if(Rec."End Date" <> 0D)then begin
            if(Rec."Start Date" <> 0D)then LengthOfService:=Dates.DetermineDatesDiffrence(Rec."Start Date", Rec."End Date");
        end
        else
        begin
            if(Rec."Start Date" <> 0D)then LengthOfService:=Dates.DetermineDatesDiffrence(Rec."Start Date", Today);
        end;
    end;
    trigger OnOpenPage()
    begin
        LengthOfService:='';
        if(Rec."End Date" <> 0D)then begin
            if(Rec."Start Date" <> 0D)then LengthOfService:=Dates.DetermineDatesDiffrence(Rec."Start Date", Rec."End Date");
        end
        else
        begin
            if(Rec."Start Date" <> 0D)then LengthOfService:=Dates.DetermineDatesDiffrence(Rec."Start Date", Today);
        end;
    end;
    var Dates: Codeunit "HR Dates";
    LengthOfService: Text[100];
}

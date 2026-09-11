page 52203543 "Outsourcing Setup"
{
    // version THL- Client Payroll 1.0PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Outsourcing Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Primary Key"; Rec."Primary Key")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("Employee Import Nos."; Rec."Employee Import Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Leave Nos."; Rec."Employee Leave Nos.")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    trigger OnOpenPage()
    var
        OutsourcingSetup: Record "Outsourcing Setup";
    begin
        if OutsourcingSetup.IsEmpty then begin
            OutsourcingSetup.Init();
            OutsourcingSetup.Insert(true);
        end;
    end;
}

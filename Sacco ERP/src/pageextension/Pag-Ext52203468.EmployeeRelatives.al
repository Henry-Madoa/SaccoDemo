pageextension 52203468 "Employee Relatives" extends "Employee Relatives"
{
    layout
    {
        // Add changes to page layout here  
        addafter("Middle Name")
        {
            field("Last Name"; Rec."Last Name")
            {
                ApplicationArea = Basic, Suite;
            }
        }
        modify("Middle Name")
        {
            Visible = true;
        }
    }
}

pageextension 52203476 "Reverse Transaction Entr." extends "Reverse Transaction Entries"
{
    actions
    {
        modify(Reverse)
        {
            trigger OnBeforeAction()
            var
                UserSetup: Record "User Setup";
            begin
                If UserSetup.Get(UserId)then UserSetup.TestField("Can Auto Reverse");
            end;
        }
        modify("Reverse and &Print")
        {
            trigger OnBeforeAction()
            var
                UserSetup: Record "User Setup";
            begin
                If UserSetup.Get(UserId)then UserSetup.TestField("Can Auto Reverse");
            end;
        }
    }
}

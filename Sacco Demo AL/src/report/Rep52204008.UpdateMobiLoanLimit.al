report 52204008 "Update Mobi Loan Limit"
{
    ProcessingOnly = true;
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    field(Current; Current)
                    {
                        Caption = 'Current Limit';
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field(NewAmount; NewAmount)
                    {
                        Caption = 'New Limit';
                        ShowMandatory = true;
                        ApplicationArea = All;
                    }
                }
            }
        }
    }

    var
        Current, NewAmount : Decimal;
        MemberNo: Code[20];
        Member: Record Members;
        UserSetup: Record "User Setup";


    trigger OnPostReport()
    begin
        if Member.Get(MemberNo) then begin
            if Confirm(StrSubstNo('You are about to update %1 Mobi Allocation From %2 to %3. \\Do you wish to continue?', Member."First Name", Current, NewAmount)) then begin
                Member."Mobi Loan Limit" := NewAmount;
                Member.Modify(true);
            end;
        end;
    end;

    procedure SetCurrentDetails(MemNo: Code[20]; CurAmount: Decimal)
    begin
        UserSetup.Get(UserId);
        if not UserSetup."Can M-Allocate" then
            Error('You are not permitted to perform this action, Kindly contact Admin.');
        MemberNo := MemNo;
        Current := CurAmount;
    end;
}

pageextension 52203430 "Approval User Setup" extends "Approval User Setup"
{
    Editable = false;

    layout
    {
        // Add changes to page layout here
        modify(Substitute)
        {
            Visible = false;
        }
        modify("E-Mail")
        {
            Editable = false;
        }
        modify(PhoneNo)
        {
            Editable = false;
        }
        addafter(PhoneNo)
        {
            field(Signature; Rec.Signature)
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addafter("Notification Setup")
        {
            action("Update Signature")
            {
                ApplicationArea = Suite;
                Image = Signature;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    UpdateSignature(Rec);
                end;
            }
        }
    }
    local procedure UpdateSignature(UserSetup: Record "User Setup")
    var
        DialogTitle: Label 'Please select a signature...';
        PathToFile: Text;
        FileMgmt: Codeunit "File Management";
    begin
        PathToFile := FileMgmt.UploadFile(DialogTitle, '');
        if PathToFile <> '' then begin
            if UserSetup.Signature.HasValue then begin
                if Confirm('You are about to Update the Current Signature, Do you wish to continue?', false) then UserSetup.Signature.Import(PathToFile);
            end
            else
                UserSetup.Signature.Import(PathToFile);
        end
        else begin
            if UserSetup.Signature.HasValue then begin
                if Confirm('You are about to Clear the Current Signature, Do you wish to continue?', false) then begin
                    UserSetup.CalcFields(Signature);
                    Clear(UserSetup.Signature);
                end;
            end;
        end;
        UserSetup.Modify;
    end;
}

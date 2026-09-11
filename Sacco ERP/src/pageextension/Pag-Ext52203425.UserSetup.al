pageextension 52203425 "User Setup" extends "User Setup"
{
    layout
    {
        modify(Email)
        {
            Visible = false;
        }
        modify(PhoneNo)
        {
            Visible = false;
        }
        modify("Allow Posting From")
        {
            Visible = false;
        }
        modify("Allow Posting To")
        {
            Visible = false;
        }
        modify("Allow VAT From")
        {
            Visible = false;
        }
        modify("Allow VAT To")
        {
            Visible = false;
        }
        modify("Allow Deferral Posting From")
        {
            Visible = false;
        }
        modify("Allow Deferral Posting To")
        {
            Visible = false;
        }
        modify("Sales Invoice Posting Policy")
        {
            Visible = false;
        }
        modify("Purch. Invoice Posting Policy")
        {
            Visible = false;
        }
        modify("Service Invoice Posting Policy")
        {
            Visible = false;
        }
        modify("Register Time")
        {
            Visible = false;
        }
        modify("Salespers./Purch. Code")
        {
            Visible = false;
        }
        modify("Sales Resp. Ctr. Filter")
        {
            Visible = false;
        }
        modify("Purchase Resp. Ctr. Filter")
        {
            Visible = false;
        }
        modify("Service Resp. Ctr. Filter")
        {
            Visible = false;
        }
        modify("Time Sheet Admin.")
        {
            Visible = false;
        }
        addafter("User ID")
        {
            field("Employee No."; Rec."Employee No.")
            {
                ApplicationArea = Basic, Suite;
            }
            field("&Allow Posting From"; Rec."Allow Posting From")
            {
                ApplicationArea = Basic, Suite;
            }
            field("&Allow Posting To"; Rec."Allow Posting To")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Approver ID"; Rec."Approver ID")
            {
                ApplicationArea = Basic, Suite;
            }
            field("E-Mail"; Rec."E-Mail")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
            }
            field("Phone No."; Rec."Phone No.")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
            }
            field("In Management"; Rec."In Management")
            {
                ApplicationArea = Basic, Suite;
            }
            field(CEO; Rec.CEO)
            {
                ApplicationArea = Basic, Suite;
            }
            field("Is HOD"; Rec."Is HOD")
            {
                ApplicationArea = Basic, Suite;
            }
            field("HR Admin"; Rec."HR Admin")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Finance Admin"; Rec."Finance Admin")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Procurement Admin"; Rec."Procurement Admin")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Store Admin"; Rec."Store Admin")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Apply Leave Later Dater"; Rec."Apply Leave Later Dater")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Payroll Admin"; Rec."Payroll Admin")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Is System Admin"; Rec."Is System Admin")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Head of Department"; Rec."Head of Department")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Head of Branch"; Rec."Head of Branch")
            {
                ApplicationArea = All;
            }
            field("Line Manager"; Rec."Line Manager")
            {
                ApplicationArea = Basic, Suite;
            }
            field("User Signature"; Rec.Signature)
            {
                ApplicationArea = Basic, Suite;
            }
            field("Approval Administrator"; Rec."Approval Administrator")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    actions
    {
        addlast(Navigation)
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
                if Confirm('You are about to Update the Current Signature, Do you wish to continue?', false) then
                    UserSetup.Signature.Import(PathToFile);
            end
            else
                UserSetup.Signature.Import(PathToFile);
        end else begin
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

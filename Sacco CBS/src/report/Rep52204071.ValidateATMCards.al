report 52204071 "Validate ATM Cards"
{
    UsageCategory = Administration;
    Caption = 'Validate ATM Cradc';
    ApplicationArea = Basic, Suite;
    ProcessingOnly = true;

    //RDLCLayout = './ssrs/ssrs/LoanRepayment.rdl';
    dataset
    {
        dataitem("ATM Application"; "ATM Application")
        {
            trigger OnAfterGetRecord()
            begin
                GenLegSet.get;
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
                ObjMember.reset;
                ObjMember.SetRange(ObjMember."No.", "ATM Application"."Member No");
                if ObjMember.findset then begin
                    ObjMember.Validate("No.");
                    ObjMember.modify;
                end;
            end;
        }
    }
    var
        CompanyInformation: Record "Company Information";
        Members: Record Members;
        MemberName: Text;
        ObjCheck: Codeunit "Amount To Words";
        AmountInWords: array[2] of Text[80];
        GenLegSet: Record "General Ledger Setup";
        ObjMember: Record Members;
}

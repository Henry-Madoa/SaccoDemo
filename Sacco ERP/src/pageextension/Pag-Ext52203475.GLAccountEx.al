pageextension 52203475 "G/LAccountEx" extends "G/L Account Card"
{
    layout
    {
        modify("No.")
        {
            Editable = EditableX;
        }
        modify("Income/Balance")
        {
            Editable = EditableX;
        }
        modify("Account Category")
        {
            Editable = EditableX;
        }
        modify("Debit/Credit")
        {
            Editable = EditableX;
        }
        modify("Direct Posting")
        {
            Editable = EditableX;
        }
        modify(Posting)
        {
            Editable = EditableX;
        }
    }
    trigger OnAfterGetCurrRecord()
    var
        myInt: Integer;
    begin
        GlEntryEdit();
    end;
    trigger OnOpenPage()
    var
        myInt: Integer;
    begin
        GlEntryEdit();
    end;
    local procedure GlEntryEdit()
    var
        GLEntry: Record "G/L Entry";
    begin
        EditableX:=true;
        GLEntry.Reset();
        GLEntry.SetRange("G/L Account No.", Rec."No.");
        if GLEntry.FindFirst()then EditableX:=false;
    end;
    var EditableX: Boolean;
}

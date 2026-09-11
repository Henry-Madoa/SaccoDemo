tableextension 52203466 "Bank Stataement" extends "Bank Account Statement"
{
    fields
    {
    }
    trigger OnBeforeDelete()
    begin
        Error('Delete is Not Allowed on Posted Documents!');
    end;
}

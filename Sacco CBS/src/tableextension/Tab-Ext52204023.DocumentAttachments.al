tableextension 52204023 "Document Attachments" extends "Document Attachment"
{
    fields
    {
        field(52204000; "Sharepoint Link"; Text[2000])
        {
            ExtendedDatatype = URL;
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
}

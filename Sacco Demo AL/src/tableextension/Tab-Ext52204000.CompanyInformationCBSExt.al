tableextension 52204000 "Company Information CBS Ext." extends "Company Information"
{
    fields
    {
        field(52204000; Signature; blob)
        {
            Subtype = Bitmap;
        }
        field(52204001; "Paybill No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }
}

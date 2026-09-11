tableextension 52203434 "Company Information" extends "Company Information"
{
    fields
    {
        // Add changes to table fields here
        field(52203423; Picture2; Blob)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                // PictureUpdated := TRUE;
            end;
        }
        field(52203424; "Branch Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(52203425; "Branch Address"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(52203426; "Branch Address 2"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(52203427; "Branch City"; Text[30])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                //  PostCode.ValidateCity(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) AND GUIALLOWED);
            end;
        }
        field(52203428; "Branch Phone No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(52203429; "Pension No."; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(52203430; "Procurement Email"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(52203431; Location; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(52203432; "Company Watermark"; BLOB)
        {
            DataClassification = ToBeClassified;
            Subtype = Bitmap;
        }
    }
}

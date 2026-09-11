page 52203925 "Applicant Picture"
{
    // version THL- HRM 1.0
    Caption = 'Applicant Picture';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = CardPart;
    SourceTable = Applicant;

    layout
    {
        area(content)
        {
            field(Image; Rec.Image)
            {
                ApplicationArea = All;
                ShowCaption = false;
                ToolTip = 'Specifies the picture of the employee.';
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        SetEditableOnPictureActions;
    end;
    trigger OnOpenPage()
    begin
    /*CameraAvailable := CameraProvider.IsAvailable;
            IF CameraAvailable THEN
              CameraProvider := CameraProvider.Create;*/
    end;
    var CameraAvailable: Boolean;
    OverrideImageQst: Label 'The existing picture will be replaced. Do you want to continue?';
    DeleteImageQst: Label 'Are you sure you want to delete the picture?';
    SelectPictureTxt: Label 'Select a picture to upload';
    DeleteExportEnabled: Boolean;
    DownloadImageTxt: Label 'Download image';
    local procedure SetEditableOnPictureActions()
    begin
    //DeleteExportEnabled := Image.HASVALUE;
    end;
}

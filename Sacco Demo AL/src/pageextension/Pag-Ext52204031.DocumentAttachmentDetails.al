pageextension 52204031 "Document Attachment Details" extends "Document Attachment Details"
{
    ModifyAllowed = false;
    InsertAllowed = false;
    layout
    {
        modify(Name)
        {
            Visible = false;
        }

        addafter(Name)
        {
            field("File Name"; Rec."File Name")
            {
                ApplicationArea = All;
            }
        }
        addafter("File Type")
        {
            field("Sharepoint Link"; Rec."Sharepoint Link")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        modify(AttachmentsUpload)
        {
            Enabled = false;
            Visible = false;
            Caption = 'Not Applicable';
        }
        modify(OpenInOneDrive)
        {
            Visible = false;
        }
        modify(EditInOneDrive)
        {
            Visible = false;
        }
        modify(ShareWithOneDrive)
        {
            Visible = false;
        }
        modify(OpenInFileViewer)
        {
            Visible = false;
        }
        modify(Preview)
        {
            Visible = false;
        }
        modify(AttachFromEmail)
        {
            Visible = false;
        }
        modify(UploadFile)
        {
            Visible = false;
        }
        addafter(UploadFile)
        {
            action("&UploadFile")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Caption = 'Attach to Sharepoint';
                Image = Attachments;
                Enabled = true;
                Scope = Page;
                ToolTip = 'Upload one file';

                trigger OnAction()
                begin
                    UploadAttachment;
                end;
            }
        }
    }

    procedure UploadAttachment()
    var
        FileName: Text;
        InStr: InStream;
        OutStr: OutStream;
        Base64: Text;
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        DocumentAttachmentMgmtCxt: Codeunit "Document Attachment Mgmt Cxt";
    begin
        UploadIntoStream('Select File', '', '', FileName, InStr);
        TempBlob.CreateOutStream(OutStr);
        CopyStream(OutStr, InStr);
        TempBlob.CreateInStream(InStr);
        Base64 := Base64Convert.ToBase64(InStr);
        DocumentAttachmentMgmtCxt.UploadToSharepoint(FromRecRef, Base64, FileName);
    end;
}

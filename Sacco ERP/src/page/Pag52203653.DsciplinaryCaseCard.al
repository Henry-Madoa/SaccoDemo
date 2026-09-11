page 52203653 "Dsciplinary Case Card"
{
    PageType = Card;
    SourceTable = "Disciplinary Case Header";

    layout
    {
        area(content)
        {
            group("Header Details")
            {
                Editable = false;

                field(No; Rec.No)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee No"; Rec."Employee No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part(Control10; "Disciplinary Case subforms")
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = "Disciplinary No"=FIELD(No);
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Report Case")
            {
                ApplicationArea = BasicHR;
                Image = Register;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = NewVisible AND NOT ArchiveVisible;

                trigger OnAction()
                begin
                    Rec.Testfield(Status, Rec.Status::New);
                    if not Confirm('Are you sure you want to report the case no. ' + Format(Rec.No) + ' ?')then exit;
                    Disciplinarymanagement.ReportDisciplinaryCase(Rec);
                end;
            }
            action("Archive Case")
            {
                ApplicationArea = BasicHR;
                Image = Archive;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ReportedVisible AND NOT ArchiveVisible;

                trigger OnAction()
                begin
                    Rec.Testfield(Status, Rec.Status::Reported);
                    if not Confirm('Are you sure you want to Archive the case no. ' + Format(Rec.No) + ' ?')then exit;
                    Disciplinarymanagement.ArchiveDisciplinaryCase(Rec);
                end;
            }
            action(Attachments)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attachments';
                Image = Attach;
                Promoted = true;
                PromotedCategory = Category9;
                ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';

                trigger OnAction()
                var
                    DocumentAttachmentDetails: Page "Document Attachment Details";
                    RecRef: RecordRef;
                begin
                    RecRef.GetTable(Rec);
                    DocumentAttachmentDetails.OpenForRecRef(RecRef);
                    DocumentAttachmentDetails.RunModal;
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        ControlAppearance();
    end;
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Validate(Type, Rec.Type::Disciplinary);
    end;
    trigger OnOpenPage()
    begin
        ControlAppearance;
    end;
    var Disciplinarymanagement: Codeunit "Disciplinary management";
    NewVisible: Boolean;
    ReportedVisible: Boolean;
    ArchiveVisible: Boolean;
    Text0001: Label 'Disciplinary,Grievance';
    GrievanceLinesVisible: Boolean;
    DisciplinaryLinesVisible: Boolean;
    local procedure ControlAppearance()
    begin
        if Rec.Status in[Rec.Status::New]then begin
            NewVisible:=true;
        end
        else
            NewVisible:=false;
        if Rec.Status in[Rec.Status::Reported]then begin
            ReportedVisible:=true;
        end
        else
            ReportedVisible:=false;
        if Rec.Status in[Rec.Status::Archived]then begin
            ArchiveVisible:=true;
        end
        else
            ArchiveVisible:=false;
        if Rec.Type in[Rec.Type::Disciplinary]then DisciplinaryLinesVisible:=true
        else
            DisciplinaryLinesVisible:=false;
        if Rec.Type in[Rec.Type::Grievance]then GrievanceLinesVisible:=true
        else
            GrievanceLinesVisible:=false;
    end;
}

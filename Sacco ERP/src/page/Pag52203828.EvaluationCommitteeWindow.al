page 52203828 "Evaluation Committee Window"
{
    ApplicationArea = All;
    PageType = List;
    SourceTable = "Evaluation Committee";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("User Name"; Rec."User Name")
                {
                    ApplicationArea = All;
                }
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = All;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = All;
                }
                field(Stage; Rec.Stage)
                {
                    ApplicationArea = All;
                }
                field("Submitted Mandatory Evaluation"; Rec."Submitted Mandatory Evaluation")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Submitted Technical Evaluation"; Rec."Submitted Technical Evaluation")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Notify Committee Members")
            {
                ApplicationArea = All;
                Image = SendToMultiple;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not Confirm('Do you want to send notifications to the committee members?')then exit;
                    EvaluationCommitteeCopy.Reset;
                    EvaluationCommitteeCopy.SetRange("Reference No", Rec."Reference No");
                    EvaluationCommitteeCopy.SetFilter("User Name", '%1', EvaluationCommitteeCopy."User Name");
                    if EvaluationCommitteeCopy.FindFirst then begin
                        repeat NotifyCommitee(EvaluationCommitteeCopy);
                        until EvaluationCommitteeCopy.Next = 0;
                    end;
                end;
            }
        }
    }
    var EvaluationCommitteeCopy: Record "Evaluation Committee";
    local procedure NotifyCommitee(var EvaluationCommittee: Record "Evaluation Committee")
    var
        Employee: Record Employee;
        UserSetup: Record "User Setup";
        SMTPMail: Codeunit Mail;
        ProcurementSetup: Record "Purchases & Payables Setup";
        SenderName: Text;
        SenderAddress: Text;
        Recepient: Text;
        RecepientCC: Text;
        Subject: Text;
        Body: Text;
        EmployeeII: Record Employee;
        ProcurementRequest: Record "Procurement Request";
    begin
        EvaluationCommittee.Reset();
        begin
            if ProcurementRequest.Get(EvaluationCommittee."Reference No")then begin
                //  EvaluationCommittee.SETFILTER("User Name",'%1',EvaluationCommittee."User Name");
                //  IF EvaluationCommittee.FINDFIRST THEN BEGIN
                //  REPEAT
                if Employee.Get(EvaluationCommittee."Employee No.")then begin
                    Employee.TestField("Company E-Mail");
                    // SMTPMailSetup.Get;
                    // SenderName := SMTPMailSetup."From Name";
                    // SenderAddress := SMTPMailSetup."From Address";
                    Recepient:=Employee."Company E-Mail";
                    ProcurementSetup.Get;
                    if UserSetup.Get(ProcurementSetup."Procurement Officer User Id")then begin
                        if EmployeeII.Get(UserSetup."Employee No.")then begin
                            EmployeeII.TestField("Company E-Mail");
                            RecepientCC:=EmployeeII."Company E-Mail";
                        end;
                    end;
                    Subject:='INVITATION FOR TENDER COMMITTEE EVALUATION';
                    Body:='Dear' + ' ' + Employee.FullName + ',' + '<br>You have been invited as a committee member to do an evaluation on Tender No.' + ' ' + Format(EvaluationCommittee."Reference No") + '.' + '<br>Kindly attend the meeting to be held at the' + ' ' + Format(ProcurementRequest."Committee Meeting Venue") + ' ' + 'on' + ' ' + Format(ProcurementRequest."Committee Meeting Date") + ' ' + 'at' + ' ' + Format(ProcurementRequest."Committee Meeting Time") + ' ' + 'for the evaluation process.' + '<br><br>THIS IS A SYSTEM GENERATED EMAIL. DO NOT REPLY TO IT.';
                    if(SenderName <> '') and (SenderAddress <> '') and (Recepient <> '') and (Subject <> '') and (Body <> '')then begin
                        SMTPMail.CreateMessage(Recepient, RecepientCC, '', Subject, Body, true, true);
                    // SMTPMail.AddCC(RecepientCC);
                    // SMTPMail.Send();
                    end;
                end;
            //    UNTIL EvaluationCommittee.NEXT = 0;
            //  END;
            end;
        end;
    end;
}

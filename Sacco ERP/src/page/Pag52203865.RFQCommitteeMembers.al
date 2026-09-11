page 52203865 "RFQ Committee Members"
{
    ApplicationArea = All;
    AutoSplitKey = true;
    PageType = List;
    SourceTable = "RFQ Committee Members";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("RFQ No."; Rec."RFQ No.")
                {
                    ApplicationArea = All;
                }
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = All;
                }
                field("Committee UserID"; Rec."Committee UserID")
                {
                    ApplicationArea = All;
                }
                field("Committee Member Name"; Rec."Committee Member Name")
                {
                    ApplicationArea = All;
                }
                field("Email Address"; Rec."Email Address")
                {
                    ApplicationArea = All;
                }
                field("Email Sent"; Rec."Email Sent")
                {
                    ApplicationArea = All;
                }
                field("Analysis Completed"; Rec."Analysis Completed")
                {
                    ApplicationArea = All;
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
                var
                    RFQCommitteeMembersII: Record "RFQ Committee Members";
                begin
                    QuotationBidders.Reset;
                    QuotationBidders.SetRange("Reference No", Rec."RFQ No.");
                    QuotationBidders.CalcFields("Total Quoted Amount");
                    QuotationBidders.SetFilter("Total Quoted Amount", '<>%1', 0);
                    if not QuotationBidders.FindSet then begin
                        Error('Please enter the amounts quoted by the vendors before inviting the committee members.');
                    end; // ELSE BEGIN
                    //    IF QuotationBidders.COUNT < 2 THEN
                    //      ERROR('You need atleast two vendors with quoted amounts');
                    //    END;
                    if not Confirm('Do you want to send notifications to the committee members?')then exit;
                    RFQCommitteeMembers.Reset;
                    RFQCommitteeMembers.SetRange("RFQ No.", Rec."RFQ No.");
                    RFQCommitteeMembers.SetRange("Email Sent", false);
                    if RFQCommitteeMembers.FindFirst then begin
                        repeat //         if Employee.Get(RFQCommitteeMembers."Employee No.") then begin
 //             Employee.TestField("Company E-Mail");
                            //             SMTPMailSetup.Get;
                            //             SenderName := SMTPMailSetup."From Name";
                            //             SenderAddress := SMTPMailSetup."From Address";
                            //             Recepient := Employee."Company E-Mail";
                            //             if Company.Get(CompanyName) then begin
                            //                 Company.TestField("Procurement Email");
                            //                 RecepientCC := Company."Procurement Email";
                            //             end;
                            //             ProcurementSetup.Get;
                            //             if UserSetup.Get(ProcurementSetup."Procurement Officer User Id") then begin
                            //                 if EmployeeII.Get(UserSetup."Employee No.") then begin
                            //                     EmployeeII.TestField("Company E-Mail");
                            //                     RecepientCC2 := EmployeeII."Company E-Mail";
                            //                 end;
                            //             end;
                            //             Subject := 'INVITATION FOR RFQ COMMITTEE EVALUATION';
                            //             Body := 'Dear' + ' ' + Employee.FullName + ',' +
                            //             '<br>You have been invited as a committee member to do an evaluation on Quotation No.' + ' ' + Format(RFQCommitteeMembers."RFQ No.") + '.' +
                            //             '<br>Kindly login to the ERP system to complete this task.' +
                            //             '<br><br>THIS IS A SYSTEM GENERATED EMAIL. DO NOT REPLY TO IT.';
                            //             if (SenderName <> '') and (SenderAddress <> '') and (Recepient <> '') and (Subject <> '') and (Body <> '') then begin
                            //                 SMTPMail.CreateMessage(Recepient, RecepientCC, RecepientCC2, Subject, Body, true, true);
                            //                 // if Recepient <> '' then
                            //                 //     SMTPMail.AddCC(RecepientCC);
                            //                 // if RecepientCC2 <> '' then
                            //                 //     SMTPMail.AddBCC(RecepientCC2);
                            //                 //        SMTPMail.Send();
                            //                 RFQCommitteeMembers."Email Sent" := true;
                            //                 RFQCommitteeMembers.Modify(true);
                            //             end;
                            //         end;
                            RFQCommitteeMembers."Email Sent":=true;
                            RFQCommitteeMembers.Modify(true);
                        until RFQCommitteeMembers.Next = 0;
                    end;
                    RFQCommitteeMembersII.Reset;
                    RFQCommitteeMembersII.SetRange("RFQ No.", Rec."RFQ No.");
                    RFQCommitteeMembersII.SetRange("Email Sent", true);
                    if RFQCommitteeMembersII.FindSet then begin
                        Message('Email(s) sent successfully');
                        CurrPage.Close;
                    end;
                end;
            }
        }
    }
    var UserSetup: Record "User Setup";
    Employee: Record Employee;
    SMTPMail: Codeunit Mail;
    RFQCommitteeMembers: Record "RFQ Committee Members";
    ProcurementSetup: Record "Purchases & Payables Setup";
    SenderName: Text;
    SenderAddress: Text;
    Recepient: Text;
    Subject: Text;
    Body: Text;
    RecepientCC: Text;
    RecepientCC2: Text;
    EmployeeII: Record Employee;
    Company: Record "Company Information";
    QuotationBidders: Record "Quotation Bidders";
    ProcurementRequest: Record "Procurement Request";
}

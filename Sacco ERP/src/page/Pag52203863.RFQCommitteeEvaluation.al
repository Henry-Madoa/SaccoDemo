page 52203863 "RFQ Committee Evaluation"
{
    ApplicationArea = All;
    AutoSplitKey = true;
    PageType = List;
    SourceTable = "RFQ Committee Evaluation";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("RFQ No."; Rec."RFQ No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(No; Rec.No)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Specification; Rec.Specification)
                {
                    ApplicationArea = All;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                }
                field("Committee Member ID"; Rec."Committee Member ID")
                {
                    ApplicationArea = All;
                }
                field("Quoted Amount"; Rec."Quoted Amount")
                {
                    ApplicationArea = All;
                }
                field(Award; Rec.Award)
                {
                    ApplicationArea = All;
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = All;
                }
                field("Revised Quote"; Rec."Revised Quote")
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
            action("Get Bidders & Committee Members")
            {
                ApplicationArea = All;
                Image = Users;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    ProcurementSetup.Get;
                    UserSetup.Get(UserId);
                    ProcurementSetup.TestField("Procurement Officer User Id", UserId);
                    RFQCommitteeEvaluation.Reset;
                    RFQCommitteeEvaluation.SetRange("RFQ No.", Rec."RFQ No.");
                    RFQCommitteeEvaluation.SetRange(Award, true);
                    if RFQCommitteeEvaluation.FindFirst then begin
                        if not Confirm('The committee members have already picked vendors, re-populating will delete existing data. Do you want to continue?')then exit;
                    end;
                    RFQCommitteeEvaluationII.Reset;
                    RFQCommitteeEvaluationII.SetRange("RFQ No.", Rec."RFQ No.");
                    if RFQCommitteeEvaluationII.FindSet then begin
                        RFQCommitteeEvaluationII.DeleteAll;
                    end;
                    QuotationBidders.Reset;
                    QuotationBidders.SetRange("Reference No", Rec."RFQ No.");
                    if QuotationBidders.FindFirst then begin
                        repeat RFQCommitteeMembers.Reset;
                            RFQCommitteeMembers.SetRange("RFQ No.", QuotationBidders."Reference No");
                            if RFQCommitteeMembers.FindFirst then begin
                                repeat RFQItemSpecifications.Reset;
                                    RFQItemSpecifications.SetRange("RFQ No.", RFQCommitteeMembers."RFQ No.");
                                    if RFQItemSpecifications.FindFirst then begin
                                        repeat RFQCommitteeEvaluation.Init;
                                            RFQCommitteeEvaluation."RFQ No.":=Rec."RFQ No.";
                                            RFQCommitteeEvaluation."Line No."+=10;
                                            RFQCommitteeEvaluation.No:=RFQItemSpecifications.No;
                                            RFQCommitteeEvaluation.Description:=RFQItemSpecifications.Description;
                                            RFQCommitteeEvaluation.Specification:=RFQItemSpecifications.Specification;
                                            RFQCommitteeEvaluation."Vendor No.":=QuotationBidders."Vendor No.";
                                            RFQCommitteeEvaluation."Vendor Name":=QuotationBidders."Vendor Name";
                                            QuotationVendorsBids.Reset;
                                            QuotationVendorsBids.SetRange("Quote No", Rec."RFQ No.");
                                            QuotationVendorsBids.SetRange("Vendor No", QuotationBidders."Vendor No.");
                                            QuotationVendorsBids.SetRange("Item No", RFQItemSpecifications.No);
                                            if QuotationVendorsBids.FindFirst then RFQCommitteeEvaluation."Quoted Amount":=QuotationVendorsBids."Quoted Amount";
                                            RFQCommitteeEvaluation."Committee Member ID":=RFQCommitteeMembers."Committee UserID";
                                            RFQCommitteeEvaluation."Committee Member No":=RFQCommitteeMembers."Employee No.";
                                            RFQCommitteeEvaluation."Committee Member Name":=RFQCommitteeMembers."Committee Member Name";
                                            RFQCommitteeEvaluation.Insert;
                                        until RFQItemSpecifications.Next = 0;
                                    end;
                                until RFQCommitteeMembers.Next = 0;
                            end
                            else
                            begin
                                Error('The Procurement Committee List has not been filled');
                            end;
                        until QuotationBidders.Next = 0;
                    end;
                end;
            }
            action("Submit Evaluation")
            {
                ApplicationArea = All;
                Image = SendConfirmation;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not Confirm('Do you want to submit your evaluation?')then exit;
                    RFQCommitteeEvaluation.Reset;
                    RFQCommitteeEvaluation.SetRange("RFQ No.", Rec."RFQ No.");
                    RFQCommitteeEvaluation.SetRange("Committee Member ID", UserId);
                    if not RFQCommitteeEvaluation.FindFirst then begin
                        Error('You are not part of the committee for this quote');
                    end;
                    RFQCommitteeEvaluation.Reset;
                    RFQCommitteeEvaluation.SetRange("RFQ No.", Rec."RFQ No.");
                    RFQCommitteeEvaluation.SetRange(No, Rec.No);
                    if RFQCommitteeEvaluation.FindSet then begin
                        repeat RFQCommitteeEvaluationII.Reset;
                            RFQCommitteeEvaluationII.SetRange("Committee Member ID", RFQCommitteeEvaluation."Committee Member ID");
                            RFQCommitteeEvaluationII.SetRange(Award, true);
                        //    IF NOT RFQCommitteeEvaluationII.FINDFIRST THEN BEGIN
                        //      ERROR('You have not picked any Vendor to award for No : %1 Name : %2',RFQCommitteeEvaluation.No,RFQCommitteeEvaluation.Description);
                        //      END;
                        until RFQCommitteeEvaluation.Next = 0;
                    end;
                    RFQCommitteeMembersII.Reset;
                    RFQCommitteeMembersII.SetRange("RFQ No.", Rec."RFQ No.");
                    RFQCommitteeMembersII.SetRange("Committee UserID", Rec."Committee Member ID");
                    if RFQCommitteeMembersII.FindFirst then begin
                        RFQCommitteeMembersII."Analysis Completed":=true;
                        if RFQCommitteeMembersII.Modify(true)then Message('Analysis has been submitted successfully');
                    end;
                    CurrPage.Close;
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        ProcurementSetup.Get;
        if UserSetup.Get(UserId)then begin
            if not((UserSetup."Is System Admin") or (ProcurementSetup."Procurement Officer User Id" = UserId))then begin
                Rec.SetRange("Committee Member ID", UserId);
            end;
        end;
    end;
    trigger OnOpenPage()
    begin
        // ControlVisibility;
        ProcurementSetup.Get;
        if UserSetup.Get(UserId)then begin
            if not((UserSetup."Is System Admin") or (ProcurementSetup."Procurement Officer User Id" = UserId))then begin
                Rec.SetRange("Committee Member ID", UserId);
            end;
        end;
    end;
    var QuotationBidders: Record "Quotation Bidders";
    ProcurementCommitteeMembers: Record "Procurement Committee Members";
    RFQCommitteeEvaluation: Record "RFQ Committee Evaluation";
    ProcurementRequestLines: Record "Procurement Request Lines";
    RFQCommitteeMembers: Record "RFQ Committee Members";
    ProcurementSetup: Record "Purchases & Payables Setup";
    GetBiddersMembersVisible: Boolean;
    ProcurementRequest: Record "Procurement Request";
    RFQItemSpecifications: Record "RFQ Item Specifications";
    QuotationVendorsBids: Record "Quotation Vendors Bids";
    RFQCommitteeEvaluationII: Record "RFQ Committee Evaluation";
    RFQCommitteeMembersII: Record "RFQ Committee Members";
    UserSetup: Record "User Setup";
    local procedure ControlVisibility(): Boolean begin
        GetBiddersMembersVisible:=false;
        ProcurementSetup.Get;
        if ProcurementSetup."Procurement Officer User Id" = UserId then begin
            GetBiddersMembersVisible:=true;
        end
        else
        begin
            GetBiddersMembersVisible:=false;
        end;
    end;
}

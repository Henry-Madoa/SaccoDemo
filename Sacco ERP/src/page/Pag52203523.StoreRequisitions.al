page 52203523 "Store Requisitions"
{
    CardPageID = "Store Requisition";
    PromotedActionCategories = 'New,Process,Report,Approval,Request Approval';
    PageType = List;
    Editable = false;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Requisition Header";
    SourceTableView = WHERE("Requisition Type"=FILTER("Store Requisition"));

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Code"; Rec."Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Reason; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Requisition Date"; Rec."Requisition Date")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Raised by"; Rec."Raised by")
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
                field("Global Dimension 3 Code"; Rec."Global Dimension 3 Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control15; Notes)
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(Print)
            {
                ApplicationArea = Suite;
                Caption = 'Print';
                Image = PrintReport;
                Promoted = true;
                PromotedCategory = Report;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    Rec.Reset();
                    Rec.SetRange("No.", Rec."No.");
                    Report.Run(Report::"Store Requisition", true, false, Rec);
                end;
            }
            action("Store Requisition Summary")
            {
                ApplicationArea = Suite;
                Image = PrintReport;
                Promoted = true;
                PromotedCategory = Report;
                PromotedOnly = true;
                RunObject = report "Store Requisition Summary";
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        RequisitionHeader.Reset;
        RequisitionHeader.SetRange("No.", Rec."No.");
        if RequisitionHeader.FindFirst then begin
            RequisitionHeader.CalcFields("Store Req. Qty. Issued");
            RequisitionHeader.CalcFields("Store Req. Qty. Approved");
            if(RequisitionHeader."Store Req. Qty. Issued" = RequisitionHeader."Store Req. Qty. Approved") and (RequisitionHeader."Store Req. Qty. Approved" <> 0) and (RequisitionHeader."Store Req. Qty. Issued" <> 0)then begin
                RequisitionHeader.Status:=RequisitionHeader.Status::Archived;
                RequisitionHeader.Issued:=true;
                RequisitionHeader.Modify;
            end;
        end;
    end;
    var StoresMgt: Codeunit "Stores Management";
    Text000: Label 'You are about to issue the store items to %1. Do you wish to continue?';
    RequisitionHeader: Record "Requisition Header";
}

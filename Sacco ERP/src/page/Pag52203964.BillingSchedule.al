page 52203964 "Billing Schedule"
{
    PageType = List;
    SourceTable = "Billing Schedule";
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Schedule Date"; Rec."Schedule Date")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
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
            action("Generate Tenant Schedules")
            {
                ApplicationArea = All;
                Image = OpenWorksheet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    BillingSchedule: Record "Billing Schedule";
                    AssetManagement: Codeunit "Asset Management";
                    TenantShedule: Record "Tenant Bill Schedule";
                begin
                    if not Confirm('Do you want to generate tenant schedules for this period?')then exit;
                    CurrPage.SetSelectionFilter(Rec);
                    Rec.TestField(Status, Rec.Status::Open);
                    AssetManagement.GenerateDepositBillingSchedule(Rec."No.", Rec."Schedule Date");
                    AssetManagement.GenerateMonthlyBillingSchedule(Rec."No.", Rec."Schedule Date");
                    TenantShedule.Reset();
                    TenantShedule.SetRange("Schedule No.", Rec."No.");
                    TenantShedule.SetRange("Schedule Date", Rec."Schedule Date");
                    if TenantShedule.FindSet()then begin
                        Rec.Status:=Rec.Status::Generated;
                        Rec.Modify(true);
                    end;
                end;
            }
            action("Open Tenant Schedules")
            {
                ApplicationArea = All;
                Image = OpenWorksheet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not Confirm('Do you want to open the tenant schedules?')then exit;
                    if Rec.Status <> Rec.Status::Open then begin
                        TenantBillSchedule.Reset;
                        TenantBillSchedule.SetRange("Schedule No.", Rec."No.");
                        TenantBillSchedule.SetRange("Schedule Date", Rec."Schedule Date");
                        if TenantBillSchedule.FindFirst then begin
                            PAGE.RunModal(PAGE::"Tenant Bill Schedules", TenantBillSchedule);
                        end;
                    end
                    else
                        Error('No Tenant schedules have been generated');
                end;
            }
            action("Generate Sales Invoices")
            {
                ApplicationArea = All;
                Image = CreateJobSalesInvoice;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    AssetManagementSetup: Record "Asset Management Setup";
                    AssetManagement: Codeunit "Asset Management";
                begin
                    if not Confirm('Do you want to generate tenant invoices for the schedules?')then exit;
                    CurrPage.SetSelectionFilter(Rec);
                    Rec.TestField(Status, Rec.Status::Generated);
                    TenantBillSchedule.Reset;
                    TenantBillSchedule.SetRange("Schedule No.", Rec."No.");
                    TenantBillSchedule.SetRange("Schedule Date", Rec."Schedule Date");
                    if TenantBillSchedule.FindSet then begin
                        repeat AssetManagement.GenerateSalesInvoices(TenantBillSchedule."Schedule No.", TenantBillSchedule."Schedule Date", TenantBillSchedule."Tenant No.");
                        until TenantBillSchedule.Next = 0;
                    end;
                end;
            }
        }
    }
    var TenantBillSchedule: Record "Tenant Bill Schedule";
}

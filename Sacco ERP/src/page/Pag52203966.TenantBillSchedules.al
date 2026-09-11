page 52203966 "Tenant Bill Schedules"
{
    CardPageID = "Tenant Bill Schedule";
    PageType = List;
    SourceTable = "Tenant Bill Schedule";
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Schedule No."; Rec."Schedule No.")
                {
                    ApplicationArea = All;
                }
                field("Schedule Date"; Rec."Schedule Date")
                {
                    ApplicationArea = All;
                }
                field("Tenant No."; Rec."Tenant No.")
                {
                    ApplicationArea = All;
                }
                field("Tenant Name"; Rec."Tenant Name")
                {
                    ApplicationArea = All;
                }
                field("Property Code"; Rec."Property Code")
                {
                    ApplicationArea = All;
                }
                field("Property Name"; Rec."Property Name")
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
            action("Generate Sales Invoices")
            {
                ApplicationArea = All;
                Image = CreateJobSalesInvoice;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not Confirm('Do you want to generate tenant invoices for the schedules?')then exit;
                    TenantBillSchedule.Reset;
                    TenantBillSchedule.CalcFields("Schedule Status");
                    TenantBillSchedule.SetRange("Schedule No.", Rec."Schedule No.");
                    TenantBillSchedule.SetRange("Schedule Date", Rec."Schedule Date");
                    TenantBillSchedule.SetRange("Schedule Status", TenantBillSchedule."Schedule Status"::Generated);
                    if TenantBillSchedule.FindSet then begin
                        repeat until TenantBillSchedule.Next = 0;
                    end;
                end;
            }
        }
    }
    var AssetManagement: Codeunit "Asset Management";
    TenantBillSchedule: Record "Tenant Bill Schedule";
}

page 52203962 "Tenant Booking"
{
    PageType = Card;
    SourceTable = "Tenant Booking";
    PromotedActionCategories = 'New,Process,Report,Category4,Category5';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Tenancy Start Date"; Rec."Tenancy Start Date")
                {
                    ApplicationArea = All;
                }
                field("Tenancy Status"; Rec."Tenancy Status")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }
            }
            group(Employment)
            {
                field(Occupation; Rec.Occupation)
                {
                    ApplicationArea = All;
                }
                field("Employment Type"; Rec."Employment Type")
                {
                    ApplicationArea = All;
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                }
                field("Company Address"; Rec."Company Address")
                {
                    ApplicationArea = All;
                }
            }
            group(Property)
            {
                field("Property Booked"; Rec."Property Booked")
                {
                    ApplicationArea = All;
                }
                field("Property Name"; Rec."Property Name")
                {
                    ApplicationArea = All;
                }
                field("Landlord Code"; Rec."Landlord Code")
                {
                    ApplicationArea = All;
                }
                field("Landlord Name"; Rec."Landlord Name")
                {
                    ApplicationArea = All;
                }
                field("Unit No."; Rec."Unit No.")
                {
                    ApplicationArea = All;
                }
                field("Property Type"; Rec."Property Type")
                {
                    ApplicationArea = All;
                }
                field("Floor Space (M2)"; Rec."Floor Space (M2)")
                {
                    ApplicationArea = All;
                }
                field("No. of Rooms"; Rec."No. of Rooms")
                {
                    ApplicationArea = All;
                }
                field("No. of Bedrooms"; Rec."No. of Bedrooms")
                {
                    ApplicationArea = All;
                }
                field("Floor No."; Rec."Floor No.")
                {
                    ApplicationArea = All;
                }
                field("Rent Amount"; Rec."Rent Amount")
                {
                    ApplicationArea = All;
                }
                field("Deposit Amount"; Rec."Deposit Amount")
                {
                    ApplicationArea = All;
                }
                field("Water Deposit"; Rec."Water Deposit")
                {
                    ApplicationArea = All;
                }
                field("Electricity Deposit"; Rec."Electricity Deposit")
                {
                    ApplicationArea = All;
                }
                field("Other Deposits"; Rec."Other Deposits")
                {
                    ApplicationArea = All;
                }
                field("Expected Rent Date"; Rec."Expected Rent Date")
                {
                    ApplicationArea = All;
                }
                field("Late Payment Penalty %"; Rec."Late Payment Penalty %")
                {
                    ApplicationArea = All;
                }
            }
            group(Audit)
            {
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                }
                field("Created Date"; Rec."Created Date")
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
            action("Approve Booking")
            {
                ApplicationArea = All;
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::New);
                    Rec.TestField("Tenancy Status", Rec."Tenancy Status"::Inactive);
                    Rec.TestField("Property Booked");
                    Rec.TestField("Landlord Code");
                    Rec.TestField("Unit No.");
                    Rec.TestField(Name);
                    Rec.TestField("Rent Amount");
                    if not Confirm('Do you want to approve this booking?')then exit;
                    Rec.Status:=Rec.Status::Approved;
                    Rec."Tenancy Status":=Rec."Tenancy Status"::Booked;
                    Rec.Modify(true);
                    CurrPage.Close;
                end;
            }
            action("Create Tenant")
            {
                ApplicationArea = All;
                Image = CreateBinContent;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::Approved);
                    Rec.TestField("Tenancy Status", Rec."Tenancy Status"::Booked);
                    if not Confirm('Do you want to create a tenant from this booking?')then exit;
                    "NewCustomerNo.":=AssetManagement.CreateTenant(Rec, Rec."No.");
                    if "NewCustomerNo." <> '' then begin
                        Rec."Customer No.":="NewCustomerNo.";
                        if Rec.Modify(true)then Message('Tenant No. %1 has been successfully created', "NewCustomerNo.");
                    end;
                end;
            }
        }
    }
    var AssetManagement: Codeunit "Asset Management";
    "NewCustomerNo.": Code[20];
}

page 52204190 "Signatories Card"
{
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Signatories & Directors";

    layout
    {
        area(Content)
        {
            group("General Information")
            {
                field("Source Code"; Rec."Source Code")
                {
                    Visible = isWebService;
                }
                field("Identification Type"; Rec."Identification Type")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Identification No."; Rec."Identification No.")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                group(IPRSData)
                {
                    ShowCaption = false;
                    Editable = not Rec."IPRS Uneditability";

                    field(Name; Rec.Name)
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Date of Birth"; Rec."Date of Birth")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                field(Designation; Rec.Designation)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Nationality; Rec.Nationality)
                {
                    ApplicationArea = Basic, Suite;
                }
                group("&&Domicile")
                {
                    ShowCaption = false;
                    Visible = Rec.Nationality = Rec.Nationality::Diaspora;

                    field(Domicile; Rec.Domicile)
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Country Name"; Rec."Country Name")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                field("Phone No"; Rec."Phone No")
                {
                    ApplicationArea = Basic, Suite;
                }
                group("Microfinance")
                {
                    Visible = Rec."Category Type" = Rec."Category Type"::"Micro Finance";

                    field("Member No"; Rec."Member No")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
            }
            group(Images)
            {
                field("Signature Card"; Rec."Signature Card")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Passport Image"; Rec."Passport Image")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Validate IPRS Data")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Addresses;

                trigger OnAction()
                begin
                    Rec.Testfield("Identification No.");
                    if Confirm('Do you wish to validate from IPRS', false) then begin
                        MemberMgmt.PopulateIPRSData(Rec.RecordId, Rec."Identification No.");
                        CurrPage.Update(true);
                    end;
                end;
            }
        }
    }
    var
        isWebService: Boolean;
        LoginMgmt: Codeunit "User Management Ext";
        MemberMgmt: Codeunit "Member Management";
        Member: Record Members;
        MemberApplication: Record "Member Application";
        MemberEditting: Record "Member Editing";

    trigger OnModifyRecord(): Boolean
    begin
        If Member.Get(Rec."Source Code") then Error('You cannot update Members Details');
        if MemberApplication.Get(Rec."Source Code") then MemberApplication.TestField(Status, MemberApplication.Status::Open);
        if MemberEditting.Get(Rec."Source Code") then MemberEditting.TestField(Status, MemberEditting.Status::Open);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        If Member.Get(Rec."Source Code") then Error('You cannot delete Members Details');
        if MemberApplication.Get(Rec."Source Code") then MemberApplication.TestField(Status, MemberApplication.Status::Open);
        if MemberEditting.Get(Rec."Source Code") then MemberEditting.TestField(Status, MemberEditting.Status::Open);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        If Member.Get(Rec."Source Code") then Error('You cannot delete Members Details');
        if MemberApplication.Get(Rec."Source Code") then MemberApplication.TestField(Status, MemberApplication.Status::Open);
        if MemberEditting.Get(Rec."Source Code") then MemberEditting.TestField(Status, MemberEditting.Status::Open);
    end;

    trigger OnAfterGetRecord()
    begin
        isWebService := LoginMgmt.IsWebServiceUser;
    end;

    trigger OnOpenPage()
    begin
        isWebService := LoginMgmt.IsWebServiceUser;
    end;
}

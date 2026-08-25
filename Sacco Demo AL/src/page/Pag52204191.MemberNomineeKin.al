page 52204191 "Member Nominee/Kin"
{
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Member Nominee/Kin";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = isWebService;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
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
                    // trigger OnValidate()
                    // begin
                    //     if not isWebService then CurrPage.Update(true);
                    // end;
                }
                field("Relative Code"; Rec."Relative Code")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        If Member.Get(Rec."Source Code") then Error('You cannot create new Members Details');
                        if MemberApplication.Get(Rec."Source Code") then MemberApplication.TestField(Status, MemberApplication.Status::Open);
                    end;
                }
                group(IPRSDetails)
                {
                    ShowCaption = false;
                    Editable = not Rec."IPRS Uneditability";

                    field(Name; Rec.Name)
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                    field("Date of Birth"; Rec."Date of Birth")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                group(AmountPaid)
                {
                    ShowCaption = false;
                    Visible = (Rec."Document Type" = Rec."Document Type"::Benevolent);

                    field("Amount Paid"; Rec."Amount Paid")
                    {
                        ShowMandatory = true;
                        ApplicationArea = Basic, Suite;
                    }
                }
                group(Alloc)
                {
                    ShowCaption = false;
                    Visible = (Rec."Document Type" = Rec."Document Type"::Nominee);

                    field(Allocation; Rec.Allocation)
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                    field("Add As Next of Kin"; Rec."Add As Next of Kin")
                    {
                        ShowMandatory = true;
                        ApplicationArea = Basic, Suite;
                    }
                }
            }
            group(Image)
            {
                field("Passport Image"; Rec."Passport Image")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Identification Document"; Rec."Identification Document")
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
                Visible = Rec."Document Type" = Rec."Document Type"::Nominee;

                trigger OnAction()
                begin
                    Rec.TestField("Identification No.");
                    if Rec."Document Type" = Rec."Document Type"::Nominee then begin
                        Relatives.Get(Rec."Relative Code");
                        If not Relatives.Minor then begin
                            if Confirm('Do you wish to validate Nominee data from IPRS', false) then begin
                                MemberMgmt.PopulateIPRSData(Rec.RecordId, Rec."Identification No.");
                                CurrPage.Update(true);
                            end;
                        end
                        else
                            Error('You cannot validate the data of a minor from IPRS');
                    end;
                end;
            }
        }
    }
    trigger OnClosePage()
    var
        MemberNextofKins: Record "Member Nominee/Kin";
        TotalAllocation: Decimal;
    begin
        if Rec."Document Type" = Rec."Document Type"::Nominee then begin
            MemberNextofKins.Reset();
            MemberNextofKins.SetRange("Source Code", Rec."Source Code");
            MemberNextofKins.SetRange("Document Type", Rec."Document Type"::Nominee);
            MemberNextofKins.CalcSums(Allocation);
            TotalAllocation := MemberNextofKins.Allocation;
            if TotalAllocation < 100 then
                if Confirm('Your allocation do not add up to 100%, Do you wish to exit first?', false) then
                    exit
                else
                    CurrPage.Editable;
        end;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        If Member.Get(Rec."Source Code") then Error('You cannot update Members Details');
        if MemberApplication.Get(Rec."Source Code") then MemberApplication.TestField(Status, MemberApplication.Status::Open);
        if MemberEditting.Get(Rec."Source Code") then MemberEditting.TestField(Status, MemberEditting.Status::Open);
        if not MemberApplication.Get(Rec."Source Code") and not MemberEditting.Get(Rec."Source Code") then Error('You cannot modify this record');
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        If Member.Get(Rec."Source Code") then Error('You cannot delete Members Details');
        if MemberApplication.Get(Rec."Source Code") then MemberApplication.TestField(Status, MemberApplication.Status::Open);
        if MemberEditting.Get(Rec."Source Code") then MemberEditting.TestField(Status, MemberEditting.Status::Open);
        if not MemberApplication.Get(Rec."Source Code") and not MemberEditting.Get(Rec."Source Code") then Error('You cannot delete this record');
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
    end;

    trigger OnAfterGetRecord()
    begin
        isWebService := LoginMgmt.IsWebServiceUser;
    end;

    trigger OnOpenPage()
    begin
        isWebService := LoginMgmt.IsWebServiceUser;
    end;

    var
        Member: Record Members;
        MemberApplication: Record "Member Application";
        MemberEditting: Record "Member Editing";
        isWebService: Boolean;
        LoginMgmt: Codeunit "User Management Ext";
        Relatives: Record Relative;
        MemberMgmt: Codeunit "Member Management";
}

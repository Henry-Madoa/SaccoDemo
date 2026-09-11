page 52204011 "Member"
{
    PromotedActionCategories = 'New,Process,Report,Account Details';
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = Members;
    InsertAllowed = false;
    Editable = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Old No."; Rec."Old No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Class; Rec.Class)
                {
                    ApplicationArea = Basic, Suite;
                }
                group(JointAccDetails)
                {
                    Visible = Rec."Category Type" = Rec."Category Type"::"Joint Account";
                    ShowCaption = false;

                    field("Corporate Name"; Rec."Group/Corporate Name")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                group(GroupMemberAccDetails)
                {
                    Visible = Rec."Category Type" = Rec."Category Type"::"Group Member";
                    ShowCaption = false;

                    field("Micro Finance Account"; Rec."Micro Finance Account")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                }
                field("Recruited By"; Rec."Recruited By")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Recruiter Code"; Rec."Recruiter Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Relationship Officer"; Rec."Relationship Officer")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Relationship Officer Name"; Rec."Relationship Officer Name")
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
                group(NationalityInfo)
                {
                    ShowCaption = false;
                    Visible = NOT Rec."Is Group/Corporate";
                    field(Nationality; Rec.Nationality)
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                    group(DomicileInfo)
                    {
                        ShowCaption = false;
                        Visible = Rec.Nationality = Rec.Nationality::Diaspora;

                        field(Domicile; Rec.Domicile)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowMandatory = true;
                        }
                    }
                    field("Identification Type"; Rec."Identification Type")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
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
                    group(PassportDetails)
                    {
                        ShowCaption = false;

                        field("Passport No."; Rec."Passport No.")
                        {
                            ApplicationArea = Basic, Suite;
                        }
                        field("Date of Issue"; Rec."Date of Issue")
                        {
                            ApplicationArea = Basic, Suite;
                        }
                        field("Date of Expiry"; Rec."Date of Expiry")
                        {
                            ApplicationArea = Basic, Suite;
                        }
                    }
                }
                field("Mobile Transacting No"; Rec."Mobile Transacting No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Protected Account"; Rec."Protected Account")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                group(AccountAct)
                {
                    ShowCaption = false;
                    Visible = Rec."Protected Account";

                    field("Account Owner"; Rec."Account Owner")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
            }
            group(Activations)
            {
                ShowCaption = false;
                Visible = ((not Rec."Is Group/Corporate") and (Rec."Category Type" <> Rec."Category Type"::"Group Member"));

                label(ActivationLable)
                {
                    ApplicationArea = Basic, Suite;
                    Style = Favorable;
                    Caption = '*****Activations*****';
                }
                field(ATM; Rec.ATM)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Mobile; Rec.Mobile)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Marketing Texts"; Rec."Marketing Texts")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("E-Statement"; Rec."E-Statement")
                {
                    ApplicationArea = Basic, Suite;
                }
                group(EstatementPeriod)
                {
                    ShowCaption = false;
                    Visible = Rec."E-Statement";

                    field("E-Statement Period"; Rec."E-Statement Period")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                }
            }
            group("Basic Information")
            {
                Visible = not Rec."Is Group/Corporate";

                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Full Name"; Rec."Full Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("National ID No"; Rec."Identification No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("KRA PIN"; Rec."KRA PIN")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Date of Birth"; Rec."Date of Birth")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Type of Residence"; Rec."Type of Residence")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Marital Status"; Rec."Marital Status")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Gender; Rec.Gender)
                {
                    ApplicationArea = Basic, Suite;
                }
                group("Employement Information")
                {
                    ShowCaption = false;
                    Visible = not Rec."Is Group/Corporate";

                    label("**")
                    {
                        ApplicationArea = Basic, Suite;
                        Style = Favorable;
                        Caption = '*****Employement Information*****';
                    }
                    field("Emplyoment Type"; Rec."Emplyoment Type")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                    group(EmployedInfo)
                    {
                        ShowCaption = false;
                        Visible = Rec."Emplyoment Type" = Rec."Emplyoment Type"::"Employed (Checkoff)";

                        field(Salaried; Rec.Salaried)
                        {
                            ApplicationArea = Basic, Suite;
                        }
                        field("Employer Code"; Rec."Employer Code")
                        {
                            ApplicationArea = Basic, Suite;
                            ShowMandatory = true;
                        }
                        field("Station Code"; Rec."Station Code")
                        {
                            ApplicationArea = Basic, Suite;
                            ShowMandatory = true;
                        }
                        field(Designation; Rec.Designation)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowMandatory = true;
                        }
                        field("Payroll No."; Rec."Payroll No.")
                        {
                            ApplicationArea = Basic, Suite;
                            ShowMandatory = true;
                        }
                    }
                    group(Employed_Non_CheckOff_Info)
                    {
                        ShowCaption = false;
                        Visible = Rec."Emplyoment Type" = Rec."Emplyoment Type"::"Employed (Non-Checkoff)";

                        field("Employer Details"; Rec."Occupation Description")
                        {
                            MultiLine = true;
                            ApplicationArea = Basic, Suite;
                            Caption = 'Employer Details';
                        }
                    }
                    group(SelfEmployedInfo)
                    {
                        ShowCaption = false;
                        Visible = Rec."Emplyoment Type" = Rec."Emplyoment Type"::"Self Employed";

                        field(Occupation; Rec.Occupation)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowMandatory = true;
                        }
                        field("Occupation Description"; Rec."Occupation Description")
                        {
                            MultiLine = true;
                            ApplicationArea = Basic, Suite;
                        }
                    }
                }
            }
            group("Group/Corporate Information")
            {
                Visible = (Rec."Is Group/Corporate" and (Rec."Category Type" <> Rec."Category Type"::"Joint Account"));

                field("Group/Corporate No"; Rec."Group/Corporate No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Group/Corporate Name"; Rec."Group/Corporate Name")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Certificate of Incoop"; Rec."Certificate of Incoop")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Date of Registration"; Rec."Date of Registration")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Certificate Expiry"; Rec."Permit Expiry")
                {
                    ApplicationArea = Basic, Suite;
                }
                group(KRADetails)
                {
                    ShowCaption = false;
                    Visible = ((Rec."Category Type" <> Rec."Category Type"::Group) and (Rec."Category Type" <> Rec."Category Type"::"Micro Finance"));

                    field("&KRA PIN"; Rec."KRA PIN")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
                group("&Employement Information")
                {
                    ShowCaption = false;

                    //Visible = not Rec."Is Group/Corporate";
                    label("&**")
                    {
                        ApplicationArea = Basic, Suite;
                        Style = Favorable;
                        Caption = '*****Employement Information*****';
                    }
                    field("&Emplyoment Type"; Rec."Emplyoment Type")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                    group("&EmployedInfo")
                    {
                        ShowCaption = false;
                        Visible = Rec."Emplyoment Type" = Rec."Emplyoment Type"::"Employed (Checkoff)";

                        field("&Salaried"; Rec.Salaried)
                        {
                            ApplicationArea = Basic, Suite;
                        }
                        field("&Employer Code"; Rec."Employer Code")
                        {
                            ApplicationArea = Basic, Suite;
                            ShowMandatory = true;
                        }
                        field("&Payroll No."; Rec."Payroll No.")
                        {
                            ApplicationArea = Basic, Suite;
                            ShowMandatory = true;
                        }
                    }
                }
            }
            group("Contacts and Addresses")
            {
                field("Mobile Phone No."; Rec."Mobile Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Alt. Phone No"; Rec."Alt. Phone No")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Address 2"; Rec."Address 2")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(County; Rec.County)
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        if Counties.Get(Rec.County) then CountyName := Counties.Name;
                    end;
                }
                field("County Name"; CountyName)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Additional;
                }
                field("Sub County"; Rec."Sub County")
                {
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate()
                    begin
                        if SubCounties.Get(Rec.County, Rec."Sub County") then SubCountyName := SubCounties."Sub County Name";
                    end;
                }
                field("Sub County Name"; SubCountyName)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Additional;
                }
                field("Town of Residence"; Rec."Town of Residence")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = not Rec."Is Group/Corporate";
                }
                field("Estate of Residence"; Rec."Estate of Residence")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = not Rec."Is Group/Corporate";
                }
            }
            group(Images)
            {
                Visible = not Rec."Is Group/Corporate";

                field("Member Image"; Rec."Passport Size Photo")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Front ID Image"; Rec."Front ID Photo")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Back ID Image"; Rec."Back ID Photo")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Signature Card"; Rec.Signature)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            part("Accounts"; "Member Accounts")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Member No." = field("No.");
            }
        }
        area(Factboxes)
        {
            part("Account Instructions"; "Member Account Instructions")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                UpdatePropagation = Both;
                SubPageLink = "Source Code" = field("No.");
            }
            part("Member Statistics"; "Member Statistics")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("No.");
            }
            part("Document Attachment Factbox"; "Document Attachment Factbox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Table ID" = const(Database::Members), "No." = field("No.");
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }
    actions
    {
        area(Reporting)
        {
            action("Print Statement")
            {
                ApplicationArea = Basic, Suite;
                Image = PrintAcknowledgement;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    Statement: Report "Member Statement";
                    MemberList: Record Members;
                begin
                    MemberList.Reset();
                    MemberList.SetRange("No.", Rec."No.");
                    if MemberList.FindSet() then begin
                        Clear(Statement);
                        Report.Run(Report::"Member Statement", true, false, MemberList);
                    end
                end;
            }
            action("Print Statement - With Reversals")
            {
                ApplicationArea = Basic, Suite;
                Image = PrintExcise;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    Member: Record Members;
                begin
                    Member.Reset();
                    Member.SetRange("No.", Rec."No.");
                    if Member.FindSet() then Report.RunModal(Report::"Member Statement2", true, false, Member);
                end;
            }
            action(Guarantors)
            {
                ApplicationArea = Basic, Suite;
                Image = Report2;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                trigger OnAction();
                var
                    Member: Record Members;
                begin
                    Member.Reset();
                    Member.SetRange("No.", Rec."No.");
                    if Member.FindSet() then Report.RunModal(Report::"Member Guarantors", true, false, Member);
                end;
            }
        }
        area(Processing)
        {
            action("Member Accounts")
            {
                ApplicationArea = Basic, Suite;
                RunObject = page "Member Accounts List";
                RunPageLink = "Member No." = field("No.");
                Image = Accounts;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
            }
            action("Nexts of KIN")
            {
                ApplicationArea = Basic, Suite;
                RunObject = page "Member Nominees/Kins";
                RunPageLink = "Source Code" = field("No."), "Document Type" = const("Next of Kin");
                Image = AddContacts;
                Visible = not Rec."Is Group/Corporate";
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Next of Kins / Emergency Contact';
            }
            action("Nominees")
            {
                ApplicationArea = Basic, Suite;
                RunObject = page "Member Nominees/Kins";
                RunPageLink = "Source Code" = field("No."), "Document Type" = const(Nominee);
                Image = Relatives;
                Visible = not Rec."Is Group/Corporate";
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Nominees / Beneficiaries';
            }
            action(Benevolent)
            {
                ApplicationArea = Basic, Suite;
                Image = CoupledUsers;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Benevolent';
                Visible = not Rec."Is Group/Corporate";
                RunObject = page "Member Nominees/Kins";
                RunPageLink = "Source Code" = field("No."), "Document Type" = const(Benevolent);
            }
            action("Group Signatories")
            {
                ApplicationArea = Basic, Suite;
                Image = Administration;
                PromotedCategory = Process;
                RunObject = page "Signatories & Directors";
                RunPageLink = "Source Code" = field("No.");
                Visible = Rec."Is Group/Corporate";
                Promoted = true;
            }
            action("Additional Controls")
            {
                ApplicationArea = Basic, Suite;
                Image = LotInfo;
                PromotedCategory = Process;
                RunObject = page "Member Controls";
                RunPageLink = "No." = field("No.");
                Promoted = true;
            }
            action("Subscriptions")
            {
                ApplicationArea = Basic, Suite;
                RunObject = page "Member Subscriptions";
                RunPageLink = "Source Code" = field("No.");
                Image = AddAction;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
            }
            action("&Account Instructions")
            {
                ApplicationArea = Basic, Suite;
                RunObject = page "Member Account Instructions";
                RunPageLink = "Source Code" = field("No.");
                Image = AddAction;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
            }
            action("Referees")
            {
                ApplicationArea = Basic, Suite;
                RunObject = page "Member Application Referee";
                RunPageLink = "Application No." = field("No.");
                Image = ApplyTemplate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
            }
            action("Send SMS")
            {
                ApplicationArea = Basic, Suite;
                Image = SendEmailPDF;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    Member: Record Members;
                begin
                    Member.Reset();
                    Member.SetRange("No.", Rec."No.");
                    if Member.FindSet() then Report.Run(Report::"Send SMS", true, false, Member);

                end;
            }
            action("M-Allocate")
            {
                ApplicationArea = Basic, Suite;
                Image = PostApplication;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    UpdateMobiLoanLimit: Report "Update Mobi Loan Limit";
                begin
                    UpdateMobiLoanLimit.SetCurrentDetails(Rec."No.", Rec."Mobi Loan Limit");
                    UpdateMobiLoanLimit.Run;
                end;
            }
        }
    }
    trigger OnOpenPage()
    var
        UserSetup: Record "User Setup";
        Members: Record Members;
        SMSMessage, SMSNo : Text[250];
        SMSSource: Code[20];
        SMSMgt: Codeunit "Notifications Management";
        SaccoSetup: Record "General Ledger Setup";
        MemberMgt: Codeunit "Member Management";
        ReasonDialog: Page "Member View Reason Dialog";
        Reason: Text[100];
    begin
        if Counties.Get(Rec.County) then
            CountyName := Counties.Name;
        if SubCounties.Get(Rec.County, Rec."Sub County") then
            SubCountyName := SubCounties."Sub County Name";
        Reason := '';

        if CurrentClientType IN [ClientType::Web, ClientType::Windows] then begin
            if Rec."Protected Account" then begin
                if (MemberMgt.ViewProtectedAccounts(UserId) = false) and (Rec."Account Owner" <> UserId) then
                    Error('The Account is protected. You are not authorised to view.');
            end;

            if ((Rec.Status <> Rec.Status::Active) and (Rec.Status <> Rec.Status::"Not Paid Up")) then begin
                if ReasonDialog.RunModal() = Action::OK then
                    Reason := ReasonDialog.GetReason();
                if Reason = '' then
                    Error('You must provide the reason');
                SMSSource := StrSubstNo('%1_Access', Format(Rec.Status));
                SMSMessage := StrSubstNo('%1 accessed a %2 account %3 at %4 Reasons : %5', UserId, Format(Rec.Status), Rec."No.", Format(CurrentDateTime), Reason);
                SMSNo := SaccoSetup."ICT Admin Phone No.";
                SMSMgt.SendSms(SMSNo, SMSMessage, SMSSource);
                Commit;
            end;
            MemberMgt.LogView(Rec."No.", CurrPage.Caption, Reason);
        end;
    end;

    var
        CountyName: Text;
        SubCountyName: Text;
        Counties: Record Counties;
        SubCounties: Record "Sub Counties";
}

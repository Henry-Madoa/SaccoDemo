page 52204010 "Members"
{
    PromotedActionCategories = 'New,Process,Report,Account Details';
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = Members;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    CardPageId = Member;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Old No."; Rec."Old No.")
                {
                    Caption = 'Old FOSA No.';
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field(Name; Rec.FullName)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Identification Type"; Rec."Identification Type")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Identification No."; Rec."Identification No.")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Date of Registration"; Rec."Date of Registration")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field(Nationality; Rec.Nationality)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field(Domicile; Rec.Domicile)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Recruited By"; Rec."Recruited By")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Recruiter Code"; Rec."Recruiter Code")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Emplyoment Type"; Rec."Emplyoment Type")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Employer Code"; Rec."Employer Code")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Payroll No."; Rec."Payroll No.")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Passport No."; Rec."Passport No.")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Category Type"; Rec."Category Type")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Mobile Phone No."; Rec."Mobile Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Reg. Fee Paid"; Rec."Reg. Fee Paid")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("FOSA Balance"; FosaBal)
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Protected Account"; Rec."Protected Account")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field(Classification; Rec.Classification)
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleText;
                }
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
        }
        area(Processing)
        {
            action("Apply Signatories Images")
            {
                Visible = true;

                trigger OnAction()
                var
                    SignatoriesDirectors: Record "Signatories & Directors";
                    FPath: Text;
                    Window: Dialog;
                    Vendor: Record Vendor;
                    All, Current : integer;
                begin
                    SignatoriesDirectors.Reset();
                    SignatoriesDirectors.SetFilter("Identification No.", '<>%1', '');
                    if SignatoriesDirectors.FindSet() then begin
                        Window.Open('Applying #1##/#2##');
                        All := SignatoriesDirectors.Count;
                        Current := 0;
                        repeat
                            Window.Update(1, SignatoriesDirectors.Name);
                            FPath := 'C:\Signatories\Picture\' + SignatoriesDirectors."Identification No." + '.JPEG';
                            if File.Exists(FPath) then SignatoriesDirectors."Passport Image".Import(FPath);
                            FPath := 'C:\Signatories\Signature\' + SignatoriesDirectors."Identification No." + '.JPEG';
                            if File.Exists(FPath) then SignatoriesDirectors."Signature Card".Import(FPath);
                            SignatoriesDirectors.Modify();
                            Current += 1;
                            Window.Update(2, Format(Current) + '  of  ' + Format(All));
                        until SignatoriesDirectors.Next() = 0;
                        Window.Close();
                    end;
                    Message('Imported');
                end;
            }
            action("Apply Images")
            {
                Visible = false;

                trigger OnAction()
                var
                    Members: Record Members;
                    FPath: Text;
                    Window: Dialog;
                    Vendor: Record Vendor;
                    All, Current : integer;
                begin
                    Members.Reset();
                    Members.SetFilter("Identification No.", '<>%1', '');
                    if Members.FindSet() then begin
                        Window.Open('Applying #1##/#2##');
                        All := Members.Count;
                        Current := 0;
                        repeat
                            Window.Update(1, Members.FullName);
                            FPath := 'C:\Images\Picture\' + Members."Identification No." + '.JPEG';
                            if File.Exists(FPath) then Members."Passport Size Photo".Import(FPath);
                            FPath := 'C:\Images\Signature\' + Members."Identification No." + '.JPEG';
                            if File.Exists(FPath) then Members.Signature.Import(FPath);
                            Members.Modify();
                            Current += 1;
                            Window.Update(2, Format(Current) + '  of  ' + Format(All));
                        until Members.Next() = 0;
                        Window.Close();
                    end;
                    Message('Imported');
                end;
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
        }
    }
    trigger OnOpenPage()
    begin
        SetControlAppearance;
    end;

    trigger OnAfterGetRecord()
    begin
        SetControlAppearance;
        FosaBal := 0;
        Vendor.Reset();
        Vendor.SetRange("Member No.", Rec."No.");
        Vendor.SetRange("Product Posting Type", Vendor."Product Posting Type"::"Withdrawable Deposit");
        If Vendor.FindSet then begin
            repeat
                Vendor.CalcFields(Balance);
                FosaBal += Vendor.Balance;
            until Vendor.Next = 0;
        end;
    end;

    local procedure SetControlAppearance()
    begin
        StyleText := 'Standard';
        if Rec."Protected Account" = true then StyleText := 'StrongAccent';
    end;

    var
        StyleText: Text;

    var
        MemberMgt: Codeunit "Member Management";
        PortalMgt: Codeunit "Channels Integrations";
        Vendor: Record Vendor;
        FosaBal: Decimal;
}

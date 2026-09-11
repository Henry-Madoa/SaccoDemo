codeunit 52204027 "User Profile Management"
{
    trigger OnRun()
    begin
        UserRolesSelection;
    end;

    var
        UserPersonalization: Record "User Personalization";
        UserProfilesAssigned: Record "User Profiles Assigned";
        UserProfilesAssigned2: Record "User Profiles Assigned";
        sessionSetting: SessionSettings;

    procedure OnInsertUserPersonalization(UserName: Code[50]; var UserProfile: Code[30])
    begin
        UserProfilesAssigned.Init;
        UserProfilesAssigned."User ID" := UserName;
        UserProfilesAssigned."Profile ID" := UserProfile;
        if not UserProfilesAssigned2.Get(UserName) then
            UserProfilesAssigned.Insert(true)
        else begin
            UserProfilesAssigned2."Profile ID" := UserProfile;
            UserProfilesAssigned2.Modify(true);
        end;
    end;

    procedure AssignNormalRoleCenter()
    begin
        if UserPersonalization.Get(UserSecurityId) then begin
            if UserProfilesAssigned.Get(UserId) then begin
                UserPersonalization."Profile ID" := UserProfilesAssigned."Profile ID";
                UserPersonalization.Modify(true);
                Commit;
                sessionSetting.Init();
                sessionSetting.ProfileId := UserProfilesAssigned."Profile ID";
                sessionSetting.RequestSessionUpdate(true);
            end;
        end;
        Commit;
    end;

    procedure UserRolesSelection()
    var
        MyRole: Record "User Personalization";
        UserSetup: Record "User Setup";
    begin
        if MyRole.Get(UserSecurityId) then begin
            if UserSetup.Get(UserId) then begin
                if (UserSetup."HR Admin" or UserSetup."Payroll Admin") then begin
                    if (MyRole."Profile ID" <> '') then begin
                        if ((MyRole."Profile ID" <> 'HR & PAYROLL')) then begin
                            if Confirm(StrSubstNo('Do you want to change your Profile from %1 to HR & Payroll Role Center?', MyRole."Profile ID"), false) = true then begin
                                OnInsertUserPersonalization(UserId, MyRole."Profile ID");
                                AssignHRPayrollRoleCenter();
                            end
                            else
                                exit;
                        end
                        else begin
                            if Confirm('Do you want to change your Profile from HR & Payroll Role Center to your Normal Role Center?', false) = true then
                                AssignNormalRoleCenter()
                            else
                                exit;
                        end;
                    end
                    else begin
                        if Confirm('Do you want to change your Profile from HR & Payroll Role Center to your Normal Role Center?', false) = true then
                            AssignNormalRoleCenter()
                        else
                            exit;
                    end;
                end;
            end;
        end;
    end;

    procedure AssignHRPayrollRoleCenter()
    begin
        UserPersonalization.Reset();
        UserPersonalization.SetRange("User ID", UserId);
        if UserPersonalization.FindFirst then begin
            UserPersonalization."Profile ID" := 'HR & PAYROLL';
            UserPersonalization.Modify(true);
            Commit;
            sessionSetting.Init();
            sessionSetting.ProfileId := 'HR & PAYROLL';
            sessionSetting.RequestSessionUpdate(true);
        end;
        Commit;
    end;
}

table 52203667 "Contract Change Request"
{
    DrillDownPageID = "Appraisal List";
    LookupPageID = "Appraisal List";

    fields
    {
        field(1; "Change No"; Code[20])
        {
        }
        field(2; "Employee No"; Code[20])
        {
            TableRelation = Employee."No." where("Nature Of Employment"=filter(<>Board), "Employee Status"=FILTER(Active|OnLeave));

            trigger OnValidate()
            begin
                if xRec."Employee No" <> Rec."Employee No" then begin
                    "Employee Name":='';
                    CDonorAllocationDetails.Reset;
                    CDonorAllocationDetails.SetRange("Change No", Rec."Change No");
                    if CDonorAllocationDetails.FindSet then CDonorAllocationDetails.DeleteAll;
                    CEmployeeContractDetails.Reset;
                    CEmployeeContractDetails.SetRange("Change No.", Rec."Change No");
                    if CEmployeeContractDetails.FindSet then CEmployeeContractDetails.DeleteAll;
                end;
                if EmployeesHR.Get("Employee No")then begin
                    "Employee Name":=EmployeesHR.FullName;
                    EmployeeContractDetails.Reset;
                    EmployeeContractDetails.SetRange("Employee No", Rec."Employee No");
                    EmployeeContractDetails.SetRange("Current Contract", true);
                    if EmployeeContractDetails.FindFirst then begin
                        CEmployeeContractDetails.Init;
                        CEmployeeContractDetails.TransferFields(EmployeeContractDetails);
                        CEmployeeContractDetails."Change No.":=Rec."Change No";
                        CEmployeeContractDetails.Insert;
                    end;
                    DonorAllocationDetails.Reset;
                    DonorAllocationDetails.SetRange("Employee No", Rec."Employee No");
                    DonorAllocationDetails.SetRange("Current Donor Details", true);
                    if DonorAllocationDetails.FindSet then begin
                        repeat CDonorAllocationDetails.Init;
                            CDonorAllocationDetails.TransferFields(DonorAllocationDetails);
                            CDonorAllocationDetails."Change No":=Rec."Change No";
                            CDonorAllocationDetails."C. Line No":=CDonorAllocationDetails.Count + 1;
                            CDonorAllocationDetails.Insert;
                        until DonorAllocationDetails.Next = 0;
                    end;
                end;
            end;
        }
        field(3; "Employee Name"; Text[70])
        {
        }
        field(4; Status; Option)
        {
            OptionCaption = 'New,Pending Apprroval,Approved,Rejected';
            OptionMembers = New, "Pending Apprroval", Approved, Rejected;

            trigger OnValidate()
            begin
                if Status <> Status::Approved then exit;
                with Rec do begin
                    CEmployeeContractDetails.Reset;
                    CEmployeeContractDetails.SetRange("Employee No", "Employee No");
                    CEmployeeContractDetails.SetRange("Change No.", "Change No");
                    CEmployeeContractDetails.SetRange("Current Contract", true);
                    if CEmployeeContractDetails.FindFirst then begin
                        CDonorAllocationDetails.Reset;
                        CDonorAllocationDetails.SetRange("Employee No", "Employee No");
                        CDonorAllocationDetails.SetRange("Change No", "Change No");
                        CDonorAllocationDetails.SetRange("Current Donor Details", false);
                        if CDonorAllocationDetails.FindSet then begin
                            DonorAllocationDetails.Reset;
                            DonorAllocationDetails.SetRange("Employee No", "Employee No");
                            DonorAllocationDetails.SetRange("Current Donor Details", true);
                            if DonorAllocationDetails.FindSet then begin
                                repeat DonorAllocationDetails."Current Donor Details":=false;
                                    DonorAllocationDetails.Modify(true);
                                until DonorAllocationDetails.Next = 0;
                            end;
                            repeat DonorAllocationDetails.Init;
                                DonorAllocationDetails."Line No.":=DonorAllocationDetails.Count + 1;
                                DonorAllocationDetails."Employee No":=CDonorAllocationDetails."Employee No";
                                DonorAllocationDetails.Donor:=CDonorAllocationDetails.Donor;
                                DonorAllocationDetails."Donor Name":=CDonorAllocationDetails."Donor Name";
                                DonorAllocationDetails."End Date of grant":=CDonorAllocationDetails."End Date of grant";
                                DonorAllocationDetails."Donor Name":=CDonorAllocationDetails."Donor Name";
                                DonorAllocationDetails.Percentage:=CDonorAllocationDetails.Percentage;
                                DonorAllocationDetails."Contract Line No":=CEmployeeContractDetails."Line No";
                                DonorAllocationDetails."Current Donor Details":=true;
                                if DonorAllocationDetails.Insert then begin
                                    Clear(Recipients);
                                    UserSetup.Reset;
                                    UserSetup.SetRange("HR Admin", true);
                                    if UserSetup.FindFirst then begin
                                        Recipients.Add(UserSetup."E-Mail");
                                        Subject:='Contract Change';
                                        Body:='Hello ' + Format(UserSetup."User ID") + '<br> The contract details of employee :' + Format("Employee Name") + 'has changed , please check on his employee card for further details ' + '<br> Regards';
                                        CommunicationsMgmt.SendEmailWithoutAttachement(Recipients, Subject, Body);
                                    end;
                                end;
                            until CDonorAllocationDetails.Next = 0;
                        end;
                    end;
                end;
            end;
        }
        field(5; "No. Series"; Code[10])
        {
        }
        field(6; "Created on"; Date)
        {
        }
        field(7; "Current Contract"; Integer)
        {
        }
        field(8; "Contract Code"; Code[10])
        {
        }
        field(9; "Contract Description"; Text[30])
        {
        }
        field(10; "Contract Start Date"; Date)
        {
        }
        field(11; "Contract End Date"; Date)
        {
        }
        field(12; "Contract Period"; DateFormula)
        {
        }
    }
    keys
    {
        key(Key1; "Change No")
        {
        }
    }
    trigger OnInsert()
    begin
        if "Change No" = '' then begin
            HumanResourcesSetup.Get;
            HumanResourcesSetup.TestField("Profile Nos");
            NoSeriesManagement.InitSeries(HumanResourcesSetup."Profile Nos", "No. Series", 0D, "Change No", "No. Series");
        end;
        "Created on":=WorkDate;
    end;
    var EmployeesHR: Record Employee;
    NoSeriesSetup: Record "Human Resource Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    UserSetup: Record "User Setup";
    EmployeeContractDetails: Record "Employee Contract Details";
    DonorAllocationDetails: Record "Donor Allocation Details";
    CEmployeeContractDetails: Record "C.Employee Contract Details";
    CDonorAllocationDetails: Record "C.Donor Allocation Details";
    ContractCode: Code[20];
    CommunicationsMgmt: Codeunit "Communications Mgmt";
    Body: Text;
    Recipients: List of[Text];
    Subject: Text;
    HumanResourcesSetup: Record "Human Resources Setup";
}

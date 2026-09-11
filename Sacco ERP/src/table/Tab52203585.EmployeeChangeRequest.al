table 52203585 "Employee Change Request"
{
    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Nature of Change"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Bio Data,Next Of Kin,Asset Assignment,Emergency Contacts,Beneficiaries,Medical Dependants,Qualifications,Proffesional Bodies,Work History,Contract Renewal,New Contract';
            OptionMembers = " ", "Bio Data", "Next Of Kin", "Asset Assignment", "Emergency Contacts", Beneficiaries, "Medical Dependants", Qualifications, "Proffesional Bodies", "Work History", "Contract Renewal", "New Contract", "Salary Increment";

            trigger OnValidate()
            begin
                if xRec."Nature of Change" <> Rec."Nature of Change" then begin
                    EmployeeQualificationChange.Reset;
                    EmployeeQualificationChange.SetRange("Change No", Rec."No.");
                    if EmployeeQualificationChange.FindSet then EmployeeQualificationChange.DeleteAll;
                    EmployeeWorkHistoryCH.Reset;
                    EmployeeWorkHistoryCH.SetRange("Change No", Rec."No.");
                    if EmployeeWorkHistoryCH.FindSet then EmployeeWorkHistoryCH.DeleteAll;
                    EmployeeDepandantsChange.Reset;
                    EmployeeDepandantsChange.SetRange("Change No", Rec."No.");
                    if EmployeeDepandantsChange.FindSet then EmployeeDepandantsChange.DeleteAll;
                    EmployeeEmergencyContactsC.Reset;
                    EmployeeEmergencyContactsC.SetRange("Change No", Rec."No.");
                    if EmployeeEmergencyContactsC.FindSet then EmployeeEmergencyContactsC.DeleteAll;
                    EmployeeRelativeChange.Reset;
                    EmployeeRelativeChange.SetRange("Change No", Rec."No.");
                    if EmployeeRelativeChange.FindSet then EmployeeRelativeChange.DeleteAll;
                    EmployeeProffesionalBodiesC.Reset;
                    EmployeeProffesionalBodiesC.SetRange("Change No", Rec."No.");
                    if EmployeeProffesionalBodiesC.FindSet then EmployeeProffesionalBodiesC.DeleteAll;
                    MiscArticleInformationCH.Reset;
                    MiscArticleInformationCH.SetRange("Change No", Rec."No.");
                    if MiscArticleInformationCH.FindSet then MiscArticleInformationCH.DeleteAll;
                    EmployeeBeneficiariesChange.Reset;
                    EmployeeBeneficiariesChange.SetRange("Change No", Rec."No.");
                    if EmployeeBeneficiariesChange.FindSet then EmployeeBeneficiariesChange.DeleteAll;
                    EmployeeBioDataChange.Reset;
                    EmployeeBioDataChange.SetRange("Change No.", Rec."No.");
                    if EmployeeBioDataChange.FindFirst then EmployeeBioDataChange.DeleteAll;
                end;
                if Rec."Nature of Change" in[Rec."Nature of Change"::Qualifications]then begin
                    EmployeeQualification.Reset;
                    EmployeeQualification.SetRange("Employee No.", Rec."Employee No");
                    if EmployeeQualification.FindSet then begin
                        repeat EmployeeQualificationChange.Init;
                            EmployeeQualificationChange.TransferFields(EmployeeQualification);
                            EmployeeQualificationChange."Change No":=Rec."No.";
                            EmployeeQualificationChange.Action:=EmployeeQualificationChange.Action::Existing;
                            EmployeeQualificationChange.Insert;
                        until EmployeeQualification.Next = 0;
                    end;
                end;
                if Rec."Nature of Change" in[Rec."Nature of Change"::"Emergency Contacts"]then begin
                    EmployeeEmergencyContacts.Reset;
                    EmployeeEmergencyContacts.SetRange("Employee No.", Rec."Employee No");
                    if EmployeeEmergencyContacts.FindSet then begin
                        repeat EmployeeEmergencyContactsC.Init;
                            EmployeeEmergencyContactsC.TransferFields(EmployeeEmergencyContacts);
                            EmployeeEmergencyContactsC."Change No":=Rec."No.";
                            EmployeeEmergencyContactsC.Action:=EmployeeEmergencyContactsC.Action::Retain;
                            EmployeeEmergencyContactsC.Insert;
                        until EmployeeEmergencyContacts.Next = 0;
                    end;
                end;
                if Rec."Nature of Change" in[Rec."Nature of Change"::"Bio Data"]then begin
                    if Employee.Get("Employee No")then begin
                        EmployeeBioDataChange.Init;
                        EmployeeBioDataChange."Line No.":=EmployeeBioDataChange.Count + 1;
                        EmployeeBioDataChange."Employee No.":=Employee."No.";
                        EmployeeBioDataChange."Phone Number":=Employee."Phone No.";
                        EmployeeBioDataChange."Change No.":=Rec."No.";
                        EmployeeBioDataChange."Passport No":=Employee."Passport Number";
                        EmployeeBioDataChange."Personal E-mail":=Employee."E-Mail";
                        EmployeeBioDataChange.Status:=EmployeeBioDataChange.Status::Current;
                        EmployeeBioDataChange.Insert;
                    end;
                end;
                if Rec."Nature of Change" in[Rec."Nature of Change"::Beneficiaries]then begin
                    EmployeeBeneficiaries.Reset;
                    EmployeeBeneficiaries.SetRange("Employee No.", Rec."Employee No");
                    if EmployeeBeneficiaries.FindSet then begin
                        repeat EmployeeBeneficiariesChange.Init;
                            EmployeeBeneficiariesChange.TransferFields(EmployeeBeneficiaries);
                            EmployeeBeneficiariesChange."Change No":=Rec."No.";
                            EmployeeBeneficiariesChange.Action:=EmployeeBeneficiariesChange.Action::Retain;
                            EmployeeBeneficiariesChange.Insert;
                        until EmployeeBeneficiaries.Next = 0;
                    end;
                end;
                if Rec."Nature of Change" in[Rec."Nature of Change"::"Medical Dependants"]then begin
                    EmployeeDepandants.Reset;
                    EmployeeDepandants.SetRange("Employee No.", Rec."Employee No");
                    if EmployeeDepandants.FindSet then begin
                        repeat EmployeeDepandantsChange.Init;
                            EmployeeDepandantsChange.TransferFields(EmployeeDepandants);
                            EmployeeDepandantsChange."Change No":=Rec."No.";
                            EmployeeDepandantsChange.Action:=EmployeeDepandantsChange.Action::Retain;
                            EmployeeDepandantsChange.Insert;
                        until EmployeeDepandants.Next = 0;
                    end;
                end;
                if Rec."Nature of Change" in[Rec."Nature of Change"::"Next Of Kin"]then begin
                    EmployeeRelative.Reset;
                    EmployeeRelative.SetRange("Employee No.", Rec."Employee No");
                    if EmployeeRelative.FindSet then begin
                        repeat EmployeeRelativeChange.Init;
                            EmployeeRelativeChange.TransferFields(EmployeeRelative);
                            EmployeeRelativeChange."Change No":=Rec."No.";
                            EmployeeRelativeChange.Action:=EmployeeRelativeChange.Action::Retain;
                            EmployeeRelativeChange.Insert;
                        until EmployeeRelative.Next = 0;
                    end;
                end;
                if Rec."Nature of Change" in[Rec."Nature of Change"::"Proffesional Bodies"]then begin
                    EmployeeProffesionalBodies.Reset;
                    EmployeeProffesionalBodies.SetRange("Employee No.", Rec."Employee No");
                    if EmployeeProffesionalBodies.FindSet then begin
                        repeat EmployeeProffesionalBodiesC.Init;
                            EmployeeProffesionalBodiesC.TransferFields(EmployeeProffesionalBodies);
                            EmployeeProffesionalBodiesC."Change No":=Rec."No.";
                            EmployeeProffesionalBodiesC.Action:=EmployeeProffesionalBodiesC.Action::Retain;
                            EmployeeProffesionalBodiesC.Insert;
                        until EmployeeProffesionalBodies.Next = 0;
                    end;
                end;
                if Rec."Nature of Change" in[Rec."Nature of Change"::"Work History"]then begin
                    EmployeeWorkHistory.Reset;
                    EmployeeWorkHistory.SetRange("Employee No.", Rec."Employee No");
                    if EmployeeWorkHistory.FindSet then begin
                        repeat EmployeeWorkHistoryCH.Init;
                            EmployeeWorkHistoryCH.TransferFields(EmployeeWorkHistory);
                            EmployeeWorkHistoryCH."Change No":=Rec."No.";
                            EmployeeWorkHistoryCH.Action:=EmployeeWorkHistoryCH.Action::Existing;
                            EmployeeWorkHistoryCH.Insert;
                        until EmployeeWorkHistory.Next = 0;
                    end;
                end;
            /*if Rec."Nature of Change" in [Rec."Nature of Change"::"Asset Assignment"] THEN
                              BEGIN
                                MiscArticleInformation.RESET;
                                MiscArticleInformation.SETRANGE("Employee No.",Rec."Employee No");
                                IF MiscArticleInformation.FINDSET THEN
                                  BEGIN
                                    REPEAT
                                      MiscArticleInformationCH.INIT;
                                      MiscArticleInformationCH.TRANSFERFIELDS(MiscArticleInformation);
                                      MiscArticleInformationCH."Change No":=Rec."No.";
                                      MiscArticleInformationCH.Action:=MiscArticleInformationCH.Action::Retain;
                                      MiscArticleInformationCH.INSERT;
                                    UNTIL MiscArticleInformation.NEXT=0;
                                  end;
                              end;*/
            end;
        }
        field(3; "Employee No"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = if("Nature Of Change"=const("New Contract"))Employee where("Employee Status"=const(Active), "Nature Of Employment"=CONST(Contract))
            else if("Nature of Change"=const("Contract Renewal"))Employee where("Employee Status"=filter(Active|Onleave), "Nature Of Employment"=const(Contract))
            else
            Employee where("Nature Of Employment"=filter(<>Board), "Employee Status"=filter(Active|Onleave));

            trigger OnValidate()
            begin
                if Employee.Get("Employee No")then begin
                    "Employee Name":=Employee.FullName;
                    if Rec."Nature of Change" in[Rec."Nature of Change"::"salary Increment"]then begin
                        "Current Grade":=Employee."Job Scale";
                        "Current Pointer":=Employee."J-G Steps";
                        "Current Salary Grade":=Employee."Job Scale" + '.' + Employee."J-G Steps";
                    end;
                end
                else
                    "Employee Name":='';
                if xRec."Employee No" <> Rec."Employee No" then begin
                    EmployeeQualificationChange.Reset;
                    EmployeeQualificationChange.SetRange("Change No", Rec."No.");
                    if EmployeeQualificationChange.FindSet then EmployeeQualificationChange.DeleteAll;
                    EmployeeWorkHistoryCH.Reset;
                    EmployeeWorkHistoryCH.SetRange("Change No", Rec."No.");
                    if EmployeeWorkHistoryCH.FindSet then EmployeeWorkHistoryCH.DeleteAll;
                    EmployeeDepandantsChange.Reset;
                    EmployeeDepandantsChange.SetRange("Change No", Rec."No.");
                    if EmployeeDepandantsChange.FindSet then EmployeeDepandantsChange.DeleteAll;
                    EmployeeEmergencyContactsC.Reset;
                    EmployeeEmergencyContactsC.SetRange("Change No", Rec."No.");
                    if EmployeeEmergencyContactsC.FindSet then EmployeeEmergencyContactsC.DeleteAll;
                    EmployeeRelativeChange.Reset;
                    EmployeeRelativeChange.SetRange("Change No", Rec."No.");
                    if EmployeeRelativeChange.FindSet then EmployeeRelativeChange.DeleteAll;
                    EmployeeProffesionalBodiesC.Reset;
                    EmployeeProffesionalBodiesC.SetRange("Change No", Rec."No.");
                    if EmployeeProffesionalBodiesC.FindSet then EmployeeProffesionalBodiesC.DeleteAll;
                    MiscArticleInformationCH.Reset;
                    MiscArticleInformationCH.SetRange("Change No", Rec."No.");
                    if MiscArticleInformationCH.FindSet then MiscArticleInformationCH.DeleteAll;
                    EmployeeBioDataChange.Reset;
                    EmployeeBioDataChange.SetRange("Change No.", Rec."No.");
                    if EmployeeBioDataChange.FindFirst then EmployeeBioDataChange.DeleteAll;
                end;
                if Rec."Nature of Change" in[Rec."Nature of Change"::Qualifications]then begin
                    EmployeeQualification.Reset;
                    EmployeeQualification.SetRange("Employee No.", Rec."Employee No");
                    if EmployeeQualification.FindSet then begin
                        repeat EmployeeQualificationChange.Init;
                            EmployeeQualificationChange.TransferFields(EmployeeQualification);
                            EmployeeQualificationChange."Change No":=Rec."No.";
                            EmployeeQualificationChange.Action:=EmployeeQualificationChange.Action::Existing;
                            EmployeeQualificationChange.Insert;
                        until EmployeeQualification.Next = 0;
                    end;
                end;
                if Rec."Nature of Change" in[Rec."Nature of Change"::"Emergency Contacts"]then begin
                    EmployeeEmergencyContacts.Reset;
                    EmployeeEmergencyContacts.SetRange("Employee No.", Rec."Employee No");
                    if EmployeeEmergencyContacts.FindSet then begin
                        repeat EmployeeEmergencyContactsC.Init;
                            EmployeeEmergencyContactsC.TransferFields(EmployeeEmergencyContacts);
                            EmployeeEmergencyContactsC."Change No":=Rec."No.";
                            EmployeeEmergencyContactsC.Action:=EmployeeEmergencyContactsC.Action::Retain;
                            EmployeeEmergencyContactsC.Insert;
                        until EmployeeEmergencyContacts.Next = 0;
                    end;
                end;
                if Rec."Nature of Change" in[Rec."Nature of Change"::Beneficiaries]then begin
                    EmployeeBeneficiaries.Reset;
                    EmployeeBeneficiaries.SetRange("Employee No.", Rec."Employee No");
                    if EmployeeBeneficiaries.FindSet then begin
                        repeat EmployeeBeneficiariesChange.Init;
                            EmployeeBeneficiariesChange.TransferFields(EmployeeBeneficiaries);
                            EmployeeBeneficiariesChange."Change No":=Rec."No.";
                            EmployeeBeneficiariesChange.Action:=EmployeeBeneficiariesChange.Action::Retain;
                            EmployeeBeneficiariesChange.Insert;
                        until EmployeeBeneficiaries.Next = 0;
                    end;
                end;
                if Rec."Nature of Change" in[Rec."Nature of Change"::"Medical Dependants"]then begin
                    EmployeeDepandants.Reset;
                    EmployeeDepandants.SetRange("Employee No.", Rec."Employee No");
                    if EmployeeDepandants.FindSet then begin
                        repeat EmployeeDepandantsChange.Init;
                            EmployeeDepandantsChange.TransferFields(EmployeeDepandants);
                            EmployeeDepandantsChange."Change No":=Rec."No.";
                            EmployeeDepandantsChange.Action:=EmployeeDepandantsChange.Action::Retain;
                            EmployeeDepandantsChange.Insert;
                        until EmployeeDepandants.Next = 0;
                    end;
                end;
                if Rec."Nature of Change" in[Rec."Nature of Change"::"Next Of Kin"]then begin
                    EmployeeRelative.Reset;
                    EmployeeRelative.SetRange("Employee No.", Rec."Employee No");
                    if EmployeeRelative.FindSet then begin
                        repeat EmployeeRelativeChange.Init;
                            EmployeeRelativeChange.TransferFields(EmployeeRelative);
                            EmployeeRelativeChange."Change No":=Rec."No.";
                            EmployeeRelativeChange.Action:=EmployeeRelativeChange.Action::Retain;
                            EmployeeRelativeChange.Insert;
                        until EmployeeRelative.Next = 0;
                    end;
                end;
                if Rec."Nature of Change" in[Rec."Nature of Change"::"Proffesional Bodies"]then begin
                    EmployeeProffesionalBodies.Reset;
                    EmployeeProffesionalBodies.SetRange("Employee No.", Rec."Employee No");
                    if EmployeeProffesionalBodies.FindSet then begin
                        repeat EmployeeProffesionalBodiesC.Init;
                            EmployeeProffesionalBodiesC.TransferFields(EmployeeProffesionalBodies);
                            EmployeeProffesionalBodiesC."Change No":=Rec."No.";
                            EmployeeProffesionalBodiesC.Action:=EmployeeProffesionalBodiesC.Action::Retain;
                            EmployeeProffesionalBodiesC.Insert;
                        until EmployeeProffesionalBodies.Next = 0;
                    end;
                end;
                if Rec."Nature of Change" in[Rec."Nature of Change"::"Work History"]then begin
                    EmployeeWorkHistory.Reset;
                    EmployeeWorkHistory.SetRange("Employee No.", Rec."Employee No");
                    if EmployeeWorkHistory.FindSet then begin
                        repeat EmployeeWorkHistoryCH.Init;
                            EmployeeWorkHistoryCH.TransferFields(EmployeeWorkHistory);
                            EmployeeWorkHistoryCH."Change No":=Rec."No.";
                            EmployeeWorkHistoryCH.Action:=EmployeeWorkHistoryCH.Action::Existing;
                            EmployeeWorkHistoryCH.Insert;
                        until EmployeeWorkHistory.Next = 0;
                    end;
                end;
                /*if Rec."Nature of Change" in [Rec."Nature of Change"::"Asset Assignment"] THEN
                      BEGIN
                        MiscArticleInformation.RESET;
                        MiscArticleInformation.SETRANGE("Employee No.",Rec."Employee No");
                        IF MiscArticleInformation.FINDSET THEN
                          BEGIN
                            REPEAT
                              MiscArticleInformationCH.INIT;
                              MiscArticleInformationCH.TRANSFERFIELDS(MiscArticleInformation);
                              MiscArticleInformationCH."Change No":=Rec."No.";
                              MiscArticleInformationCH.Action:=MiscArticleInformationCH.Action::Retain;
                              MiscArticleInformationCH.INSERT;
                            UNTIL MiscArticleInformation.NEXT=0;
                          end;
                      end;*/
                if Rec."Nature of Change" in[Rec."Nature of Change"::"New Contract"]then begin
                    if Employee.Get("Employee No")then begin
                        Employee.TestField("Job Scale");
                        Employee.TestField("J-G Steps");
                        Employee.TestField("Manager No.");
                        Employee.TestField("Global Dimension 1 Code");
                    //Employee.TESTFIELD("Job Title");
                    end;
                end;
                if Rec."Nature of Change" in[Rec."Nature of Change"::"Bio Data"]then begin
                    if Employee.Get("Employee No")then begin
                        EmployeeBioDataChange.Init;
                        EmployeeBioDataChange."Line No.":=EmployeeBioDataChange.Count + 1;
                        EmployeeBioDataChange."Employee No.":=Employee."No.";
                        EmployeeBioDataChange."Phone Number":=Employee."Phone No.";
                        EmployeeBioDataChange."Change No.":=Rec."No.";
                        EmployeeBioDataChange."Passport No":=Employee."Passport Number";
                        EmployeeBioDataChange."Personal E-mail":=Employee."E-Mail";
                        EmployeeBioDataChange.Status:=EmployeeBioDataChange.Status::Current;
                        EmployeeBioDataChange.Insert;
                    end;
                end;
                if Rec."Nature of Change" in[Rec."Nature of Change"::"Contract Renewal", "Nature of Change"::"Salary Increment"]then begin //    EmployeeChangeRequest.RESET;
                    if Employee.Get("Employee No")then begin
                        "Employee Name":=Employee.FullName;
                    end;
                    if Rec."Employee No" <> xRec."Employee No" then begin
                        ContractChangeLines.Reset;
                        ContractChangeLines.SetRange("Change No", Rec."No.");
                        if ContractChangeLines.FindSet then ContractChangeLines.DeleteAll;
                    end;
                    EmployeeContractDetails.Reset;
                    EmployeeContractDetails.SetRange("Employee No", Rec."Employee No");
                    EmployeeContractDetails.SetRange("Contract Status", EmployeeContractDetails."Contract Status"::Active);
                    if EmployeeContractDetails.FindFirst then begin
                        ContractChangeLines.Init;
                        ContractChangeLines.TransferFields(EmployeeContractDetails);
                        Employee.Get("Employee No");
                        ContractChangeLines.Pointer:=Employee."J-G Steps";
                        ContractChangeLines."Change No":="No.";
                        ContractChangeLines.Status:=ContractChangeLines.Status::Current;
                        ContractChangeLines.Insert;
                    end;
                end;
            end;
        }
        field(4; "Employee Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Current Grade"; Code[10])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "Employee Payroll Scales".Scale;
        }
        field(6; "New Grade"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Employee Payroll Scales".Scale;
        }
        field(7; "Current Contract"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(8; "New Contract"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Current Location"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = Location.Code;
        }
        field(10; "New Location"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location.Code;
        }
        field(11; "Current Department"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));
        }
        field(12; "Current Basic Pay"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(13; "New Basic Pay"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(14; Executed; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(15; "Created By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Created On"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "New Department"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(2), Blocked=const(false));
        }
        field(19; "Current Project"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
        }
        field(20; "New Project"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No."=CONST(1), Blocked=const(false));
        }
        field(21; "Current Job"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "Company Jobs";
        }
        field(22; "New Job"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Company Jobs";
        }
        field(23; Status;Enum "Document Status")
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Rec.Status = Rec.Status::Approved then begin
                    ChangeRequestManagement.EffectChangesOfApprovedRequest(Rec);
                end;
            end;
        }
        field(24; "Approval Entries"; Integer)
        {
            CalcFormula = Count("Approval Entry" WHERE("Document No."=FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(25; "Current Pointer"; Code[10])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "Salary Scale Pointers".Pointer WHERE(Scale=FIELD("New Grade"));
        }
        field(26; "New Pointer"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Salary Scale Pointers".Pointer WHERE(Scale=FIELD("New Grade"));

            trigger OnValidate()
            begin
                "New Salary Grade":="New Grade" + '.' + "New Pointer";
                ContractChangeLines.Reset;
                ContractChangeLines.SetRange("Change No", "No.");
                if ContractChangeLines.FindFirst then begin
                    if SalaryScalePointers.Get("New Grade", "New Pointer")then begin
                        ContractChangeLines."New Salary":=SalaryScalePointers."Basic Pay";
                        ContractChangeLines.Modify(true);
                    end;
                end;
            end;
        }
        field(27; "New Salary Grade"; Code[10])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(28; "Current Salary Grade"; Code[10])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(29; "Last Modified By"; Code[70])
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Last Date Modified"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(31; "Approval Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "No.")
        {
        }
    }
    trigger OnInsert()
    begin
        if "No." = '' then begin
            HumanResourcesSetup.Get;
            HumanResourcesSetup.TestField("Change Request Nos.");
            NoSeriesManagement.InitSeries(HumanResourcesSetup."Change Request Nos.", "No. Series", 0D, "No.", "No. Series");
        end;
        "Created On":=WorkDate;
        // if not HumanResourceMgmt.IsWebServiceUser then
        "Created By":=UserId;
        if Rec."Nature of Change" in[Rec."Nature of Change"::Qualifications]then if UserSetup.Get(UserId)then Validate("Employee No", UserSetup."Employee No.");
    end;
    trigger OnModify()
    begin
        "Last Modified By":=UserId;
        "Last Date Modified":=CreateDateTime(Today, Time);
        ;
    end;
    var HumanResourcesSetup: Record "Human Resources Setup";
    NoSeriesManagement: Codeunit NoSeriesManagement;
    UserSetup: Record "User Setup";
    Employee: Record Employee;
    PayrollSalaryCard: Record "Payroll Salary Card";
    ContractChangeLines: Record "Contract Change Lines";
    EmployeeContractDetails: Record "Employee Contract Details";
    EmployeeQualification: Record "Employee Qualification";
    EmployeeQualificationChange: Record "Employee Qualification Change";
    EmployeeRelative: Record "Employee Relative";
    EmployeeRelativeChange: Record "Employee Relative Change";
    EmployeeEmergencyContacts: Record "Employee Emergency Contacts";
    EmployeeEmergencyContactsC: Record "Employee Emergency Contacts C";
    EmployeeProffesionalBodies: Record "Employee Proffesional Bodies";
    EmployeeProffesionalBodiesC: Record "Employee Proffesional Bodies C";
    EmployeeDepandants: Record "Employee Depandants";
    EmployeeDepandantsChange: Record "Employee Depandants Change";
    EmployeeWorkHistory: Record "Employee Work History";
    EmployeeWorkHistoryCH: Record "Employee Work History CH";
    EmployeeBeneficiaries: Record "Employee Beneficiaries";
    EmployeeBeneficiariesChange: Record "Employee Beneficiaries Change";
    MiscArticleInformationCH: Record "Misc. Article Information CH";
    MiscArticleInformation: Record "Misc. Article Information";
    SalaryScalePointers: Record "Salary Scale Pointers";
    HumanResourceMgmt: Codeunit "Human Resource Management";
    EmployeeChangeRequest: Record "Employee Change Request";
    EmployeeBioDataChange: Record "Employee Bio Data Change";
    EmployeeMgmt: Codeunit "Employee Management";
    ChangeRequestManagement: Codeunit "Change Request Management";
}

report 52203534 Payslip
{
    DefaultLayout = RDLC;
    RDLCLayout = './ssrs/Payslip.rdl';

    dataset
    {
        dataitem(Employee; Employee)
        {
            DataItemTableView = SORTING("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Period Filter";

            column(COMPANYNAME; CompanyName)
            {
            }
            column(CompanyInfo_Picture; CompanyInfo.Picture)
            {
            }
            column(IDNumber_HREmployees; Employee."National ID")
            {
            }
            column(DOB_HREmployees; Employee."Birth Date")
            {
            }
            column(COMPANYNAME_Control1102756028; CompanyInfo.Name)
            {
            }
            column(CompanyInfo_Picture_Control1102756013; CompanyInfo.Picture)
            {
            }
            column(CompanyInfoCompanyWatermark; CompanyInfo."Company Watermark")
            {
            }
            column(HR_Employee_No_; "No.")
            {
            }
            column(GlobalDimension1Code_HREmployees; "Global Dimension 1 Code")
            {
            }
            column(PINNo_HREmployees; "KRA Number")
            {
            }
            column(NSSFNo_HREmployees; "NSSF No.")
            {
            }
            column(SHIFNo_HREmployees; "SHIF No.")
            {
            }
            column(GlobalDimension2Code_HREmployees; "Global Dimension 2 Code")
            {
            }
            column(JobTitle_HREmployees; "Job Title")
            {
            }
            column(Spacer; Spacer)
            {
            }
            column(CountyName; CountyName)
            {
            }
            column(Birth_Date; "Birth Date")
            {
            }
            column(Employment_Date; "Employment Date")
            {
            }
            column(Retirement_Date; Retirement_Date)
            {
            }
            dataitem("Payroll Salary Card"; "Payroll Salary Card")
            {
                DataItemLink = "Employee Code"=FIELD("No.");
                DataItemTableView = SORTING("Employee Code")ORDER(Ascending);
                PrintOnlyIfDetail = false;

                column(NoDaysWorked; NoDaysWorked)
                {
                }
                column(RatePerDay; RatePerDay)
                {
                }
                column(Trans_1__1_; Trans[1][1])
                {
                }
                column(TransAmt_1__1_; TransAmt[1][1])
                {
                }
                column(TransBal_1__1_; TransBal[1][1])
                {
                }
                column(TransBal_1__2_; TransBal[1][2])
                {
                }
                column(TransAmt_1__2_; TransAmt[1][2])
                {
                }
                column(Trans_1__2_; Trans[1][2])
                {
                }
                column(TransBal_1__3_; TransBal[1][3])
                {
                }
                column(TransAmt_1__3_; TransAmt[1][3])
                {
                }
                column(Trans_1__3_; Trans[1][3])
                {
                }
                column(TransBal_1__4_; TransBal[1][4])
                {
                }
                column(TransBal_1__5_; TransBal[1][5])
                {
                }
                column(TransBal_1__6_; TransBal[1][6])
                {
                }
                column(TransAmt_1__4_; TransAmt[1][4])
                {
                }
                column(TransAmt_1__5_; TransAmt[1][5])
                {
                }
                column(TransAmt_1__6_; TransAmt[1][6])
                {
                }
                column(Trans_1__4_; Trans[1][4])
                {
                }
                column(Trans_1__5_; Trans[1][5])
                {
                }
                column(Trans_1__6_; Trans[1][6])
                {
                }
                column(TransBal_1__7_; TransBal[1][7])
                {
                }
                column(TransBal_1__8_; TransBal[1][8])
                {
                }
                column(TransBal_1__9_; TransBal[1][9])
                {
                }
                column(TransAmt_1__7_; TransAmt[1][7])
                {
                }
                column(TransAmt_1__8_; TransAmt[1][8])
                {
                }
                column(TransAmt_1__9_; TransAmt[1][9])
                {
                }
                column(Trans_1__7_; Trans[1][7])
                {
                }
                column(Trans_1__8_; Trans[1][8])
                {
                }
                column(Trans_1__9_; Trans[1][9])
                {
                }
                column(TransBal_1__10_; TransBal[1][10])
                {
                }
                column(TransBal_1__12_; TransBal[1][12])
                {
                }
                column(TransBal_1__13_; TransBal[1][13])
                {
                }
                column(TransAmt_1__10_; TransAmt[1][10])
                {
                }
                column(TransAmt_1__12_; TransAmt[1][12])
                {
                }
                column(TransAmt_1__13_; TransAmt[1][13])
                {
                }
                column(Trans_1__10_; Trans[1][10])
                {
                }
                column(Trans_1__12_; Trans[1][12])
                {
                }
                column(Trans_1__13_; Trans[1][13])
                {
                }
                column(TransBal_1__14_; TransBal[1][14])
                {
                }
                column(TransBal_1__15_; TransBal[1][15])
                {
                }
                column(TransBal_1__16_; TransBal[1][16])
                {
                }
                column(TransBal_1__17_; TransBal[1][17])
                {
                }
                column(TransBal_1__18_; TransBal[1][18])
                {
                }
                column(TransBal_1__19_; TransBal[1][19])
                {
                }
                column(TransBal_1__11_; TransBal[1][11])
                {
                }
                column(TransBal_1__20_; TransBal[1][20])
                {
                }
                column(TransAmt_1__14_; TransAmt[1][14])
                {
                }
                column(TransAmt_1__15_; TransAmt[1][15])
                {
                }
                column(TransAmt_1__16_; TransAmt[1][16])
                {
                }
                column(TransAmt_1__17_; TransAmt[1][17])
                {
                }
                column(TransAmt_1__18_; TransAmt[1][18])
                {
                }
                column(TransAmt_1__19_; TransAmt[1][19])
                {
                }
                column(TransAmt_1__11_; TransAmt[1][11])
                {
                }
                column(TransAmt_1__20_; TransAmt[1][20])
                {
                }
                column(Trans_1__14_; Trans[1][14])
                {
                }
                column(Trans_1__15_; Trans[1][15])
                {
                }
                column(Trans_1__16_; Trans[1][16])
                {
                }
                column(Trans_1__17_; Trans[1][17])
                {
                }
                column(Trans_1__18_; Trans[1][18])
                {
                }
                column(Trans_1__19_; Trans[1][19])
                {
                }
                column(Trans_1__11_; Trans[1][11])
                {
                }
                column(Trans_1__20_; Trans[1][20])
                {
                }
                column(Addr_1__1_; Addr[1][1])
                {
                }
                column(Addr_1__2_; Addr[1][2])
                {
                }
                column(Addr_1__3_; Addr[1][3])
                {
                }
                column(TransBal_1__21_; TransBal[1][21])
                {
                }
                column(TransBal_1__22_; TransBal[1][22])
                {
                }
                column(TransAmt_1__21_; TransAmt[1][21])
                {
                }
                column(TransAmt_1__22_; TransAmt[1][22])
                {
                }
                column(TransBal_1__23_; TransBal[1][23])
                {
                }
                column(TransAmt_1__23_; TransAmt[1][23])
                {
                }
                column(TransBal_1__24_; TransBal[1][24])
                {
                }
                column(TransAmt_1__24_; TransAmt[1][24])
                {
                }
                column(Trans_1__21_; Trans[1][21])
                {
                }
                column(Trans_1__23_; Trans[1][23])
                {
                }
                column(Trans_1__24_; Trans[1][24])
                {
                }
                column(Trans_1__22_; Trans[1][22])
                {
                }
                column(TransBal_1__25_; TransBal[1][25])
                {
                }
                column(TransAmt_1__25_; TransAmt[1][25])
                {
                }
                column(Trans_1__25_; Trans[1][25])
                {
                }
                column(TransBal_1__26_; TransBal[1][26])
                {
                }
                column(TransAmt_1__26_; TransAmt[1][26])
                {
                }
                column(Trans_1__26_; Trans[1][26])
                {
                }
                column(TransBal_1__27_; TransBal[1][27])
                {
                }
                column(TransAmt_1__27_; TransAmt[1][27])
                {
                }
                column(Trans_1__27_; Trans[1][27])
                {
                }
                column(TransBal_1__28_; TransBal[1][28])
                {
                }
                column(TransAmt_1__28_; TransAmt[1][28])
                {
                }
                column(Trans_1__28_; Trans[1][28])
                {
                }
                column(TransBal_1__29_; TransBal[1][29])
                {
                }
                column(TransAmt_1__29_; TransAmt[1][29])
                {
                }
                column(Trans_1__29_; Trans[1][29])
                {
                }
                column(TransBal_1__30_; TransBal[1][30])
                {
                }
                column(TransAmt_1__30_; TransAmt[1][30])
                {
                }
                column(Trans_1__30_; Trans[1][30])
                {
                }
                column(TransBal_1__31_; TransBal[1][31])
                {
                }
                column(TransAmt_1__31_; TransAmt[1][31])
                {
                }
                column(Trans_1__31_; Trans[1][31])
                {
                }
                column(TransBal_1__32_; TransBal[1][32])
                {
                }
                column(TransBal_1__33_; TransBal[1][33])
                {
                }
                column(TransBal_1__34_; TransBal[1][34])
                {
                }
                column(TransBal_1__35_; TransBal[1][35])
                {
                }
                column(TransBal_1__36_; TransBal[1][36])
                {
                }
                column(TransBal_1__37_; TransBal[1][37])
                {
                }
                column(TransBal_1__38_; TransBal[1][38])
                {
                }
                column(TransBal_1__39_; TransBal[1][39])
                {
                }
                column(TransBal_1__40_; TransBal[1][40])
                {
                }
                column(TransAmt_1__32_; TransAmt[1][32])
                {
                }
                column(TransAmt_1__33_; TransAmt[1][33])
                {
                }
                column(TransAmt_1__34_; TransAmt[1][34])
                {
                }
                column(TransAmt_1__35_; TransAmt[1][35])
                {
                }
                column(TransAmt_1__36_; TransAmt[1][36])
                {
                }
                column(TransAmt_1__37_; TransAmt[1][37])
                {
                }
                column(TransAmt_1__38_; TransAmt[1][38])
                {
                }
                column(TransAmt_1__39_; TransAmt[1][39])
                {
                }
                column(TransAmt_1__40_; TransAmt[1][40])
                {
                }
                column(Trans_1__32_; Trans[1][32])
                {
                }
                column(Trans_1__34_; Trans[1][34])
                {
                }
                column(Trans_1__35_; Trans[1][35])
                {
                }
                column(Trans_1__33_; Trans[1][33])
                {
                }
                column(Trans_1__36_; Trans[1][36])
                {
                }
                column(Trans_1__37_; Trans[1][37])
                {
                }
                column(Trans_1__38_; Trans[1][38])
                {
                }
                column(Trans_1__39_; Trans[1][39])
                {
                }
                column(Trans_1__40_; Trans[1][40])
                {
                }
                column(Trans_1__45_; Trans[1][45])
                {
                }
                column(TransAmt_1__45_; TransAmt[1][45])
                {
                }
                column(TransAmt_1__46_; TransAmt[1][46])
                {
                }
                column(TransAmt_1__47_; TransAmt[1][47])
                {
                }
                column(TransAmt_1__48_; TransAmt[1][48])
                {
                }
                column(TransAmt_1__49_; TransAmt[1][49])
                {
                }
                column(Trans_1__46_; Trans[1][46])
                {
                }
                column(Trans_1__47_; Trans[1][47])
                {
                }
                column(Trans_1__48_; Trans[1][48])
                {
                }
                column(Trans_1__49_; Trans[1][49])
                {
                }
                column(TransAmt_1__50_; TransAmt[1][50])
                {
                }
                column(TransAmt_1__51_; TransAmt[1][51])
                {
                }
                column(Trans_1__50_; Trans[1][50])
                {
                }
                column(Trans_1__51_; Trans[1][51])
                {
                }
                column(Trans_1__53_; Trans[1][53])
                {
                }
                column(TransBal_1__42_; TransBal[1][42])
                {
                }
                column(TransAmt_1__42_; TransAmt[1][42])
                {
                }
                column(Trans_1__42_; Trans[1][42])
                {
                }
                column(TransBal_1__43_; TransBal[1][43])
                {
                }
                column(TransAmt_1__43_; TransAmt[1][43])
                {
                }
                column(Trans_1__43_; Trans[1][43])
                {
                }
                column(TransBal_1__44_; TransBal[1][44])
                {
                }
                column(TransAmt_1__44_; TransAmt[1][44])
                {
                }
                column(Trans_1__44_; Trans[1][44])
                {
                }
                column(Trans_1__41_; Trans[1][41])
                {
                }
                column(TransAmt_1__41_; TransAmt[1][41])
                {
                }
                column(TransBal_1__41_; TransBal[1][41])
                {
                }
                column(TransAmt_1__52_; TransAmt[1][52])
                {
                }
                column(Trans_1__52_; Trans[1][52])
                {
                }
                column(TransBal_1__45_; TransBal[1][45])
                {
                }
                column(TransBal_1__46_; TransBal[1][46])
                {
                }
                column(TransBal_1__47_; TransBal[1][47])
                {
                }
                column(TransBal_1__48_; TransBal[1][48])
                {
                }
                column(TransBal_1__49_; TransBal[1][49])
                {
                }
                column(TransBal_1__50_; TransBal[1][50])
                {
                }
                column(TransBal_1__51_; TransBal[1][51])
                {
                }
                column(TransBal_1__52_; TransBal[1][52])
                {
                }
                column(TransBal_1__53_; TransBal[1][53])
                {
                }
                column(TransBal_1__54_; TransBal[1][54])
                {
                }
                column(Trans_1__54_; Trans[1][54])
                {
                }
                column(TransAmt_1__53_; TransAmt[1][53])
                {
                }
                column(TransAmt_1__54_; TransAmt[1][54])
                {
                }
                column(Trans_1__55_; Trans[1][55])
                {
                }
                column(TransBal_1__55_; TransBal[1][55])
                {
                }
                column(TransAmt_1__55_; TransAmt[1][55])
                {
                }
                column(Trans_1__56_; Trans[1][56])
                {
                }
                column(TransBal_1__56_; TransBal[1][56])
                {
                }
                column(TransAmt_1__56_; TransAmt[1][56])
                {
                }
                column(Trans_1__57_; Trans[1][57])
                {
                }
                column(TransBal_1__57_; TransBal[1][57])
                {
                }
                column(TransAmt_1__57_; TransAmt[1][57])
                {
                }
                column(Trans_1__58_; Trans[1][58])
                {
                }
                column(TransBal_1__58_; TransBal[1][58])
                {
                }
                column(TransAmt_1__58_; TransAmt[1][58])
                {
                }
                column(Trans_1__59_; Trans[1][59])
                {
                }
                column(TransBal_1__59_; TransBal[1][59])
                {
                }
                column(TransAmt_1__59_; TransAmt[1][59])
                {
                }
                column(Trans_1__60_; Trans[1][60])
                {
                }
                column(TransBal_1__60_; TransBal[1][60])
                {
                }
                column(TransAmt_1__60_; TransAmt[1][60])
                {
                }
                column(Trans_1__61_; Trans[1][61])
                {
                }
                column(TransBal_1__61_; TransBal[1][61])
                {
                }
                column(TransAmt_1__61_; TransAmt[1][61])
                {
                }
                column(Trans_1__62_; Trans[1][62])
                {
                }
                column(TransBal_1__62_; TransBal[1][62])
                {
                }
                column(TransAmt_1__62_; TransAmt[1][62])
                {
                }
                column(Trans_1__63_; Trans[1][63])
                {
                }
                column(TransBal_1__63_; TransBal[1][63])
                {
                }
                column(TransAmt_1__63_; TransAmt[1][63])
                {
                }
                column(Trans_1__64_; Trans[1][64])
                {
                }
                column(TransBal_1__64_; TransBal[1][64])
                {
                }
                column(TransAmt_1__64_; TransAmt[1][64])
                {
                }
                column(Trans_1__65_; Trans[1][55])
                {
                }
                column(TransBal_1__65_; TransBal[1][65])
                {
                }
                column(TransAmt_1__65_; TransAmt[1][65])
                {
                }
                column(Trans_1__66_; Trans[1][66])
                {
                }
                column(TransBal_1__66_; TransBal[1][66])
                {
                }
                column(TransAmt_1__66_; TransAmt[1][66])
                {
                }
                column(Trans_1__67_; Trans[1][67])
                {
                }
                column(TransBal_1__67_; TransBal[1][67])
                {
                }
                column(TransAmt_1__67_; TransAmt[1][67])
                {
                }
                column(Trans_1__68_; Trans[1][68])
                {
                }
                column(TransBal_1__68_; TransBal[1][68])
                {
                }
                column(TransAmt_1__68_; TransAmt[1][68])
                {
                }
                column(Trans_1__69_; Trans[1][69])
                {
                }
                column(TransBal_1__69_; TransBal[1][69])
                {
                }
                column(TransAmt_1__69_; TransAmt[1][69])
                {
                }
                column(Trans_1__70_; Trans[1][70])
                {
                }
                column(TransBal_1__70_; TransBal[1][70])
                {
                }
                column(TransAmt_1__70_; TransAmt[1][70])
                {
                }
                column(Trans_1__71_; Trans[1][71])
                {
                }
                column(TransBal_1__71_; TransBal[1][71])
                {
                }
                column(TransAmt_1__71_; TransAmt[1][71])
                {
                }
                column(Trans_1__72_; Trans[1][71])
                {
                }
                column(TransBal_1__72_; TransBal[1][72])
                {
                }
                column(TransAmt_1__72_; TransAmt[1][72])
                {
                }
                column(Trans_1__73_; Trans[1][73])
                {
                }
                column(TransBal_1__73_; TransBal[1][73])
                {
                }
                column(TransAmt_1__73_; TransAmt[1][73])
                {
                }
                column(Trans_1__74_; Trans[1][74])
                {
                }
                column(TransBal_1__74_; TransBal[1][74])
                {
                }
                column(TransAmt_1__74_; TransAmt[1][74])
                {
                }
                column(Trans_1__75_; Trans[1][75])
                {
                }
                column(TransBal_1__75_; TransBal[1][75])
                {
                }
                column(TransAmt_1__75_; TransAmt[1][75])
                {
                }
                column(Trans_1__76_; Trans[1][76])
                {
                }
                column(TransBal_1__76_; TransBal[1][76])
                {
                }
                column(TransAmt_1__76_; TransAmt[1][76])
                {
                }
                column(Trans_1__77_; Trans[1][77])
                {
                }
                column(TransBal_1__77_; TransBal[1][77])
                {
                }
                column(TransAmt_1__77_; TransAmt[1][77])
                {
                }
                column(Trans_1__78_; Trans[1][78])
                {
                }
                column(TransBal_1__78_; TransBal[1][78])
                {
                }
                column(TransAmt_1__78_; TransAmt[1][78])
                {
                }
                column(Trans_1__79_; Trans[1][79])
                {
                }
                column(TransBal_1__79_; TransBal[1][79])
                {
                }
                column(TransAmt_1__79_; TransAmt[1][79])
                {
                }
                column(Trans_1__80_; Trans[1][80])
                {
                }
                column(TransBal_1__80_; TransBal[1][80])
                {
                }
                column(TransAmt_1__80_; TransAmt[1][80])
                {
                }
                column(EmptyStringCaption; EmptyStringCaptionLbl)
                {
                }
                column(Employee_Caption; Employee_CaptionLbl)
                {
                }
                column(Department_Caption; Department_CaptionLbl)
                {
                }
                column(Period_Caption; Period_CaptionLbl)
                {
                }
                column(PR_Salary_Card_Employee_Code; "Employee Code")
                {
                }
                column(PayslipMessage; PayslipMessage)
                {
                }
                column(Currencycode; Currencycode)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    strNssfNo:='. ';
                    strSHIFNo:='. ';
                    strBank:='. ';
                    strBranch:='. ';
                    strAccountNo:='. ';
                    strPin:='. ';
                    STRGRATUITY:=0;
                    RecordNo:=RecordNo + 1;
                    ColumnNo:=ColumnNo + 1;
                    //Get the staff details (header)
                    HREmployeePR.Reset;
                    HREmployeePR.SetRange(HREmployeePR."No.", "Employee Code");
                    if HREmployeePR.Find('-')then begin
                        strEmpName:='[' + "Employee Code" + '] ' + HREmployeePR."Last Name" + ' ' + HREmployeePR."First Name" + ' ' + HREmployeePR."Middle Name";
                        strPin:=HREmployeePR."KRA Number";
                        dtDOE:=HREmployeePR."Employment Date";
                        //Status:=FORMAT(HREmployeePR.Status);
                        //"Served Notice Period" := HREmployeePR."Served Notice Period";
                        dept:=HREmployeePR."Global Dimension 1 Code";
                        if HREmployeePR."Date of Leaving" = 0D then dtOfLeaving:=DMY2Date(31, 12, 9999)
                        else
                            dtOfLeaving:=HREmployeePR."Date of Leaving";
                        strNssfNo:=HREmployeePR."NSSF No.";
                        strSHIFNo:=HREmployeePR."SHIF No.";
                        strPin:=HREmployeePR."KRA Number";
                    //*************************************************************************************************
                    end;
                    /*If the Employee's Pay is suspended, OR  the guy is active DO NOT execute the following code
                    *****************************************************************************************************/
                    if("Suspend Pay" = false)then begin
                        //CLEAR(PRPayrollProcessing);
                        strEmpCode:="Employee Code";
                    //PRPayrollProcessing.fnProcesspayroll(strEmpCode,dtDOE,"Basic Pay","Pays PAYE","Pays NSSF","Pays SHIF",SelectedPeriod,STATUS,
                    //dtOfLeaving,"Served Notice Period", dept);
                    end;
                    /******************************************************************************************************/
                    //Clear headers
                    Addr[ColumnNo][1]:='';
                    Addr[ColumnNo][2]:='';
                    Addr[ColumnNo][3]:='';
                    Addr[ColumnNo][4]:='';
                    Addr[ColumnNo][5]:='';
                    //Clear previous Transaction entries 53
                    for intRow:=1 to 55 do begin
                        Trans[ColumnNo, intRow]:='';
                        TransAmt[ColumnNo, intRow]:='';
                        TransBal[ColumnNo, intRow]:='';
                    end;
                    //Loop through the transactions
                    PeriodTrans.Reset;
                    PeriodTrans.SetRange(PeriodTrans."Employee Code", "Employee Code");
                    PeriodTrans.SetRange(PeriodTrans."Payroll Period", SelectedPeriod);
                    PeriodTrans.SetRange(PeriodTrans."Company Deduction", false); //dennis to filter our company deductions
                    PeriodTrans.SetCurrentKey(PeriodTrans."Employee Code", PeriodTrans."Period Month", PeriodTrans."Period Year", PeriodTrans."Group Order", PeriodTrans."Sub Group Order");
                    Addr[ColumnNo][1]:=Format(strEmpName);
                    Addr[ColumnNo][2]:=dept; //Depart
                    Addr[ColumnNo][3]:=PeriodName; //Period
                    Addr[ColumnNo][4]:=strPin; //Pin
                    Index:=1;
                    strGrpText:='';
                    if PeriodTrans.Find('-')then repeat //****************************************************************
 if(PeriodTrans."Transaction Code" = 'D43')then begin
                            //MESSAGE('');
                            end;
                            //****************************************************************
                            //Check if the group has changed
                            if strGrpText <> PeriodTrans."Group Text" then begin
                                if PeriodTrans."Group Order" <> 1 then begin
                                    Index:=Index + 1;
                                /* Trans[ColumnNo,Index]:='......................................';
                                         TransAmt[ColumnNo,Index]:='......................................';
                                         TransBal[ColumnNo,Index]:='......................................';  */
                                end;
                                Index:=Index + 1;
                                strGrpText:=PeriodTrans."Group Text";
                                Trans[ColumnNo, Index]:=strGrpText;
                                TransAmt[ColumnNo, Index]:='.';
                                TransBal[ColumnNo, Index]:='.';
                                // IF PeriodTrans.Amount>0 THEN
                                // BEGIN
                                Index:=Index + 1;
                                Trans[ColumnNo, Index]:=PeriodTrans."Transaction Name";
                                Evaluate(TransAmt[ColumnNo, Index], Format(PeriodTrans.Amount));
                                if(PeriodTrans.Balance = 0) or (PeriodTrans."Transaction Code" = 'BPAY')then Evaluate(TransBal[ColumnNo, Index], Format('                           .'))
                                else
                                    Evaluate(TransBal[ColumnNo, Index], Format(PeriodTrans.Balance));
                            // END;
                            end
                            else
                            begin
                                //  IF PeriodTrans.Amount>0 THEN
                                //  BEGIN
                                Index:=Index + 1;
                                strGrpText:=PeriodTrans."Group Text";
                                Trans[ColumnNo, Index]:=PeriodTrans."Transaction Name";
                                Evaluate(TransAmt[ColumnNo, Index], Format(PeriodTrans.Amount));
                                if PeriodTrans.Balance = 0 then Evaluate(TransBal[ColumnNo, Index], Format('                           .'))
                                else
                                    Evaluate(TransBal[ColumnNo, Index], Format(PeriodTrans.Balance + PeriodTrans."Emp Amount"));
                            //  END;
                            end;
                        until PeriodTrans.Next = 0;
                    //******************************************************************************
                    // DW - Display Employer Contributions on the Payslip
                    Index+=1;
                    Trans[ColumnNo, Index]:='......................................';
                    Evaluate(TransAmt[ColumnNo, Index], '......................................');
                    Index+=1;
                    Trans[ColumnNo, Index]:='EMPLOYER CONTRIBUTIONS:';
                    Evaluate(TransAmt[ColumnNo, Index], '.');
                    PREmployerContr.Reset;
                    PREmployerContr.SetRange(PREmployerContr."Payroll Period", SelectedPeriod);
                    //PREmployerContr.SETRANGE(PREmployerContr."Transaction Code",'NSSF');
                    PREmployerContr.SetRange(PREmployerContr."Employee Code", strEmpCode);
                    if PREmployerContr.Find('-')then begin
                        repeat if PREmployerContr."Transaction Code" = 'NSSF' then begin
                                Index+=1;
                                Trans[ColumnNo, Index]:='N.S.S.F: ';
                                Evaluate(TransAmt[ColumnNo, Index], Format(PREmployerContr.Amount));
                            end;
                            if PREmployerContr."Transaction Code" = 'PENSION' then begin
                                Index+=1;
                                Trans[ColumnNo, Index]:='Pension: ';
                                Evaluate(TransAmt[ColumnNo, Index], Format(PREmployerContr.Amount));
                            end;
                        until PREmployerContr.Next = 0;
                    end;
                    //COMPRESSARRAY(Addr[ColumnNo]);
                    //COMPRESSARRAY(Trans[ColumnNo]);
                    //COMPRESSARRAY(TransAmt[ColumnNo]);
                    //COMPRESSARRAY(TransBal[ColumnNo]);
                    if(RecordNo = NoOfRecords) and (ColumnNo < 3)then begin
                        for i:=ColumnNo + 1 to NoOfColumns do begin
                            Clear(Addr[i]);
                            Clear(Trans[i]);
                            Clear(TransAmt[i]);
                            Clear(TransBal[i]);
                        end;
                        ColumnNo:=0;
                    end
                    else
                    begin
                        if ColumnNo = NoOfColumns then ColumnNo:=0;
                    end;
                    if "Payroll Salary Card".Currency = '' then begin
                        Currencycode:='KES';
                    end
                    else
                        Currencycode:='USD';
                end;
                trigger OnPreDataItem()
                begin
                    NoOfRecords:=Count;
                    NoOfColumns:=1;
                    strNssfNo:='.';
                    strSHIFNo:='.';
                    strBank:='.';
                    strBranch:='.';
                    strAccountNo:='.';
                end;
            }
            trigger OnAfterGetRecord()
            begin
                DimensionValue.Reset;
                DimensionValue.SetRange(DimensionValue."Global Dimension No.", 1);
                DimensionValue.SetRange(DimensionValue.Code, "Global Dimension 1 Code");
                if DimensionValue.Find('-')then begin
                    CountyName:=UpperCase(DimensionValue.Name);
                end;
                HumanResSetup.Get();
                HumanResSetup.TestField("Retirement Age");
                if "Birth Date" <> 0D then Retirement_Date:=CalcDate(HumanResSetup."Retirement Age", "Birth Date");
            end;
        }
    }
    trigger OnPreReport()
    begin
        PeriodFilter:=Employee.GetFilter("Period Filter");
        if PeriodFilter = '' then Error('You must specify the period filter');
        SelectedPeriod:=Employee.GetRangeMin("Period Filter");
        PRPayrollPeriods.Reset;
        if PRPayrollPeriods.Get(SelectedPeriod)then PeriodName:=PRPayrollPeriods."Period Name";
        if CompanyInfo.Get()then CompanyInfo.CalcFields(CompanyInfo.Picture);
    end;
    var Addr: array[2, 10]of Text[250];
    NoOfRecords: Integer;
    RecordNo: Integer;
    NoOfColumns: Integer;
    ColumnNo: Integer;
    intInfo: Integer;
    i: Integer;
    PeriodTrans: Record "Payroll Period Transaction";
    intRow: Integer;
    Index: Integer;
    HREmployeePR: Record Employee;
    strEmpName: Text[250];
    strPin: Text[30];
    Trans: array[2, 80]of Text;
    TransAmt: array[2, 80]of Text;
    TransBal: array[2, 80]of Text;
    strGrpText: Text[100];
    strNssfNo: Text[30];
    strSHIFNo: Text[30];
    strBank: Text[100];
    strBranch: Text[100];
    strAccountNo: Text[100];
    strMessage: Text[100];
    PeriodName: Text[30];
    PeriodFilter: Text[30];
    SelectedPeriod: Date;
    PRPayrollPeriods: Record "Payroll Periods";
    dtDOE: Date;
    strEmpCode: Text[30];
    STATUS: Text[30];
    ControlInfo: Record "Company Information";
    dtOfLeaving: Date;
    "Served Notice Period": Boolean;
    dept: Text[30];
    strBankno: Text[30];
    strBranchno: Text[30];
    CompanyInfo: Record "Company Information";
    PRPayrollProcessing: Codeunit "Notify Emp. of Impending Leave";
    STRGRATUITY: Decimal;
    Gratuitty: array[2, 10]of Decimal;
    Gratuittities: Decimal;
    PRSalaryCard: Record "Payroll Salary Card";
    EmptyStringCaptionLbl: Label '.......................................................................................................';
    Employee_CaptionLbl: Label 'Employee:';
    Department_CaptionLbl: Label 'Department:';
    Period_CaptionLbl: Label 'Period:';
    PREmployerContr: Record "Payroll Employer Transaction";
    PayslipMessage: Text;
    RatePerDay: Decimal;
    NoDaysWorked: Decimal;
    PRPerTrans: Record "Payroll Period Transaction";
    Spacer: Label ' - ';
    CountyName: Text;
    DimensionValue: Record "Dimension Value";
    Currencycode: Code[10];
    PayrollPeriod: Date;
    Retirement_Date: Date;
    HumanResSetup: Record "Human Resources Setup";
    [Scope('Onprem')]
    procedure InitPeriod(PayrollPeriod: Date)
    begin
        "Payroll Salary Card"."Period Filter":=PayrollPeriod;
    end;
}

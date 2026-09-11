page 52204237 "Payroll Role Center"
{
    // CurrPage."Help And Setup List".ShowFeatured;Caption = 'HR Role Center';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            part(Part1; "Headline RC Relationship Mgt.")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    actions
    {
        area(embedding)
        {
            action("Change My Role Center")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Change My Role Center';
                Image = PersonInCharge;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Codeunit "User Profile Management";
            }
            action("Approval Status")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                RunObject = page "Approval Status";
            }
            action(Employees)
            {
                ApplicationArea = Basic, Suite;
                RunObject = page "Employee List";
            }
            action("&Human Resources Setup&")
            {
                ApplicationArea = Basic, Suite;
                RunObject = Page "Human Resources Setup";
                ToolTip = 'Open the list of employees.';
            }
        }
        area(sections)
        {
            group(Approvals)
            {
                Caption = 'Approvals';
                ToolTip = 'Approve requests made by other users.';

                action("Requests to Approve")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Requests to Approve';
                    Image = Approvals;
                    RunObject = Page "Requests to Approve";
                    ToolTip = 'View the number of approval requests that require your approval.';
                }
                action("Approval Requests")
                {
                    RunObject = page "Approval Request Entries";
                }
            }
            group("Human Resources")
            {
                group(Recruitment)
                {
                    group("Company Jobs")
                    {
                        action("Open Company Jobs")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Company Jobs";
                            RunPageView = where(Status = const(Open));
                        }
                        action("Pending Company Jobs")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Company Jobs";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("Approved Company Jobs")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Company Jobs";
                            RunPageView = where(Status = const(Approved));
                        }
                    }
                    group("Job Requisitions")
                    {
                        action("Open Job Requisition")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Job Requisitions";
                            RunPageView = where(Status = const(Open));
                        }
                        action("Pending Job Requisition")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Job Requisitions";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("Approved Job Requisition")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Job Requisitions";
                            RunPageView = where(Status = const(Approved), "Advertisement Status" = const(" "));
                        }
                        action("Advertised Job Requisition")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Job Requisitions";
                            RunPageView = where(Status = const(Approved), "Advertisement Status" = const(Open));
                        }
                        action("Closed Advertisements")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Job Requisitions";
                            RunPageView = where(Status = const(Approved), "Advertisement Status" = const(Closed));
                        }
                    }
                    action(Applicants)
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = Page Applicants;
                    }
                    group("Job Applications")
                    {
                        action("New Applications")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Job Applications";
                            RunPageView = where(Status = const(Application));
                        }
                        action("Long Listed Applications")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Job Applications";
                            RunPageView = where(Status = const("Long Listed"));
                        }
                        action("Shortlisted Applications")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Job Applications";
                            RunPageView = where(Status = const(Shortlisted));
                        }
                        action("Interview Applications")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Job Applications";
                            RunPageView = where(Status = const(Interview));
                        }
                        action("Offer Letter")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Job Applications";
                            RunPageView = where(Status = const("Offer Letter"));
                        }
                        action("Regret Letter")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Job Applications";
                            RunPageView = where(Status = const("Regret Letter"));
                        }
                        action("Employed")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Job Applications";
                            RunPageView = where(Status = const(Employed));
                        }
                        action("Unsuccessful Applications")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Job Applications";
                            RunPageView = where(Status = const(Unsuccessful));
                        }
                    }
                    group("Long&&Short Listing")
                    {
                        Caption = 'Long & Short Listing';

                        action("Long List")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Job Shortlists";
                            RunPageView = where(Status = const(Open), Type = const("Long List"));
                        }
                        action("Open Short List")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Job Shortlists";
                            RunPageView = where(Status = const(Open), Type = const("Short List"));
                        }
                        action("Closed")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Job Shortlists";
                            RunPageView = where(Status = const(Closed), Type = const("Short List"), "Interview Conducted" = const(false));
                        }
                        action("Interview Conducted")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Job Shortlists";
                            RunPageView = where(Status = const(Closed), Type = const("Short List"), "Interview Conducted" = const(true));
                        }
                    }
                    group(Interview)
                    {
                        action("&Pending")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Job Interviews";
                            RunPageView = where(Status = const(Created));
                        }
                        action("&Open")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Job Interviews";
                            RunPageView = where(Status = const(Open));
                        }
                        action("&Closed")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Job Interviews";
                            RunPageView = where(Status = const(Closed));
                        }
                    }
                    group("Onboarding")
                    {
                        action("Offers Made")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page Applicants;
                            RunPageView = Where("Offer Status" = const("Offer Made"));
                        }
                        action("Offers Accepted")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page Applicants;
                            RunPageView = Where("Offer Status" = const("Accepted Offer"));
                        }
                        action("Reported to Work")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page Applicants;
                            RunPageView = Where("Offer Status" = const("Reported to Work"));
                        }
                        action("Offers Rejected")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page Applicants;
                            RunPageView = Where("Offer Status" = const("Rejected Offer"));
                        }
                        action(Failed)
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page Applicants;
                            RunPageView = Where("Offer Status" = const(Failed));
                        }
                    }
                }
                group("Employee Management")
                {
                    action("New Employees")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Employee List";
                        RunPageView = where("Nature Of Employment" = filter(<> Board), "Employee Status" = const(New));
                    }
                    action("Employees Pending Approval")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Employee List";
                        RunPageView = where("Nature Of Employment" = filter(<> Board), "Employee Status" = const("Pending Approval"));
                    }
                    action("Active Employees")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Employee List";
                        RunPageView = where("Nature Of Employment" = filter(<> Board), "Employee Status" = const(Active));
                    }
                    action("Board Member")
                    {
                        Caption = 'Board Members';
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Board Members";
                    }
                    action("Employees On Leave")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Employee List";
                        RunPageView = where("Nature Of Employment" = filter(<> Board), "Employee Status" = const(OnLeave));
                    }
                    action("Pending Final Payment")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Employee List";
                        RunPageView = where("Nature Of Employment" = filter(<> Board), "Employee Status" = const("Pending Final Payment"));
                    }
                    action("Inactive Employees")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Employee List";
                        RunPageView = where("Nature Of Employment" = filter(<> Board), "Employee Status" = const(Inactive));
                    }
                    action("Terminated Employees")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Employee List";
                        RunPageView = where("Nature Of Employment" = filter(<> Board), "Employee Status" = const(Terminated));
                    }
                    group("Employee Management Reports")
                    {
                        Caption = 'Reports';

                        action("Employee List")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Employee List";
                        }
                        action("Employement Qualification")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Employement Qualification";
                        }
                        action("Employee Next of Kin")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Employee Next of Kin";
                        }
                        action("Inactive Employees (Periodic)")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Inactive Employees (Periodic)";
                        }
                        action("Employee Surrender Ages")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Employee Retirement Ages";
                        }
                        action("Employee Exit")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Employee Exit";
                        }
                        action("Employee Contact List")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Employee Contact List";
                        }
                        action("Employee Beneficiaries")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Employee Beneficiaries";
                        }
                        action("Employee Dependants")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Employee Dependants";
                        }
                        action("Employee Emergency Contacts")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Employee Emergency Contacts";
                        }
                        action("Employee Proffessional Bodies")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Employee Proffessional Bodies";
                        }
                        action("Employee Category List")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Employee Category List";
                        }
                        action("Employee Gender List")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Employee Gender List";
                        }
                        action("Employee Important Dates")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Employee Important Dates";
                        }
                        action("Employee Marital Status")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Employee Marital Status";
                        }
                        action("Employee Diversity List")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Employee Diversity List";
                        }
                        action("Employee Management Report")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Employee Management Report";
                        }
                        action("Employee Serving Notice")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Employee Serving Notice";
                        }
                        action("Employee Statutory Details")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Employee Statutory Details";
                        }
                        action("New Contract Details")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "New Contract Details";
                        }
                        action("Employee Contract Details")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Employee Contract Details";
                        }
                        action("Contract Change Details")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Contract Change Details";
                        }
                        action("Staff Per Contract Types")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Staff Per Contract Types";
                        }
                    }
                }
                group("Employee Change Request")
                {
                    group("Contract Creation")
                    {
                        action("New Contracts")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Contract Creation List";
                            RunPageView = where(Executed = const(false));
                        }
                        action("Executed Contracts")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Contract Creation List";
                            RunPageView = where(Executed = const(true));
                        }
                    }
                    group("Contract Renewal")
                    {
                        action("New contract Renewal")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Contract Renewal List";
                            RunPageView = where(Status = const(Open));
                        }
                        action("Pending Aproval")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Contract Renewal List";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("Approved Renewals")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Contract Renewal List";
                            RunPageView = where(Status = const(Approved));
                        }
                    }
                    group("Change Request")
                    {
                        Caption = 'Change Request';

                        action("New Change Request")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Employee Change Request";
                            RunPageView = where(Status = Const(Open));
                        }
                        action("Change Request Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Employee Change Request";
                            RunPageView = where(Status = Const("Pending Approval"));
                        }
                        action("Approved Change Request")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Employee Change Request";
                            RunPageView = where(Status = Const(Approved));
                        }
                    }
                    group("Asset Assignment")
                    {
                        action("New Asset Assignment")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Asset Asignment List";
                            RunPageView = where(Status = const(Open));
                        }
                        action("Asset Assignment Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Asset Asignment List";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("Approved Asset Assignment")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Asset Asignment List";
                            RunPageView = where(Status = const(Approved));
                        }
                    }
                    group("Promotion & Transfers")
                    {
                        action("New Salary Increament")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Promotion & Transfers List";
                            RunPageView = where(Status = const(Open));
                        }
                        action("Salary Increament Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Promotion & Transfers List";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("Approved Salary Increament")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Promotion & Transfers List";
                            RunPageView = where(Status = const(Approved));
                        }
                    }
                }
                group("Leave Management")
                {
                    group("Leave Plan")
                    {
                        action("Open Plans")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Leave Plan List";
                            RunPageView = where(Status = const(Open));
                        }
                        action("Plans Pending Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            //RunObject = Page "Leave Plan Pending Approval";
                            RunObject = Page "Leave Plan List";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("Approved Plans")
                        {
                            ApplicationArea = Basic, Suite;
                            //RunObject = Page "Approved Leave Plan";
                            RunObject = Page "Leave Plan List";
                            RunPageView = where(Status = const(Approved));
                        }
                    }
                    group("Leave Applications")
                    {
                        action("Open Leave Applications")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Leave Applications";
                            RunPageView = Where(Status = const(Open));
                        }
                        action("Leave Applications Approaval")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Leave Applications";
                            RunPageView = Where(Status = const("Pending Approval"));
                        }
                        action("Approved Leave Applications")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Leave Applications";
                            RunPageView = Where(Status = const(Approved));
                        }
                    }
                    group("Leave Recall")
                    {
                        action("Open Leave Recall")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Leave Recalls";
                            RunPageView = Where(Status = const(Open));
                        }
                        action("Leave Recall Approaval")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Leave Recalls";
                            RunPageView = Where(Status = const("Pending Approval"));
                        }
                        action("Approved Leave Recall")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Leave Recalls";
                            RunPageView = Where(Status = const(Approved));
                        }
                    }
                    group("Leave Reimbursement")
                    {
                        action("Open Leave Reimbursement")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Leave Reimbursements";
                            RunPageView = Where(Status = const(Open));
                        }
                        action("Leave Reimbursement Approaval")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Leave Reimbursements";
                            RunPageView = Where(Status = const("Pending Approval"));
                        }
                        action("Approved Leave Reimbursement")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Leave Reimbursements";
                            RunPageView = Where(Status = const(Approved));
                        }
                    }
                    group("Leave Adjustment")
                    {
                        action("Open Leave Adjustment")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Leave Adjustment List";
                            RunPageView = Where(Status = const(Open));
                        }
                        action("Leave Adjustment Approaval")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Leave Adjustment List";
                            RunPageView = Where(Status = const("Pending Approval"));
                        }
                        action("Approved Leave Adjustment")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Page "Leave Adjustment List";
                            RunPageView = Where(Status = const(Approved));
                        }
                    }
                    group("Leave Setups")
                    {
                        Caption = 'Setups';

                        action("Leave Leave Setup")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Leave Setup';
                            RunObject = page "Leave Setup";
                        }
                        action("Leave Type")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Leave Types Setup";
                        }
                        action("Leave Calendar")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "HR Leave Calendar List";
                        }
                        action("Leave Batches")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "HR Leave Batches";
                        }
                    }
                    group("Leave Reports")
                    {
                        Caption = 'Reports';

                        action("Leave Balance")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Report "Leave Balances";
                        }
                        action("Leave Balances Worth")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Report "Leave Balances Worth";
                        }
                        action("Leave Application History")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Report "Leave Application History";
                        }
                        action("Annual Leave Balances")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Report "Annual Leave Balances";
                        }
                        action("Leave Days Dropped")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Report "Leave Days Dropped";
                        }
                        action("Leave Plan Schedule")
                        {
                            ApplicationArea = Basic, Suite;
                        }
                        action("Leave Adjustment Report")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Leave Adjustment Report";
                        }
                        action("Leave Utilization Report")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Leave Utilization Report";
                        }
                        action("Leave Statement")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Leave Statement";
                        }
                    }
                }
                group("Appraisal Management")
                {
                    group("Objectives Setting")
                    {
                        action("GoalSettingAppraisee")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Appraisee';
                            RunObject = page "Appraisal List";
                            RunPageView = where(Sequence = const(0), Status = const("Appraisee Level"));
                        }
                        action("GoalSettingLineManager")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Line Manager';
                            RunObject = page "Appraisal List";
                            RunPageView = where(Sequence = const(0), Status = const("Appraiser Level"));
                        }
                        action("GoalSettingOverViewManager")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Overview Manager';
                            RunObject = page "Appraisal List";
                            RunPageView = where(Sequence = const(0), Status = const("Overview Manager Level"));
                        }
                        action("GoalSettingApproved")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved';
                            RunObject = page "Appraisal List";
                            RunPageView = where(Sequence = const(0), Status = const(Approved));
                        }
                    }
                    group("Quater One Appraisal")
                    {
                        action("QuaterOneAppraisee")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Appraisee';
                            RunObject = page "Appraisal List";
                            RunPageView = where(Sequence = const(1), Status = const("Appraisee Level"));
                        }
                        action("QuaterOneLineManager")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Line Manager';
                            RunObject = page "Appraisal List";
                            RunPageView = where(Sequence = const(1), Status = const("Appraiser Level"));
                        }
                        action("QuaterOneAgreement")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Agreement';
                            RunObject = page "Appraisal List";
                            RunPageView = where(Sequence = const(1), Status = const("Agreement Level"));
                        }
                        action("QuaterOneOverViewManager")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Overview Manager';
                            RunObject = page "Appraisal List";
                            RunPageView = where(Sequence = const(1), Status = const("Overview Manager Level"));
                        }
                        action("QuaterOneApproved")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved';
                            RunObject = page "Appraisal List";
                            RunPageView = where(Sequence = const(1), Status = const(Approved));
                        }
                    }
                    group("Quater Two Appraisal")
                    {
                        action("QuaterTwoAppraisee")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Appraisee';
                            RunObject = page "Appraisal List";
                            RunPageView = where(Sequence = const(2), Status = const("Appraisee Level"));
                        }
                        action("QuaterTwoLineManager")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Line Manager';
                            RunObject = page "Appraisal List";
                            RunPageView = where(Sequence = const(2), Status = const("Appraiser Level"));
                        }
                        action("QuaterTwoAgreement")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Agreement';
                            RunObject = page "Appraisal List";
                            RunPageView = where(Sequence = const(2), Status = const("Agreement Level"));
                        }
                        action("QuaterTwoOverViewManager")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Overview Manager';
                            RunObject = page "Appraisal List";
                            RunPageView = where(Sequence = const(2), Status = const("Overview Manager Level"));
                        }
                        action("QuaterTwoApproved")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved';
                            RunObject = page "Appraisal List";
                            RunPageView = where(Sequence = const(2), Status = const(Approved));
                        }
                    }
                    group("Quater Three Appraisal")
                    {
                        action("QuaterThreeAppraisee")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Appraisee';
                            RunObject = page "Appraisal List";
                            RunPageView = where(Sequence = const(3), Status = const("Appraisee Level"));
                        }
                        action("QuaterThreeLineManager")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Line Manager';
                            RunObject = page "Appraisal List";
                            RunPageView = where(Sequence = const(3), Status = const("Appraiser Level"));
                        }
                        action("QuaterThreeAgreement")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Agreement';
                            RunObject = page "Appraisal List";
                            RunPageView = where(Sequence = const(3), Status = const("Agreement Level"));
                        }
                        action("QuaterThreeOverViewManager")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Overview Manager';
                            RunObject = page "Appraisal List";
                            RunPageView = where(Sequence = const(3), Status = const("Overview Manager Level"));
                        }
                        action("QuaterThreeApproved")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved';
                            RunObject = page "Appraisal List";
                            RunPageView = where(Sequence = const(3), Status = const(Approved));
                        }
                    }
                    group("Quarter Four Appraisal")
                    {
                        action("QuaterFourAppraisee")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Appraisee';
                            RunObject = page "Appraisal List";
                            RunPageView = where(Sequence = const(4), Status = const("Appraisee Level"));
                        }
                        action("QuaterFourLineManager")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Line Manager';
                            RunObject = page "Appraisal List";
                            RunPageView = where(Sequence = const(4), Status = const("Appraiser Level"));
                        }
                        action("QuaterFourAgreement")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Agreement';
                            RunObject = page "Appraisal List";
                            RunPageView = where(Sequence = const(4), Status = const("Agreement Level"));
                        }
                        action("QuaterFourOverViewManager")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Overview Manager';
                            RunObject = page "Appraisal List";
                            RunPageView = where(Sequence = const(4), Status = const("Overview Manager Level"));
                        }
                        action("QuaterFourApproved")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Approved';
                            RunObject = page "Appraisal List";
                            RunPageView = where(Sequence = const(4), Status = const(Approved));
                        }
                    }
                    action("Closed Appraisal")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Appraisal List";
                        RunPageView = where(Status = const(Closed));
                    }
                    group("Appraisal Reports")
                    {
                        action("Appraisal List")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Report "Appraisal List";
                        }
                        action("Perfomance History")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Report "Appraisal Perfomance History";
                        }
                        action("Appraisal Status")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Report "Appraisal Status";
                        }
                        action("Appraisal Training Needs")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Report "Appraisal Training Needs";
                        }
                    }
                    group("Appraisal Administration")
                    {
                        action("Appraisal Calendar")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Appraisal Calender";
                        }
                        action("Appraisal Ratings")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Appraisal Ratings";
                        }
                        action("Appraisal Perspectives")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Appraisal Perspectives";
                        }
                        action("Competence Categories")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Competence Categories";
                        }
                        action("Competence Categories Behaviour")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Competence Behaviour";
                        }
                    }
                }
                group("Training Management")
                {
                    action("ConfirmationApplications")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Awaiting Availability Confirmation';
                        RunObject = page "Training Applications";
                        RunPageView = where(Status = const("Awaiting Availability Confirmation"));
                    }
                    action("Awaiting Attendance Confirmation")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Training Applications";
                        RunPageView = where(Status = const("Awaiting Attendance Confirmation"));
                    }
                    action("Awaiting HR Confirmation")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Training Applications";
                        RunPageView = where(Status = const("Awaiting HR Confirmation"));
                    }
                    action("Attended Training Applications")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Training Applications";
                        RunPageView = where(Status = const(Attended));
                    }
                    group("Training Reports")
                    {
                        action("&Training Plan")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Report "Training Plan";
                        }
                        action("Training Plan Due")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Report "Training Plan Due";
                        }
                        action("&Training Needs")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Report "Training Needs";
                        }
                        action("Training Needs Allocation")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Report "Training Needs Allocation";
                        }
                        action("Training Applications")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Report "Training Applications";
                        }
                        action("Training Expenditures")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = Report "Training Expenditures";
                        }
                    }
                    group(Setups)
                    {
                        action("Training Calender")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Training Calender List";
                        }
                        action("Training Categories")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Training Categories";
                        }
                        action("Training Needs")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Training Needs";
                        }
                        action("Training Plan")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Training Plan List";
                        }
                    }
                }
                group("Employee Separation")
                {
                    group("Exit Request")
                    {
                        action("New Exit Request")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Employee Exit";
                            RunPageView = where(Status = const(Open));
                        }
                        action("Exit Request Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Employee Exit";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("Approved Exit Request")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Employee Exit";
                            RunPageView = where(Status = const(Approved));
                        }
                        action("Employee Clearance")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Clearance Forms";
                        }
                        action("Cleared Exit Request")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Employee Exit";
                            RunPageView = where(Status = const(Cleared));
                        }
                    }
                    action("Staff Clearance Setup")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Exit Clearance Setup";
                    }
                    group("&Reports")
                    {
                        action("Employee Exit Final Dues")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = report "Employee Exit Final Dues";
                        }
                    }
                }
                group("Setup&")
                {
                    Caption = 'Setup';
                    ToolTip = 'All hr module setups';

                    action("&Human Resources Setup")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = Page "Human Resources Setup";
                    }
                    action(Action26)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Staff User Setup';
                        RunObject = Page "User Setup";
                    }
                    action("Leave Setup")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Leave Setup';
                        RunObject = Page "Leave Setup";
                    }
                }
            }
            group("Payroll&")
            {
                Caption = 'Payroll';

                action("Payroll List")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Payroll List";
                    ToolTip = 'Open the list of employees.';
                }
                action("&Board Members")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Board Members";
                    ToolTip = 'Open the list of employees.';
                }
                group("PeriodicActivities")
                {
                    Caption = 'Periodic Activities';

                    action("PayrollPeriods")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Payroll Periods';
                        Image = Calculate;
                        RunObject = page "Payroll Periods";
                        ToolTip = 'Calculate Payroll';
                    }
                    action("Generate Payroll Journal")
                    {
                        Image = InsertCurrency;
                        RunObject = Report "Post Payroll";
                        ApplicationArea = Basic, Suite;
                    }
                }
                group("&Employee Separation")
                {
                    group("&Exit Request")
                    {
                        action("&New Exit Request")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Employee Exit";
                            RunPageView = where(Status = const(Open));
                        }
                        action("&Exit Request Approval")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Employee Exit";
                            RunPageView = where(Status = const("Pending Approval"));
                        }
                        action("&Approved Exit Request")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Employee Exit";
                            RunPageView = where(Status = const(Approved));
                        }
                        action("&Cleared Exit Request")
                        {
                            ApplicationArea = Basic, Suite;
                            RunObject = page "Employee Exit";
                            RunPageView = where(Status = const(Cleared));
                        }
                    }
                    action("&Employee Clearance")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Clearance Forms";
                    }
                    action("&Staff Clearance Setup")
                    {
                        ApplicationArea = Basic, Suite;
                        RunObject = page "Exit Clearance Setup";
                    }
                }
            }
            group("Payroll Setups")
            {
                Caption = 'Setups';

                action("P9 Years")
                {
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Image = DateRange;
                    RunObject = Page "p9 Years";
                    RunPageMode = Edit;
                }
                action("Human Resources Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Image = Setup;
                    RunObject = Page "Human Resources Setup";
                    RunPageMode = Edit;
                }
                action("&Payroll Transaction Codes")
                {
                    ApplicationArea = Basic, Suite;
                    Image = Receipt;
                    RunObject = Page "Payroll Transaction Codes";
                    RunPageMode = Edit;
                }
                action("SHIF Matrix")
                {
                    ApplicationArea = Basic, Suite;
                    Image = Receipt;
                    RunObject = Page "SHIF Matrix";
                    RunPageMode = Edit;
                }
                action("PAYE Matrix")
                {
                    ApplicationArea = Basic, Suite;
                    Image = Receipt;
                    RunObject = Page "PAYE Matrix";
                    RunPageMode = Edit;
                }
                action("&Payroll Periods")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Payroll Periods';
                    Image = PaymentPeriod;
                    RunObject = Page "Payroll Periods";
                    RunPageMode = Edit;
                    ToolTip = 'Manage or Create new Payroll Periods';
                }
                action("Payroll Rates & Ceillings")
                {
                    ApplicationArea = Basic, Suite;
                    Image = Database;
                    RunObject = Page "Payroll Vital Setup";
                    RunPageMode = Edit;
                }
                action("Payroll NSSF")
                {
                    ApplicationArea = Suite;
                    Image = PaymentJournal;
                    RunObject = Page "Payroll NSSF Matrix";
                    RunPageMode = Edit;
                }
                action("Employee Payroll Scales")
                {
                    ApplicationArea = Suite;
                    Image = PaymentJournal;
                    RunObject = Page "Employee Payroll Scales";
                    RunPageMode = Edit;
                }
                action("Employee Posting Groups")
                {
                    ApplicationArea = Suite;
                    Image = PaymentJournal;
                    RunObject = Page "Employee Posting Groups";
                    RunPageMode = Edit;
                }
                action("Board Member Categories")
                {
                    ApplicationArea = Basic, Suite;
                    Image = TaxSetup;
                    RunObject = Page "Board Member Categories";
                    RunPageMode = Edit;
                }
                action("Board Allowance SetUp")
                {
                    ApplicationArea = Suite;
                    Image = TaxSetup;
                    RunObject = Page "Allowances Setup";
                    RunPageMode = Edit;
                }
            }
            group(Reports)
            {
                action("Payslips")
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    RunObject = Report Payslip;
                    ToolTip = 'View Employee Payslips';
                }
                action("Individual Earnings Report")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Individual Earning Report';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    RunObject = Report "Payroll Allowances";
                    ToolTip = 'View Earnings Report';
                }
                action("Earnings Report")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Earning Report';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    RunObject = Report "Payroll Allowances Report";
                    ToolTip = 'View Earnings Report';
                }
                action("Individual Deductions Report")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Individual Deductions Report';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    RunObject = Report "Payroll Deductions";
                }
                action("Deduction Report")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Deduction Report';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    RunObject = Report "Payroll Deductions Report";
                    ToolTip = 'View Earnings Report';
                }
                action("Payroll Company Deductions")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Payroll Company Deductions';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    RunObject = Report "Payroll Company Report";
                }
                action("Loan Deductions")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Loan Deductions';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    RunObject = Report "Loan Deductions Report";
                }
                action("Sacco Deductions")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sacco Deductions';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    RunObject = Report "Sacco Deductions Report";
                }
                action("NSSF Report")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'NSSF Report';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    RunObject = Report "NSSF Report";
                    ToolTip = 'View NHF Report';
                }
                action("SHIF Report")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'SHIF Report';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    RunObject = Report "SHIF Report";
                    ToolTip = 'View NHF Report';
                }
                action("PAYE Report")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'PAYE Report';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    RunObject = Report "Payroll Paye Report";
                }
                action("Net Pay Report")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Net Pay Report';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    RunObject = Report "Net Pay";
                }
                action("Payroll Summary Company")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Payroll Summary Company';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    RunObject = Report "Payroll Company Report";
                }
                action("Payroll Summary Breakdown")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Payroll Summary Breakdown';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    RunObject = Report "Payroll Summary Break Down";
                }
                action("Payroll Summary Standard")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Payroll Summary Standard';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    RunObject = Report "Payroll Summary Standard";
                }
                action("P9 Report")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'P9 Report';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    RunObject = Report "P9 Report";
                }
                action("Less Than a Third")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Less Than a Third';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    RunObject = Report "Less Than a third Rule";
                }
                action("Graduity Report")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Graduity Report';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    RunObject = Report "Gratuity Report";
                }
                action("Pension Report")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pension Report';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    RunObject = Report "Pension Report";
                }
                action("VarCe Check")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VarCe Check';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    RunObject = Report "Payroll VarCe";
                }
                action("Detailed Payroll Varience")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Detailed Payroll Varience';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    RunObject = Report "Detailed Payroll VarCe";
                }
                action("Payment Held")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Payment Held';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    RunObject = Report "Payment Held";
                }
                action("Leave Balances")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Leave Balances';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    RunObject = Report "Leave Balances";
                    ToolTip = 'View Employee Leave Balances';
                }
            }
        }
    }
}

table 52203441 "Leave Calendar"
{
    DrillDownPageID = "HR Leave Calendar List";
    LookupPageID = "HR Leave Calendar List";

    fields
    {
        field(1; "Calendar Code"; Code[20])
        {
            trigger OnValidate()
            begin
                //Prevent Changing Calendar code once ledger entries have been posted into HR Leave Ledger
                //TestNoEntriesExist_PrevRec(FIELDCAPTION("Calendar Code"));            if "Calendar Code" <> '' then
                HRCalendarList.Reset;
                HRCalendarList.SetRange(HRCalendarList.Code, xRec."Calendar Code");
                if HRCalendarList.Find('-')then HRCalendarList.DeleteAll; //VALIDATE("Start Date");
            end;
        }
        field(2; "Created By"; Text[100])
        {
        }
        field(3; "Start Date"; Date)
        {
            trigger OnValidate()
            begin
                HRCalendarList.Reset;
                HRCalendarList.SetRange(HRCalendarList.Code, "Calendar Code");
                HRCalendarList.DeleteAll;
                if "End Date" <> 0D then Validate("End Date")
                else
                    Message('Enter End Date');
            end;
        }
        field(4; "End Date"; Date)
        {
            trigger OnValidate()
            begin
                if "End Date" = 0D then begin
                    HRCalendarList.Reset;
                    HRCalendarList.SetRange(HRCalendarList.Code, "Calendar Code");
                    if HRCalendarList.Find then HRCalendarList.DeleteAll;
                end
                else
                begin
                    if "End Date" < "Start Date" then Error('End Date cannot be [ %1 ] while Start Date is [ %2 ]', "End Date", "Start Date");
                    Rec.Testfield("Calendar Code");
                    Rec.Testfield("Start Date");
                    CreateLeaveCalendar;
                end;
            //MESSAGE('Calendar List Updated. Please Refresh this Page (F5)');
            end;
        }
        field(5; "Current Leave Calendar"; Boolean)
        {
            trigger OnValidate()
            begin
                HRLeaveCal.Reset;
                HRLeaveCal.SetFilter(HRLeaveCal."Calendar Code", '<>%1', "Calendar Code");
                HRLeaveCal.SetRange(HRLeaveCal."Current Leave Calendar", true);
                if HRLeaveCal.Find('-')then begin
                    repeat HRLeaveCal."Current Leave Calendar":=false;
                        HRLeaveCal.Modify;
                    until HRLeaveCal.Next = 0;
                end;
            //to carry forward days
            end;
        }
        field(6; Description; Text[100])
        {
        }
        field(7; "Date Created"; Date)
        {
            Editable = false;
        }
        field(8; "Last Modified By"; Code[100])
        {
            Editable = false;
        }
        field(9; "Date Modified"; Date)
        {
            Editable = false;
        }
        field(10; Closed; Boolean)
        {
        }
        field(11; "Closed On"; Date)
        {
        }
        field(12; "Closed By"; Code[70])
        {
        }
    }
    keys
    {
        key(Key1; "Calendar Code")
        {
        }
    }
    trigger OnDelete()
    begin
    // IF "Current Leave Calendar" THEN ERROR('Cannot delete current leave calendar');
    //
    // //Prevent Changing Calendar code once ledger entries have been posted into HR Leave Ledger
    // TestNoEntriesExist_CurrRec(FIELDCAPTION("Calendar Code"));
    end;
    trigger OnInsert()
    begin
        "Created By":=UserId;
        "Date Created":=WorkDate;
    end;
    trigger OnModify()
    begin
        "Last Modified By":=UserId;
        "Date Modified":=WorkDate;
    end;
    var HRLeaveCal: Record "Leave Calendar";
    Day: Date;
    Date: Record Date;
    HRCalendarList: Record "Leave Calendar Lines";
    HRLeaveLedger: Record "Leave Ledger Entries";
    Text000: Label 'You cannot change %1 because there are one or more ledger entries associated with this account.';
    local procedure CreateLeaveCalendar()
    begin
        Rec.Testfield("Calendar Code");
        Date.Reset;
        Date.SetRange(Date."Period Type", Date."Period Type"::Date);
        Date.SetRange(Date."Period Start", "Start Date", "End Date");
        if Date.Find('-')then begin
            HRCalendarList.Reset;
            HRCalendarList.SetRange(HRCalendarList.Code, "Calendar Code");
            if HRCalendarList.FindSet then HRCalendarList.DeleteAll;
            repeat HRCalendarList.Init;
                HRCalendarList.Code:="Calendar Code";
                HRCalendarList.Date:=Date."Period Start";
                ; // e.g 01-01-15
                HRCalendarList.Day:=Date."Period Name"; // e.g Thursday
                HRCalendarList."Non Working":=DetermineNonWorking(Date."Period Start");
                //Saturday
                if(Date."Period Name" = 'Saturday') and not(HRCalendarList."Non Working")then begin
                    HRCalendarList."Non Working":=true;
                    HRCalendarList.Reason:='Saturday';
                end;
                //Sunday
                if(Date."Period Name" = 'Sunday') and not(HRCalendarList."Non Working")then begin
                    HRCalendarList."Non Working":=true;
                    HRCalendarList.Reason:='Sunday';
                end;
                HRCalendarList.Insert;
            until Date.Next = 0;
        end
        else
        begin
            Error('Invalid Date format');
        end;
    end;
    local procedure DetermineNonWorking(currDate: Date)isNonWorking: Boolean var
        HRNonWorkingDays: Record "Non Working Days & Dates";
    begin
        isNonWorking:=false;
        HRCalendarList.Reason:='';
        HRNonWorkingDays.Reset;
        if HRNonWorkingDays.Get(currDate)then begin
            isNonWorking:=true;
            HRCalendarList.Reason:=HRNonWorkingDays.Reason;
        end;
    end;
    procedure TestNoEntriesExist_PrevRec(CurrentFieldName: Text[100])
    var
        HRLeaveLedgerEntry: Record "Leave Ledger Entries";
    begin
        //To prevent change of field once entries have been posted
        HRLeaveLedgerEntry.Reset;
        HRLeaveLedgerEntry.SetRange(HRLeaveLedgerEntry."Leave Year Code", xRec."Calendar Code"); //Previous Rec
        if HRLeaveLedgerEntry.Find('-')then Error(Text000, CurrentFieldName);
    end;
    procedure TestNoEntriesExist_CurrRec(CurrentFieldName: Text[100])
    var
        HRLeaveLedgerEntry: Record "Leave Ledger Entries";
    begin
        //To prevent change of field once entries have been posted
        HRLeaveLedgerEntry.Reset;
        HRLeaveLedgerEntry.SetRange(HRLeaveLedgerEntry."Leave Year Code", "Calendar Code"); //Current Rec
        if HRLeaveLedgerEntry.Find('-')then Error(Text000, CurrentFieldName);
    end;
}

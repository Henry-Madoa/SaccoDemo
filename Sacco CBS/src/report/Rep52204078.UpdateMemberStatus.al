report 52204078 "Update Member Status"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Members; Members)
        {
            DataItemTableView = where(Status = filter(Active | Dormant));

            trigger OnAfterGetRecord()
            begin
                GeneralSetup.Get;
                GeneralSetup.TestField("Dormancy Period");
                Members.CALCFIELDS("Last Transaction Date");
                if Members.Status = Members.Status::Deceased then
                    CurrReport.SKIP;
                if Members."Last Transaction Date" <> 0D then begin
                    DormancyDate := CALCDATE(StrSubstNo('-%1', GeneralSetup."Dormancy Period"), WorkDate);
                    if Members."Last Transaction Date" <= DormancyDate then
                        Members.Status := Members.Status::Dormant
                    else
                        Members.Status := Members.Status::Active;

                    DormacyPeriod := WorkDate - Members."Last Transaction Date";
                    if (DormacyPeriod <= 30) then
                        Members.Classification := Members.Classification::Regular
                    else if (DormacyPeriod > 30) and (DormacyPeriod <= 60) then
                        Members.Classification := Members.Classification::Watch
                    else if (DormacyPeriod > 60) and (DormacyPeriod <= 90) then
                        Members.Classification := Members.Classification::Underperforming
                    else if (DormacyPeriod > 90) and (DormacyPeriod <= 180) then
                        Members.Classification := Members.Classification::Critical
                    else if (DormacyPeriod > 180) then
                        Members.Classification := Members.Classification::"Absolute Dormant";
                end
                else
                    Members.Status := Members.Status::Dormant;
                Members.MODIFY;
            end;
        }
    }
    var
        DormancyDate: Date;
        DormacyPeriod: Integer;
        GeneralSetup: Record "General Ledger Setup";
}

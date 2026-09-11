table 52203548 "Project Report Header"
{
    fields
    {
        field(1; Project; Code[10])
        {
            TableRelation = "Project Details";

            trigger OnValidate()
            begin
                if ProjectDetails.Get(Project)then begin
                    "Project Name":=ProjectDetails."Project Name";
                end;
                Template.Reset;
                if Template.FindSet then begin
                    repeat if not Details.Get(Project, Template.Code)then begin
                            Details.Init;
                            Details.Project:=Project;
                            Details.Code:=Template.Code;
                            Details.Description:=Template.Description;
                            Details.Insert;
                        end;
                    until Template.Next = 0;
                end;
            end;
        }
        field(2; "Project Name"; Text[50])
        {
        }
        field(3; "Report Start Date"; Date)
        {
        }
        field(4; "Report End Date"; Date)
        {
        }
    }
    keys
    {
        key(Key1; Project)
        {
        }
    }
    var ProjectDetails: Record "Project Details";
    Template: Record "Project Report Template";
    Details: Record "Project Report Details";
}

pageextension 50710 "Sample Bus. Mgr. RC Ext" extends "Business Manager Role Center"
{
    layout
    {
        addafter(Control16)
        {
            part(SampleReportInbox; "Report Inbox Part")
            {
                ApplicationArea = Basic, Suite;
                // AL0573: procedure calls are not valid for client expressions.
                Visible = CanSeeReportInbox();
            }
        }
    }

    // AL0569: a page of type Role Center cannot have procedures.
    local procedure CanSeeReportInbox(): Boolean
    var
        ReportInbox: Record "Report Inbox";
    begin
        exit(ReportInbox.ReadPermission());
    end;
}

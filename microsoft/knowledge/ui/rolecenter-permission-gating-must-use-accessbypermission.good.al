pageextension 50710 "Sample Bus. Mgr. RC Ext" extends "Business Manager Role Center"
{
    layout
    {
        addafter(Control16)
        {
            part(SampleReportInbox; "Report Inbox Part")
            {
                ApplicationArea = Basic, Suite;
                // Declarative permission gating: the part is removed for users
                // without Insert, Modify, or Delete permission on Report Inbox.
                AccessByPermission = TableData "Report Inbox" = IMD;
            }
        }
    }
}

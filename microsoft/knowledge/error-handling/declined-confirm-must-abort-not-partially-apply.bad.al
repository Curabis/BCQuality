table 50100 "Sample Mailbox Watch"
{
    fields
    {
        field(1; "Code"; Code[20])
        {
        }
        field(2; "Watched Email"; Text[250])
        {
            trigger OnValidate()
            var
                StopWatchingQst: Label 'Email %1 is being watched. Stop watching it?', Comment = '%1 = previous email address';
            begin
                if (xRec."Watched Email" <> '') and (xRec."Watched Email" <> "Watched Email") then
                    if Confirm(StopWatchingQst, false, xRec."Watched Email") then
                        Unsubscribe("Subscription ID");
                // On "no" the old subscription is never removed, and the only field
                // that tracked it is overwritten here: it is orphaned.
                "Subscription ID" := Subscribe("Watched Email");
            end;
        }
        field(3; "Subscription ID"; Guid)
        {
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    local procedure Subscribe(EmailAddress: Text[250]): Guid
    begin
        // Registers EmailAddress with the external watch service and returns its subscription.
        exit(CreateGuid());
    end;

    local procedure Unsubscribe(SubscriptionId: Guid)
    begin
        // Removes the subscription from the external watch service.
    end;
}

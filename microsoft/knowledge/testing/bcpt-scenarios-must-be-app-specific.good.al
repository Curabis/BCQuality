codeunit 50100 "BCPT Create Service Request" implements "BCPT Test Param. Provider"
{
    SingleInstance = true;

    trigger OnRun()
    begin
        if not IsInitialized then begin
            InitTest();
            IsInitialized := true;
        end;
        CreateServiceRequest(GlobalBCPTTestContext);
    end;

    var
        GlobalBCPTTestContext: Codeunit "BCPT Test Context";
        CustomerNo: Code[20];
        NextNo: Integer;
        IsInitialized: Boolean;

    local procedure InitTest()
    var
        Customer: Record Customer;
    begin
        Customer.FindFirst();
        CustomerNo := Customer."No.";
    end;

    local procedure CreateServiceRequest(var BCPTTestContext: Codeunit "BCPT Test Context")
    var
        ServiceRequestHeader: Record "Service Request Header";
        ServiceRequestLine: Record "Service Request Line";
    begin
        BCPTTestContext.StartScenario('Create Service Request Header');
        NextNo += 1;
        ServiceRequestHeader.Init();
        ServiceRequestHeader."No." := CopyStr(Format(NextNo), 1, MaxStrLen(ServiceRequestHeader."No."));
        ServiceRequestHeader.Validate("Customer No.", CustomerNo);
        ServiceRequestHeader.Insert(true);
        BCPTTestContext.EndScenario('Create Service Request Header');
        BCPTTestContext.UserWait();

        BCPTTestContext.StartScenario('Add Service Request Line');
        ServiceRequestLine.Init();
        ServiceRequestLine."Document No." := ServiceRequestHeader."No.";
        ServiceRequestLine."Line No." := 10000;
        ServiceRequestLine.Description := 'Performance test line';
        ServiceRequestLine.Insert(true);
        BCPTTestContext.EndScenario('Add Service Request Line');
    end;

    procedure GetDefaultParameters(): Text[1000]
    begin
        exit('');
    end;

    procedure ValidateParameters(Parameters: Text[1000])
    begin
    end;
}

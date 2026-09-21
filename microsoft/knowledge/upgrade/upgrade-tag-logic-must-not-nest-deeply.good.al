local procedure UpgradeCustomerDiscountField()
begin
    if UpgradeTag.HasUpgradeTag(GetCustomerDiscountFieldTag()) then
        exit;

    Customer.SetLoadFields("Discount %", "Customer Posting Group");
    if Customer.FindSet() then
        repeat
            SetDefaultDiscountIfEligible(Customer);
        until Customer.Next() = 0;

    UpgradeTag.SetUpgradeTag(GetCustomerDiscountFieldTag());
end;

local procedure SetDefaultDiscountIfEligible(var Customer: Record Customer)
begin
    // Both safety conditions from the original logic are preserved, just
    // flattened into early exits instead of nested ifs: don't overwrite an
    // already-set discount, and don't touch a customer with no posting
    // group configured yet.
    if Customer."Discount %" <> 0 then
        exit;
    if Customer."Customer Posting Group" = '' then
        exit;

    Customer."Discount %" := 5;
    Customer.Modify();
end;

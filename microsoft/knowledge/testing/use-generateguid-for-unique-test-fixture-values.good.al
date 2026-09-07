codeunit 50132 "Sample Customer Type Library"
{
    var
        LibraryUtility: Codeunit "Library - Utility";

    procedure CreateCustomerType(var CustomerType: Record "Customer Type")
    begin
        CustomerType.Init();
        // Code is shorter than GenerateGUID()'s 10 characters, so use
        // GenerateRandomCode instead of truncating a GUID ourselves — it
        // verifies uniqueness against the table rather than just returning
        // a truncated slice of the number series.
        CustomerType.Code := LibraryUtility.GenerateRandomCode(CustomerType.FieldNo(Code), Database::"Customer Type");
        // Description is long enough to hold the full GenerateGUID() value
        // untruncated, so no uniqueness verification is needed here.
        CustomerType.Description := CopyStr(LibraryUtility.GenerateGUID(), 1, MaxStrLen(CustomerType.Description));
        CustomerType.Insert(true);
    end;
}

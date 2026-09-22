table 50144 "Sample Setup"
{
    fields
    {
        field(1; "Primary Key"; Code[10]) { }
        field(2; "Default Category Code"; Code[20]) { }
    }
    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}

table 50145 "Sample Header"
{
    fields
    {
        field(1; "No."; Code[20]) { }
        // A known exception: this field is allowed to reference "Sample
        // Setup" loosely (no TableRelation enforced here on purpose), so
        // the standard Table Relation Test would otherwise reject it.
        field(10; "Category Code"; Code[20]) { }
    }
    keys
    {
        key(PK; "No.") { Clustered = true; }
    }
}

codeunit 50141 "Sample Table Relation Test Ext"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Table Relation Test", 'OnAfterRemoveTableRelation', '', false, false)]
    local procedure ExcludeSampleFieldFromTableRelationTest(var TableRelationsMetadata: Record "Table Relations Metadata" temporary)
    var
        TableRelationTest: Codeunit "Table Relation Test";
    begin
        TableRelationTest.RemoveTableRelation(TableRelationsMetadata, Database::"Sample Header", 10, Database::"Sample Setup", 1);
    end;
}

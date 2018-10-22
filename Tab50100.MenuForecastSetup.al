table 50100 "AIR Menu Forecast Setup"
{

    fields
    {
        field(1; "Primary Key"; Code[10])
        {

        }
        field(6; "API URI"; Text[250])
        {
        }
        field(7; "API Key ID"; Text[250])
        {
        }
        field(10; "Menu Item Category"; Code[20])
        {
            TableRelation = "Item Category";
        }
        field(11; "Menu Attribute"; Text[250])
        {
            TableRelation = "Item Attribute".Name;
        }


        //You might want to add fields here

    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }

    }

    procedure InsertIfNotExists()
    var
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert(true);
        end;
    end;

    procedure IsMenuForecastProperlyConfigured(): Boolean
    var
    begin
        if Get() then
            exit(false);

        Exit(("Menu Attribute" <> '') and ("Menu Item Category" <> ''))
    end;



}
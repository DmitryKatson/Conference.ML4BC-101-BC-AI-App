codeunit 50102 "AIR MF Load Demo Data"
{
    procedure LoadDemoData()
    begin
        DoLoadDemoData();
    end;

    local procedure DoLoadDemoData()
    begin
        ConfigureWithDefaultMLEndPoint();

        DeleteAllDemoItems();

        InsertMenuItem('34', 'rice pudding', true, 198);
        InsertMenuItem('12', 'Fruit', true, 116);
        InsertMenuItem('18', 'Oranges', true, 189);
        InsertMenuItem('32', 'Sweet Potatoes', true, 178);
        InsertMenuItem('4 ', 'Chicken Sandwich', true, 134);
        InsertMenuItem('23', 'STRAWBERRY ICE CREAM', true, 65);
        InsertMenuItem('29', 'Sliced Tomatoes', true, 131);
        InsertMenuItem('14', 'Milk', true, 113);
        InsertMenuItem('13', 'Grapes', true, 145);
        InsertMenuItem('11', 'French fried potatoes', true, 64);
        InsertMenuItem('24', 'Sardines', false, 67);
        InsertMenuItem('25', 'Sauterne', false, 77);
        InsertMenuItem('26', 'Scrambled Eggs', false, 190);
        InsertMenuItem('21', 'Plums', false, 87);
        InsertMenuItem('27', 'Shrimp Cocktail', false, 133);
        InsertMenuItem('28', 'Shrimp Salad', false, 180);
        InsertMenuItem('30', 'Stewed Corn', false, 91);
        InsertMenuItem('31', 'Stewed Prunes', false, 122);
        InsertMenuItem('33', 'Tea', false, 158);
        InsertMenuItem('22', 'ROQUEFORT CHEESE', false, 81);
        InsertMenuItem('0 ', 'Biscuit Tortoni', false, 163);
        InsertMenuItem('20', 'Pear', false, 87);
        InsertMenuItem('19', 'Oyster cocktail', false, 79);
        InsertMenuItem('1 ', 'Blue Point Oysters', false, 161);
        InsertMenuItem('16', 'Orange Juice', false, 183);
        InsertMenuItem('15', 'Nesselrode Pudding', false, 82);
        InsertMenuItem('10', 'Dessert', false, 149);
        InsertMenuItem('9 ', 'Cream Cheese', false, 127);
        InsertMenuItem('8 ', 'Crackers', false, 66);
        InsertMenuItem('7 ', 'Crab Flake Cocktail', false, 76);
        InsertMenuItem('6 ', 'Corned Beef Hash', false, 135);
        InsertMenuItem('5 ', 'Chocolate Ice Cream', false, 167);
        InsertMenuItem('3 ', 'Boiled potatoes', false, 172);
        InsertMenuItem('2 ', 'Boiled eggs', false, 113);
        InsertMenuItem('17', 'Orange marmalade', false, 70);

        DeleteAllEvents();

        InsertEvent(CalcDate('<3D>', WorkDate()), 1, '');
        InsertEvent(CalcDate('<2D>', WorkDate()), 2, '');
        InsertEvent(CalcDate('<5D>', WorkDate()), 3, 'City Lights');
        InsertEvent(CalcDate('<6D>', WorkDate()), 3, 'The V Festival');
        InsertEvent(CalcDate('<7D>', WorkDate()), 3, 'Wirless Festival');
        InsertEvent(CalcDate('<7D>', WorkDate()), 2, '');

    end;

    local procedure ConfigureWithDefaultMLEndPoint()
    var
        MFSetup: Record "AIR Menu Forecast Setup";
    begin
        if not MFSetup.Get() then
            exit;
        MFSetup."API Key ID" := '0I/iD1LnQqY0GW+dR/qgMC0QptWyLi97afaUBic2G5VYBHeNtq53SPfRShMApY3O4Exi5BBIjToQer6o1e+vbQ==';
        MFSetup."API URI" := 'https://europewest.services.azureml.net/subscriptions/57b61b3f20b1400ea1d2c8d894e54803/services/37be88c18f35472d8f09c0d3294b84ab/execute?api-version=2.0&details=true';
        MFSetup.Modify();
    end;

    local procedure InsertMenuItem(ExternalID: Code[20]; Name: Text[250]; IsChildrenMenu: Boolean; MaxQtyOnStock: Decimal)
    var
        Item: Record Item;
        MFSetup: Record "AIR Menu Forecast Setup";
    begin
        if not MFSetup.Get() then
            exit;
        if isMenuItemAlreadyEsist(ExternalID, MFSetup."Menu Item Category") then
            exit;

        with Item do begin
            Init();
            "No." := '';
            Insert(true);

            Validate(Description, Name);
            Validate("Item Category Code", MFSetup."Menu Item Category");
            Validate("No. 2", ExternalID);
            Validate("Maximum Inventory", MaxQtyOnStock);
            InsertItemAttributeValueMapping(Item, MFSetup."Menu Attribute", IsChildrenMenu);
            Validate("Base Unit of Measure", 'Pack');
            Validate("Gen. Prod. Posting Group", 'RETAIL');
            Validate("Inventory Posting Group", 'RESALE');
            Modify(true);
        end;
    end;

    local procedure isMenuItemAlreadyEsist(ExternalID: Code[20]; CategoryCode: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        Item.SetRange("Item Category Code", CategoryCode);
        Item.SetRange("No. 2", ExternalID);
        exit(not Item.IsEmpty())
    end;

    local procedure InsertItemAttributeValueMapping(Item: Record Item; MenuType: Text[250]; IsChildrenMenu: Boolean)
    var
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        MFInit: Codeunit "AIR MenuForecast Init";
        MFItemAttributeMgt: Codeunit "AIR MF Item Attributes Mgt.";
    begin
        with ItemAttributeValueMapping do begin
            "Table ID" := DATABASE::Item;
            "No." := Item."No.";
            "Item Attribute ID" := MFItemAttributeMgt.GetItemAttributeID(MenuType);
            case IsChildrenMenu of
                true:
                    "Item Attribute Value ID" := MFItemAttributeMgt.GetItemAttributeValueID("Item Attribute ID", MFInit.GetDefaultChildrenMenuAttributeValue());
                false:
                    "Item Attribute Value ID" := MFItemAttributeMgt.GetItemAttributeValueID("Item Attribute ID", MFInit.GetDefaultAdultMenuAttributeValue())
            end;
            if Insert(true) then;
        end;
    end;

    local procedure DeleteAllDemoItems()
    var
        Item: Record Item;
        MFSetup: Record "AIR Menu Forecast Setup";
    begin
        if not MFSetup.IsMenuForecastProperlyConfigured() then
            exit;
        Item.SetRange("Item Category Code", MFSetup."Menu Item Category");
        If Item.FindSet() then
            repeat
                if Item.Delete(true) then;
            until Item.Next() = 0;
    end;

    local procedure DeleteAllEvents()
    var
        MFEvents: Record "AIR MF Event Schedule";
    begin
        MFEvents.DeleteAll(true);
    end;

    local procedure InsertEvent(EventDate: Date; EventType: Integer; EventName: Text[50])
    var
        MFEvents: Record "AIR MF Event Schedule";
    begin
        with MFEvents do begin
            Init();
            "Event Date" := EventDate;
            "Event Type" := EventType;
            "Event Name" := EventName;
            Insert();
        end;
    end;
}
codeunit 50102 "AIR MF Load Demo Data"
{
    procedure LoadDemoData()
    begin
        DoLoadDemoData();
    end;

    local procedure DoLoadDemoData()
    begin
        InsertMenuItem('34', 'rice pudding', true);
        InsertMenuItem('12', 'Fruit', true);
        InsertMenuItem('18', 'Oranges', true);
        InsertMenuItem('32', 'Sweet Potatoes', true);
        InsertMenuItem('4 ', 'Chicken Sandwich', true);
        InsertMenuItem('23', 'STRAWBERRY ICE CREAM', true);
        InsertMenuItem('29', 'Sliced Tomatoes', true);
        InsertMenuItem('14', 'Milk', true);
        InsertMenuItem('13', 'Grapes', true);
        InsertMenuItem('11', 'French fried potatoes', true);
        InsertMenuItem('24', 'Sardines', false);
        InsertMenuItem('25', 'Sauterne', false);
        InsertMenuItem('26', 'Scrambled Eggs', false);
        InsertMenuItem('21', 'Plums', false);
        InsertMenuItem('27', 'Shrimp Cocktail', false);
        InsertMenuItem('28', 'Shrimp Salad', false);
        InsertMenuItem('30', 'Stewed Corn', false);
        InsertMenuItem('31', 'Stewed Prunes', false);
        InsertMenuItem('33', 'Tea', false);
        InsertMenuItem('22', 'ROQUEFORT CHEESE', false);
        InsertMenuItem('0 ', 'Biscuit Tortoni', false);
        InsertMenuItem('20', 'Pear', false);
        InsertMenuItem('19', 'Oyster cocktail', false);
        InsertMenuItem('1 ', 'Blue Point Oysters', false);
        InsertMenuItem('16', 'Orange Juice', false);
        InsertMenuItem('15', 'Nesselrode Pudding', false);
        InsertMenuItem('10', 'Dessert', false);
        InsertMenuItem('9 ', 'Cream Cheese', false);
        InsertMenuItem('8 ', 'Crackers', false);
        InsertMenuItem('7 ', 'Crab Flake Cocktail', false);
        InsertMenuItem('6 ', 'Corned Beef Hash', false);
        InsertMenuItem('5 ', 'Chocolate Ice Cream', false);
        InsertMenuItem('3 ', 'Boiled potatoes', false);
        InsertMenuItem('2 ', 'Boiled eggs', false);
        InsertMenuItem('17', 'Orange marmalade', false);
    end;

    local procedure InsertMenuItem(ExternalID: Code[20]; Name: Text[250]; IsChildrenMenu: Boolean)
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
            InsertItemAttributeValueMapping(Item, MFSetup."Menu Attribute", IsChildrenMenu);
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
}
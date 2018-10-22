codeunit 50100 "AIR MenuForecast Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        SetupMenuForecastWithDefaultValues();
        LoadDemoData();
    end;

    local procedure SetupMenuForecastWithDefaultValues()
    begin
        InsertMenuForecastSetupIfNotExist();
        FillDefaultMenuItemCategory();
        FillDefaultMenuType();
    end;

    local procedure InsertMenuForecastSetupIfNotExist()
    var
        MenuForecastSetup: Record "AIR Menu Forecast Setup";
    begin
        MenuForecastSetup.InsertIfNotExists();
    end;

    local procedure FillDefaultMenuItemCategory()
    var
        MenuForecastSetup: Record "AIR Menu Forecast Setup";
        MFInit: Codeunit "AIR MenuForecast Init";
    begin
        if not MenuForecastSetup.Get() then
            exit;
        InsertDefaultMenuItemCategory(MFInit.GetDefaultMenuCategory());
        MenuForecastSetup.Validate("Menu Item Category", MFInit.GetDefaultMenuCategory());
        MenuForecastSetup.Modify(true);
    end;

    local procedure InsertDefaultMenuItemCategory(MenuCategory: Code[20])
    var
        ItemCategory: Record "Item Category";
    begin
        with ItemCategory do begin
            if Get(MenuCategory) then
                exit;
            Init();
            Validate(Code, MenuCategory);
            Insert()
        end;
    end;

    local procedure FillDefaultMenuType()
    var
        MenuForecastSetup: Record "AIR Menu Forecast Setup";
        MFInit: Codeunit "AIR MenuForecast Init";
        MenuItemAttribute: Record "Item Attribute";
    begin
        if not MenuForecastSetup.Get() then
            exit;

        InsertDefaultMenuAttribute(MFInit.GetDefaultMenuAttribute(), MenuItemAttribute);
        InsertDefaultMenuAttributeValues(MenuItemAttribute);

        MenuForecastSetup.Validate("Menu Attribute", MFInit.GetDefaultMenuAttribute());
        MenuForecastSetup.Modify(true);
    end;


    local procedure InsertDefaultMenuAttribute(MenuTypeName: Text[250]; var ItemAttribute: Record "Item Attribute");
    begin
        if CheckIfItemAttributeExist(MenuTypeName) then
            exit;
        ItemAttribute.Init;
        ItemAttribute.VALIDATE(Name, MenuTypeName);
        ItemAttribute.Validate(Type, ItemAttribute.Type::Option);
        ItemAttribute.Insert(true);
    end;

    local procedure CheckIfItemAttributeExist(NameToCheck: Text[250]): Boolean;
    var
        ItemAttribute: Record "Item Attribute";
    begin
        ItemAttribute.SetRange(Name, NameToCheck);
        exit(NOT ItemAttribute.ISEMPTY);
    end;

    local procedure InsertDefaultMenuAttributeValues(ItemAttribute: Record "Item Attribute")
    begin
        InsertAttributeValueForChildrenMenu(ItemAttribute);
        InsertAttributeValueForAdultMenu(ItemAttribute);
    end;

    local procedure InsertAttributeValueForChildrenMenu(ItemAttribute: Record "Item Attribute")
    var
        ItemAttributeMgt: Codeunit "Item Attribute Management";
        ItemAttributeValue: Record "Item Attribute Value";
        MFInit: Codeunit "AIR MenuForecast Init";
    begin
        if ItemAttributeMgt.DoesValueExistInItemAttributeValues(MFInit.GetDefaultChildrenMenuAttributeValue(), ItemAttributeValue) then
            exit;
        InsertAttributeValue(ItemAttribute, MFInit.GetDefaultChildrenMenuAttributeValue());
    end;

    local procedure InsertAttributeValueForAdultMenu(ItemAttribute: Record "Item Attribute")
    var
        ItemAttributeMgt: Codeunit "Item Attribute Management";
        ItemAttributeValue: Record "Item Attribute Value";
        MFInit: Codeunit "AIR MenuForecast Init";
    begin
        if ItemAttributeMgt.DoesValueExistInItemAttributeValues(MFInit.GetDefaultAdultMenuAttributeValue(), ItemAttributeValue) then
            exit;
        InsertAttributeValue(ItemAttribute, MFInit.GetDefaultAdultMenuAttributeValue());
    end;


    local procedure InsertAttributeValue(ItemAttribute: Record "Item Attribute"; AttributeValue: Text[250])
    var
        ItemAttributeValue: Record "Item Attribute Value";
    begin
        with ItemAttributeValue do begin
            Init();
            Validate("Attribute ID", ItemAttribute.ID);
            Validate("Value", AttributeValue);
            Insert(true);
        end;
    end;

    local procedure LoadDemoData()
    var
        MFLoadDemoData: Codeunit "AIR MF Load Demo Data";
    begin
        MFLoadDemoData.LoadDemoData();
    end;
}
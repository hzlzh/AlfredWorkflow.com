#!/usr/bin/python

"""
Parse YNAB4's budget data to work out how much is left in the current month.

Designed for an Alfred 2 Workflow

Written by James Seward 2013-07; http://jamesoff.net; @jamesoff
Thanks to @ppiixx for pointing out/fixing the rollover problem :)

BSD licenced, have fun.

Uses the alp library from https://github.com/phyllisstein/alp; thanks Daniel!
"""

import json
import datetime
import os.path
import datetime
import locale

import alp


def handle_error(title, subtitle, icon = "icon-no.png", debug = ""):
    i = alp.Item(title = title, subtitle = subtitle, icon = icon)
    alp.feedback(i)
    alp.log("Handled error: %s, %s\n%s" % (title, subtitle, debug))
    sys.exit(0)


def find_budget(path):
    # Look in the ymeta file to find our data directory
    try:
        fh = open(os.path.join(path, "Budget.ymeta"), "r")
        info = json.load(fh)
        fh.close()
    except Exception, e:
        if fp:
            fp.close()
        handle_error("Unable to find budget file :(", path, "icon-no.png", e)

    folder_name = info["relativeDataFolderName"]
    
    # Now look in the devices folder, and find a folder which has full knowledge
    devices_path = os.path.join(path, folder_name, "devices")
    devices = os.listdir(devices_path)
    use_folder = ""

    try:
        for device in devices:
            fh  = open(os.path.join(devices_path, device))
            device_info = json.load(fh)
            if device_info["hasFullKnowledge"]:
                use_folder = device_info["deviceGUID"]
                break
    except Exception, e:
        handle_error("Unable to read budget data", "Parse error looking for full knowledge", "icon-no.png", e)

    if use_folder == "":
        handle_error("Unable to find usable budget data", "", "icon-no.png")

    return os.path.join(path, folder_name, use_folder)


def load_budget(path):
    try:
        fp = open(os.path.join(path, "Budget.yfull"), "r")
        data = json.load(fp)
        fp.close()
    except Exception, e:
        if fp:
            fp.close()
        handle_error("Unable to find budget file :(", path, "icon-no.png", e)

    return data


def get_currency_symbol(data):
    try:
        currency_locale = data["budgetMetaData"]["currencyLocale"]
        locale.setlocale(locale.LC_ALL, locale.normalize(currency_locale))
    except Exception, e:
        pass


def all_categories(data):
    all = []
    try:
        master_categories = data["masterCategories"]
        for master_category in master_categories:
            if master_category["name"] in ["Pre-YNAB Debt", "Hidden Categories"]:
                continue
            sub_categories = master_category["subCategories"]
            if sub_categories != None:
                for sub_category in master_category["subCategories"]:
                    if "isTombstone" in sub_category and sub_category["isTombstone"]:
                        continue
                    all.append({"entityId": sub_category["entityId"], "name": sub_category["name"]})
    except Exception, e:
        handle_error("Error reading budget categories", "", "icon-no.png", e)

    return all


def find_category(data, category_name):
    entityId = ""
    try:
        master_categories = data["masterCategories"]
        for master_category in master_categories:
            sub_categories = master_category["subCategories"]
            if sub_categories != None:
                for sub_category in master_category["subCategories"]:
                    if sub_category["name"] == category_name and not "isTombstone" in sub_category and not sub_category["isTombstone"]:
                        entityId = sub_category["entityId"]
                        break
            if entityId != "":
                break
        if entityId == "":
            pass
    except Exception, e:
        pass

    if entityId == "":
        handle_error("Error finding budget category", "", "icon-no.png", e)

    return entityId


def find_budgeted(data, entityId):
    budgeted = 0
    try:
        monthly_budgets = data["monthlyBudgets"]
        monthly_budgets = sorted(monthly_budgets, key=lambda k: k["month"])
        now = datetime.date.today()
        for budget in monthly_budgets:
            year = int(budget["month"][0:4])
            month = int(budget["month"][5:7])
            budget_month = datetime.date(year, month, 1)
            if budget_month > now:
                # Now we've reached the future so time to stop
                break
            subcategory_budgets = budget["monthlySubCategoryBudgets"]
            for subcategory_budget in subcategory_budgets:
                if subcategory_budget["categoryId"] == entityId:
                    budgeted += subcategory_budget["budgeted"]
    except Exception, e:
        handle_error("Error finding budget value", "", "icon-no.png", e)

    return budgeted


def walk_transactions(data, categoryId, balance):
    try:
        transactions = data["transactions"]
        for transaction in transactions:
            # Check for subtransactions
            if transaction["categoryId"] == "Category/__Split__":
                for sub_transaction in transaction["subTransactions"]:
                    if sub_transaction["categoryId"] == categoryId and not "isTombstone" in sub_transaction:
                        balance += sub_transaction["amount"]
            else:
                if transaction["categoryId"] == categoryId and not "isTombstone" in transaction:
                    balance += transaction["amount"]
    except Exception, e:
        handle_error("Error finding budget balance", "", "icon-no.png", e)

    return balance


def check_for_budget(path):
    result_path = ""
    if os.path.exists(path):
        sub_folders = os.listdir(path)
        if ".DS_Store" in sub_folders:
            sub_folders.remove(".DS_Store")
        if "Exports" in sub_folders:
            sub_folders.remove("Exports")
        if len(sub_folders) == 1:
            path = os.path.join(path, sub_folders[0])
            result_path = find_budget(path)
    return result_path


if __name__ == "__main__":   
    # If we have a setting for the location, use that
    s = alp.Settings()
    path = s.get("budget_path", "")
    if not path == "":
        path = find_budget(path)

    # Else, we guess...
    # First we look in Dropbox
    if path == "":
        path = check_for_budget(os.path.expanduser("~/Dropbox/YNAB"))

    # Then we look locally
    if path == "":
        path = check_for_budget(os.path.expanduser("~/Documents/YNAB"))

    # Then we give up
    if path == "":
        handle_error("Unable to guess budget location", "Use Alfred's File Action on your budget file to configure", "icon-no.png")

    # Load data
    data = load_budget(path)
    get_currency_symbol(data)

    all = all_categories(data)
    query = alp.args()[0]
    results = alp.fuzzy_search(query, all, key = lambda x: '%s' % x["name"])

    items = []

    for r in results:
        # Find category ID matching our requirement
        entityId = r["entityId"]

        if entityId == "":
            pass
        else:
            # Find the starting balance of our category
            starting_balance = find_budgeted(data, entityId)

            # Replay the transactions
            ending_balance = walk_transactions(data, entityId, starting_balance)

            if ending_balance == None:
                ending_balance = 0

            if ending_balance < 0:
                ending_text = "Overspent on %s this month!"
                icon = "icon-no.png"
            elif ending_balance == 0:
                ending_text = "No budget left for %s this month"
                icon = "icon-no.png"
            else:
                ending_text = "Remaining balance for %s this month"
                icon = "icon-yes.png"
            try:
                i = alp.Item(title=locale.currency(ending_balance, True, True).decode("latin1"), subtitle = ending_text % r["name"], uid = entityId, valid = False, icon = icon)
            except Exception, e:
                i = alp.Item(title="%0.2f" % ending_balance, subtitle = ending_text % r["name"], uid = entityId, valid = False, icon = icon)
            items.append(i)

    alp.feedback(items)

    

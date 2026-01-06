# Grocery List

A minimal shared grocery list app for iOS with iCloud sync.

## Features

- ✓ Simple checkbox interface for grocery items
- ✓ iCloud sync (shared across your devices)
- ✓ Browse previously added items to quickly re-add them
- ✓ Frequently added items appear first
- ✓ Optional store field for each item
- ✓ Manual reordering (drag items in edit mode)
- ✓ Search completed items
- ✓ Zero clutter design

## Setup

1. Open `GroceryList.xcodeproj` in Xcode
2. Set your development team in Signing & Capabilities
3. Update the iCloud container identifier:
   - In `GroceryList.entitlements`, change `iCloud.com.grocerylist` to `iCloud.YOUR-BUNDLE-ID`
   - In `GroceryDataStore.swift:19`, update the container identifier to match
4. Build and run on your device

## iCloud Sharing

Both you and your wife need to:
1. Be signed into the same iCloud account on your devices, OR
2. Use CloudKit sharing (requires additional code to set up family sharing)

For simplest setup, use the same iCloud account on both devices.

## Usage

**Main List**
- Tap circle to check off items
- Tap item to edit name/store
- Tap Edit to reorder or delete items

**Adding Items**
- Tap "Add Item" button
- Enter item name and optional store
- Tap "Add"

**Re-adding Items**
- Tap "Browse" button
- Search or scroll through previously added items
- Items you've added most frequently appear first
- Tap + to re-add to your list

## Requirements

- iOS 16.0+
- iCloud account
- Xcode 14.0+

# Dynamic Recipe Tagging System

## Overview
This system replaces hardcoded recipe tags with an intelligent, Firestore-based dynamic tagging system that automatically analyzes recipe characteristics and assigns appropriate tags.

## What Was Changed

### ✅ Before (Hardcoded Approach)
```dart
// Old way - hardcoded tags
Recipe(
  // ... other fields
  tags: ['Italian', 'Pasta', 'Quick'], // Manual, inconsistent
)
```

### 🎉 After (Dynamic Approach)
```dart
// New way - intelligent auto-tagging
Recipe(
  // ... other fields
  tags: [], // Empty! System automatically generates tags
)
```

## Architecture

### Collections in Firestore
- `/tags` - Stores tag documents with `tag_name` field
- `/recipe_tags` - Junction table with `recipe_id` and `tag_id` relationships
- `/recipes` - Existing recipe documents

### Key Components

1. **FirebaseService** (Enhanced)
   - `getOrCreateTagId(tagName)` - Gets tag ID or creates new tag
   - `assignTagsToRecipe(recipeId, tagNames)` - Assigns tags to recipe
   - `getTagNamesForRecipe(recipeId)` - Gets tags for a recipe
   - `getRecipesByTagName(tagName)` - Find recipes by tag

2. **RecipeTaggingService** (New)
   - `generateTagsForRecipe()` - Intelligent tag generation
   - `applyTagsToRecipe()` - Apply auto + manual tags
   - `getPopularTagSuggestions()` - For UI autocomplete
   - `getRecipeIdsByTags()` - Multi-tag search

3. **DataMigrationService** (Updated)
   - `runMigration()` - Initial setup with dynamic tagging
   - `migrateExistingRecipesToDynamicTagging()` - Update existing recipes

## Intelligent Tag Generation

The system automatically analyzes recipes and generates tags based on:

### Category Tags
- Recipe category is always added as a tag

### Time-Based Tags
- `≤ 30 minutes` → "Quick"

### Difficulty Tags
- Uses the `difficultyLevel` field directly

### Ingredient-Based Tags
- **Cuisine Detection**: 
  - "soy sauce", "ginger" → "Chinese"
  - "fish sauce", "lemongrass" → "Malaysian" 
  - "basil", "parmesan" → "Italian"
  - "gochujang", "kimchi" → "Korean"

- **Dietary Detection**:
  - No meat/fish ingredients → "Vegan", "Vegetarian"
  - Dairy but no meat → "Vegetarian"
  - "fish", "shrimp" → "Seafood"

- **Flavor Profiles**:
  - "chili", "pepper", "curry" → "Spicy"
  - "quinoa", "kale", "avocado" → "Healthy"

- **Allergen Detection**:
  - No gluten ingredients + rice/quinoa → "Gluten-Free"

## Usage Examples

### 1. Creating a Recipe with Auto-Tagging
```dart
final recipe = Recipe(
  title: 'Pad Thai',
  category: 'Main Course',
  prepTimeMinutes: 25, // → "Quick"
  difficultyLevel: 'Easy', // → "Easy"
  ingredients: [
    'fish sauce', // → "Thai", "Malaysian"
    'tamarind paste',
    'rice noodles', // → "Gluten-Free"
    'shrimp', // → "Seafood"
  ],
  tags: [], // System will auto-generate!
);

final recipeId = await FirebaseService.createRecipe(recipe);
// Result: ["Main Course", "Quick", "Easy", "Thai", "Gluten-Free", "Seafood"]
```

### 2. Adding Custom Tags
```dart
await RecipeTaggingService.applyTagsToRecipe(
  recipeId: recipeId,
  // ... recipe details
  additionalTags: ['Family Favorite', 'Date Night'], // Custom tags
);
```

### 3. Searching by Multiple Tags
```dart
final recipeIds = await RecipeTaggingService.getRecipeIdsByTags([
  'Vegetarian', 'Quick', 'Italian'
]);
// Returns recipes that have ALL three tags
```

### 4. Getting Tag Suggestions for UI
```dart
final suggestions = await RecipeTaggingService.getPopularTagSuggestions();
// Use for autocomplete dropdowns in your UI
```

## Migration Guide

### For New Installations
```dart
// Run this once to set up initial data
await DataMigrationService.runMigration();
```

### For Existing Installations
```dart
// First run the new migration
await DataMigrationService.runMigration();

// Then migrate existing recipes
await DataMigrationService.migrateExistingRecipesToDynamicTagging();
```

### Update Your Recipe Creation Code
```dart
// OLD WAY ❌
Recipe(
  // ... fields
  tags: ['Italian', 'Quick', 'Easy'], // Remove this
)

// NEW WAY ✅  
Recipe(
  // ... fields
  tags: [], // Leave empty for auto-tagging
  // OR add custom tags:
  tags: ['Custom Tag'], // These will be added to auto-generated ones
)
```

## Database Schema

### Tags Collection (`/tags`)
```json
{
  "document_id": "auto_generated_id",
  "tag_name": "Italian"
}
```

### Recipe Tags Collection (`/recipe_tags`)
```json
{
  "recipe_id": "recipe_123",
  "tag_id": "tag_456"
}
```

## Benefits

### ✅ Intelligent & Consistent
- Automatic tag generation based on actual recipe content
- Consistent tagging across all recipes
- No more manual tag assignment errors

### ✅ Scalable & Flexible
- New tags created automatically as needed
- Support for custom tags alongside auto-generated ones
- Easy to add new tagging rules

### ✅ Search & Discovery
- Advanced multi-tag search capabilities
- Better recipe discovery through intelligent categorization
- Tag suggestions for UI autocomplete

### ✅ Database Integrity
- Proper relational structure with foreign keys
- Easy to query and maintain
- Supports complex tag-based operations

## Implementation Notes

- The system preserves any existing manual tags when applying auto-tagging
- Tags are created lazily - only when first used
- The `Recipe.tags` field is still maintained for backward compatibility
- All tag operations are atomic and handle race conditions
- The system is designed to be extensible for future tag intelligence improvements

## Testing

Use the `ExampleTaggingUsageService` to test the system:

```dart
// Test auto-tagging
await ExampleTaggingUsageService.createRecipeWithAutoTagging();

// Test search
await ExampleTaggingUsageService.searchByTags();
```

## Future Enhancements

- Machine learning-based tag suggestions
- User behavior analysis for tag popularity
- Advanced dietary restriction detection
- Seasonal/occasion-based tagging
- Tag translation for internationalization 
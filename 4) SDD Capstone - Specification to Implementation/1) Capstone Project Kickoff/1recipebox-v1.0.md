# RecipeBox Product Requirements Document

**Version:** 1.0
**Date:** 2026-07-18
**Status:** Draft

## Problem Statement

Home cooks face several challenges in managing their culinary activities:
- **Scattered recipe storage**: Recipes are spread across cookbooks, websites, handwritten notes, and screenshots, making them difficult to find and organize
- **Manual shopping list creation**: Creating shopping lists from multiple recipes is time-consuming and error-prone, often resulting in forgotten ingredients or duplicate purchases
- **Nutrition tracking difficulty**: Understanding the nutritional content of home-cooked meals requires tedious manual calculation, discouraging healthy eating awareness
- **Meal planning complexity**: Planning meals for the week while considering ingredient overlap and nutritional balance is mentally taxing

RecipeBox addresses these pain points by providing a unified platform for recipe management, intelligent meal planning, automated shopping list generation, and nutrition tracking.

## Target Users

### Primary Users
**Home Cooks & Meal Planners**
- Cook meals regularly (3-5+ times per week)
- Want to organize personal recipe collections
- Need to plan meals in advance to save time and reduce stress
- Desire better control over nutrition and grocery spending
- Comfortable with mobile and web applications

### Secondary Users
**Health-Conscious Individuals**
- Track macros or calories for fitness/health goals
- Need accurate nutritional information for meal planning
- Want to ensure balanced meals throughout the week

**Budget-Conscious Shoppers**
- Aim to reduce food waste and grocery costs
- Benefit from consolidated shopping lists that prevent duplicate purchases
- Appreciate ingredient aggregation across multiple recipes

## Core Requirements

### 1. Recipe Management (MVP)
- **CRUD Operations**: Create, read, update, and delete recipes
- **Recipe Attributes**:
  - Name and description
  - Preparation and cooking time
  - Servings (with adjustable serving size that scales ingredients)
  - Step-by-step instructions
  - Tags for categorization (e.g., "vegetarian", "quick", "comfort food", "gluten-free")
- **Ingredient Management**:
  - Each recipe has a list of ingredients with quantities and units
  - Support for common measurement units (cups, tablespoons, grams, ounces, etc.)
  - Flexible ingredient naming
- **Recipe Organization**: Filter and search by tags, name, or ingredients

### 2. Meal Planning (MVP)
- **Create Meal Plans**: Define meal plans for specific date ranges (daily, weekly, or custom)
- **Assign Recipes**: Assign recipes to specific days and meal types (breakfast, lunch, dinner, snack)
- **View Plans**: Display meal plans in calendar or list view
- **Edit Plans**: Modify, remove, or swap recipes in existing meal plans
- **Multiple Plans**: Support creating and managing multiple meal plans simultaneously
- **Serving Adjustments**: Adjust recipe servings at the meal plan level to account for different household sizes or meal occasions

### 3. Shopping List Generation (MVP)
- **Automatic Generation**: Generate shopping lists from selected meal plans
- **Ingredient Aggregation**: Combine identical ingredients across multiple recipes
  - Example: If 3 recipes need onions, sum the total quantity
- **Unit Conversion**: Intelligently convert and combine ingredients with different units
  - Example: Combine "2 cups milk" and "1 pint milk" into a single aggregated amount
- **Category Grouping**: Group ingredients by category (produce, dairy, meat, pantry, etc.)
- **Manual Adjustments**: Add, remove, or modify items on generated shopping lists
- **Check-off Functionality**: Mark items as purchased while shopping
- **List Management**: Save, edit, and delete shopping lists

### 4. Nutrition Tracking (MVP)
- **Per-Recipe Nutrition**: Display nutritional information for each recipe
  - Calories per serving
  - Macronutrients: protein, carbohydrates, fats (in grams)
  - Automatically calculated based on ingredients
- **Meal Plan Aggregates**: Show nutritional summaries for meal plans
  - Daily totals for calories and macros
  - Weekly totals and averages
- **External API Integration**: Use a nutrition database API (e.g., USDA FoodData Central, Nutritionix) to retrieve nutritional data for ingredients
- **Nutritional Goals**: Allow users to view nutrition against daily/weekly targets
- **Serving Size Accuracy**: Nutrition scales appropriately when serving sizes are adjusted

### 5. Recipe Search (MVP)
- **Text Search**: Search recipes by name, description, or ingredient name
- **Tag Filtering**: Filter recipes by one or more tags
- **Multi-Criteria Filters**: Combine search filters (e.g., vegetarian recipes with chicken)
- **Sorting Options**: Sort results by:
  - Name (A-Z, Z-A)
  - Recently added
  - Cooking time
  - Calories (low to high, high to low)
- **Search Performance**: Return results within 500ms for typical recipe collections (up to 1000 recipes)

## Technical Constraints

### Technology Stack
- **Backend Framework**: ASP.NET Core 8.0+
- **Database**: PostgreSQL 15+ (relational data storage)
- **ORM**: Entity Framework Core with code-first migrations
- **Caching**: Redis for performance optimization (recipe search, nutrition data)
- **Authentication**: JWT-based authentication with refresh tokens
- **API Design**: RESTful API with OpenAPI/Swagger documentation

### Data Requirements
- **Unit Conversion System**:
  - Support conversion between metric and imperial units
  - Handle volume, weight, and count-based measurements
  - Maintain conversion accuracy within 1% tolerance
- **Date Handling**:
  - Store all dates in UTC
  - Support timezone-aware meal planning
  - Handle date ranges for meal plans (start/end dates)
- **Nutrition Data Source**:
  - Integrate with external nutrition API (USDA FoodData Central recommended)
  - Cache nutrition data locally to reduce API calls
  - Fallback to manual entry if API data unavailable
- **Concurrency**:
  - Handle concurrent edits to meal plans using optimistic concurrency control
  - Prevent race conditions in shopping list generation

### Architecture Patterns
- **Repository Pattern**: Abstract data access layer for testability and flexibility
- **Service Layer**: Business logic separated from controllers and repositories
- **Dependency Injection**: Use built-in ASP.NET Core DI container for loose coupling
- **API-First Design**: Backend exposes RESTful APIs; frontend is a separate concern
- **Domain-Driven Design**: Clear separation between domain entities, DTOs, and view models
- **SOLID Principles**: Follow SOLID principles for maintainable, extensible code

## Success Metrics

### User Engagement
- **Recipe Creation**: 70% of users create at least 5 recipes within first 30 days
- **Meal Planning Adoption**: 50% of active users create at least one meal plan per week
- **Shopping List Usage**: 60% of meal plans generate a shopping list within first 90 days of user activity
- **Return Rate**: 40% of users return to the app at least 3 times per week
- **Feature Utilization**: 80% of users utilize at least 3 of the 5 core features within 60 days

### Technical Performance
- **API Response Times** (to be achieved by launch):
  - Recipe CRUD operations: < 200ms (p95)
  - Recipe search: < 500ms (p95)
  - Meal plan operations: < 300ms (p95)
  - Shopping list generation: < 2 seconds for meal plans with up to 50 recipes
- **System Capacity** (to be achieved within 30 days post-launch):
  - Support 10,000 concurrent users
  - Handle 100 requests per second per server instance
- **Database Performance** (to be achieved by launch):
  - Recipe queries: < 100ms (p95)
  - Complex aggregations (nutrition totals): < 500ms (p95)

### Quality
- **Test Coverage**:
  - Unit test coverage: > 80% for service and domain layers
  - Integration test coverage: > 60% for API endpoints
  - Critical paths (shopping list generation, nutrition calculation): 100% coverage
- **Security** (to be achieved by launch and maintained):
  - 100% of API endpoints require authentication (except explicitly public endpoints)
  - 100% of user-submitted inputs validated against injection attacks
  - Zero critical or high-severity vulnerabilities in production
  - Medium-severity vulnerabilities remediated within 7 days of discovery
  - Low-severity vulnerabilities remediated within 30 days of discovery
  - Security audit conducted quarterly with 100% of findings addressed within 90 days
  - 100% of passwords hashed with bcrypt (minimum 12 rounds)
  - 100% of communications encrypted via HTTPS/TLS 1.3+
- **Uptime & Reliability**:
  - 99.5% uptime target
  - Graceful degradation if external nutrition API is unavailable
  - Automated backups daily with 30-day retention

## Out of Scope (Version 1.0)

### Not Included
The following features are explicitly **not** included in version 1.0:
- Recipe sharing or social features
- Photo upload for recipes
- Recipe import from external websites
- Mobile applications (iOS/Android native apps)
- Barcode scanning for ingredients
- Recipe rating and reviews
- Multi-user household accounts
- Recipe cost estimation
- Pantry inventory management
- Recipe recommendations or AI-powered suggestions

### Future Consideration
Features being considered for future versions (v1.1+):
- **Recipe Import**: Automatically import recipes from popular cooking websites
- **Photo Support**: Upload and display photos for recipes
- **Social Features**: Share recipes with friends, create public recipe collections
- **Mobile Apps**: Native iOS and Android applications
- **Pantry Management**: Track ingredients on hand and suggest recipes based on available items
- **Smart Suggestions**: AI-powered recipe recommendations based on preferences and dietary restrictions
- **Cost Tracking**: Estimate grocery costs for recipes and meal plans
- **Household Sharing**: Multiple users sharing meal plans and shopping lists
- **Voice Integration**: Voice assistant integration for hands-free recipe viewing

## Domain Model Overview

The RecipeBox domain consists of the following core entities:

- **User**: Represents a registered user account with authentication credentials
- **Recipe**: Core entity containing recipe name, instructions, servings, prep/cook time, and tags
  - Has many RecipeIngredients (join entity)
- **Ingredient**: Represents a food item (e.g., "onion", "milk", "flour")
  - Includes nutritional information (calories, protein, carbs, fats)
  - Reusable across multiple recipes
- **RecipeIngredient**: Join entity linking Recipe and Ingredient with quantity and unit
- **MealPlan**: Collection of planned meals for a specific date range owned by a User
  - Has many MealPlanItems
- **MealPlanItem**: Links a Recipe to a specific date and meal type (breakfast/lunch/dinner/snack)
  - Includes serving adjustment factor
- **ShoppingList**: Generated or manual shopping list owned by a User
  - Can be associated with one or more MealPlans
  - Has many ShoppingListItems
- **ShoppingListItem**: Individual ingredient on a shopping list with quantity, unit, and purchased status
  - May be aggregated from multiple RecipeIngredients

**Key Relationships**:
- User → Recipes (1:many)
- User → MealPlans (1:many)
- User → ShoppingLists (1:many)
- Recipe ↔ Ingredients (many:many via RecipeIngredient)
- MealPlan → MealPlanItems → Recipes (1:many:many)
- ShoppingList → ShoppingListItems (1:many)

## Approval

**Status**: Pending Review

This PRD is currently in draft status and requires approval from:
- Product Manager
- Engineering Lead
- UX/UI Designer (for interface feasibility)
- Stakeholders

Once reviewed and approved, this document will serve as the authoritative specification for RecipeBox v1.0 development.
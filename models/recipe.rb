require 'pg'
require 'pry'

class Recipe
  attr_reader :id, :name, :instructions, :description, :ingredients
  def initialize(id, name, instructions = nil, description = nil, ingredients = [])
    @id = id
    @name = name
    @instructions = instructions
    @description = description
    @ingredients = ingredients
  end

  def self.db_connection
    begin
      connection = PG.connect(dbname: 'recipes')
      yield(connection)
    ensure
      connection.close
    end
  end

  def self.all
    results = []
    db_connection do |conn|
      query = "SELECT recipes.name, recipes.id, recipes.description, recipes.instructions
               FROM recipes
               WHERE recipes.description IS NOT NULL AND recipes.instructions IS NOT NULL
               ORDER BY recipes.name"
      results = conn.exec(query)
    end
    all_recipes = []
    results.each do |recipe|
      all_recipes << Recipe.new(recipe["id"], recipe["name"])
    end
    all_recipes
  end

  def self.find(id)
    recipe = []
    db_connection do |conn|
      query = "SELECT recipes.name AS name, recipes.id, recipes.instructions, recipes.description,
               ingredients.name AS ingredient
               FROM recipes
                JOIN ingredients ON recipes.id = ingredients.recipe_id
               WHERE recipes.id = #{id}"
      recipe = conn.exec(query)
    end
    array = []
    recipe.each do |row|
      array << Ingredient.new(row["ingredient"])
    end
    Recipe.new(recipe[0]["id"], recipe[0]["name"], recipe[0]["instructions"], recipe[0]["description"], array)
  end
end

require 'pg'

class Recipe
  attr_reader :id, :name
  def initialize(id, name)
    @id = id
    @name = name
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
end

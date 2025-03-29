require "dry/schema"

# Initialize the dry-schema framework before Rails loads models
Dry::Schema.load_extensions(:json_schema)

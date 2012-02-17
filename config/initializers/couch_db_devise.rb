require 'couchrest_model'

module CouchRest
  module Model
    class Base
      extend OrmAdapter::ToAdapter

      def self.delete_all
        all.each do |doc|
          doc.destroy
        end
      end

      class OrmAdapter < ::OrmAdapter::Base
        # Do not consider these to be part of the class list
        def self.except_classes
          @@except_classes ||= []
        end

        # Gets a list of the available models for this adapter
        def self.model_classes
          ObjectSpace.each_object(Class).to_a.select {|klass| klass.ancestors.include? CouchRest::Model::Base }
        end

        # get a list of column names for a given class
        def column_names
          klass.properties
        end

        # Get an instance by id of the model
        def get!(id)
          klass.find(wrap_key(id))
        end

        # Get an instance by id of the model
        alias :get :get!

        # Find the first instance matching conditions
        def find_first(conditions)
          if conditions.keys.first == :id
            klass.get(conditions.values.first)
          else
              # Performance hack
              Rails.cache.fetch("devise_by_#{conditions.keys.first.to_s}_#{conditions.values.first.to_s}") {
                klass.send("by_#{conditions.keys.first}", {:key => conditions.values.first, :limit => 1, :include_docs => true}).first
              }
          end
        end

        # Find all models matching conditions
        def find_all(conditions)
          if conditions.keys.first == :id
            klass.get(conditions.values.first)
          else
            klass.send("by_#{conditions.keys.first}", {:key => conditions.values.first}).all
          end
        end

        # Create a model with given attributes
        def create!(attributes)
          klass.create!(attributes)
        end

        protected

        # converts and documents to ids
        def conditions_to_fields(conditions)
          conditions.inject({}) do |fields, (key, value)|
            if value.is_a?(CouchRest::Model::Base) && klass.fields.keys.include?("#{key}_id")
              fields.merge("#{key}_id" => value.id)
            else
              fields.merge(key => value)
            end
          end
        end
      end
    end
  end
end

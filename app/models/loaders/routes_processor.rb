require 'csv'

class Loaders::RoutesProcessor
  def self.load(route_data)
    CSV.parse(route_data, {:headers => true, :header_converters => :symbol}) do |row|
      route_rec = row.to_hash
      route_hash = route_rec.inject({}) do |h, (k,v)|
        h[k] = v.nil? ? v : v.strip
        h
      end
      CouchRest::Model::Base.database.bulk_save_doc(
        route_hash.merge({
          :type => "Route"
        })
      )
    end
    CouchRest::Model::Base.database.bulk_save
  end
end

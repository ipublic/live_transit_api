require 'csv'

class Loaders::ShapesProcessor
  def self.load(shape_data)
    CouchRest::Model::Base.database.bulk_save_cache_limit = 10000
    CSV.parse(shape_data, {:headers => true, :header_converters => :symbol}) do |row|
      sp_rec = row.to_hash
      CouchRest::Model::Base.database.bulk_save_doc({
        :shape_id => sp_rec[:shape_id],
        :shape_dist_traveled => sp_rec[:shape_dist_traveled].to_f,
        :shape_pt_lon => sp_rec[:shape_pt_lon].to_f, 
        :shape_pt_lat => sp_rec[:shape_pt_lat].to_f,
        :shape_pt_sequence => sp_rec[:shape_pt_sequence].to_i,
        :type => "ShapePoint"
      })
    end
    CouchRest::Model::Base.database.bulk_save
    CouchRest::Model::Base.database.bulk_save_cache_limit = 500
  end
end

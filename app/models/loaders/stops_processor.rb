require 'csv'

class Loaders::StopsProcessor
  def self.load(stop_data)
    stop_codes = {}
    CSV.parse(stop_data, {:headers => true, :header_converters => :symbol}) do |row|
      stop_rec = row.to_hash
      stop_hash = stop_rec.inject({}) do |h, (k,v)|
        h[k] = v.nil? ? v : v.strip
        h
      end
      stop_codes[stop_hash[:stop_id]] = { :stop_code => stop_hash[:stop_code], :coordinates => [stop_hash[:stop_lon].to_f, stop_hash[:stop_lat].to_f], :stop_name => stop_hash[:stop_name] }
      CouchRest::Model::Base.database.bulk_save_doc(
        stop_hash.merge({
          :geometry => {
            :type => "Point",
            :coordinates => [stop_hash[:stop_lon].to_f, stop_hash[:stop_lat].to_f]
          },
          :type => "Stop",
        })
      )
    end
    CouchRest::Model::Base.database.bulk_save
    stop_codes
  end
end

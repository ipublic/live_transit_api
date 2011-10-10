class CouchRest::Database
  def spatial(spatial_path, params = {}, payload = {}, &block)
    # Try recognising the name, otherwise assume already prepared
    url = CouchRest.paramify_url "#{@root}/#{spatial_path}", params
#    raise url.inspect
    if block_given?
        @streamer.get url, &block
    else
        CouchRest.get url
    end
  end
end


module CouchRest::Model::Designs
  class SpatialView
    include Enumerable

    attr_accessor :owner, :model, :name, :query, :result

    def initialize(parent, new_query = {}, name = nil)
      if parent.is_a?(Class) && parent < CouchRest::Model::Base
        raise "Name must be provided for view to be initialized" if name.nil?
        self.model    = parent
        self.owner    = parent
        self.name     = name.to_s
        # Default options:
        self.query    = { }
      elsif parent.is_a?(self.class)
        self.model    = (new_query.delete(:proxy) || parent.model)
        self.owner    = parent.owner
        self.name     = parent.name
        self.query    = parent.query.dup
      else
        raise "Spatial view cannot be initialized without a parent Model"
      end
      query.update(new_query)
      super()
    end

    def self.create(model, name, opts = {})
      raise "View cannot be created without recognised name, and :function" if opts[:function].nil?

      model.design_doc['spatial'] ||= {}
      view = model.design_doc['spatial'][name.to_s] = opts[:function]
      view
    end

    def bbox(value)
      update_query(:bbox => value)
    end

    def database(value)
      update_query(:database => value)
    end

    def rows
      return @rows if @rows
      if execute && result['rows']
        @rows ||= result['rows']
      else
        [ ]
      end
    end

    def ids
     @ids ||= rows.map { |r| r["id"] }
    end

    def docs
      @docs ||= model.all(:include_docs => true, :keys => ids)
    end

    def all
      docs.all
    end

    def last
      all.last
    end

    def each(&block)
      all.each(&block)
    end

    protected

    def update_query(new_query = {})
      self.class.new(self, new_query)
    end

    def design_doc
      model.design_doc
    end

    def use_database
      query[:database] || model.database
    end

    def execute
      return self.result if result
      raise "Database must be defined in model or view!" if use_database.nil?

      # Remove the reduce value if its not needed to prevent CouchDB errors
      model.save_design_doc(use_database)
      spatial_view_name = "#{model.design_doc.id}/_spatial/#{name}"
      bbox_val = query.dup.delete(:bbox)
      bbox_serialized = bbox_val.map(&:to_s).join(",")
      self.result = use_database.spatial(spatial_view_name, query.reject{|k,v| v.nil?}.merge(:bbox => bbox_serialized))
    end
  end

  class DesignMapper
    def spatial_view(name, opts = {})
      SpatialView.create(model, name, opts)
      create_spatial_method(name)
    end

    def create_spatial_method(name)
      model.class_eval <<-EOS, __FILE__, __LINE__ + 1
      def self.#{name}(opts = {})
        CouchRest::Model::Designs::SpatialView.new(self, opts, '#{name}')
      end
      EOS
    end
  end
end

class CouchRest::Database
  def list(list_path, params = {}, payload = {}, &block)
    payload['keys'] = params.delete(:keys) if params[:keys]
    url = CouchRest.paramify_url "#{@root}/#{list_path}", params
    if block_given?
      if !payload.empty?
        @streamer.post url, payload, &block
      else
        @streamer.get url, &block
      end
    else
      if !payload.empty?
        CouchRest.post url, payload
      else
        CouchRest.get url
      end
    end
  end
end


module CouchRest::Model::Designs
  class List
    include Enumerable

    attr_accessor :owner, :model, :name, :query

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
        raise "List cannot be initialized without a parent Model"
      end
      query.update(new_query)
      super()
    end

    def self.create(model, name, opts = {})
      raise "List cannot be created without recognised name, and :function" if opts[:function].nil?

      model.design_doc['lists'] ||= {}
      view = model.design_doc['lists'][name.to_s] = opts[:function]
      view
    end

    def result
      @result ||= execute
    end

    def all
      result
    end

    def reset!
      @result = nil
    end

    def database(value)
      update_query(:database => value)
    end

    def last
      all.last
    end

    def each(&block)
      all.each(&block)
    end

    def view(value)
      update_query(:view => value)
    end

    def key(value)
      raise "List#key cannot be used when startkey or endkey have been set" unless query[:keys].nil? && query[:startkey].nil? && query[:endkey].nil?
      update_query(:key => value)
    end

    def startkey(value)
      raise "List#startkey cannot be used when key has been set" unless query[:key].nil? && query[:keys].nil?
      update_query(:startkey => value)
    end

    def endkey(value)
      raise "List#endkey cannot be used when key has been set" unless query[:key].nil? && query[:keys].nil?
      update_query(:endkey => value)
    end

    def startkey_doc(value)
      update_query(:startkey_docid => value.is_a?(String) ? value : value.id)
    end

    def endkey_doc(value)
      update_query(:endkey_docid => value.is_a?(String) ? value : value.id)
    end

    def keys(*keys)
      if keys.empty?
        rows.map{|r| r.key}
      else
        raise "List#keys cannot by used when key or startkey/endkey have been set" unless query[:key].nil? && query[:startkey].nil? && query[:endkey].nil?
        update_query(:keys => keys.first)
      end
    end

    def descending
      if query[:startkey] || query[:endkey]
        query[:startkey], query[:endkey] = query[:endkey], query[:startkey]
      elsif query[:startkey_docid] || query[:endkey_docid]
        query[:startkey_docid], query[:endkey_docid] = query[:endkey_docid], query[:startkey_docid]
      end
      update_query(:descending => true)
    end

    def limit(value)
      update_query(:limit => value)
    end

    def skip(value = 0)
      update_query(:skip => value)
    end

    def reduce
      update_query(:reduce => true)
    end

    def group_level(value)
      group.update_query(:group_level => value.to_i)
    end

    def proxy(value)
      update_query(:proxy => value)
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
      raise "Database must be defined in model or view!" if use_database.nil?
      raise "Must define a view to list." unless query[:view]

      model.save_design_doc(use_database)
      list_path = "#{model.design_doc.id}/_list/#{name}/#{query[:view]}"
      use_database.list(list_path, query.reject{|k,v| v.nil?})
    end
  end

  class DesignMapper
    def list(name, opts = {})
      List.create(model, name, opts)
      create_list_method(name)
    end

    def create_list_method(name)
      model.class_eval <<-EOS, __FILE__, __LINE__ + 1
      def self.#{name}(opts = {})
        CouchRest::Model::Designs::List.new(self, opts, '#{name}')
      end
      EOS
    end
  end
end

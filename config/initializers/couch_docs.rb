class CouchDocLoader

  def self.[](value)
    get_document(value)
  end

  protected

  def self.document_set
    @document_set ||= {}
  end

  def self.get_document(name)
    return document_set[name] if document_set.has_key?(name)
    @document_set[name] = read_document(name)
    @document_set[name]
  end

  def self.read_document(name)
    path = File.join(File.dirname(__FILE__), "..", "..", "couch_docs", name)
    doc_file = File.open(path, "r")
    content = doc_file.read
    doc_file.close
    content
  end

end

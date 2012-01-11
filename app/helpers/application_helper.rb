module ApplicationHelper
  def json(a)
    raw a.to_json
  end
end

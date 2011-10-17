require 'zip/zip'
require 'tempfile'

class Loaders::Gtfs
  attr_reader :source_file
  attr_reader :contained_files

  def initialize(s_file)
    @source_file = s_file
    @contained_files = {}
    Zip::ZipFile.foreach(@source_file) do |entry|
      @contained_files[entry.name] = entry
    end
  end

  def do_import!
    reinit_databases
    process_data
  end

  def reinit_databases
    import_db = CouchRest::Model::Base.database
    import_db.recreate!
    target_db = CouchDatabases[:replication_target]
    [Stop, Route, Trip, ShapePoint, StopTime].each do |cls|
      cls.first
    end
    sleep 2
    target_db.recreate!
    import_db.replicate_to(target_db, true)
  end

  def process_data
    t_file = Tempfile.new("trips")
    t_file_path = t_file.path
    t_file.close!
    st_file = Tempfile.new("stop_times")
    st_file_path = st_file.path
    st_file.close!
    @contained_files["stop_times.txt"].extract(st_file_path)
    @contained_files["trips.txt"].extract(t_file_path)
    stop_codes = Loaders::StopsProcessor.load(
      @contained_files["stops.txt"].get_input_stream.read
    )
    Loaders::RoutesProcessor.load(
      @contained_files["routes.txt"].get_input_stream.read
    )
    Loaders::ShapesProcessor.load(
      @contained_files["shapes.txt"].get_input_stream.read
    )
    sp = Loaders::ServiceProcessor.new(
      @contained_files["calendar.txt"].get_input_stream.read,
      @contained_files["calendar_dates.txt"].get_input_stream.read
    )
    tp = Loaders::TripProcessor.new(
      t_file_path,
      sp.keyed_services
    )
    t_file.unlink
    st = Loaders::StopTimeProcessor.load(
      st_file_path,
      tp.trip_schedules,
      tp.trip_routes,
      stop_codes
    )
    st_file.unlink
    tp.process_additional_records_and_persist(st)
    nil
  end

end

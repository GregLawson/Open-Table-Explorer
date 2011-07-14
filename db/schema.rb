# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110714171029) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.string   "parent"
    t.string   "tax_reporting"
    t.string   "budgeting"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "open_tax_solver_line"
  end

  create_table "acquisition_interfaces", :force => true do |t|
    t.text     "library"
    t.text     "acquire_data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "return_error_code"
    t.text     "rescue_code"
  end

  create_table "acquisition_stream_specs", :force => true do |t|
    t.string  "acquisition_interface"
    t.string  "url"
    t.integer "table_spec_id"
    t.integer "required_order"
    t.integer "acquisition_interface_id"
  end

  add_index "acquisition_stream_specs", ["url"], :name => "altered_acquisition_stream_specs_url_key", :unique => true

  create_table "acquisitions", :force => true do |t|
    t.string   "acquisition_data"
    t.datetime "created_at",                 :null => false
    t.string   "url"
    t.integer  "acquisition_stream_spec_id"
    t.string   "error"
    t.boolean  "acquisition_updated"
  end

  create_table "breakers", :force => true do |t|
    t.integer "node",               :null => false
    t.string  "description"
    t.integer "parent_node"
    t.string  "parent_description"
    t.integer "volts"
    t.integer "amps"
    t.integer "measured_load"
    t.integer "Position"
    t.integer "node_id"
  end

  create_table "bugs", :force => true do |t|
    t.boolean  "gui"
    t.string   "url"
    t.string   "error"
    t.string   "context"
    t.text     "resolution"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "error_type_id"
  end

  add_index "bugs", ["error", "context", "url"], :name => "index_bugs_on_error_and_context_and_url", :unique => true

  create_table "edisons", :force => true do |t|
    t.string  "CANUM",      :limit => 13
    t.string  "SANUM",      :limit => 13
    t.date    "READDATE",                                                :null => false
    t.integer "KHWREAD"
    t.float   "kwhusage"
    t.integer "Days"
    t.float   "AVGDAILY"
    t.decimal "TOTCHARGES",               :precision => 19, :scale => 2
  end

  create_table "error_types", :force => true do |t|
    t.string   "error_type"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "example_acquisitions", :force => true do |t|
    t.string  "acquisition_data"
    t.integer "acquisition_id",   :null => false
  end

  add_index "example_acquisitions", ["acquisition_data", "id"], :name => "No_Redundant_Examples", :unique => true

  create_table "example_types", :force => true do |t|
    t.string "import_class",   :null => false
    t.string "example_string", :null => false
    t.string "inspect_value",  :null => false
  end

  add_index "example_types", ["example_string", "import_class"], :name => "Unique_examples", :unique => true

  create_table "frequencies", :force => true do |t|
    t.string   "frequency_name"
    t.float    "min_seconds"
    t.float    "max_seconds"
    t.datetime "scheduled_time"
    t.float    "interval"
    t.float    "shortest_update"
    t.float    "longest_no_update"
    t.datetime "previous_update"
  end

  add_index "frequencies", ["frequency_name"], :name => "frequencies_frequency_name_key", :unique => true

  create_table "generic_acquisitions", :force => true do |t|
    t.string   "model_class"
    t.string   "acquisition_interface"
    t.string   "url"
    t.string   "table_selection"
    t.string   "row_selection"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "parse_interface"
    t.string   "tree_walk"
    t.string   "name_prefix"
    t.string   "column_name_location"
    t.string   "column_name_selection"
    t.string   "column_selection"
    t.string   "column_value_selection"
    t.boolean  "table_selection_is_regexp"
    t.float    "min_seconds",               :default => 10.0
    t.float    "max_seconds",               :default => 3600.0
    t.string   "acquisition_size"
    t.string   "file_caching"
  end

  add_index "generic_acquisitions", ["model_class", "parse_interface", "url"], :name => "Generic_Uniqueness", :unique => true

  create_table "generic_columns", :force => true do |t|
    t.string   "model_class"
    t.string   "Column_Name"
    t.string   "Before_Pattern"
    t.string   "Data_Pattern"
    t.string   "After_Pattern"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "generic_types", :force => true do |t|
    t.integer "search_sequence", :null => false
    t.string  "import_class",    :null => false
    t.string  "rails_type"
    t.string  "data_regexp",     :null => false
    t.string  "ruby_conversion", :null => false
  end

  add_index "generic_types", ["data_regexp"], :name => "generic_types_data_regexp_key", :unique => true

  create_table "hosts", :force => true do |t|
    t.text     "nmap"
    t.integer  "otherports"
    t.string   "otherstate"
    t.string   "mac"
    t.string   "nicvendor"
    t.string   "ip",                  :null => false
    t.string   "name"
    t.datetime "last_detection"
    t.float    "nmap_execution_time"
  end

  add_index "hosts", ["mac"], :name => "network_mac_key", :unique => true
  add_index "hosts", ["name"], :name => "network_name_key", :unique => true

  create_table "huelseries", :force => true do |t|
    t.string  "show"
    t.string  "name"
    t.integer "number"
  end

  create_table "huelshows", :force => true do |t|
    t.string "name"
    t.string "shortname"
  end

  add_index "huelshows", ["name"], :name => "unique_name", :unique => true
  add_index "huelshows", ["shortname"], :name => "unique_shortname", :unique => true

  create_table "loads", :force => true do |t|
    t.integer "node",                        :null => false
    t.string  "description"
    t.integer "parent_node"
    t.string  "parent_description"
    t.integer "plug_in_location"
    t.string  "x_10_address"
    t.boolean "volatile"
    t.boolean "daylight_savings_adjustment"
    t.boolean "timer_savings"
    t.boolean "motion_savings"
    t.boolean "bedtime_savings"
    t.boolean "away_savings"
    t.boolean "background"
    t.boolean "computer_common"
    t.boolean "audio_video"
    t.boolean "recorder"
    t.string  "plug_width"
    t.integer "node_id"
  end

  create_table "loads1", :force => true do |t|
    t.integer "wired_location"
    t.string  "description"
    t.string  "x_10_address"
    t.integer "volatile"
    t.string  "mode"
    t.string  "load_measurement"
    t.integer "load"
    t.string  "va"
    t.float   "power_factor"
    t.string  "period"
    t.string  "duty_cycle_measurement"
    t.float   "duty_cycle"
    t.integer "load_id"
    t.integer "daylight_savings_adjustment"
    t.integer "tmer_savings"
    t.integer "motion_savings"
    t.integer "bedtime_savings"
    t.integer "away_savings"
    t.integer "background"
    t.integer "computer_common"
    t.integer "audio_video"
    t.integer "recorder"
    t.string  "plug_width"
  end

  create_table "loads1nf", :force => true do |t|
    t.integer "wired_location"
    t.string  "loads_description"
    t.string  "x_10_address"
    t.boolean "volatile"
    t.string  "load_measurement"
    t.integer "load"
    t.string  "power_factor"
    t.string  "period"
    t.string  "duty_cycle_measurement"
    t.string  "duty_cycle"
    t.integer "load_id"
    t.boolean "daylight_savings_adjustment"
    t.boolean "tmer_savings"
    t.boolean "motion_savings"
    t.boolean "bedtime_savings"
    t.boolean "away_savings"
    t.boolean "background"
    t.boolean "computer_common"
    t.boolean "audio_video"
    t.boolean "recorder"
    t.string  "wired_location_description"
    t.string  "room"
    t.string  "wall"
    t.string  "type"
    t.boolean "ground_test_light"
    t.integer "location_id"
    t.integer "breaker"
    t.integer "new_breaker"
    t.integer "volts"
    t.string  "phase"
    t.integer "amps"
    t.integer "measured_load"
    t.string  "label"
    t.float   "va"
    t.float   "plug_width"
    t.string  "mode"
    t.string  "x10_address"
    t.integer "plug_in_location"
  end

  create_table "measurements", :force => true do |t|
    t.string  "description"
    t.string  "load_measurement"
    t.float   "load"
    t.float   "power_factor"
    t.string  "period"
    t.string  "duty_cycle_measurement"
    t.float   "duty_cycle"
    t.integer "load_id"
    t.string  "mode"
    t.float   "va"
  end

  create_table "networks", :force => true do |t|
    t.string   "nmap_addresses",      :null => false
    t.datetime "last_scan"
    t.boolean  "expanded"
    t.float    "nmap_execution_time"
  end

  create_table "nodes", :force => true do |t|
    t.integer "node",               :null => false
    t.string  "description",        :null => false
    t.integer "parent_node"
    t.string  "parent_description"
    t.integer "node_id"
  end

  add_index "nodes", ["parent_description"], :name => "fki_"
  add_index "nodes", ["parent_node"], :name => "fki_Foriegn key parent node"

  create_table "ofxes", :force => true do |t|
    t.integer  "cuisp"
    t.decimal  "units"
    t.decimal  "unit_price"
    t.decimal  "total"
    t.string   "account_number"
    t.datetime "trade_date"
    t.datetime "settle_date"
    t.string   "memo"
    t.string   "direction"
    t.string   "transfer_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "parameters", :force => true do |t|
    t.string   "parameter",   :null => false
    t.string   "import_type"
    t.string   "value"
    t.string   "formula"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "params", :force => true do |t|
    t.string   "parameter"
    t.string   "import_type"
    t.string   "value"
    t.string   "formula"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "parse_specs", :force => true do |t|
    t.string  "parse_interface"
    t.string  "table_selection"
    t.string  "row_selection"
    t.string  "name_prefix"
    t.string  "column_name_location"
    t.string  "column_name_selection"
    t.string  "column_selection"
    t.string  "column_value_selection"
    t.boolean "table_selection_is_regexp"
    t.integer "acquisition_stream_spec_id"
  end

  create_table "ports", :force => true do |t|
    t.string  "protocol", :null => false
    t.integer "port",     :null => false
    t.string  "portname"
    t.string  "ip",       :null => false
  end

  create_table "postgresql2import", :force => true do |t|
    t.string "postgresql_type", :null => false
    t.string "import_type"
  end

  create_table "postgresql2rails", :force => true do |t|
    t.string "postgresql_type", :null => false
    t.string "rails_type"
  end

  create_table "production_ftps", :force => true do |t|
    t.time    "timestamp",     :null => false
    t.integer "backup_state"
    t.float   "co2_saved"
    t.integer "error"
    t.float   "e_total"
    t.float   "fac"
    t.integer "grid_type"
    t.float   "h_on"
    t.float   "h_total"
    t.float   "iac"
    t.float   "ipv"
    t.integer "mode"
    t.float   "pac"
    t.integer "power_on"
    t.integer "serial_number"
    t.float   "temperature"
    t.float   "vac"
    t.float   "vpv"
    t.date    "Date",          :null => false
  end

  create_table "productions", :force => true do |t|
    t.float    "power"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "productions", ["created_at"], :name => "production_created", :unique => true

  create_table "routers", :force => true do |t|
    t.string   "Model"
    t.float    "Version"
    t.string   "Serial_Number"
    t.string   "WAN_MAC"
    t.string   "Status"
    t.string   "Power_Supply"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ruby_interfaces", :force => true do |t|
    t.string   "name"
    t.string   "library"
    t.text     "interface_code"
    t.text     "return_code"
    t.text     "rescue_code"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scalar_arguments", :force => true do |t|
    t.string   "name"
    t.string   "value"
    t.string   "formula"
    t.string   "ruby_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stations", :force => true do |t|
    t.string  "dtv"
    t.string  "antennatype"
    t.string  "call_sign"
    t.float   "channel",        :null => false
    t.string  "network"
    t.string  "city__state"
    t.string  "livedate"
    t.string  "compassheading"
    t.float   "milesfrom"
    t.integer "rfchannel"
  end

  create_table "stream_method_arguments", :force => true do |t|
    t.integer  "stream_method_id"
    t.string   "name"
    t.string   "ruby_type"
    t.string   "direction"
    t.integer  "parameter_id"
    t.string   "parameter_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stream_method_calls", :force => true do |t|
    t.integer  "stream_method_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stream_methods", :force => true do |t|
    t.string   "name"
    t.string   "library"
    t.text     "interface_code"
    t.text     "return_code"
    t.text     "rescue_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stream_parameters", :force => true do |t|
    t.integer  "stream_method_call_id"
    t.integer  "stream_method_argument_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stream_pattern_arguments", :force => true do |t|
    t.integer  "stream_pattern_id"
    t.string   "name"
    t.string   "ruby_type"
    t.string   "direction"
    t.integer  "parameter_id"
    t.string   "parameter_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stream_patterns", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "table_specs", :force => true do |t|
    t.string  "merge"
    t.string  "file_caching"
    t.string  "model_class_name"
    t.integer "frequency_id"
    t.string  "primary_key_expression"
  end

  add_index "table_specs", ["model_class_name"], :name => "table_specs_model_class_name_key", :unique => true

  create_table "ted_web_box_fulls", :force => true do |t|
    t.integer  "hour"
    t.integer  "minute"
    t.integer  "month"
    t.integer  "day"
    t.integer  "year"
    t.integer  "maxsecond"
    t.integer  "accusecond"
    t.integer  "total_voltagenow"
    t.integer  "mtu1_voltagenow"
    t.integer  "total_powernow"
    t.integer  "total_kva"
    t.integer  "mtu1_powernow"
    t.integer  "mtu1_kva"
    t.integer  "total_costnow"
    t.integer  "mtu1_costnow"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "sign"
    t.integer  "outlier"
    t.float    "production"
    t.float    "prediction"
    t.float    "predictkva"
    t.integer  "switched_state"
    t.float    "noise"
    t.integer  "prediction_samples"
    t.float    "change_interval"
    t.float    "switched_age"
    t.float    "predict_reactive_power"
    t.string   "backup_state"
    t.float    "co2_saved_lbs"
    t.string   "error"
    t.float    "e_total_kwh"
    t.integer  "event_cnt"
    t.float    "fac_hz"
    t.string   "grid_type"
    t.float    "h_on_h"
    t.float    "h_total_h"
    t.integer  "iac_a"
    t.integer  "i_dif_ma"
    t.integer  "ipv_a"
    t.float    "max_temperature_degc"
    t.integer  "max_vpv_v"
    t.string   "mode"
    t.integer  "pac_w"
    t.integer  "power_on"
    t.integer  "serial_number"
    t.float    "temperature_degc"
    t.float    "vac_v"
    t.float    "vacl1_v"
    t.float    "vacl2_v"
    t.integer  "vfan_v"
    t.integer  "vpv__pe_v"
    t.integer  "vpv_v"
    t.integer  "vpv_setpoint_v"
    t.string   "prefix"
  end

  create_table "tedprimaries", :force => true do |t|
    t.integer  "hour"
    t.integer  "minute"
    t.integer  "month"
    t.integer  "day"
    t.integer  "year"
    t.integer  "maxsecond"
    t.integer  "accusecond"
    t.integer  "total_voltagenow"
    t.integer  "mtu1_voltagenow"
    t.integer  "total_powernow"
    t.integer  "total_kva"
    t.integer  "mtu1_powernow"
    t.integer  "mtu1_kva"
    t.integer  "total_costnow"
    t.integer  "mtu1_costnow"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "sign"
    t.integer  "outlier"
    t.float    "production"
    t.float    "prediction"
    t.float    "predictkva"
    t.integer  "switched_state"
    t.float    "noise"
    t.integer  "prediction_samples"
    t.float    "change_interval"
    t.float    "switched_age"
    t.float    "predict_reactive_power"
  end

  add_index "tedprimaries", ["created_at", "switched_age"], :name => "redo"

  create_table "test_runs", :force => true do |t|
    t.string   "model"
    t.string   "test"
    t.string   "test_type"
    t.string   "environment"
    t.integer  "tests"
    t.integer  "assertions"
    t.integer  "failures"
    t.integer  "tests_stop_on_error"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tests", :force => true do |t|
    t.string   "model"
    t.string   "test"
    t.string   "test_type"
    t.string   "environment"
    t.integer  "tests"
    t.integer  "assertions"
    t.integer  "failures"
    t.integer  "errors"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transactions", :force => true do |t|
    t.datetime "Date",          :default => '2009-12-31 00:00:00'
    t.datetime "Posted"
    t.string   "Payee"
    t.string   "Descrition"
    t.string   "From_Accont"
    t.string   "To_Account"
    t.float    "Amount"
    t.string   "Tax_Reporting"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transfers", :force => true do |t|
    t.string   "account"
    t.float    "amount"
    t.date     "posted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  create_table "urls", :force => true do |t|
    t.string   "href"
    t.string   "url"
    t.string   "cache_path"
    t.time     "last_cache"
    t.string   "error"
    t.string   "context"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "weathers", :force => true do |t|
    t.string   "khhr_observation_time_rfc822", :null => false
    t.string   "khhr_weather"
    t.string   "khhr_temperature_string"
    t.float    "khhr_temp_f"
    t.float    "khhr_temp_c"
    t.integer  "khhr_relative_humidity"
    t.string   "khhr_wind_string"
    t.string   "khhr_wind_dir"
    t.integer  "khhr_wind_degrees"
    t.float    "khhr_wind_mph"
    t.integer  "khhr_wind_kt"
    t.string   "khhr_pressure_string"
    t.float    "khhr_pressure_mb"
    t.float    "khhr_pressure_in"
    t.string   "khhr_dewpoint_string"
    t.float    "khhr_dewpoint_f"
    t.float    "khhr_dewpoint_c"
    t.string   "klax_observation_time_rfc822"
    t.string   "klax_weather"
    t.string   "klax_temperature_string"
    t.float    "klax_temp_f"
    t.float    "klax_temp_c"
    t.integer  "klax_relative_humidity"
    t.string   "klax_wind_string"
    t.string   "klax_wind_dir"
    t.integer  "klax_wind_degrees"
    t.float    "klax_wind_mph"
    t.integer  "klax_wind_kt"
    t.string   "klax_pressure_string"
    t.float    "klax_pressure_mb"
    t.float    "klax_pressure_in"
    t.string   "klax_dewpoint_string"
    t.float    "klax_dewpoint_f"
    t.float    "klax_dewpoint_c"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "khhr_visibility_mi"
    t.float    "klax_visibility_mi"
    t.float    "klax_wind_gust_mph"
    t.float    "khhr_wind_gust_mph"
    t.float    "khhr_wind_gust_kt"
    t.float    "klax_wind_gust_kt"
    t.string   "klax_windchill_string"
    t.string   "khhr_windchill_string"
    t.float    "klax_windchill_c"
    t.float    "klax_windchill_f"
    t.float    "khhr_windchill_f"
    t.float    "khhr_windchill_c"
    t.string   "klax_heat_index_string"
    t.string   "klax_heat_index_f"
    t.string   "klax_heat_index_c"
    t.float    "khhr_heat_index_c"
    t.float    "khhr_heat_index_f"
    t.string   "khhr_heat_index_string"
  end

  create_table "wired_locations", :force => true do |t|
    t.integer "node",               :null => false
    t.string  "description"
    t.integer "plug_in_location"
    t.string  "x10_address"
    t.string  "room"
    t.string  "wall"
    t.string  "interface"
    t.boolean "ground_test_light"
    t.integer "node_id"
    t.string  "parent_description"
    t.integer "parent_node"
    t.string  "user_interface"
  end

end

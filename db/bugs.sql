insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisitions TEST=test_should_get_new','ActionView::Template::Error: undefined method `acquisition_stream_id` for #<Acquisition:0xb61a32c0>','new, , ');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=bugs TEST=test_should_create_bug','StandardError: No fixture with name `one` found for table `bugs`','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=bugs TEST=test_should_destroy_bug','StandardError: No fixture with name `one` found for table `bugs`','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=bugs TEST=test_should_get_edit','StandardError: No fixture with name `one` found for table `bugs`','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=bugs TEST=test_should_get_index','StandardError: No fixture with name `one` found for table `bugs`','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=bugs TEST=test_should_get_new','StandardError: No fixture with name `one` found for table `bugs`','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=bugs TEST=test_should_show_bug','StandardError: No fixture with name `one` found for table `bugs`','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=bugs TEST=test_should_update_bug','StandardError: No fixture with name `one` found for table `bugs`','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=edisons TEST=test_should_create_edison','ActiveRecord::StatementInvalid: SQLite3::ConstraintException: edisons.READDATE may not be NULL: INSERT INTO "edisons" ("kwhusage", "TOTCHARGES", "KHWREAD", "SANUM", "Days", "CANUM", "AVGDAILY", "READDATE") VALUES (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)','test_should_create_edison, create, create');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=huelseries TEST=test_should_create_huelseries','FixtureClassNotFound: No class attached to find.','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=huelseries TEST=test_should_destroy_huelseries','FixtureClassNotFound: No class attached to find.','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=huelseries TEST=test_should_get_edit','FixtureClassNotFound: No class attached to find.','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=huelseries TEST=test_should_get_index','FixtureClassNotFound: No class attached to find.','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=huelseries TEST=test_should_get_new','FixtureClassNotFound: No class attached to find.','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=huelseries TEST=test_should_show_huelseries','FixtureClassNotFound: No class attached to find.','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=huelseries TEST=test_should_update_huelseries','FixtureClassNotFound: No class attached to find.','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=loads TEST=test_should_create_loads','ActiveRecord::StatementInvalid: SQLite3::ConstraintException: loads.node may not be NULL: INSERT INTO "loads" ("parent_description", "recorder", "timer_savings", "plug_in_location", "description", "volatile", "plug_width", "away_savings", "motion_savings", "computer_common", "parent_node", "bedtime_savings", "background", "node", "daylight_savings_adjustment", "audio_video", "node_id", "x_10_address") VALUES (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)','test_should_create_loads, create, create');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=transfer TEST=test_canonical','"to_sql" is not in list ["instance_values", "table','assert_relation, assert_include');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=transfer TEST=test_each','"to_sql" is not in list ["instance_values", "table','assert_relation, assert_include');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=transfer TEST=test_join','NoMethodError: You have a nil object when you didn`t expect it!',', ');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=transfer TEST=test_relations','"to_sql" is not in list ["instance_values", "table','assert_relation, assert_include');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=transfer TEST=test_stable_and_working','TypeError: Cannot visit Account','explain_assert_respond_to, canonicalName');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=urls TEST=test_should_create_url','ActionController::RoutingError: No route matches {:controller=>"urls", :action=>"show"}','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=urls TEST=test_should_get_edit','ActionView::Template::Error: undefined method `model_name` for NilClass:Class',', ');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=urls TEST=test_should_get_new','ActionView::Template::Error: undefined method `model_name` for NilClass:Class','new, , ');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=urls TEST=test_should_show_url','ActionView::Template::Error: undefined method `href` for nil:NilClass','show, ');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=acquisition_interface TEST=test_acquisition','ActiveRecord::StatementInvalid: SQLite3::SQLException: no such table: ruby_interfaces: DELETE FROM "ruby_interfaces" WHERE 1=1','');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=acquisition_interface TEST=test_default_acquisition','ActiveRecord::StatementInvalid: SQLite3::SQLException: no such table: ruby_interfaces: DELETE FROM "ruby_interfaces" WHERE 1=1','');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=acquisition_interface TEST=test_id_equal','ActiveRecord::StatementInvalid: SQLite3::SQLException: no such table: ruby_interfaces: DELETE FROM "ruby_interfaces" WHERE 1=1','');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=acquisition_interface TEST=test_scheme','ActiveRecord::StatementInvalid: SQLite3::SQLException: no such table: ruby_interfaces: DELETE FROM "ruby_interfaces" WHERE 1=1','');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=acquisition_interface TEST=test_stream_acquire','ActiveRecord::StatementInvalid: SQLite3::SQLException: no such table: ruby_interfaces: DELETE FROM "ruby_interfaces" WHERE 1=1','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=test_runs TEST=test_should_create_test_run','ActiveRecord::DangerousAttributeError: errors is defined by ActiveRecord','test_should_create_test_run, create, new');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=test_runs TEST=test_should_destroy_test_run','ActiveRecord::DangerousAttributeError: errors is defined by ActiveRecord','test_should_destroy_test_run');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=test_runs TEST=test_should_get_edit','ActiveRecord::DangerousAttributeError: errors is defined by ActiveRecord','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=test_runs TEST=test_should_get_index','ActionView::Template::Error: errors is defined by ActiveRecord','index, , each, ');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=test_runs TEST=test_should_get_new','ActionView::Template::Error: errors is defined by ActiveRecord','new, , ');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=test_runs TEST=test_should_show_test_run','ActiveRecord::DangerousAttributeError: errors is defined by ActiveRecord','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=test_runs TEST=test_should_update_test_run','ActiveRecord::DangerousAttributeError: errors is defined by ActiveRecord','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=test_runs TEST=test_should_create_test_run','ActiveRecord::StatementInvalid: SQLite3::SQLException: table test_runs has no column named tests_stop_on_error: INSERT INTO "test_runs" ("tests_stop_on_error", "failures", "test_type", "model", "created_at", "updated_at", "tests", "id", "assertions", "environment", "test") VALUES (1, 1, `MyString`, `MyString`, `2011-05-30 18:01:44`, `2011-05-30 18:01:44`, 1, 298486374, 1, `MyString`, `MyString`)','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=test_runs TEST=test_should_destroy_test_run','ActiveRecord::StatementInvalid: SQLite3::SQLException: table test_runs has no column named tests_stop_on_error: INSERT INTO "test_runs" ("tests_stop_on_error", "failures", "test_type", "model", "created_at", "updated_at", "tests", "id", "assertions", "environment", "test") VALUES (1, 1, `MyString`, `MyString`, `2011-05-30 18:01:59`, `2011-05-30 18:01:59`, 1, 298486374, 1, `MyString`, `MyString`)','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=test_runs TEST=test_should_get_edit','ActiveRecord::StatementInvalid: SQLite3::SQLException: table test_runs has no column named tests_stop_on_error: INSERT INTO "test_runs" ("tests_stop_on_error", "failures", "test_type", "model", "created_at", "updated_at", "tests", "id", "assertions", "environment", "test") VALUES (1, 1, `MyString`, `MyString`, `2011-05-30 18:02:19`, `2011-05-30 18:02:19`, 1, 298486374, 1, `MyString`, `MyString`)','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=test_runs TEST=test_should_get_index','ActiveRecord::StatementInvalid: SQLite3::SQLException: table test_runs has no column named tests_stop_on_error: INSERT INTO "test_runs" ("tests_stop_on_error", "failures", "test_type", "model", "created_at", "updated_at", "tests", "id", "assertions", "environment", "test") VALUES (1, 1, `MyString`, `MyString`, `2011-05-30 18:02:35`, `2011-05-30 18:02:35`, 1, 298486374, 1, `MyString`, `MyString`)','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=test_runs TEST=test_should_get_new','ActiveRecord::StatementInvalid: SQLite3::SQLException: table test_runs has no column named tests_stop_on_error: INSERT INTO "test_runs" ("tests_stop_on_error", "failures", "test_type", "model", "created_at", "updated_at", "tests", "id", "assertions", "environment", "test") VALUES (1, 1, `MyString`, `MyString`, `2011-05-30 18:02:48`, `2011-05-30 18:02:48`, 1, 298486374, 1, `MyString`, `MyString`)','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=test_runs TEST=test_should_show_test_run','ActiveRecord::StatementInvalid: SQLite3::SQLException: table test_runs has no column named tests_stop_on_error: INSERT INTO "test_runs" ("tests_stop_on_error", "failures", "test_type", "model", "created_at", "updated_at", "tests", "id", "assertions", "environment", "test") VALUES (1, 1, `MyString`, `MyString`, `2011-05-30 18:03:03`, `2011-05-30 18:03:03`, 1, 298486374, 1, `MyString`, `MyString`)','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=test_runs TEST=test_should_update_test_run','ActiveRecord::StatementInvalid: SQLite3::SQLException: table test_runs has no column named tests_stop_on_error: INSERT INTO "test_runs" ("tests_stop_on_error", "failures", "test_type", "model", "created_at", "updated_at", "tests", "id", "assertions", "environment", "test") VALUES (1, 1, `MyString`, `MyString`, `2011-05-30 18:03:16`, `2011-05-30 18:03:16`, 1, 298486374, 1, `MyString`, `MyString`)','');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_create_acquisition_interface','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5f64248>','test_should_create_acquisition_interface, create, new, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_destroy_acquisition_interface','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5f061ac>','test_should_destroy_acquisition_interface, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_edit','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5ef9d94>','setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_index','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5ecc36c>','index, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_new','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5ea70d0>','new, new, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_show_acquisition_interface','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5e9e098>','setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_update_acquisition_interface','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5e959c0>','setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_create_acquisition_interface','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5f2f250>','test_should_create_acquisition_interface, create, new, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_destroy_acquisition_interface','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5ed1204>','test_should_destroy_acquisition_interface, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_edit','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5ec4db0>','setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_index','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5e973d8>','index, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_new','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5e7213c>','new, new, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_show_acquisition_interface','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5e690f0>','setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_update_acquisition_interface','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5e60a18>','setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_create_acquisition_interface','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5dd84d8>','test_should_create_acquisition_interface, create, new, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_destroy_acquisition_interface','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5d7ac70>','test_should_destroy_acquisition_interface, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_edit','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5d6e844>','setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_index','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5d40bc4>','index, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_new','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5d1b914>','new, new, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_show_acquisition_interface','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5d128c8>','setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_update_acquisition_interface','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5d0a650>','setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_create_acquisition_interface','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5ea7530>','test_should_create_acquisition_interface, create, new, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_destroy_acquisition_interface','NameError: undefined local variable or method `return_error_code` for #<AcquisitionInterface:0xb5e49cdc>','test_should_destroy_acquisition_interface, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_edit','NameError: undefined local variable or method `return_error_code` for #<AcquisitionInterface:0xb5e3d374>','setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_index','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5e0f53c>','index, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_new','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5dea264>','new, new, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_show_acquisition_interface','NameError: undefined local variable or method `return_error_code` for #<AcquisitionInterface:0xb5de122c>','setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_update_acquisition_interface','NameError: undefined local variable or method `return_error_code` for #<AcquisitionInterface:0xb5dd87a8>','setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_create_acquisition_interface','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5e90470>','test_should_create_acquisition_interface, create, new, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_destroy_acquisition_interface','NameError: undefined local variable or method `return_error_code` for #<AcquisitionInterface:0xb5e32c08>','test_should_destroy_acquisition_interface, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_edit','NameError: undefined local variable or method `return_error_code` for #<AcquisitionInterface:0xb5e262a0>','setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_index','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5df8454>','index, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_new','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5dd317c>','new, new, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_show_acquisition_interface','NameError: undefined local variable or method `return_error_code` for #<AcquisitionInterface:0xb5dca144>','setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_update_acquisition_interface','NameError: undefined local variable or method `return_error_code` for #<AcquisitionInterface:0xb5dc16d4>','setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_create_acquisition_interface','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5e784d8>','test_should_create_acquisition_interface, create, new, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_edit','ActionView::Template::Error: undefined method `acquire_data` for #<AcquisitionInterface:0xb5db9f9c>',', ');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_index','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5d37f10>','index, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_new','NameError: undefined local variable or method `acquire_data` for #<AcquisitionInterface:0xb5d126fc>','new, new, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_show_acquisition_interface','ActionView::Template::Error: undefined method `acquire_data` for #<AcquisitionInterface:0xb5ce6aac>','show, ');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_edit','ActionView::Template::Error: undefined method `acquire_data` for #<AcquisitionInterface:0xb5de4990>',', ');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_index','ActionView::Template::Error: undefined method `acquire_data` for #<AcquisitionInterface:0xb5d6323c>','index, , each, ');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_new','ActionView::Template::Error: undefined method `acquire_data` for #<AcquisitionInterface:0xb5d33a78>','new, , ');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_show_acquisition_interface','ActionView::Template::Error: undefined method `acquire_data` for #<AcquisitionInterface:0xb5cf6ca4>','show, ');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_edit','ActionView::Template::Error: undefined method `acquire_data` for #<AcquisitionInterface:0xb5d069c4>',', ');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_index','ActionView::Template::Error: undefined method `acquire_data` for #<AcquisitionInterface:0xb5c85270>','index, , each, ');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_new','ActionView::Template::Error: undefined method `acquire_data` for #<AcquisitionInterface:0xb5c55aac>','new, , ');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_show_acquisition_interface','ActionView::Template::Error: undefined method `acquire_data` for #<AcquisitionInterface:0xb5c18cd8>','show, ');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_edit','ActionView::Template::Error: undefined method `acquire_data` for #<AcquisitionInterface:0xb5dad990>',', ');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_new','ActionView::Template::Error: undefined method `acquire_data` for #<AcquisitionInterface:0xb5cdcb88>','new, , ');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_edit','ActionView::Template::Error: undefined method `acquire_data` for #<AcquisitionInterface:0xb5d0991c>',', ');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=acquisition_interface TEST=test_default_acquisition','NoMethodError: undefined method `acquire_data=` for #<AcquisitionInterface:0xb5db32dc>','');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=acquisition_interface TEST=test_acquisition','NameError: uninitialized class variable @@Default_Return_Code in RubyInterface','setup, codeBody');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=acquisition_interface TEST=test_default_acquisition','NameError: uninitialized class variable @@Default_Return_Code in RubyInterface','setup, codeBody');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=acquisition_interface TEST=test_id_equal','NameError: uninitialized class variable @@Default_Return_Code in RubyInterface','setup, codeBody');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=acquisition_interface TEST=test_scheme','NameError: uninitialized class variable @@Default_Return_Code in RubyInterface','setup, codeBody');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=acquisition_interface TEST=test_stream_acquire','NameError: uninitialized class variable @@Default_Return_Code in RubyInterface','acquire, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_create_acquisition_interface','NameError: uninitialized class variable @@Default_Return_Code in RubyInterface','test_should_create_acquisition_interface, create, new, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_destroy_acquisition_interface','NameError: uninitialized class variable @@Default_Return_Code in RubyInterface','test_should_destroy_acquisition_interface, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_edit','NameError: uninitialized class variable @@Default_Return_Code in RubyInterface','setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_index','NameError: uninitialized class variable @@Default_Return_Code in RubyInterface','index, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_get_new','NameError: uninitialized class variable @@Default_Return_Code in RubyInterface','new, new, setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_show_acquisition_interface','NameError: uninitialized class variable @@Default_Return_Code in RubyInterface','setup, codeBody');
insert into bugs(url,error,context) values('rake testing:functional_test TABLE=acquisition_interfaces TEST=test_should_update_acquisition_interface','NameError: uninitialized class variable @@Default_Return_Code in RubyInterface','setup, codeBody');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=acquisition_interface TEST=test_default_acquisition','NoMethodError: undefined method `acquire_data=` for #<AcquisitionInterface:0xb5d7d100>','');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=acquisition_interface TEST=test_default_acquisition','NoMethodError: undefined method `return_error_code=` for #<AcquisitionInterface:0xb5d013e8>','');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_id_equal','NameError: undefined local variable or method `setup` for #<AcquisitionInterface:0xb5f70840>','');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_id_equal','NameError: undefined local variable or method `setup` for #<AcquisitionInterface:0xb5e598bc>','');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=acquisition_interface TEST=test_acquisition','NoMethodError: undefined method `setup` for #<AcquisitionInterface:0xb5e6d088>','');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=acquisition_interface TEST=test_default_acquisition','NoMethodError: undefined method `codeBody` for #<AcquisitionInterface:0xb5e1f3c4>','');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=acquisition_interface TEST=test_acquisition','NoMethodError: undefined method `setup` for #<AcquisitionInterface:0xb5defe30>','');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=acquisition_interface TEST=test_acquisition','NoMethodError: undefined method `acquisition` for #<AcquisitionInterface:0xb5f720dc>','');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=acquisition_interface TEST=test_acquisition','NoMethodError: undefined method `acquisition` for #<AcquisitionInterface:0xb5fbe054>','');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=acquisition_interface TEST=test_default_acquisition','NoMethodError: undefined method `acquisition` for #<AcquisitionInterface:0xb5f1a79c>','');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_general_associations','SyntaxError: (eval):3:in `eval_method`: compile error','define_association_names, assert_model_class, fixtures, each, fixtures, new, compile_code, eval_method, , , , , , , , , , , , , , , , , , , ');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_id_equal','SyntaxError: (eval):3:in `eval_method`: compile error','define_association_names, assert_model_class, fixtures, each, fixtures, new, compile_code, eval_method, , , , , , , , , , , , , , , , , , , ');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_general_associations','SyntaxError: (eval):3:in `eval_method`: compile error','define_association_names, assert_model_class, fixtures, each, fixtures, new, compile_code, eval_method, , , , , , , , , , , , , , , , , , , ');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_id_equal','SyntaxError: (eval):3:in `eval_method`: compile error','define_association_names, assert_model_class, fixtures, each, fixtures, new, compile_code, eval_method, , , , , , , , , , , , , , , , , , , ');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_general_associations','SyntaxError: (eval):3:in `eval_method`: compile error','define_association_names, assert_model_class, fixtures, each, fixtures, new, compile_code, eval_method, , , , , , , , , , , , , , , , , , , ');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_id_equal','SyntaxError: (eval):3:in `eval_method`: compile error','define_association_names, assert_model_class, fixtures, each, fixtures, new, compile_code, eval_method, , , , , , , , , , , , , , , , , , , ');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_general_associations','SyntaxError: (eval):3:in `eval_method`: compile error','define_association_names, assert_model_class, fixtures, each, fixtures, new, compile_code, eval_method, , , , , , , , , , , , , , , , , , , ');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_id_equal','SyntaxError: (eval):3:in `eval_method`: compile error','define_association_names, assert_model_class, fixtures, each, fixtures, new, compile_code, eval_method, , , , , , , , , , , , , , , , , , , ');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_general_associations','<false> is not true.','define_association_names, assert_not_empty');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_id_equal','<false> is not true.','define_association_names, assert_not_empty');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_general_associations','Array s not empty but contains []','define_association_names, assert_not_empty');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_id_equal','Array s not empty but contains []','define_association_names, assert_not_empty');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_general_associations','"Array" is empty but contains "[]".','define_association_names, assert_not_empty');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_id_equal','"Array" is empty but contains "[]".','define_association_names, assert_not_empty');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_general_associations','NoMethodError: undefined method `empty` for #<Array:0xb5cbf3a8>','define_association_names, assert_has_instance_methods, assert_has_instance_methods');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_id_equal','NoMethodError: undefined method `empty` for #<Array:0xb5c0cdd4>','define_association_names, assert_has_instance_methods, assert_has_instance_methods');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_general_associations','"Array instance" is empty but contains "[]".','define_association_names, assert_not_empty');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_id_equal','"Array instance" is empty but contains "[]".','define_association_names, assert_not_empty');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_general_associations','"Array instance" is empty with value "[]".','define_association_names, assert_not_empty');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_id_equal','"Array instance" is empty with value "[]".','define_association_names, assert_not_empty');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_general_associations','NameError: undefined local variable or method `define_association_names` for #<RubyInterfaceTest:0xb6c3ae90>','');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_id_equal','NameError: undefined local variable or method `define_association_names` for #<RubyInterfaceTest:0xb6c3acec>','');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_general_associations','NoMethodError: undefined method `association_names` for #<Class:0xb63e0d94>','define_association_names, assert_has_associations, assert_has_associations');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_id_equal','NoMethodError: undefined method `association_names` for #<Class:0xb63e0d94>','define_association_names, assert_has_associations, assert_has_associations');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_general_associations','In define_association_names of test_helper.rb, .
"','define_association_names, assert_has_associations');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_id_equal','In define_association_names of test_helper.rb, .
"','define_association_names, assert_has_associations');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_general_associations','NoMethodError: undefined method `push_error` for #<RubyInterface:0xb5f7faac>','define_model_of_test, new, compile_code');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_id_equal','NoMethodError: undefined method `push_error` for #<RubyInterface:0xb5f3ae98>','define_model_of_test, new, compile_code');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_general_associations','NoMethodError: You have a nil object when you didn`t expect it!','define_model_of_test, new, compile_code, push_error, , ');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_id_equal','NoMethodError: You have a nil object when you didn`t expect it!','define_model_of_test, new, compile_code, push_error, , ');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_interaction','<#<RubyInterface id: 749574446, name: "File", libr','each_value, test_interaction');
insert into bugs(url,error,context) values('rake testing:unit_test TABLE=ruby_interface TEST=test_interaction','<#<RubyInterface id: 749574446, name: "File", libr','each_value, test_interaction');

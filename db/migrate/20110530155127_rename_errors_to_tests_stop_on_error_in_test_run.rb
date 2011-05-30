class RenameErrorsToTestsStopOnErrorInTestRun < ActiveRecord::Migration
  def self.up
	change_table :test_runs do |t|
		t.rename :errors, :tests_stop_on_error
	end #change_table
  end

  def self.down
	change_table :test_runs do |t|
		t.rename :tests_stop_on_error,:errors
	end #change_table
  end
end

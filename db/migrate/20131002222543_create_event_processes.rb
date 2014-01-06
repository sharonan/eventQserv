class CreateEventProcesses < ActiveRecord::Migration
  def change
    create_table :event_processes do |t|

      t.timestamps
    end
  end
end

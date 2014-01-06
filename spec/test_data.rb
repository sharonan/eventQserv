class TestData
  def self.create_test_data
    puts "Creating test data, e"

    return if test_db.tables["dev_event"].exists?
    
    puts "Creating test data, e"

    event_table = test_db.tables.create(
      "dev_event", 10, 5,
      :hash_key => { :event_id => :string }
    )
    event_table.load_schema
    event_table.items.create("event_id" => self.dinner_id, "title" => "Take Ms. Wallace Out",
      "organizer" => self.vega_phone_number, "id" => self.dinner_id )
      # Note: ID is not used, but it is tested for in the controller code.

    user_table = test_db.tables.create(
      "dev_users", 10, 5,
      :hash_key => { :phone_number => :string }
    )
    user_table.load_schema
    user_table.items.create("phone_number" => self.vega_phone_number, "first_name" => "Vincent", "last_name" => "Vega")
    user_table.items.create("phone_number" => self.john_phone_number, "first_name" => "John", "last_name" => "Doe")

  end
  
  def self.test_db
    AWS::DynamoDB.new()
  end
  
  def self.dinner_id
    return "e8316faf-eeee-4f3d-9fcb-d8cbed18e73d"
  end
  
  def self.vega_phone_number
    return "5005556669"
  end
  def self.john_phone_number
    return "+1111"
  end
end
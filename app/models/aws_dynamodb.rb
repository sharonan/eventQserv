class AwsDynamodb

  def self.create_table(table_name,read_capacity_units,write_capacity_units,hash_key)


    table = $dynamo_db.tables.create("#{$env}_#{table_name}", read_capacity_units, write_capacity_units,
                                     :hash_key => hash_key )
    sleep 1 while !table.status == :active

    return table


  end

  def self.get_table_by_name(table_name)
    table = $dynamo_db.tables["#{$env}_#{table_name}"]

    return table
  end


  def self.get_record_from_table_name_by_hash_key_value(table_name,hash_key_value,hash_key={},consistent_read=false)
    puts "IN DYNAMODB TABLE #{$env}_#{table_name}"

    table = $dynamo_db.tables["#{$env}_#{table_name}"]
    #table.hash_key = hash_key#[:uid, :string]
    table.load_schema
    if (!table.nil?)
      item = table.items[hash_key_value]
      if (!item.nil? )

        hash = item.attributes.to_h(:consistent_read => consistent_read)
      end
      return hash
    else
      return nil
    end

  end
  # gets the table name and the record to be saved (in a hash form)
  def self.save_record(table_name,item_record_hash,hash_key={})
    puts "SAVE TO #{$env}_#{table_name} RECORD #{item_record_hash}"
    table_name = "#{$env}_#{table_name}"
    item_record_hash =   remove_empty_attributes(item_record_hash)

    if (!table_name.nil? && !item_record_hash.nil? && !item_record_hash.empty?)
      table = $dynamo_db.tables[table_name]
      #table.hash_key = hash_key#[:phone_number, :string]
      table.load_schema
      puts "TABLE ITEMS #{ table.items}"

      items = table.items
      puts "ITEMS #{item_record_hash}"

      items.put(item_record_hash)
      return true
    else
      return false
    end

  end

  #    table (Table, String) — A Table object or table name string.
  #batch.write(table, :put => [
  #    { :id => 'abc', :color => 'red', :count => 2 },
  #    { :id => 'mno', :color => 'blue', :count => 3 },
  #    { :id => 'xyz', :color => 'green', :count => 5 },
  #Options Hash (options)- hash_key_value_records_array:
  #    :put (Array<Hash>) — An array of items to put. Each item should be an array of attribute hashes.
  #])
  def self.save_all_records(table_name, hash_key_value_records_array)

    puts "TABLE WRITE BATCH #{$env}_#{table_name}"


    hash_key_value_records_array = remove_empty_attributes_from_array_hash(hash_key_value_records_array)
    n = 0
    ### AWS API allow no more than 25 writes per batch
    partial_hash_key_value_records_array = hash_key_value_records_array[n..n+20]
    while (!partial_hash_key_value_records_array.nil? && !partial_hash_key_value_records_array.empty?) do
      $batch_write.put("#{$env}_#{table_name}",partial_hash_key_value_records_array)
      $batch_write.process!
      "puts #{hash_key_value_records_array}"
      n += 21
      partial_hash_key_value_records_array = hash_key_value_records_array[n..n+20]

    end
    return true
  end
  def self.save_all_test_records(table_name, hash_key_value_records_array)

    puts "TABLE WRITE BATCH prod_#{table_name}"
    hash_key_value_records_array = remove_empty_attributes_from_array_hash(hash_key_value_records_array)
    if (!hash_key_value_records_array.nil? && !hash_key_value_records_array.empty?)
      puts "HASHHHHHH = #{hash_key_value_records_array}"
      $batch_write.put("prod_#{table_name}",hash_key_value_records_array)
      $batch_write.process!
      return true
    else
      return false
    end

  end

  # gets the table name and  array of attributes names to retrieve
  # return Array of hashes
  def self.get_all_table_attributes(table_name, attributes,hash_key)
    table = $dynamo_db.tables["#{$env}_#{table_name}"]
    table.hash_key = hash_key
    items =   table.items
    arr = Array.new
    if (!items.nil? )

      puts "items #{items}"
      puts "items #{items.count}"
      items.each do|item|
        puts "item #{item}"
        puts "item #{item.attributes.to_hash}"
        new_hash = Hash.new
        hashed_item = item.attributes.to_hash
        puts "hashed_item #{hashed_item}"
        attributes.each do |att|
          new_hash[att] = hashed_item[att]

        end

        arr.push(new_hash)
      end
      puts "arr #{arr}"

    end
    return arr

  end


  def self.get_all_records_by_attribute_value (table_name, attribute_value_hash,hash_key)

    table = $dynamo_db.tables["#{$env}_#{table_name}"]
    table.hash_key = hash_key
    items =   table.items.where(attribute_value_hash)

    arr = Array.new
    if (!items.nil? )

      items.each do|item|
        arr.push(item.attributes.to_h)
      end
    end
    #puts "ITEMS #{arr}"
    return arr
    #$batch_get.table("dev_#{table_name}", :all , items)

  end


  def self.get_all_json_records_by_hash(table_name,  hash_key, hash_key_values)
    table = $dynamo_db.tables["#{$env}_#{table_name}"]
    table.hash_key = hash_key#[:uid, :string]
                             #table = AwsDynamodb.get_table_by_name(table_name)
                             #item

    puts "HASH KEYS PHONE NUMBERS #{hash_key_values}"
    arr = Array.new
    if (!table.nil? && !hash_key_values.nil?)

      hash_key_values.each do | hash_key_value|
        item = table.items[hash_key_value]
        if (!item.nil? )

          hash = item.attributes.to_h

          arr.push(hash.to_json)

        end
      end
      puts "ARRAY #{arr}"
      return arr
    else
      puts "ARRAY #{arr}"
      return arr
    end
  end
  #def self.get_all_records_by_hash(table_name,  hash_key, hash_key_values)
  #  table = $dynamo_db.tables["#{$env}_#{table_name}"]
  #  #table.hash_key = hash_key#[:uid, :string]
  #  table.load_schema
  #  puts "HASH KEYS PHONE NUMBERS #{hash_key_values}"
  #  arr = Array.new
  #  if (!table.nil? && !hash_key_values.nil?)
  #
  #    hash_key_values.each do | hash_key_value|
  #      item = table.items[hash_key_value]
  #      if (!item.nil? )
  #
  #        hash = item.attributes.to_h
  #
  #        arr.push(hash)
  #      end
  #    end
  #    puts "ARRAY #{arr}"
  #    return arr
  #  else
  #    return arr
  #  end
  #end
  def self.get_all_records_by_hash(table_name,   hash_key_values, range_key=nil)
    table = $dynamo_db.tables["#{$env}_#{table_name}"]
    #table.hash_key = hash_key#[:uid, :string]
    table.load_schema
    if (!range_key.nil?)
      table.range_key = range_key
    end
    puts "HASH KEYS PHONE NUMBERS #{hash_key_values}"
    arr = Array.new
    if (!table.nil? && !hash_key_values.nil?)

      hash_key_values.each do | hash_key_value|
        item = table.items[hash_key_value]
        if (!item.nil? )

          hash = item.attributes.to_h

          arr.push(hash)
        end
      end
      puts "ARRAY #{arr}"
      return arr
    else
      return arr
    end
  end
  def self.get_record_by_hash_and_range_key(table_name,  hash_key, range_key, hash_key_values,range_key_value)
    table = $dynamo_db.tables["#{$env}_#{table_name}"]
    table.hash_key = hash_key #[:uid, :string]
    table.range_key = range_key


    item = table.items.at(hash_key_values, range_key_value)
    hash_records = Hash.new
    if (!item.nil? && !item.attributes.nil? && !item.attributes.to_h.nil?)
      hash_records = item.attributes.to_h
    end
    return hash_records
  end
  def self.get_all_range_records_by_hash(table_name,hash_key_values,range_key=nil)
  table = $dynamo_db.tables["#{$env}_#{table_name}"]
  #table.hash_key = hash_key#[:uid, :string]
  #table.range_key = range_key#[:device_token, :string]
                           #table = AwsDynamodb.get_table_by_name(table_name)
                           #item
                           #table.range_key = [:device_token, :string]
  table.load_schema
  puts "HASH KEYS PHONE NUMBERS #{hash_key_values}"
  hash_records = Hash.new

  if (!table.nil? && !hash_key_values.nil?)
    array = Array.new
    hash_key_values.each do | hash_key_value|
      #puts "NEXT H#{hash_key_value}"
      #item = table.items.at(hash_key_value)

      items = table.items.query(:hash_value =>hash_key_value)
      if (!items.nil? )

        #puts "ITEMS #{items}"
        #items.each do |enum|
        #  puts enum
        #end
        #puts "ITEMS A#{item.attributes}"
        #puts "ITEMS H#{item.to_h}"

        #if (!item.nil? && !item.attributes.nil? && !item.attributes.to_h.nil?)
        items.each do |item|
          if (!item.nil? )
            puts item
            hash = item.attributes.to_h
            #puts "ITEMS #{hash}"
            #arr.push(hash)
            #if (hash_records.has_key?(hash[hash_key_record]))
            #  array = hash_records[hash[hash_key_record]]
              array.push(hash)
            #  hash_records[hash[hash_key_record]] = array
            #else
            #
            #  hash_records[hash[hash_key_record]]  =  [hash]
            #end
          end
        end
      end
      #end

    end
    puts "Hash #{hash_records}"
    return array
  else
    return array
  end
  end

  def self.get_all_hash_records_by_hash(table_name,  hash_key, range_key, hash_key_values,hash_key_record)
    table = $dynamo_db.tables["#{$env}_#{table_name}"]
    table.hash_key = hash_key#[:uid, :string]
    table.range_key = range_key#[:device_token, :string]
                             #table = AwsDynamodb.get_table_by_name(table_name)
                             #item
                             #table.range_key = [:device_token, :string]
    puts "HASH KEYS PHONE NUMBERS #{hash_key_values}"
    hash_records = Hash.new

    if (!table.nil? && !hash_key_values.nil?)

      hash_key_values.each do | hash_key_value|
        #puts "NEXT H#{hash_key_value}"
        #item = table.items.at(hash_key_value)

        items = table.items.query(:hash_value =>hash_key_value)
        if (!items.nil? )

          #puts "ITEMS #{items}"
          #items.each do |enum|
          #  puts enum
          #end
          #puts "ITEMS A#{item.attributes}"
          #puts "ITEMS H#{item.to_h}"

          #if (!item.nil? && !item.attributes.nil? && !item.attributes.to_h.nil?)
          items.each do |item|
            if (!item.nil? )
              puts item
              hash = item.attributes.to_h
              #puts "ITEMS #{hash}"
              #arr.push(hash)
              if (hash_records.has_key?(hash[hash_key_record]))
                array = hash_records[hash[hash_key_record]]
                array.push(hash)
                hash_records[hash[hash_key_record]] = array
              else

                hash_records[hash[hash_key_record]]  =  [hash]
              end
            end
          end
        end
        #end

      end
      puts "Hash #{hash_records}"
      return hash_records
    else
      return hash_records
    end
  end




  def self.get_hash_records_by_attribute(table_name, hash_key_values,attribute)
    table = $dynamo_db.tables["#{$env}_#{table_name}"]

    puts "HASH KEYS PHONE NUMBERS #{hash_key_values} FROM #{$env}_#{table_name}"
    hash_records = Hash.new
    table.load_schema

    if (!table.nil? && !hash_key_values.nil?)
      items = Array.new
      hash_key_values.each do | hash_key_value|


        item = table.items.at(hash_key_value)
        items.push(item)
      end

        if (!items.nil? )

          items.each do |item|
            if (!item.nil? )
              puts item
              hash = item.attributes.to_h
              puts "HASH ATT #{hash} === PHONE #{hash[attribute]}"
              if (hash_records.has_key?(hash[attribute]) && !hash[attribute].nil? && !hash[attribute].empty?)

              else
               if (!hash[attribute].nil? && !hash[attribute].empty?)
                hash_records[hash[attribute]]  =  hash
                end
              end
            end
          end
        end


      puts "Hash #{hash_records}"
      return hash_records
    else
      return hash_records
    end
  end
  def self.get_attribute_by_hash(table_name, attribute, hash_key, hash_key_values)
    table = $dynamo_db.tables["#{$env}_#{table_name}"]
    table.hash_key = hash_key#[:uid, :string]
                             #table = AwsDynamodb.get_table_by_name(table_name)
                             #item

    puts "HASH KEYS PHONE NUMBERS #{hash_key_values}"
    arr = Array.new
    if (!table.nil? && !hash_key_values.nil?)

      hash_key_values.each do | hash_key_value|
        item = table.items[hash_key_value]
        if (!item.nil? )

          hash = item.attributes.to_h
          puts   "HASH ITEM ATTRIBUTE #{hash[attribute]}"
          attribute_from_record   = hash[attribute]
          if (!attribute_from_record.nil?)
            arr.push(attribute_from_record)
          end
        end
      end
      puts "ARRAY #{arr}"
      return arr
    else
      puts "HASH KEYS PHONE NUMBERS ARRAY#{arr}"

      return arr
    end

  end

  def self.update_record_attributes_with_range(table_name,  attributes_updated_values_hash,hash_key, hash_key_value,range_key,range_key_value)
    #AwsS3.new

    success = false
    table = $dynamo_db.tables["#{$env}_#{table_name}"]
    table.hash_key = hash_key

    #begin
      table.range_key = range_key

      hash_value =  Hash.new
      hash_value[range_key]   = range_key_value
      hash_value[hash_key]   = hash_key_value
      item = table.items.where(hash_value)

      if (!item.nil? )

        item_to_update  =item.at(hash_key_value, range_key_value)

        attributes_updated_values_hash.each do |attribute_to_update, attribute_updated_value|

          item_to_update.attributes[attribute_to_update] = attribute_updated_value
          puts ":ITEMS #{item_to_update.attributes[attribute_to_update]}"

        end
        success = true

      end
    #rescue  Exception => e
    #  puts "EXEPTION UPDATING #{attributes_updated_values_hash} Error - #{e.message} "
    #
    #end

    return success
  end

  def self.update_record_attributes(table_name,  attributes_updated_values_hash, hash_key_value)

    table = $dynamo_db.tables["#{$env}_#{table_name}"]
    #table.hash_key = hash_key
    table.load_schema
    #begin
      item = table.items[hash_key_value]
      if (!item.nil? )

        attributes_updated_values_hash.each do |attribute_to_update, attribute_updated_value|
          item.attributes[attribute_to_update] = attribute_updated_value

        end
      end
    #rescue  Exception => e
    #  puts "EXEPTION UPDATING #{attributes_updated_values_hash} Error - #{e.message}"
    #end


  end
  def self.update_record_by_hash(table_name,  attribute_to_update,attribute_updated_value,hash_key, hash_key_value)
    table = $dynamo_db.tables["#{$env}_#{table_name}"]
    table.hash_key = hash_key
    #begin
      item = table.items[hash_key_value]
      if (!item.nil? )

        item.attributes[attribute_to_update] = attribute_updated_value
      end
    #rescue  Exception => e
    #  puts "EXEPTION UPDATING #{hash_key_value}  Error - #{e.message}"
    #
    #end

  end
  # attribute_hash_query = { :color => "red" }
  def self.delete_records(table_name, attribute_hash_query, hash_key)
    table = $dynamo_db.tables["#{$env}_#{table_name}"]
    table.hash_key = hash_key
    if (!table.nil? )
      items_to_delete = table.items.where(attribute_hash_query)
      if (!items_to_delete.nil? )

        items_to_delete.each do|item|
          item.delete(:if => attribute_hash_query)
        end
      end
    end
  end

  def self.delete_record(table_name,email_record_id,hash_key)
    table = $dynamo_db.tables["#{$env}_#{table_name}"]
    table.hash_key = hash_key
    if (!table.nil? )
      items_to_delete = table.items.where(email_record_id)
      if (!items_to_delete.nil? )

        items_to_delete.each do|item|
          item.delete()
        end
      end
    end
  end

  def self.get_record_by_attribute(table_name,attribute, attribute_hash_query, hash_key)
    table = $dynamo_db.tables["#{$env}_#{table_name}"]
    #table.hash_key = hash_key
    items_to_retrieve = Array.new
    arr = Array.new
    table.hash_key = hash_key
    if (!table.nil? )
      items_to_retrieve = table.items.where(attribute_hash_query)
      if (!items_to_retrieve.nil? )

        puts " ITEMS RETRIEVED  #{items_to_retrieve}"
        puts " attribute_hash_query  #{attribute_hash_query}"
        items_to_retrieve.each do|item|
          puts " ITEM RETRIEVED #{item} ATT -  #{item.attributes[attribute]}"

          arr.push(item.attributes[attribute])
        end
      end
    end
    return   arr
  end

  def self.remove_empty_attributes(record)
    new_record = Hash.new

    if (!record.nil? && !record.empty?)
      record.each {|key,value|
        puts "CHECK KEY #{key} VALUE #{value}"
        if ((value.nil? || (!value.nil? && value.is_a?(String) && value.empty?)) )
          record.delete(key)
          puts "DELETE KEY #{key}"
        end
      }
      puts "NEW RECORD #{record}"
      new_record = record
    end

    return new_record
  end
  def self.remove_empty_attributes_from_array_hash(records)
    new_records = Array.new


    if (!records.nil? && !records.empty?)
      records.each do |record|
        new_record =  remove_empty_attributes(record)
        if (!new_record.nil? && !new_record.empty?)
          new_records.push(new_record)
        end

      end

    end

    return new_records
  end


  def remove_empty_key_attribute_from_array_hash(hash_key_value_records_array,attribute_key_to_delete)
    new_records = Array.new


    if (!records.nil? && !records.empty?)
      records.each do |record|
        new_record =  remove_empty_attributes(record)


        if (!new_record.nil? && !new_record.empty?)
          if (new_record.has_key?(attribute_key_to_delete) )
            new_record.delete(attribute_key_to_delete)
          end
          new_records.push(new_record)
        end

      end

    end

    return new_records
  end


end

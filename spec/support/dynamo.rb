RSpec.configure do |config|
  dynamo_thread = nil

  config.before(:suite) do
    FakeDynamo::Storage.db_path = '/usr/local/var/fake_dynamo/db.fdb'
    FakeDynamo::Logger.setup(:warn)
    FakeDynamo::Storage.instance.load_aof

    dynamo_thread = Thread.new do
      FakeDynamo::Server.run!(port: 4567, bind: '127.0.0.1') do |server|
        if server.respond_to?('config') && server.config.respond_to?('[]=')
          server.config[:AccessLog] = []
        end
      end
    end
  end

  config.after(:suite) do
    FakeDynamo::Storage.instance.shutdown
    dynamo_thread.exit
  end
end
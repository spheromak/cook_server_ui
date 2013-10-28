require "./main"
run Rack::Cascade.new [ Cook::Server ]

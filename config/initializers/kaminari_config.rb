Kaminari.configure do |config|
  config.default_per_page = 200
  config.window = 3
  config.outer_window = 0
  config.left = 0
  config.right = 0
  config.param_name = :page
end

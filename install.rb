require 'erb'

carrot_config = Dir.getwd + "/config/carrots.yml"
carrot_config_template = Dir.getwd + "/vendor/plugins/simplified_carrot/files/carrots.yml.erb"

unless File.exist?(carrot_config)

  pwd = Dir.getwd
  template = File.read(carrot_config_template)
  result = ERB.new(template).result(binding)

  carrot_config_file = File.open(carrot_config, 'w+')
  carrot_config_file.puts result
  carrot_config_file.close

  puts "=> Copied carrot configuration file."

else

  puts "=> carrot configuration file already exists."

end

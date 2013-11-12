Dir[File.join("./app", "**/*.rb")].each do |file|
   require file
end
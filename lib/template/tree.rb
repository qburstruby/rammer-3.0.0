Dir[File.join("./app", "**/*.rb")].each do |file|
   require file
end

Dir[File.join("./modules", "**/*.rb")].each do |file|
   require file
end

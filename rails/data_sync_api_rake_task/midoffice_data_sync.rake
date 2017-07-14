namespace :replicate_midoffice_data do
  desc "Fetch data from Midoffice for different entities"
  task :fetch_data,[:entities] => :environment do |t, args|
    begin
      #   args.with_defaults(:entities => Settings.midoffice_apis.to_hash.keys)
      models = args.entities.present? ? args.entities.split(" ").map(&:to_sym) : Settings.midoffice_apis.to_hash.keys
      apis = Settings.midoffice_apis.to_hash.slice(*models)
      apis.each do |k,v|
        response =  HTTParty.get(v)
        c, u = 0, 0
        response.each do |object|
          if object[0].present?
            obj = k.to_s.classify.constantize.find_or_initialize_by(midoffice_master_id: object[0])
            obj.new_record? ? c += 1 : u += 1
            obj.assign_attributes(object[1])
            obj.save!         
          end
        end
        puts "#{k} stats: #{c} created and #{u} updated"
      end
    rescue Exception => e
      puts e.message
    end
  end
end












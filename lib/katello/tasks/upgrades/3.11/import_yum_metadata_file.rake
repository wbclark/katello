namespace :katello do
  namespace :upgrades do
    namespace '3.11' do
      desc "Import yum metadata file units from pulp"
      task :import_yum_metadata => ["environment"] do
        User.current = User.anonymous_api_admin
        puts _("Importing Yum Metadata Files")
        Katello::YumMetadataFile.import_all
      end
    end
  end
end

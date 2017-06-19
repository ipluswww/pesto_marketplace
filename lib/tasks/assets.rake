# lib/tasks/assets.rake
# The webpack task must run before assets:environment task.
# Otherwise Sprockets cannot find the files that webpack produces.
# This is the secret sauce for how a Heroku deployment knows to create the webpack generated JavaScript files.
Rake::Task["assets:precompile"]
  .clear_prerequisites
  .enhance([
             "js:routes",
             "i18n:js:export",
             "assets:compile_environment"
           ])

namespace :assets do
  # In this task, set prerequisites for the assets:precompile task
  task compile_environment: :webpack do
    Rake::Task["assets:environment"].invoke
    sh "mkdir public/assets"
    sh "cp app/assets/images/origin_site_resource public/assets/origin_site_resource -a"
  end

  desc "Compile assets with webpack"
  task :webpack do
    sh "cd client && npm run build:client"

    # Skip next line if not doing server rendering
    sh "cd client && npm run build:server"
  end

  task :clobber do
    # Remove compiled webpack files
    rm_r Dir.glob(Rails.root.join("app/assets/webpack/*"))

    # Remove compiled language bundles
    rm_r Dir.glob(Rails.root.join("app/assets/javascripts/i18n/*"))
    rm_r Dir.glob(Rails.root.join("client/app/i18n/*"))

    # Remove routes
    rm_r Dir.glob(Rails.root.join("client/app/routes/*"))
  end

  desc "Create symlinks without cache busting digest"
  task :create_symlinks_without_digest => :environment do
    Dir.glob(Rails.root.join('public', 'assets', '**', '*')).each do |item|
      if File.file?(item) && item.match(/-[a-f0-9]{32}/)
        FileUtils.ln_s Pathname(item).basename, item.sub(/-[a-f0-9]{32}/, '')
      end
    end

    Dir.glob(Rails.root.join('public/assets/vendor/revolution/css/*')).each do |item|
      if File.file?(item) && item.match(/-[a-f0-9]{32}/)
        FileUtils.ln_s Pathname(item).basename, item.sub(/-[a-f0-9]{32}/, '')
      end
    end

  end
end

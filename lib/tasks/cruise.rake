desc 'Continuous build target'
task :cruise do
  ENV['RAILS_ENV'] = 'test'
  
  out = ENV['CC_BUILD_ARTIFACTS']
  mkdir_p out unless File.directory? out if out

  Rake::Task["db:migrate"].invoke
  Rake::Task["db:test:purge"].invoke
  Rake::Task["db:test:prepare"].invoke

  ENV['SHOW_ONLY'] = 'models,lib,helpers'
  Rake::Task["test:units:rcov"].invoke
  mv 'coverage/units', "#{out}/unit test coverage" if out
  
  ENV['SHOW_ONLY'] = 'controllers'
  Rake::Task["test:functionals:rcov"].invoke
  mv 'coverage/functionals', "#{out}/functional test coverage" if out
  
  # Commenting until we have integration tests...
  # Rake::Task["test:integration"].invoke 
  
end


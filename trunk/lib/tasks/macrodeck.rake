namespace :doc do
  desc "MacroDeck: Generate documentation"
  Rake::RDocTask.new("app") { |rdoc|
    rdoc.rdoc_dir = 'doc/app'
    rdoc.title    = "MacroDeck Rails Application Documentation"
    rdoc.options << '--line-numbers' << '--inline-source'
    rdoc.rdoc_files.include('doc/README*')
    rdoc.rdoc_files.include('app/**/*.rb')
	rdoc.rdoc_files.include('lib/**/*.rb')
  }
end
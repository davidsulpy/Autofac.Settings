require 'albacore'

PRODUCT_NAME = "Autofac.Settings"

BUILD_PATH = File.expand_path("build")
TOOLS_PATH = File.expand_path("tools")
LIB_PATH = File.expand_path("lib")

configuration = ENV['Configuration'] || "Debug"

task :default => :all

task :all => [:clean,:build,:specs,:copy]

task :clean do
	rmtree BUILD_PATH
end

msbuild :build do |msb|
	msb.properties :configuration => configuration
	msb.targets :Clean, :Build
	msb.verbosity = "minimal"
	msb.solution = "#{PRODUCT_NAME}.sln"
end

mspec :specs => [:build] do |mspec|
	mspec.command = "packages/Machine.Specifications.0.6.2/tools/mspec-clr4.exe"
	mspec.assemblies Dir.glob('specs/**/bin/*Debug/*Specs.dll')
end

task :copy => [:specs] do
	Dir.glob("src/**/*.csproj") do |proj|
		name=File.basename(proj,".csproj")
		puts "Copying output for #{name}"
		src=File.dirname(proj)
		dest = "#{BUILD_PATH}/#{name}/"
		mkdir_p(dest)
		cp_r("#{src}/bin/#{configuration}/.",dest)
	end
end
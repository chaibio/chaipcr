task :headers do
  require 'rubygems'
  require 'copyright_header'

  args = {
    :license => 'ASL2',
    :copyright_software => 'Chai PCR',
    :copyright_software_description => "Software platform for Open qPCR and Chai's Real-Time PCR instruments. For more information visit http://www.chaibio.com",
    :copyright_holders => ['Chai Biotechnologies Inc. <info@chaibio.com>'],
    :copyright_years => ['2016'],
    :add_path => 'browser:devops:frontend/javascripts/app:realtime/app:realtime/control:realtime/db:realtime/server:realtime/test:realtime/util:web/app',
    :output_dir => '.'
  }

  command_line = CopyrightHeader::CommandLine.new( args )
  command_line.execute
end
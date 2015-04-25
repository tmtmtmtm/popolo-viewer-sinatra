require 'date'
require 'fileutils'
require 'json'
require 'open-uri'

Numeric.class_eval { def empty?; false; end }

file 'popit.json' do
  POPIT_URL = 'https://pmocl.popit.mysociety.org/api/v0.1/export.json'
  File.write('popit.json', open(POPIT_URL).read)
end

file 'chile.json' => 'popit.json' do
  json = JSON.load(File.read('popit.json'), lambda { |h| 
    if h.class == Hash 
      h.reject! { |_, v| v.nil? or v.empty? }
      h.reject! { |k, v| (k == 'url' or k == 'html_url') and v[/popit.mysociety.org/] }
    end
  }, { symbolize_names: true })

  # ensure there's a legislative Organization
  if json[:organizations].find_all { |h| h[:classification] == 'legislature' }.count.zero?
    json[:organizations] << {
      classification: "legislature",
      name: "Legislature",
      id: "legislature",
    }
  end

  # ensure at least one legislative period
  leg = json[:organizations].find { |h| h[:classification] == 'legislature' } or raise "No legislature"
  unless leg.has_key?(:legislative_periods) and not leg[:legislative_periods].count.zero? 
    leg[:legislative_periods] = [{
      id: 'term/current',
      name: 'current',
      classification: 'legislative period',
    }]
  end

  # change Party Memberships to on_behalf_of
  # Here *all* other Orgs are Parties
  json[:organizations].find_all { |h| h[:classification] != 'legislature' }.each do |o|
    json[:memberships].find_all { |m| m[:organization_id] == o[:id] }.each do |m|
      m[:role] = 'member'
      m[:on_behalf_of_id] = o[:id]
      m[:organization_id] = 'legislature'
    end
  end

  # Set all Legislative memberships with no term to be current
  json[:memberships].find_all { |m| m[:organization_id] == 'legislature' && m[:role] == 'member' }.each do |m|
    m[:legislative_period_id] ||= 'term/current'
  end

  File.write('chile.json', JSON.pretty_generate(json))
end

task :install => 'chile.json' do
  FileUtils.cp('chile.json', '../')
end

task :rebuild => [ :clean, 'chile.json' ]

task :clean do
  FileUtils.rm('chile.json') if File.exist?('chile.json')
end

task :default => 'chile.json'

require 'open-uri'

class Zipcode
  def initialize(zip)
    if zip =~ /^\d{5}$/
      @zip = zip
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def senators
    legislators.select do |l|
      l["title"] == "Sen" 
    end
  end

  def reps
    legislators.select do |l|
      l["title"] == 'Rep'
    end
  end

  def legislators
    unless @legislators
      @legislators = 
        ActiveSupport::JSON.decode(
          open("http://services.sunlightlabs.com/api/legislators.allForZip?zip=#{@zip}&apikey=#{SUNLIGHT_API_KEY}").string
        )["response"]["legislators"]
      @legislators.map!{|l| l["legislator"]}
    end
    @legislators
  end

  def to_s
    @zip
  end
end

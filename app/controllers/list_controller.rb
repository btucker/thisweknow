class ListController < ApplicationController
  helper ActionView::Helpers::NumberHelper
  LISTS = ["Most Toxins", "Least Toxins", "Most Nomadic", "Least Nomadic", "Most Cancer", "Highest Unemployment", 
           "Lowest Unemployment"]

  caches_page :show
  def show
    @list_name = params[:id].gsub('_', ' ')
    
    if LISTS.include? @list_name
      @columns = [
        ['City', lambda{|row| "<a href='#{location_path(row.city.location)}'>#{row.city.to_s}</a>" }]
      ]
      case @list_name
      when "Most Toxins"
        @factoid = Factoid.find(2)
        @results = @factoid.factoid_results.find(:all,
                                                 :include => :city,
                                                 :group => :city_id,
                                                 :conditions => 'count1 IS NOT NULL AND cities.land_area > 0',
                                                 :order => '(count1/cities.land_area) DESC',
                                                 :limit => 100)
      when "Least Toxins"
        @factoid = Factoid.find(2)
        @results = @factoid.factoid_results.find(:all,
                                                 :include => :city,
                                                 :group => :city_id,
                                                 :conditions => 'count1 IS NOT NULL AND count1 > 0 AND cities.land_area > 0',
                                                 :order => '(count1/cities.land_area) ASC',
                                                 :limit => 100)
      when "Most Nomadic"
        @factoid = Factoid.find(15)
        @results = @factoid.factoid_results.find(:all,
                                                 :include => :city,
                                                 :group => :city_id,
                                                 :conditions => 'count1 IS NOT NULL AND count1 > 0',
                                                 :order => 'count1 DESC',
                                                 :limit => 100)

      when "Least Nomadic"
        @factoid = Factoid.find(15)
        @results = @factoid.factoid_results.find(:all,
                                                 :include => :city,
                                                 :group => :city_id,
                                                 :conditions => 'count1 IS NOT NULL AND count1 > 0',
                                                 :order => 'count1 ASC',
                                                 :limit => 100)

      when "Most Cancer"
        @results = []
        @factoid = Factoid.find(17)

        @factoid.factoid_results.find(:all,
                                      :select => 'distinct count1',
                                      :order => 'count1 DESC',
                                      :limit => 100).map(&:count1).each do |count|
          @results << @factoid.factoid_results.find(:first,
                                                    :conditions => {:count1 => count},
                                                    :include => :city,
                                                    :order => 'cities.population DESC',
                                                    :limit => 1)
                                             end
      when 'Highest Unemployment'
        @factoid = Factoid.find(11)
        @results = @factoid.factoid_results.find(:all,
                                             :conditions => 'count3 IS NOT NULL',
                                             :joins => 'inner join cities on city_id = cities.id',
                                             :group => 'count1,count2',
                                             :order => 'count3 DESC',
                                             :limit => 100)

      when 'Lowest Unemployment'
        @factoid = Factoid.find(11)
        @results = @factoid.factoid_results.find(:all,
                                                 :conditions => 'count3 IS NOT NULL AND count3 > 0',
                                                 :joins => 'inner join cities on city_id = cities.id',
                                                 :group => 'count1,count2',
                                                 :order => 'count3 ASC',
                                                 :limit => 100)


      end

      case @list_name
      when /Nomadic/
        @columns << ['% Relocated', lambda{|row| "#{row.count1.to_i}%"}]
        @columns << ['Total Households', lambda{|row| "#{with_delimiter row.city.households}"}]
      when /Toxins/
        @columns << ['Lbs. Toxins', lambda{|row| with_delimiter row.count1.to_i}]
        @columns << ['Land Area', lambda{|row| with_delimiter row.city.land_area}]
        @columns << ['Lbs. Toxins per Sq-Mile', 
          lambda{|row| with_delimiter((row.count1/row.city.land_area * 100.to_f).round / 100.0)}]
      when /Cancer/
        @columns << ['Total Cancer Diagnoses (in county)', lambda{|row| with_delimiter row.count1.to_i}]
        #@columns << ['Cancer Rate (per capita)', lambda{|row| with_delimiter((row.count1/row.city.population * 100.0).round / 100.0)}]
      when /Unemployment/
        @columns << ['Unemployed Workers (in county)', lambda{|row| with_delimiter row.count1.to_i}]
        @columns << ['Workers With Jobs (in county)', lambda{|row| with_delimiter row.count2.to_i}]
        @columns << ['County Unemployment', lambda{|row| "#{row.count3.to_i}%"}]
      end

    else
      redirect_to "/"
    end
  end
end

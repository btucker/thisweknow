class PagesController < ApplicationController
  caches_page :homepage

  def homepage
    @body_classes = %w(homepg)
    @homepage = true
    @examples = ['Bridgeport, CT', '90210', 'Miami, FL', 'Los Angeles, CA']

    @toxins_factoid = Factoid.find(2)
    @most_toxins = @toxins_factoid.factoid_results.find(:all,
							:include => :city,
							:group => :city_id,
                                                        :conditions => 'count3 IS NOT NULL',
                                                        :order => 'count3 DESC',
                                                        :limit => 5)
    @least_toxins = @toxins_factoid.factoid_results.find(:all,
							:include => :city,
                                                        :group => :city_id,
                                                        :conditions => 'count3 IS NOT NULL AND count3 > 0',
                                                         :order => 'count3 ASC',
                                                         :limit => 5)

    @cancer_factoid = Factoid.find(17)
    # we do this so we get the largest town in a given CBSA
    @most_cancer = []
    @cancer_factoid.factoid_results.find(:all,
                                         :select => 'distinct count1',
                                         :order => 'count1 DESC',
                                         :limit => 5).map(&:count1).each do |count|
      @most_cancer << @cancer_factoid.factoid_results.find(:first,
                                                           :conditions => {:count1 => count},
                                                           :include => :city,
                                                           :order => 'cities.population DESC',
                                                           :limit => 1)

    end

    @nomad_factoid = Factoid.find(15)
    @most_nomadic = @nomad_factoid.factoid_results.find(:all,
							:include => :city,
							:group => :city_id,
                                                        :conditions => 'count1 IS NOT NULL AND count1 > 0',
                                                        :order => 'count1 DESC',
                                                        :limit => 5)

    @unemployment_factoid = Factoid.find(11)
    @lowest_unemployment = @unemployment_factoid.factoid_results.find(:all,
                                                       :conditions => 'count3 IS NOT NULL AND count3 > 0',
						       :joins => 'inner join cities on city_id = cities.id',
						       :group => 'city_id,cities.admin2_code',
                                                       :order => 'count3 ASC',
                                                       :limit => 5)

    @highest_unemployment = @unemployment_factoid.factoid_results.find(:all,
                                                       :conditions => 'count3 IS NOT NULL',
						       :joins => 'inner join cities on city_id = cities.id',
						       :group => 'city_id,cities.admin2_code',
                                                       :order => 'count3 DESC',
                                                       :limit => 5)


  end
end

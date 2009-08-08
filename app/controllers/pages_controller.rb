class PagesController < ApplicationController
  def homepage
    @body_classes = %w(homepg)
    @homepage = true
    @examples = ['New York, NY', '90210', 'Miami, FL', 'Los Angeles, CA']

    @toxins_factoid = Factoid.find(2)
    @most_toxins = @toxins_factoid.factoid_results.find(:all,
                                                        :conditions => 'count1 IS NOT NULL',
                                                        :order => 'count1 DESC',
                                                        :limit => 5)
    @least_toxins = @toxins_factoid.factoid_results.find(:all,
                                                        :conditions => 'count1 IS NOT NULL AND count1 > 0',
                                                         :order => 'count1 ASC',
                                                         :limit => 5)

    @crime_factoid = Factoid.find(7)
    @most_crime = @crime_factoid.factoid_results.find(:all,
                                                        :conditions => 'count1 IS NOT NULL',
                                                       :order => 'count1 DESC',
                                                       :limit => 5)
    @least_crime = @crime_factoid.factoid_results.find(:all,
                                                        :conditions => 'count1 IS NOT NULL AND count1 > 0',
                                                        :order => 'count1 ASC',
                                                        :limit => 5)

    @unemployed_factoid = Factoid.find(11)
    @lowest_unemployment = @unemployed_factoid.factoid_results.find(:all,
                                                       :conditions => 'count3 IS NOT NULL AND count3 > 0',
                                                       :order => 'count3 ASC',
                                                       :limit => 5)

    @highest_unemployment = @unemployed_factoid.factoid_results.find(:all,
                                                       :conditions => 'count3 IS NOT NULL',
                                                       :order => 'count3 DESC',
                                                       :limit => 5)


  end
end

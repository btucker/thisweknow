class PagesController < ApplicationController
  def homepage
    @body_classes = %w(homepg)
    @homepage = true
    @examples = ['New York, NY', '90210', 'Miami, FL', 'Brattleboro, VT']

    @toxins_factoid = Factoid.find(2)
    @most_toxins = @toxins_factoid.factoid_results.find(:all,
                                                        :order => 'count1 DESC',
                                                        :limit => 5)
    @least_toxins = @toxins_factoid.factoid_results.find(:all,
                                                         :order => 'count1 ASC',
                                                         :limit => 5)

    @crime_factoid = Factoid.find(7)
    @most_crime = @toxins_factoid.factoid_results.find(:all,
                                                       :order => 'count1 DESC',
                                                       :limit => 5)
    @least_crime = @toxins_factoid.factoid_results.find(:all,
                                                        :conditions => 'count1 > 0',
                                                        :order => 'count1 ASC',
                                                        :limit => 5)


  end
end

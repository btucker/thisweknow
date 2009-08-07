class PagesController < ApplicationController
  def homepage
    @body_classes = %w(homepg)
    @homepage = true
    @examples = ['New York, NY', '90210', 'Miami, FL', 'Brattleboro, VT']
  end
end

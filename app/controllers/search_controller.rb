class SearchController < ApplicationController
  def search
  end

  def view
    @q = params[:search]
  end
end

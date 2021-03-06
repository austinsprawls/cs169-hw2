class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.ratings_array
    @ratings = Hash.new {|h,k| h[k] = 1}

    if params.has_key?(:ratings)
        @ratings = params[:ratings]
        session[:ratings] = params[:ratings]
    elsif session.has_key?(:ratings)
        redirect_to movies_path(:sort => session[:sort], :ratings => session[:ratings])
    else
        @all_ratings.each {|r| @ratings[r] }
    end

    @movies = []
    @ratings.each_key do |r|
        @movies += Movie.find_all_by_rating(r)
    end

    @hilite = Hash.new {|h,k| h[k] = ''}
    if params[:sort] == 'title'
        @movies = @movies.sort {|a,b| a.title <=> b.title}
        @hilite[:title] = 'hilite'
        session[:sort] = params[:sort]
    elsif params[:sort] == 'release_date'
        @movies = @movies.sort {|a,b| a.release_date <=> b.release_date}
        @hilite[:release_date] = 'hilite'
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end

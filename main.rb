require 'rubygems'
require 'sinatra'

set :sessions, true

helpers do
  def calculate_total(cards)
  	arr = cards.map{|face| face[1]}

  	total = 0
  	arr.each do |v|
  		if v == "A"
  			total += 11
  		else
  			total += v.to_i == 0 ? 10 : v.to_i
  		end
  	end

  	#correct for Aces
  	arr.select{|face| face == "A"}.count.times do
  		break if total <= 21
  		total -= 10
  	end

  	total
  end

  def card_image(card) # ['H', '4']
    suit = case card[0]
      when 'H' then 'hearts'
      when 'D' then 'diamonds'
      when 'C' then 'clubs'
      when 'S' then 'spades'
    end

    value = card[1]
    if ['J', 'Q', 'K', 'A'].include?(value)
      value = case card[1]
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
        when 'A' then 'ace'
      end
    end

    "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
  end
end

before do
  @show_hit_or_stay_buttons = true
end

get '/' do 
  if session[:player_name]
  	redirect '/game'
  else
  	redirect '/new_player'
  end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do
if params[:player_name].empty?
  @error = "Name is required"
  halt erb(:new_player)
end

  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do
	# deck
	suits = ['H', 'D', 'S', 'C']
	values = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
	session[:deck] = suits.product(values).shuffle! #[['H', '9'], ['C', 'K']]

	#deal cards
	session[:dealer_cards] = []
	session[:player_cards] = []
	session[:player_cards] << session[:deck].pop
	session[:dealer_cards] << session[:deck].pop
	session[:player_cards] << session[:deck].pop
	session[:dealer_cards] << session[:deck].pop
  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop

  player_total = calculate_total(session[:player_cards])
  if player_total == 21
    @success = "Congratulations! #{session[:player_name]} hit blackjack!"
    @show_hit_or_stay_buttons = false
  elsif player_total > 21
  	@error = "Sorry, it looks like #{session[:player_name]} busted."
  	@show_hit_or_stay_buttons = false
  end
  erb :game
end

post '/game/player/stay' do
	@success = "#{player_name} has chosen to stay."
	@show_hit_or_stay_buttons = false
  erb :game
end


get '/about' do
	erb :about
end

get '/contact' do
	erb :contact
end
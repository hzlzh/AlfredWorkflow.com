# -*- coding: utf-8 -*-
import alfred
import config
from uuid import uuid4
import newgame

# feedback item to display the hint
def get_target_item(target, gameover = False):
	return alfred.Item(
		attributes = { 
		'uid' : uuid4(),
		'arg' : '',
		'valid' : 'no'
		},
		title = target,
		subtitle = "Your hint" if gameover == False else "Best guess",
		icon = "icon.png"
	)

# feedback item for what is being typed into Alfred
def get_typed_item(guess):
	length = len(guess)
	already_attempted = word_in_attempts(guess)
		
	valid = length == 5 and not already_attempted
	subtitle = "Enter a guess"
	config.put('lingo.last.action', False)

	if already_attempted:
		subtitle = "You already played that"
	elif length == 5:
		subtitle = "Have a go!"
		config.put('lingo.last.word', guess)
		config.put('lingo.last.action', True)
	elif length > 5:
		subtitle = "Must be 5 letters long"

	if length > 5:
		guess = guess[:5]
	
	guess = guess.replace(' ', '_') + '_' * (5 - length)
	
	return alfred.Item(
		attributes = { 
			'uid' : uuid4(),
			'arg' : guess,
			'valid' : 'no',
			'autocomplete' : ''
		},
		title = guess.upper() + "   ", # hack
		subtitle = subtitle,
		icon = "guess.png"
	)

# checks if a given word is in the dictionary or not
def word_in_list(word):
	if word_in_list_of(word,"e"):
		return True
	if word_in_list_of(word,"m"):
		return True
	if word_in_list_of(word,"h"):
		return True
	return False

def word_in_list_of(word, difficulty):
	word_list_file = open( difficulty+'.txt', 'r')
	words = word_list_file.readlines()
	word_list_file.close()
	for w in words:
		if word in w:
			return True
	return False	

# checks if a given word has been tried before
def word_in_attempts(word):
	attempts = config.get('attempts')
	for a in attempts:
		if a['original'] == word:
			return True
	return False

# feedback item in case there is not active game to play
def no_game():
	return alfred.Item(
		attributes = { 
			'uid' : uuid4(),
			'arg' : 'another_round',
			'valid' : 'yes'
		},
		title = "No game in progress",
		subtitle = "Press Enter to start a new game",
		icon = "icon.png"
	)

# feedback items for the history of word guesses made
def get_attempt_items():
	attempts = config.get('attempts')
	i = 1
	feedback_items = []
	for attempt in attempts:
		feedback_items.append(
			alfred.Item(
				attributes = { 
					'uid' : uuid4(),
					'arg' : '',
					'valid' : 'no',
					'autocomplete' : attempt['original']
				},
				title = attempt['guess'],
				subtitle = attempt['original'] + (" - not in dictionary" if attempt['outcome'] == "badword" else ""),
				icon = "attempt{0}.png".format(i)
			)
		)
		i=i+1
	return feedback_items

# feedback item in case one is not able to solve the puzzle
def get_solution_item():
	config.put('lingo.last.action', 'gameover')
	if config.get('stats'):
		config.put('games_played', config.get('games_played') + 1 )
		config.put('games_lost', config.get('games_lost') + 1 )
		config.put('stats', False)
	return alfred.Item(
		attributes = { 
			'uid' : uuid4(),
			'arg' : 'another_round',
			'valid' : 'yes',
			'autocomplete' : ''
		},
		title = "The word was {0}".format(config.get('target').upper()),
		subtitle = "Why not try another round?",
		icon = "icon.png"
	)
	
# feedback item when one solves the puzzle
def get_winner_item(attempts):
	# we won, we won, we won!
	config.put('lingo.last.action', 'gamewon')
	# update the average moves taken

	won = config.get('games_won')
	played = config.get('games_played')
	average = config.get('average_moves')
	if config.get('stats'):
		won = won+1
		played = played+1
		average = ((won-1) * average + len(attempts))/((won)*1.0)
		config.put('average_moves', average)
		config.put('games_played',  played)
		config.put('games_won', won)
		config.put('stats', False)
	subtitle = "won {1} of {0} played | {3:.0f}% | {2:.1f} attempts on average".format(played,won,average, (100.0 * won)/(played))
	return alfred.Item(
		attributes = { 
			'uid' : uuid4(),
			'arg' : 'another_round',
			'valid' : 'yes',
			'autocomplete' : ''
		},
		title = "You won!",
		subtitle = subtitle,
		icon = "icon.png"
	)

# feedback item to output debug text (internal use only)
def debug_item(text):
	return alfred.Item(
		attributes = { 
			'uid' : uuid4(),
			'arg' : ''
		},
		title = text,
		subtitle = "",
		icon = "icon.png"
	)

def process_guess(guess):
	# a simple method to avoid the flickering Alfred
	# uses the autocomplete feature of non valid items
	# to maintain an internal state
	# 
	# Knowing this state allows us to recognize that the user
	# is actioning a non-valid item but the state variable
	# helps us to validate the action none the less
	# This only works because Alfred fires the script on
	# every key press!
	feedback_items = []
	if config.get('lingo.last.action') == True and len(guess) == 0:
		add_guess(config.get('lingo.last.word'))
		config.put('lingo.last.action', False)
		config.put('lingo.last.word','')
	# elif config.get('lingo.last.action') == 'gameover' or config.get('lingo.last.action') == 'gamewon':
	# 	newgame.make_new_game()
	#  	config.put('lingo.last.action', False)
	#  	config.put('lingo.last.word','')
	if config.get('inplay') == False:
		feedback_items.append(no_game())
	else:
		attempts = config.get('attempts')
		gameover = False
		if len(attempts) > 0 and attempts[-1]['outcome'] == 'won':
			feedback_items.append(get_winner_item(attempts))
		elif len(attempts) == 5:
			feedback_items.append(get_solution_item())
			feedback_items.append(get_target_item(config.get('hint'), gameover=True))
		else:
			# feedback for typed item
			feedback_items.append(get_typed_item(guess.lower()))
			# feedback for word to guess
			feedback_items.append(get_target_item(config.get('hint')))
		# feedback for all attempted words
		feedback_items = feedback_items + get_attempt_items()
	alfred.write(alfred.xml(feedback_items))


def add_guess(guess):
	# get the current list of attempts
	attempts = config.get('attempts')
	if len(attempts) == 5:
		return

	attempt = {}

	valid_word = word_in_list(guess)
	if not valid_word:
		g = list(guess.lower())
		# add some spacing for the guess
		i=0
		while i<5:
			if len(g[i]) == 1:
				g[i] = "_".format(g[i])
			i+=1
		final_guess = " ".join(g).strip()
		attempt = {
			'guess' : final_guess,
			'original' : guess,
			'outcome' : 'badword'
		}
	else:
		# make uppercase all letters in the right place
		t = list(config.get('target'))
		g = list(guess.lower())
		matched = [False, False, False, False, False]
		i=0
		while i<5:
			if g[i] == t[i]:
				g[i] = u"{0}".format(g[i].upper())
				matched[i] = True
			i+=1
		# highlight all letters in the guess word that may not be in the right pos
		i=0
		while i<5:
			if g[i].islower(): #unprocessed
				j=0
				while j<5:
					if not matched[j] and g[i] == t[j]:
						g[i] = u" [{0}]".format(g[i])
						matched[j] = True
					j+=1
			i+=1
		
		# update the original hint with all letters in correct place
		h = list(config.get('hint'))
		i=0
		while i<5:
			if g[i].isupper():
				h[i] = g[i]
			i+=1


		# add some spacing for the guess
		i=0
		while i<5:
			if len(g[i]) == 1:
				g[i] = " {0}".format(g[i])
			i+=1


		final_hint = "".join(h)
		final_guess = "".join(g).strip()
		config.put('hint', final_hint)
		attempt = {
			'guess' : final_guess,
			'original' : guess,
			'outcome' : 'won' if guess.upper() == final_hint else 'inplay'
		}

	attempts.append(attempt)
	config.put('attempts', attempts)


def main():
	(mode, guess) = alfred.args2()
	if mode == '-p':
		process_guess(guess)
	elif mode == '-a':
		add_guess(guess)


if __name__ == "__main__":
    main()
import config
from random import choice, randrange

# initilizes a new game
def make_new_game():
	config.put('inplay', True)
	config.put('attempts', [])

	difficulty = config.get('difficulty')
	words = []
	with open(difficulty + '.txt') as f:
		words = [line.strip() for line in f]
	target = choice(words)
	hint1 = randrange(0,5)
	hint2 = randrange(0,4)
	if hint2>=hint1:
		hint2 = (hint2+1)%5
	hint = [ '_', '_', '_', '_', '_']
	hint[hint1] = target[hint1].upper()
	hint[hint2] = target[hint2].upper()
	hint = "".join(hint)
	config.put('target', target)
	config.put('hint', hint)
	config.put('stats', True)
	
	print (target, hint)
	

if __name__ == "__main__":
    make_new_game()
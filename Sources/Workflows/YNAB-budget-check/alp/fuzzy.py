import re


# order and rank functions are from here
# http://code.activestate.com/recipes/491268-ordering-and-ranking-for-lists/
def order(x, NoneIsLast=True, decreasing=False):
    """
    Returns the ordering of the elements of x. The list
    [ x[j] for j in order(x) ] is a sorted version of x.

    Missing values in x are indicated by None. If NoneIsLast is true,
    then missing values are ordered to be at the end.
    Otherwise, they are ordered at the beginning.
    """
    omitNone = False
    if NoneIsLast is None:
        NoneIsLast = True
        omitNone = True

    n = len(x)
    ix = range(n)
    if None not in x:
        ix.sort(reverse=decreasing, key=lambda j: x[j])
    else:
        # Handle None values properly.
        def key(i, x=x):
            elem = x[i]
            # Valid values are True or False only.
            if decreasing == NoneIsLast:
                return not(elem is None), elem
            else:
                return elem is None, elem
        ix = range(n)
        ix.sort(key=key, reverse=decreasing)

    if omitNone:
        n = len(x)
        for i in range(n-1, -1, -1):
            if x[ix[i]] is None:
                n -= 1
        return ix[:n]
    return ix


def rank(x, NoneIsLast=True, decreasing=False, ties="first"):
    """
    Returns the ranking of the elements of x. The position of the first
    element in the original vector is rank[0] in the sorted vector.

    Missing values are indicated by None.  Calls the order() function.
    Ties are NOT averaged by default. Choices are:
         "first" "average" "min" "max" "random" "average"
    """
    omitNone = False
    if NoneIsLast is None:
        NoneIsLast = True
        omitNone = True
    O = order(x, NoneIsLast=NoneIsLast, decreasing=decreasing)
    R = O[:]
    n = len(O)
    for i in range(n):
        R[O[i]] = i
    if ties == "first" or ties not in ["first", "average", "min", "max", "random"]:
        return R

    blocks = []
    newblock = []
    for i in range(1, n):
        if x[O[i]] == x[O[i-1]]:
            if i-1 not in newblock:
                newblock.append(i-1)
            newblock.append(i)
        else:
            if len(newblock) > 0:
                blocks.append(newblock)
                newblock = []
    if len(newblock) > 0:
        blocks.append(newblock)

    for i, block in enumerate(blocks):
        # Don't process blocks of None values.
        if x[O[block[0]]] is None:
            continue
        if ties == "average":
            s = 0.0
            for j in block:
                s += j
            s /= float(len(block))
            for j in block:
                R[O[j]] = s
        elif ties == "min":
            s = min(block)
            for j in block:
                R[O[j]] = s
        elif ties == "max":
            s = max(block)
            for j in block:
                R[O[j]] = s
        else:
            for i, j in enumerate(block):
                R[O[j]] = j
    if omitNone:
        R = [R[j] for j in range(n) if x[j] is not None]
    return R


def match_rank(query, strings, seq=3):
    # create regular expression that (a) matches all letters of query, (b) correct order
    # see http://stackoverflow.com/a/2897073/1318686 for more details
    el = u'[^{s}]*({s})'
    expr = u''.join([el.format(s=re.escape(c)) for c in query])
    # create matches
    mat = [re.match(expr, s, re.IGNORECASE) if query[0:seq].lower() in s.lower() else None for s in strings]
    # position of matched elements
    position = [[m.end(i) for i in range(1, m.lastindex+1, 1)] if m is not None else None for m in mat]
    # proportion of query that is in sequence
    letter_seq = [sum([p-pos[i-1] == 1 for i, p in enumerate(pos)][1::]) if pos is not None else None for pos in position]
    # [1-float(sum([j-pos[i-1] == 1 for i, j in enumerate(pos)][1::]))/(len(query)-1) if pos is not None else None for pos in position]
    # sum of position for matches
    pos_sum = [sum(pos) if pos is not None else None for pos in position]
    # rank elements
    rank_seq = rank(letter_seq, decreasing=True)
    rank_pos = rank(pos_sum)
    # return ranked output object
    return [(rank_seq[i]+rank_pos[i])/2 if m is not None else None for i, m in enumerate(mat)]


def fuzzy_search(query, elements, key=lambda x: x, rank=True, seq=3):
    """Fuzzy search for query in list of strings, dictionaries, tulpes, or lists

    Args:
        query: search string
        elements: list of strings, dictionaries, tulpes, or lists
        key: function to access string element in dictionaries, tulpes, or lists
        rank: rank the elements in the return list by quality of match (currently not supported)
        seq: minimum sequence of characters to match
    Returns:
        a ranked list of elements that matches the query

    Fuzzy matching with rankning based on quality of match with two criteria
    (a) sequence of characters (e.g. for query 'nor', 'nor' is better then 'nxoxr')
    (b) earlier matches are better (e.g. for query 'nor', 'nor' is better then 'xnor')
    """
    R = match_rank(query, [key(el) for el in elements], seq=seq)
    out = [(el, R[i]) for i, el in enumerate(elements) if R[i] is not None]
    return [el[0] for el in sorted(out, key=lambda el: el[1])]


# elements = [{'key': u'ZB7K535R', 'author': u'Reskin 2003', 'title': u'Including Mechanisms in Our Models of Ascriptive Inequality: 2002 Presidential Address'}, {'key': u'DBTD3HQS', 'author': u'Igor & Ronald 2008', 'title': u'Die Zunahme der Lohnungleichheit in der Bundesrepublik. Aktuelle Befunde f\xfcr den Zeitraum von 1998 bis 2005'}, {'key': u'BKTCNEGP', 'author': u'Kirk & Sampson 2013', 'title': u'Juvenile Arrest and Collateral Educational Damage in the Transition to Adulthood'}, {'key': u'9AN4SPKT', 'author': u'Turner 2003', 'title': u'The Structure of Sociological Theory'}, {'key': u'9M92EV6S', 'author': u'Bruhns et al. 1999', 'title': u'Die heimliche Revolution'}, {'key': u'25QBTM5P', 'author': u'Durkheim 1997', 'title': u'The Division of Labor in Society'}, {'key': u'MQ3BHTBJ', 'author': u'Marx 1978', 'title': u'Alienation and Social Class'}, {'key': u'7G4BRU45', 'author': u'Marx 1978', 'title': u'The German Ideology: Part I'}, {'key': u'9ANAZXQB', 'author': u'Llorente 2006', 'title': u'Analytical Marxism and the Division of Labor'}]
# query = 'marx'
# fuzzy_search(query, elements, key=lambda x: '%s - %s' % (x['author'], x['title']))

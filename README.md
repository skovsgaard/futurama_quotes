# FuturamaQuotes

The routes are:

    GET / #=> Get all quotes
    GET /quote #=> Same as above
    GET /quote/random #=> Get a random quote
    GET /quote/:id #=> Get by index in quote list
    GET /quote/regex/:regex #=> Get quote matching :regex
    GET /quote/by/:person #=> Get quotes featuring :person
    POST /quote #=> Save a new quote

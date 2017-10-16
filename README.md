# hex-elixir

An Elixir umbrella application, containing various services for the HEX TCG, which includes:

- `message_indexer`: a webserver that indexes all API messages from the official HEX API
- `auction_indexer`: a GenServer that indexes all auction house related API messages and builds the AH state in a database
- `database`: an application defining all database-related information, schemas and structs for the rest
  of the projects

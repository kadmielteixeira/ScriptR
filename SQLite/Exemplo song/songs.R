# Importar os pacotes necessários
library(RSQLite)

# Utilizando RSQLite, conecte-se ao arquivo songs.db e armazene a conexão na variável db
db = dbConnect(SQLite(),'songs.db')

# Liste as tabelas existentes no banco de dados
dbListTables(db)

# Liste as colunas existentes na tabela customers
dbListFields(db,'customers')

# Liste todas as informações existentes na tabela customers
dbGetQuery(db,"SELECT * FROM customers")

# Identifique quantos clientes estão cadastrados neste banco de dados
dbGetQuery(db,'SELECT COUNT(DISTINCT CustomerId) AS qtde_clientes FROM customers')

# Identifique quantos países diferentes em que moram os clientes 
dbGetQuery(db,'SELECT COUNT(DISTINCT Country) AS qtde_paises FROM customers')

# Identifique quantos clientes existem por país
dbGetQuery(db,paste("SELECT Country, COUNT(CustomerId) AS n",
                      "FROM customers",
                      "GROUP BY Country",
                      "ORDER BY n DESC"))

# Identifique a música, o id da música e albumid da banda System Of A Down
dbGetQuery(db,'SELECT ArtistId,Name FROM artists ORDER BY Name')
dbGetQuery(db, 'SELECT trackid, name, albumid FROM tracks WHERE albumid IN (SELECT albumid FROM albums WHERE artistid==135)')

# Identifique as músicas que foram compradas por clientes franceses
dbGetQuery(db, paste("SELECT name FROM tracks",
                     "INNER JOIN invoice_items, invoices, customers",
                     "ON customers.CustomerId = invoices.CustomerId",
                     "AND invoice_items.InvoiceId = invoices.InvoiceID",
                     "AND tracks.TrackID = invoice_items.TrackID",
                     "WHERE customers.Country == 'France'"))

# Não se esqueça de desconectar-se do banco de dados
dbDisconnect(db)
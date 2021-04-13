# Importar os pacotes necessários
library(RSQLite)

# Utilizando RSQLite, conecte-se ao arquivo database.sqlite3 e armazene a conexão na variável db
db = dbConnect(SQLite(),'database.sqlite3')

# Liste as tabelas existentes no banco de dados
dbListTables(db)

# Identifique os professores que lecionaram disciplinas cujo tópico era estatística
dbGetQuery(db, "SELECT DISTINCT(instructors.name) FROM instructors
INNER JOIN subjects, subject_memberships, sections, teachings
ON subjects.code = subject_memberships.subject_code
AND subject_memberships.course_offering_uuid = sections.course_offering_uuid
AND sections.uuid = teachings.section_uuid
AND teachings.instructor_id = instructors.id
WHERE subjects.abbreviation == 'STAT'")

# Professor mais fácil
dbGetQuery(db,
"SELECT DISTINCT(instructors.name), instructors.id, AVG((bc_count*2.5 + d_count*1 + ab_count*3.5 + a_count*4 + b_count*3 +
c_count*2 + f_count*0)/(bc_count + d_count + ab_count + a_count + b_count + c_count + f_count)) AS media FROM grade_distributions
INNER JOIN course_offerings ON course_offerings.uuid = grade_distributions.course_offering_uuid
INNER JOIN sections ON sections.course_offering_uuid = course_offerings.uuid
INNER JOIN teachings ON sections.uuid = teachings.section_uuid
INNER JOIN instructors ON instructors.id = teachings.instructor_id
INNER JOIN subject_memberships ON  subject_memberships.course_offering_uuid = sections.course_offering_uuid
INNER JOIN subjects ON subjects.code = subject_memberships.subject_code 
WHERE subjects.abbreviation = 'STAT'
GROUP BY instructors.name
HAVING media >= 4
ORDER BY -media")

# Top três professores mais difíceis
dbGetQuery(db, 
"SELECT DISTINCT(instructors.name), instructors.id, AVG((bc_count*2.5 + d_count*1 + ab_count*3.5 + a_count*4 + b_count*3 +
c_count*2 + f_count*0)/(bc_count + d_count + ab_count + a_count + b_count + c_count + f_count)) AS media FROM grade_distributions
INNER JOIN course_offerings ON course_offerings.uuid = grade_distributions.course_offering_uuid
INNER JOIN sections ON sections.course_offering_uuid = course_offerings.uuid
INNER JOIN subject_memberships ON  subject_memberships.course_offering_uuid = sections.course_offering_uuid
INNER JOIN subjects ON subjects.code = subject_memberships.subject_code 
INNER JOIN teachings ON teachings.section_uuid = sections.uuid 
INNER JOIN instructors ON instructors.id = teachings.instructor_id
WHERE subjects.abbreviation = 'STAT'
GROUP BY instructors.name
HAVING media > 0
ORDER BY media
LIMIT 3")

# Disciplinas mais fáceis
dbGetQuery(db, 
"SELECT DISTINCT course_offerings.name, AVG((bc_count*2.5 + d_count*1 + ab_count*3.5 + a_count*4 + b_count*3 +
c_count*2 + f_count*0)/(bc_count + d_count + ab_count + a_count + b_count + c_count + f_count)) AS media FROM grade_distributions
INNER JOIN course_offerings ON course_offerings.uuid = grade_distributions.course_offering_uuid
INNER JOIN sections ON sections.course_offering_uuid = course_offerings.uuid
INNER JOIN teachings ON sections.uuid = teachings.section_uuid
INNER JOIN instructors ON instructors.id = teachings.instructor_id
INNER JOIN subject_memberships ON  subject_memberships.course_offering_uuid = sections.course_offering_uuid
INNER JOIN subjects ON subjects.code = subject_memberships.subject_code 
WHERE subjects.abbreviation = 'STAT'
GROUP BY course_offerings.name
HAVING media >= 4
ORDER BY -media")

# Top 10 disciplinas mais difíceis
dbGetQuery(db, 
"SELECT course_offerings.name, AVG((bc_count*2.5 + d_count*1 + ab_count*3.5 + a_count*4 + b_count*3 +
c_count*2 + f_count*0)/(bc_count + d_count + ab_count + a_count + b_count + c_count + f_count)) AS media FROM grade_distributions
INNER JOIN course_offerings ON course_offerings.uuid = grade_distributions.course_offering_uuid
INNER JOIN sections ON sections.course_offering_uuid = course_offerings.uuid
INNER JOIN teachings ON sections.uuid = teachings.section_uuid
INNER JOIN instructors ON instructors.id = teachings.instructor_id
INNER JOIN subject_memberships ON  subject_memberships.course_offering_uuid = sections.course_offering_uuid
INNER JOIN subjects ON subjects.code = subject_memberships.subject_code 
WHERE subjects.abbreviation = 'STAT'
GROUP BY course_offerings.name
HAVING media >= 0
ORDER BY media
LIMIT 10")

# Não se esqueça de desconectar-se do banco de dados
dbDisconnect(db)
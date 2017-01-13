// drop everything
MATCH (n)
OPTIONAL MATCH (n)-[r]-()
DELETE n, r;

DROP CONSTRAINT ON (p:Person) ASSERT p.name IS UNIQUE;
CREATE CONSTRAINT ON (p:Person) ASSERT p.name IS UNIQUE;

CREATE
  (alice:Person { name: 'Alice' }),
  (bob:Person { name: 'Bob' }),
  (carol:Person { name: 'Carol' }),
  (dan:Person { name: 'Dan' }),
  (eve:Person { name: 'Eve' }),
  (francis:Person { name: 'Francis' }),

  (alice)-[:SENT]->(t_a_b:Transaction {amount: 5})-[:RECEIVED]->(bob),
  (bob)-[:SENT]->(t_b_a:Transaction {amount: 5})-[:RECEIVED]->(alice),
  (t_a_b)-[:SETTLEMENT_FOR]->(t_b_a),

  (bob)-[:SENT]->(t_b_c:Transaction {amount: 5})-[:RECEIVED]->(carol),
  (carol)-[:SENT]->(t_c_b:Transaction {amount: 5})-[:RECEIVED]->(bob),
  (t_c_b)-[:SETTLEMENT_FOR]->(t_b_c),
  (bob)-[:SENT]->(:Transaction {amount: 11})-[:RECEIVED]->(carol),
  (bob)-[:SENT]->(:Transaction {amount: 7})-[:RECEIVED]->(eve),

  (dan)-[:SENT]->(:Transaction {amount: 4})-[:RECEIVED]->(eve),
  (alice)-[:SENT]->(:Transaction {amount: 34})-[:RECEIVED]->(dan),
  (eve)-[:SENT]->(:Transaction {amount: 12})-[:RECEIVED]->(alice),

  (eve)-[:SENT]->(:Transaction {amount: 12})-[:RECEIVED]->(francis),
  (dan)-[:SENT]->(:Transaction {amount: 7})-[:RECEIVED]->(francis);



// Ki kapta a legtöbb pénzt?
MATCH (person:Person) WITH person
OPTIONAL MATCH (person)<-[:RECEIVED]-(t:Transaction)
RETURN person.name AS Name, SUM(t.amount) AS Received
ORDER BY Received DESC
LIMIT 1;

// Ki adta a legtöbb pénzt?
MATCH (person:Person) WITH person
OPTIONAL MATCH (person)-[:SENT]->(t:Transaction)
RETURN person.name AS Name, SUM(t.amount) AS Sent
ORDER BY Sent DESC
LIMIT 1;

// Kinek mennyi az egyenlege?
MATCH (person:Person) WITH person
OPTIONAL MATCH (person)<-[:RECEIVED]-(r:Transaction) WITH person, SUM(r.amount) AS Received
OPTIONAL MATCH (person)-[:SENT]->(s:Transaction) WITH Received, person, SUM(s.amount) AS Sent
RETURN person.name AS Name, Received - Sent AS Balance
ORDER BY Balance DESC;

// Kinek mennyivel tartoznak?
MATCH (person:Person) WITH person
OPTIONAL MATCH (person)-[:SENT]->(t:Transaction)
WHERE NOT EXISTS ((t)-[:SETTLEMENT_FOR]-())
RETURN person.name AS Name, SUM(t.amount) AS `Total amount`
ORDER BY `Total amount` DESC;

// Kinek mennyi a tartozása?
MATCH (person:Person) WITH person
OPTIONAL MATCH (person)<-[:RECEIVED]-(t:Transaction)
WHERE NOT EXISTS ((t)-[:SETTLEMENT_FOR]-())
RETURN person.name AS Name, SUM(t.amount) AS `Total amount`
ORDER BY `Total amount` DESC;

// Ki, kinek mennyivel?
MATCH (person:Person)<-[:RECEIVED]-(t:Transaction)<-[:SENT]-(to:Person)
WHERE NOT EXISTS ((t)-[:SETTLEMENT_FOR]-())
RETURN person.name AS Name, to.name AS To, SUM(t.amount) AS `Debt`
ORDER BY `Debt` DESC;

// Mennyi az összes ki nem egyenlített tartozás?
MATCH (person:Person)<-[:RECEIVED]-(t:Transaction)
WHERE NOT EXISTS ((t)-[:SETTLEMENT_FOR]-())
WITH SUM(t.amount) AS personalDebts
RETURN SUM(personalDebts) AS `Global debt`;

// Adott ember hány másiknak tartozik?
MATCH (person:Person {name: 'Eve'})<-[:RECEIVED]-(t)<-[:SENT]-(to)
WHERE NOT EXISTS ((t)-[:SETTLEMENT_FOR]-())
RETURN person.name AS Name, count(to) AS To, SUM(t.amount) AS `Debt`;

// Adott ember átlagosan mennyivel tartozik?
MATCH (person:Person {name: 'Eve'})<-[:RECEIVED]-(t)<-[:SENT]-(to)
WHERE NOT EXISTS ((t)-[:SETTLEMENT_FOR]-())
RETURN person.name AS Name, count(to) AS To, AVG(t.amount) AS `Average debt`;

// Azok, akik már adtak egy adott embernek kölcsönt, kiknek adtak még?
MATCH (person:Person {name: 'Eve'})<-[:RECEIVED]-(originalTransaction)<-[:SENT]-(patron) WITH person, patron, originalTransaction
WHERE NOT EXISTS ((originalTransaction)-[:SETTLEMENT_FOR]-())
MATCH (otherPerson)<-[]-(otherTransaction)-[:SENT]-(patron) WHERE otherPerson.name <> person.name
RETURN otherPerson, patron, otherTransaction, person, originalTransaction;
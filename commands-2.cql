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
  (eve)-[:SENT]->(:Transaction {amount: 12})-[:RECEIVED]->(alice);



// Ki kapta a legtöbb pénzt?
MATCH (person:Person)<-[:RECEIVED]-(t:Transaction)
RETURN person.name, SUM(t.amount) AS received
ORDER BY received DESC
LIMIT 1;

// Ki adta a legtöbb pénzt?
MATCH (person:Person)-[:SENT]->(t:Transaction)
RETURN person.name, SUM(t.amount) AS received
ORDER BY received DESC
LIMIT 1;

// Kinek mennyi az egyenlege?
OPTIONAL MATCH (person:Person)<-[:RECEIVED]-(r:Transaction) WITH person, SUM(r.amount) AS Received
OPTIONAL MATCH (person)-[:SENT]->(s:Transaction) WITH Received, person, SUM(s.amount) AS Sent
RETURN person.name AS Name, (Received - Sent) AS Balance
ORDER BY Balance DESC;

// Kinek mennyivel tartoznak?
MATCH (person:Person)<-[:RECEIVED]->(t:Transaction)
WHERE NOT EXISTS ((t)-[:SETTLEMENT_FOR]-())
RETURN person.name AS Name, SUM(t.amount) AS `Total amount`
ORDER BY `Total amount` DESC;

// Kinek mennyi a tartozása?
MATCH (person:Person)<-[:RECEIVED]->(t:Transaction)
WHERE NOT EXISTS ((t)-[:SETTLEMENT_FOR]-())
RETURN person.name AS Name, SUM(t.amount) AS `Total amount`
ORDER BY `Total amount` DESC;

// Ki, kinek mennyivel?
MATCH (person:Person)<-[:RECEIVED]->(t:Transaction)<-[:SENT]-(to:Person)
WHERE NOT EXISTS ((t)-[:SETTLEMENT_FOR]-())
RETURN person.name AS Name, to.name AS TO, SUM(t.amount) AS `Total debt`
ORDER BY `Total debt` DESC;

// Mennyi az összes ki nem egyenlített tartozás?
MATCH (person:Person)<-[:RECEIVED]->(t:Transaction)
WHERE NOT EXISTS ((t)-[:SETTLEMENT_FOR]-())
WITH SUM(t.amount) AS personalDebts
RETURN sum(personalDebts) AS `Global debt`;

// 1. setup

CREATE
  (alice:Person { name: 'Alice' }),
  (bob:Person { name: 'Bob' }),
  (carol:Person { name: 'Carol' }),
  (dan:Person { name: 'Dan' }),
  (eve:Person { name: 'Eve' }),
  (francis:Person { name: 'Francis' }),

  (alice)-[:BORROWED { amount: 5 }]->(bob),
  (bob)-[:BORROWED { amount: 5 }]->(alice),

  (bob)-[:BORROWED { amount: 5 }]->(carol),
  (carol)-[:BORROWED { amount: 5 }]->(bob),
  (bob)-[:BORROWED { amount: 11 }]->(carol),
  (bob)-[:BORROWED { amount: 7 }]->(eve),

  (dan)-[:BORROWED { amount: 4 }]->(eve),
  (alice)-[:BORROWED { amount: 34 }]->(dan),
  (eve)-[:BORROWED { amount: 12 }]->(alice),

  (eve)-[:BORROWED { amount: 12 }]->(francis),
  (dan)-[:BORROWED { amount: 7 }]->(francis);

CREATE CONSTRAINT ON (p:Person) ASSERT p.name IS UNIQUE;

// Ki kapta a legtöbb pénzt?
MATCH (person:Person) WITH person
OPTIONAL MATCH (person)<-[b:BORROWED]-()
RETURN person.name AS Name, SUM(b.amount) AS Received
ORDER BY Received DESC
LIMIT 1;

// Ki adta a legtöbb pénzt?
MATCH (person:Person) WITH person
OPTIONAL MATCH (person)-[b:BORROWED]->()
RETURN person.name AS Name, SUM(b.amount) AS Sent
ORDER BY Sent DESC
LIMIT 1;

// Kinek mennyi az egyenlege?
MATCH (person:Person) WITH person
OPTIONAL MATCH (person:Person)-[s:BORROWED]->() WITH person, SUM(s.amount) AS Sent
OPTIONAL MATCH (person)<-[r:BORROWED]-() WITH person, Sent, SUM(r.amount) AS Received
RETURN person.name AS Name, Received - Sent AS Balance, Sent, Received
ORDER BY Balance DESC;

// Kinek mennyivel tartoznak?
// Ezt mar nem tudjuk megmondani, mert ugye:
// - 2 embernek adtam 5-5 $.
// - Egy vissza is fizette, illetve egy 3. embertol kaptam 5 $;
// - Annyit latok, hogy van kifele 2x5 = 10, illetve befele 2x5 = 10 => egalban vagyok.
// - Pedig meg en is tartozom, es nekem is tartoznak.

// Kinek mennyi a tartozása?
// Ki, kinek mennyivel?
// Mennyi az összes ki nem egyenlített tartozás?

// 1. setup

CREATE
  (alice:Person { name: 'Alice' }),
  (bob:Person { name: 'Bob' }),
  (carol:Person { name: 'Carol' }),
  (bob)-[:BORROWED { amount: 10 }]->(carol),
  (bob)-[:BORROWED { amount: 12 }]->(carol),
  (carol)-[:BORROWED { amount: 15 }]->(bob),
  (bob)-[:BORROWED { amount: 4 }]->(alice),
  (alice)-[:BORROWED { amount: 10 }]->(carol),
  (alice)-[:BORROWED { amount: 14 }]->(bob),
  (alice)-[:BORROWED { amount: 5 }]->(carol),
  (carol)-[:BORROWED { amount: 12 }]->(alice);

CREATE CONSTRAINT ON (p:Person) ASSERT p.name IS UNIQUE;

// Ki kapta a legtöbb pénzt?
MATCH (p:Person)<-[b:BORROWED]-()
RETURN p.name AS Name, sum(b.amount) AS Received
ORDER BY Received DESC
LIMIT 1;

// Ki adta a legtöbb pénzt?
MATCH (p:Person)-[b:BORROWED]->()
RETURN p.name AS Name, sum(b.amount) AS Sent
ORDER BY Sent DESC
LIMIT 1;

// Kinek mennyi az egyenlege?
MATCH (p:Person)-[s:BORROWED]->() WITH p, sum(s.amount) AS Sent
MATCH (p)<-[r:BORROWED]-() WITH p, Sent, sum(r.amount) AS Received
RETURN p.name AS Name, (Sent - Received) AS Balance, Sent, Received
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

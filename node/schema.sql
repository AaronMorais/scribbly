USE hackathon;

CREATE TABLE notes (
id INT NOT NULL AUTO_INCREMENT,
text TEXT,
time_updated DATE,
time_created DATE,
PRIMARY KEY(id)
);
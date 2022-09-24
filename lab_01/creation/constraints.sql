ALTER TABLE films ADD CONSTRAINT films_constraint
CHECK (company >= 1 AND company <= 1000 AND
    director >= 1 AND director <= 1000 AND
    year > 0 AND
    duration > 0 AND
    rating >= 1 AND rating <= 10
);


ALTER TABLE directors ADD CONSTRAINT directors_constraint
CHECK (gender like 'male' or gender like 'female');

ALTER TABLE actors ADD CONSTRAINT actors_constraint
CHECK (gender like 'male' or gender like 'female');

ALTER TABLE screenwriters ADD CONSTRAINT screenwriters_constraint
CHECK (gender like 'male' or gender like 'female');

ALTER TABLE companies ADD CONSTRAINT companies_constraint
CHECK (rating >= 1 AND rating <= 10 AND
    year > 0
);


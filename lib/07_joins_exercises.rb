# == Schema Information
#
# Table name: actors
#
#  id          :integer      not null, primary key
#  name        :string
#
# Table name: movies
#
#  id          :integer      not null, primary key
#  title       :string
#  yr          :integer
#  score       :float
#  votes       :integer
#  director_id :integer
#
# Table name: castings
#
#  movie_id    :integer      not null, primary key
#  actor_id    :integer      not null, primary key
#  ord         :integer

require_relative './sqlzoo.rb'

def example_join
  execute(<<-SQL)
    SELECT
      *
    FROM
      movies
    JOIN
      castings ON movies.id = castings.movie_id
    JOIN
      actors ON castings.actor_id = actors.id
    WHERE
      actors.name = 'Sean Connery'
  SQL
end

def ford_films
  # List the films in which 'Harrison Ford' has appeared.
  execute(<<-SQL)
  SELECT
    title
  FROM
    movies
    JOIN castings
      ON movies.id = castings.movie_id
    JOIN actors
      ON actors.id = castings.actor_id
  WHERE
    actors.name LIKE 'Harrison Ford'
  SQL
end

def ford_supporting_films
  # List the films where 'Harrison Ford' has appeared - but not in the star
  # role. [Note: the ord field of casting gives the position of the actor. If
  # ord=1 then this actor is in the starring role]
  execute(<<-SQL)
  SELECT
    title
  FROM
    movies
    JOIN castings
      ON movies.id = castings.movie_id
    JOIN actors
      ON actors.id = castings.actor_id
  WHERE
    actors.name LIKE 'Harrison Ford' AND
    castings.ord > 1
  SQL
end

def films_and_stars_from_sixty_two
  # List the title and leading star of every 1962 film.
  execute(<<-SQL)
  SELECT
    title,
    name
  FROM
    movies
    JOIN castings
      ON movies.id = castings.movie_id
    JOIN actors
      ON actors.id = castings.actor_id
  WHERE
    movies.yr = 1962 AND
    castings.ord = 1
  SQL
end

def travoltas_busiest_years
  # Which were the busiest years for 'John Travolta'? Show the year and the
  # number of movies he made for any year in which he made at least 2 movies.
  execute(<<-SQL)
  SELECT
    yr,
    movie_count
  FROM (
    SELECT
      yr,
      COUNT(*) AS movie_count
    FROM
      movies
      JOIN castings
        ON movies.id = castings.movie_id
      JOIN actors
        ON actors.id = castings.actor_id
    WHERE
      actors.name LIKE 'John Travolta'
    GROUP BY
      yr
    ) AS sat_night_subquery
  WHERE
    movie_count > 1
  SQL
end

def andrews_films_and_leads
  # List the film title and the leading actor for all of the films 'Julie
  # Andrews' played in.
  execute(<<-SQL)
  SELECT
    title,
    actor
  FROM (
    SELECT
      title,
      actors.name AS actor,
      castings.ord AS star_ord
      FROM
        movies
        JOIN castings
          ON movies.id = castings.movie_id
        JOIN actors
          ON actors.id = castings.actor_id
      WHERE
        movies.id IN (
          SELECT
            castings.movie_id
          FROM
            actors
            JOIN castings
              ON actors.id = castings.actor_id
          WHERE
            name LIKE 'Julie Andrews'
          )
        ) AS J_A_Costars
        WHERE
          star_ord = 1
  SQL
end

def prolific_actors
  # Obtain a list in alphabetical order of actors who've had at least 15
  # starring roles.
  execute(<<-SQL)
    SELECT
      actor_name
    FROM (
      SELECT
        actors.name AS actor_name,
        COUNT(*) AS lead_count
      FROM
        actors
        JOIN castings
          ON actors.id = castings.actor_id
      WHERE
        castings.ord = 1
      GROUP BY
        actors.name
    ) AS leading_role_count
    WHERE
      lead_count >= 15
    ORDER BY
      actor_name
  SQL
end

def films_by_cast_size
  # List the films released in the year 1978 ordered by the number of actors
  # in the cast (descending), then by title (ascending).
  execute(<<-SQL)
  SELECT
    film_title,
    actor_count
  FROM (
    SELECT
      movies.title AS film_title,
      COUNT(*) AS actor_count
    FROM
      movies
      JOIN castings
        ON movies.id = castings.movie_id
      JOIN actors
        ON actors.id = castings.actor_id
    WHERE
      movies.yr = 1978
    GROUP BY
      movies.id
  ) AS actor_count_1978
  ORDER BY
    actor_count DESC,
    film_title
  SQL
end

def colleagues_of_garfunkel
  # List all the people who have played alongside 'Art Garfunkel'.
  execute(<<-SQL)
  SELECT
    name
  FROM
    actors
    JOIN castings
      ON actors.id = castings.actor_id
  WHERE
    castings.movie_id IN (
      SELECT
        movie_id
      FROM
        castings
        JOIN actors
          ON actors.id = castings.actor_id
      WHERE
          actors.name LIKE 'Art Garfunkel') AND
    name != 'Art Garfunkel'

  SQL
end

# == Schema Information
#
# Table name: albums
#
#  asin        :string       not null, primary key
#  title       :string
#  artist      :string
#  price       :float
#  rdate       :date
#  label       :string
#  rank        :integer
#
# Table name: styles
#
# album        :string       not null
# style        :string       not null
#
# Table name: tracks
# album        :string       not null
# disk         :integer      not null
# posn         :integer      not null
# song         :string

require_relative './sqlzoo.rb'

def alison_artist
  # Select the name of the artist who recorded the song 'Alison'.
  execute(<<-SQL)
  SELECT artist
    FROM albums
      JOIN tracks
        ON tracks.album = albums.asin
  WHERE
    tracks.song LIKE 'Alison'
  SQL
end

def exodus_artist
  # Select the name of the artist who recorded the song 'Exodus'.
  execute(<<-SQL)
  SELECT artist
    FROM albums
      JOIN tracks
        ON tracks.album = albums.asin
  WHERE
    tracks.song LIKE 'Exodus'
  SQL
end

def blur_songs
  # Select the `song` for each `track` on the album `Blur`.
  execute(<<-SQL)
  SELECT tracks.song
    FROM albums
      JOIN tracks
        ON tracks.album = albums.asin
  WHERE
    albums.title = 'Blur'
    SQL
end

def heart_tracks
  # For each album show the title and the total number of tracks containing
  # the word 'Heart' (albums with no such tracks need not be shown). Order first by
  # the number of such tracks, then by album title.
  execute(<<-SQL)
  SELECT
    albums.title, COUNT(tracks.*) AS track_count
    FROM albums
      JOIN tracks
        ON tracks.album = albums.asin
  WHERE
    tracks.song LIKE '%Heart%'
  GROUP BY
    albums.title
  ORDER BY
    track_count DESC, albums.title
  SQL
end

def title_tracks
  # A 'title track' has a `song` that is the same as its album's `title`. Select
  # the names of all the title tracks.
  execute(<<-SQL)
  SELECT
    tracks.song
  FROM albums
    JOIN tracks
      ON tracks.album = albums.asin
  WHERE
    tracks.song = albums.title
  SQL
end

def eponymous_albums
  # An 'eponymous album' has a `title` that is the same as its recording
  # artist's name. Select the titles of all the eponymous albums.
  execute(<<-SQL)
  SELECT
    title
  FROM albums
  WHERE
    title = artist
  SQL
end

def song_title_counts
  # Select the song names that appear on more than two albums. Also select the
  # COUNT of times they show up.
  execute(<<-SQL)
  SELECT tracks.song, COUNT(DISTINCT albums.asin)
  FROM albums
    JOIN tracks
      ON tracks.album = albums.asin
  GROUP BY
    tracks.song
  HAVING
    COUNT(DISTINCT albums.asin) > 2
  SQL
end

def best_value
  # A "good value" album is one where the price per track is less than 50
  # pence. Find the good value albums - show the title, the price and the number
  # of tracks.
  execute(<<-SQL)
    SELECT
      al.title, al.price, COUNT(tr.*)
    FROM
      albums AS al
      JOIN tracks AS tr
        ON tr.album = al.asin
    GROUP BY
      al.asin
    HAVING
      al.price / COUNT(tr.*) < 0.50
  SQL
end

def top_track_counts
  # Wagner's Ring cycle has an imposing 173 tracks, Bing Crosby clocks up 101
  # tracks. List the top 10 albums. Select both the album title and the track
  # count, and order by both track count and title (descending).
  execute(<<-SQL)
    SELECT
      al.title, COUNT(tr.*)
    FROM
      albums AS al
      JOIN tracks AS tr
        ON al.asin = tr.album
    GROUP BY
      al.asin
    ORDER BY
      COUNT(tr.*) DESC, al.title DESC
    LIMIT 10
  SQL
end

def rock_superstars
  # Select the artist who has recorded the most rock albums, as well as the
  # number of albums. HINT: use LIKE '%Rock%' in your query.
  execute(<<-SQL)
    SELECT
      al.artist, COUNT(DISTINCT al.title)
    FROM
      albums AS al
      JOIN styles as sty
      ON sty.album = al.asin
    WHERE
      sty.style LIKE '%Rock%'
    GROUP BY
      al.artist
    ORDER BY
      COUNT(DISTINCT al.title) DESC
    LIMIT 1
  SQL
end

def expensive_tastes
  # Select the five styles of music with the highest average price per track,
  # along with the price per track. One or more of each aggregate functions,
  # subqueries, and joins will be required.
  #
  # HINT: Start by getting the number of tracks per album. You can do this in a
  # subquery. Next, JOIN the styles table to this result and use aggregates to
  # determine the average price per track.
  execute(<<-SQL)
    SELECT *
    FROM (
      SELECT
        sty.style, SUM(trCount.album_price) / SUM(trCount.track_count) AS per_track_price
      FROM
        styles AS sty
        JOIN (
          SELECT
            al.asin AS album_id, al.price AS album_price, COUNT(tr.*) AS track_count
          FROM
            albums AS al
            JOIN tracks as tr
              ON al.asin = tr.album
          GROUP BY
            al.asin
        ) AS trCount
          ON trCount.album_id = sty.album
      GROUP BY
        sty.style
      ORDER BY
        SUM(trCount.album_price) / SUM(trCount.track_count) DESC
      ) AS track_prices
    WHERE
      track_prices.per_track_price IS NOT NULL
    LIMIT 5
  SQL
end

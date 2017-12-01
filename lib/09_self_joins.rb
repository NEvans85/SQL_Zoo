# == Schema Information
#
# Table name: stops
#
#  id          :integer      not null, primary key
#  name        :string
#
# Table name: routes
#
#  num         :string       not null, primary key
#  company     :string       not null, primary key
#  pos         :integer      not null, primary key
#  stop_id     :integer

require_relative './sqlzoo.rb'

def num_stops
  # How many stops are in the database?
  execute(<<-SQL)
    SELECT
      COUNT(*)
    FROM
      stops
  SQL
end

def craiglockhart_id
  # Find the id value for the stop 'Craiglockhart'.
  execute(<<-SQL)
  SELECT
    id
  FROM
    stops
  WHERE
    name LIKE 'Craiglockhart'
  SQL
end

def lrt_stops
  # Give the id and the name for the stops on the '4' 'LRT' service.
  execute(<<-SQL)
    SELECT
      id,
      name
    FROM
      stops
      JOIN routes
      ON stops.id = routes.stop_id
    WHERE
      routes.num LIKE '4' AND
      routes.company LIKE 'LRT'
  SQL
end

def connecting_routes
  # Consider the following query:
  #
  # SELECT
  #   company,
  #   num,
  #   COUNT(*)
  # FROM
  #   routes
  # WHERE
  #   stop_id = 149 OR stop_id = 53
  # GROUP BY
  #   company, num
  #
  # The query gives the number of routes that visit either London Road
  # (149) or Craiglockhart (53). Run the query and notice the two services
  # that link these stops have a count of 2. Add a HAVING clause to restrict
  # the output to these two routes.
  execute(<<-SQL)
    SELECT
      company,
      num,
      COUNT(*)
    FROM
      routes
    WHERE
      stop_id = 149 OR stop_id = 53
    GROUP BY
      company, num
    HAVING
      COUNT(*) > 1
  SQL
end

def cl_to_lr
  # Consider the query:
  #

  #
  # Observe that b.stop_id gives all the places you can get to from
  # Craiglockhart, without changing routes. Change the query so that it
  # shows the services from Craiglockhart to London Road.
  execute(<<-SQL)
  SELECT
    a.company,
    a.num,
    a.stop_id,
    b.stop_id
  FROM
    routes a
  JOIN
    routes b ON (a.company = b.company AND a.num = b.num)
  WHERE
    a.stop_id = 53 AND
    b.stop_id IN (
      SELECT
        id
      FROM
        stops
      WHERE
        name LIKE 'London Road'
    )
  SQL
end

def cl_to_lr_by_name
  # Consider the query:
  #

  #
  # The query shown is similar to the previous one, however by joining two
  # copies of the stops table we can refer to stops by name rather than by
  # number. Change the query so that the services between 'Craiglockhart' and
  # 'London Road' are shown.
  execute(<<-SQL)
  SELECT
    a.company,
    a.num,
    stopa.name,
    stopb.name
  FROM
    routes a
  JOIN
    routes b ON (a.company = b.company AND a.num = b.num)
  JOIN
    stops stopa ON (a.stop_id = stopa.id)
  JOIN
    stops stopb ON (b.stop_id = stopb.id)
  WHERE
    stopa.name = 'Craiglockhart' AND
    stopb.name = 'London Road'
  SQL
end

def haymarket_and_leith
  # Give the company and num of the services that connect stops
  # 115 and 137 ('Haymarket' and 'Leith')
  execute(<<-SQL)
  SELECT
    DISTINCT a.company,
    a.num
  FROM
    routes a
  JOIN
    routes b ON (a.company = b.company AND a.num = b.num)
  WHERE
    a.stop_id = 115 AND
    b.stop_id = 137
  SQL
end

def craiglockhart_and_tollcross
  # Give the company and num of the services that connect stops
  # 'Craiglockhart' and 'Tollcross'
  execute(<<-SQL)
  SELECT
    a.company,
    a.num
  FROM
    routes a
  JOIN
    routes b ON (a.company = b.company AND a.num = b.num)
  JOIN
    stops stopa ON (a.stop_id = stopa.id)
  JOIN
    stops stopb ON (b.stop_id = stopb.id)
  WHERE
    stopa.name = 'Craiglockhart' AND
    stopb.name = 'Tollcross'
  SQL
end

def start_at_craiglockhart
  # Give a distinct list of the stops that can be reached from 'Craiglockhart'
  # by taking one bus, including 'Craiglockhart' itself. Include the stop name,
  # as well as the company and bus no. of the relevant service.
  execute(<<-SQL)
    SELECT
      stopb.name,
      a.company,
      a.num
    FROM
      routes a
    JOIN
      routes b ON (a.company = b.company AND a.num = b.num)
    JOIN
      stops stopa ON (a.stop_id = stopa.id)
    JOIN
      stops stopb ON (b.stop_id = stopb.id)
    WHERE
      stopa.name LIKE 'Craiglockhart'
  SQL
end

def craiglockhart_to_sighthill
  # Find the routes involving two buses that can go from Craiglockhart to
  # Sighthill. Show the bus no. and company for the first bus, the name of the
  # stop for the transfer, and the bus no. and company for the second bus.
  execute(<<-SQL)
  SELECT
  *
    -- a.company AS a_co,
    -- a.num AS a_num,
    -- stopa.name AS a_stop,
    -- stopb.name AS b_stop,
    -- stopc.name AS c_stop
    -- c.company AS c_co,
    -- c.num AS c_num
    FROM stops AS start_stop
      JOIN routes AS start_routes
        ON start_routes.stop_id = start_stop.id
      JOIN routes AS trans_routes
        ON start_routes.num = trans_routes.num AND
           start_routes.company = trans_routes.company
      JOIN stops AS trans_stops
        ON trans_stops.id = trans_routes.stop_id
      JOIN routes AS t_to_end_routes
        ON t_to_end_routes.stop_id = trans_stops.id
      JOIN routes AS end_routes
        ON t_to_end_routes.num = end_routes.num AND
           t_to_end_routes.company = end_routes.company
      JOIN stops AS end_stops
        ON end_stops.id = end_routes.stop_id
      WHERE
        start_stop.name = 'Craiglockhart' AND
        end_stops.name = 'Sighthill'
  -- FROM
  --   routes AS a
  -- JOIN
  --   routes AS b ON (a.company = b.company AND a.num = b.num)
  -- JOIN
  --   routes AS c ON (b.company = c.company AND b.num = c.num)
  -- JOIN
  --   stops AS stopa ON (a.stop_id = stopa.id)
  -- JOIN
  --   stops AS stopb ON (b.stop_id = stopb.id)
  -- JOIN
  --   stops AS stopc ON (c.stop_id = stopc.id)
  -- WHERE
  --   stopa.name LIKE 'Craiglockhart'
  --   stopc.name LIKE 'Sighthill'
  SQL
end
